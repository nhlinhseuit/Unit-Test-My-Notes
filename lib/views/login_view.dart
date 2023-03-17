
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../firebase_options.dart';

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
        title: const Text('Log in'),
        ),
      body: FutureBuilder (
        future: Firebase.initializeApp (
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) { 
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
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
                      final userCredential = await  FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailText, 
                        password: passwordText
                      );
                    }
                    on FirebaseAuthException catch(e) {
                      if (e.code == 'user-not-found') {
                        print('This email has not been registered.');
                      } else if (e.code == 'wrong-password') {
                        print('Babe, your password is wrong.');
                      } else {
                        print(e.code);
                      }
                    }
                  }, child: const Text('Log in'),),
                ],
              );
              default:
              return const Text('Loading...');
            }
          },
        ),
    );
  }
}
