import 'dart:math';
import 'package:bcp_app/components/my_button.dart';
import 'package:bcp_app/components/my_textfield.dart';
import 'package:bcp_app/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

import 'otp_verify_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controllers
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  bool isLoading = false;
  String? generatedOTP;

  String generateOTP() {
    var random = Random();
    int otp = random.nextInt(9000) + 1000;
    return otp.toString();
  }

  Future<void> sendEmail(String email, String otp) async {
    final smtpServer = gmail(dotenv.env['EMAIL_USERNAME']!, dotenv.env['EMAIL_PASSWORD']!);
    final message = Message()
      ..from = Address(dotenv.env['EMAIL_USERNAME']!, 'UCSI Report')
      ..recipients.add(email)
      ..subject = 'UCSI Report OTP Verification'
      ..text = 'Your OTP code is $otp. Please do not share this code with anyone.';

    try {
      await send(message, smtpServer);
    } on MailerException catch (e) {
      debugPrint('Message not sent. $e');
    }
  }

  Future<String> resendOTP(String oldOTP) async {
    String newOTP = generateOTP();
    await sendEmail(emailController.text, newOTP);
    return newOTP;
  }

  Future<void> handleSignUp() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmpasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (passwordController.text != confirmpasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      generatedOTP = generateOTP();

      await sendEmail(emailController.text, generatedOTP!);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerifyPage(
            initialOTP: generatedOTP!,
            resendOTP: resendOTP,
            email: emailController.text,
            fullName: fullnameController.text,
            password: passwordController.text,
          ),
        ),
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
    fullnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Set up your account',
                            style: TextStyle(
                              color: Color.fromRGBO(191, 0, 6, 0.815),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Create your account. It\'s free!',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 30),
                          // fullname input
                          MyTextField(
                            controller: fullnameController,
                            hintText: 'Full Name',
                            obscureText: false,
                            prefixIcon: Icons.person,
                            allowNewLines: false,
                          ),
                          const SizedBox(height: 25),
                          // email input
                          MyTextField(
                            controller: emailController,
                            hintText: 'Email',
                            obscureText: false,
                            prefixIcon: Icons.mail,
                            allowNewLines: false,
                          ),
                          const SizedBox(height: 25),
                          // password input
                          MyTextField(
                            controller: passwordController,
                            hintText: 'Password',
                            obscureText: true,
                            prefixIcon: Icons.lock,
                          ),
                          const SizedBox(height: 25),
                          // confirm password input
                          MyTextField(
                            controller: confirmpasswordController,
                            hintText: 'Confirm Password',
                            obscureText: true,
                            prefixIcon: Icons.lock,
                          ),
                          const SizedBox(height: 35),
                          // register button
                          MyButton(
                            onTap: handleSignUp,
                            buttonText: 'Sign Up',
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              'By signing up, you agree to our ',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Terms and Conditions',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' and ',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        const TextSpan(text: '.'),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Spacer(), // This will push the "Already have an account?" section to the bottom
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AuthPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
