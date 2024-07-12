import 'package:bcp_app/components/my_button.dart';
import 'package:bcp_app/components/my_textfield.dart';
import 'package:bcp_app/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool isLoading = false;

  Future<void> handlePasswordReset() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text);

      // Show success message
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Password Reset Email Sent'),
              content: const Text(
                  'Please check your inbox from the email address and follow the instructions to reset your password.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const AuthPage(),
                      ),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 50),
              const Icon(
                Icons.lock,
                size: 150,
                color: Color.fromRGBO(191, 0, 6, 0.815),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Reset your password here',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(191, 0, 6, 0.815),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'Enter your email address below to receive a password reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 30),
              MyTextField(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
                prefixIcon: Icons.mail,
                allowNewLines: false,
              ),
              const SizedBox(height: 35),
              if (isLoading)
                Container(
                  padding: const EdgeInsets.all(25),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(191, 0, 7, 100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                )
              else
                MyButton(
                  onTap: handlePasswordReset,
                  buttonText: 'Send Password Reset Email',
                )
            ],
          ),
        ),
      ),
    );
  }
}
