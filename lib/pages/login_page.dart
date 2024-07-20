import 'package:bcp_app/components/my_button.dart';
import 'package:bcp_app/components/my_textfield.dart';
import 'package:bcp_app/pages/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controller
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmailPassword();
  }

  void _loadUserEmailPassword() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var email = prefs.getString("email") ?? "";
      var password = prefs.getString("password") ?? "";
      var rememberMeValue = prefs.getBool("remember_me") ?? false;

      if (rememberMeValue) {
        if (mounted) {
          setState(() {
            rememberMe = true;
            emailController.text = email;
            passwordController.text = password;
          });
        }
      }
    } catch (e) {
      print("Error loading email and password: $e");
    }
  }

  // sign in function
  void signUserIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (rememberMe) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("email", emailController.text);
        await prefs.setString("password", passwordController.text);
        await prefs.setBool("remember_me", rememberMe);
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove("email");
        await prefs.remove("password");
        await prefs.remove("remember_me");
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const AuthPage(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      String errorMessage;
      switch (e.code) {
        default:
          errorMessage = 'Email or password is incorrect. Please try again.';
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Login Error'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Login Error'),
              content:
                  const Text('An unexpected error occurred. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // forgot password
  void forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> showExitAppConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Exit App'),
          content: const Text('Are you sure you want to exit the app?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await showExitAppConfirmation();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  const Icon(Icons.report, size: 150),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome to UCSI Report!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(191, 0, 6, 0.815),
                    ),
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
                  MyTextField(
                    controller: emailController,
                    prefixIcon: Icons.mail,
                    hintText: 'Email',
                    obscureText: false,
                    allowNewLines: false,
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: passwordController,
                    prefixIcon: Icons.password,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 40,
                                child: Checkbox(
                                  value: rememberMe,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      rememberMe = value!;
                                    });
                                  },
                                  activeColor: Colors.red[900],
                                ),
                              ),
                              Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: forgotPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.red[900]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  MyButton(
                    buttonText: 'Login',
                    isLoading: isLoading,
                    onTap: signUserIn,
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('New user?',
                          style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: Text(
                          'Register an account',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
