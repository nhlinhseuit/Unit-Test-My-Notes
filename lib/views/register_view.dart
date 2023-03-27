import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_service.dart';
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
              await AuthService.firebase().createUser(
                email: emailText, 
                password: passwordText
              );
              final user = AuthService.firebase().currentUser;
              user?.isEmailVerified;
              AuthService.firebase().sendEmailVerification();
              Navigator.of(context).pushNamed(verifyRoute);
            } on WeakPasswordAuthException {
              await showErrorDialog(context, 'Babe, your password is not strong enough.');
            } on EmailAlreadyInUseAuthException {
              await showErrorDialog(context, 'Babe, your email is already in use.');
            } on InvaliEmailAuthException {
              await showErrorDialog(context, 'Babe, your email is invalid.');
            } on GenericAuthException {
              await showErrorDialog(context, 'Authentication erroe.');
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
