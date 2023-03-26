import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/uitilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> { 
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
        title: const Text('Resgister'),
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
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: emailText, 
                password: passwordText
              );
              final user = FirebaseAuth.instance.currentUser;
              user?.sendEmailVerification();
              Navigator.of(context).pushNamed(verifyRoute);
            } on FirebaseAuthException catch(e) {
              if (e.code == 'weak-password') {
                await showErrorDialog(context, 'Babe, your password is not strong enough.');
              } else if (e.code == 'email-already-in-use') {
                await showErrorDialog(context, 'Babe, your email is already in use.');
              } else if (e.code == 'invalid-email') {
                await showErrorDialog(context, 'Babe, your email is invalid.');
              } else {
                await showErrorDialog(context, 'Error: ${e.code}');
              }
            }
            catch (e) {
                await showErrorDialog(context, 'Error: ${e.toString()}');
            }
          }, child: const Text('Register'),),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            }, 
            child: const Text('Alreagy have an account? Login here!')
          )
        ],
      ),
    );
  }
}
