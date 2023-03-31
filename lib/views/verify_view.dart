import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VeriydEmailViewState();
}

class _VeriydEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    // final auth = AuthService.firebase().instance();
    final auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((user) {
    final user = AuthService.firebase().currentUser;
      if (user != null) {
        if (user.isEmailVerified) {
              Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false);
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify email'),
      ),
      body: Column(
        children: [
          const Text("We've sent you an email verification."),
          const Text("If you haven't receive your verification, please tap on the button below:"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            }, 
            child: const Text('Send email verification.')
          ),
          TextButton(
            onPressed: () => {
              Navigator.of(context).pushNamedAndRemoveUntil(notesRoute, (route) => false)
            }, 
            child: const Text('Later'),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            }, 
            child: const Text('Sign out'),
          )
      ]),
    );
  }
}
