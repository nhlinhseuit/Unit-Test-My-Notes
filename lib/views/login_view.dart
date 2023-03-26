
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';

import '../uitilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your email'
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'Enter your password'
            ),
          ),
          TextButton(onPressed: () async {
            final emailText = _email.text;
            final passwordText = _password.text;
            
            try {
              await  FirebaseAuth.instance.signInWithEmailAndPassword(
                email: emailText, 
                password: passwordText
              );
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final emailVerified = user.emailVerified;
                if (emailVerified) {              
                  Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                } else {              
                  Navigator.of(context).pushNamedAndRemoveUntil(verifyRoute, (route) => false);
                }
              }         
            }
            on FirebaseAuthException catch(e) {
              if (e.code == 'user-not-found') {
                await showErrorDialog(context, 'Babe, who even are you?');
              } else if (e.code == 'wrong-password') {
                await showErrorDialog(context, 'Babe, wrong password.');
              } else {
                await showErrorDialog(context, 'Error: ${e.code}');
              }
            } 
            catch (e) {
              await showErrorDialog(context, 'Error: ${e.toString()}');
            }
          }, child: const Text('Log in'),),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute, 
                (route) => false
              );
            }, 
            child: const Text('New to this app? Register here!')
          )
        ],
      ),
    );
  }
}