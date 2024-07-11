import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_loading_page.dart';
import 'login_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    print('AuthPage build called'); // Debug print
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print(
              'StreamBuilder update: ${snapshot.connectionState}'); // Debug print
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            print('User is signed in, returning HomePageLoader'); // Debug print
            return HomePageLoader();
          } else {
            print('No user signed in, returning LoginPage'); // Debug print
            return LoginPage();
          }
        },
      ),
    );
  }
}
