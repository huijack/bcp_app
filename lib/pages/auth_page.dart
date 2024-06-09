import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            return HomePageLoader();  // Use the loader
          } else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
