import 'package:bcp_app/components/my_button.dart';
import 'package:bcp_app/components/my_textfield.dart';
import 'package:bcp_app/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controller
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // sign in function
  void signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // hide loading circle
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException {
      // hide loading circle
      Navigator.pop(context);

      // show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Error'),
            content: const Text('Your email or password is incorrect. Please try again'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              )
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // logo
                const Icon(
                  Icons.report,
                  size: 150,
                ),

                const SizedBox(height: 20),

                // welcome text
                const Text(
                  'Welcome to UCSI Report!',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(191, 0, 7, 100)),
                ),

                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Text(
                    'A mobile app to submit, track, and manage equipment maintenance requests on campus',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // username input
                MyTextField(
                  controller: emailController,
                  prefixIcon: Icons.mail,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 25),

                // password input
                MyTextField(
                  controller: passwordController,
                  prefixIcon: Icons.password,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 35),

                // login button
                MyButton(
                  buttonText: 'Sign In',
                  onTap: signUserIn,
                ),

                const SizedBox(height: 15),
                // new user? register an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New user?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        // navigate to register page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        'Register an account',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
