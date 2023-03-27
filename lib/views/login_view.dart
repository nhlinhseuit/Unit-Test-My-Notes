import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';

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
              await AuthService.firebase().login(
                email: emailText, 
                password: passwordText
              );
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                final emailVerified = user.isEmailVerified;
                if (emailVerified) {              
                  Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
                } else {              
                  Navigator.of(context).pushNamedAndRemoveUntil(verifyRoute, (route) => false);
                }
              }         
            } on UserNotFoundAuthException {
              await showErrorDialog(context, 'Babe, who even are you?');
            } on WrongPasswordAuthException {
              await showErrorDialog(context, 'Babe, wrong password.');
            } on GenericAuthException {
              await showErrorDialog(context, 'Authentication Error.');
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