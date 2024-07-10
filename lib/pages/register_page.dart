import 'package:bcp_app/components/my_button.dart';
import 'package:bcp_app/components/my_textfield.dart';
import 'package:bcp_app/pages/auth_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controller
  final fullnameController = TextEditingController();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmpasswordController = TextEditingController();

  // register function
  void registerUser() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try creating the user
    try {
      // check if the passwords match
      if (passwordController.text != confirmpasswordController.text) {
        Navigator.pop(context);

        // show error message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Registration Error'),
              content:
                  const Text('Your passwords do not match. Please try again'),
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

        return;
      }

      // create the user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // get the user ID
      String uid = userCredential.user!.uid;

      // add the user to Firestore
      await FirebaseFirestore.instance.collection('User').doc(uid).set({
        'FullName': fullnameController.text,
        'Email': emailController.text,
        'Phone': '',
        'Address': '',
        'Postcode': '',
        'City': '',
        'State': '',
        'uId': uid,
        'isAdmin': false,
      });

      // hide loading circle
      Navigator.pop(context);

      // navigate the user to the home page
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
        (route) => false,
      );

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text('Your account has been created successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the success dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      Navigator.pop(context);

      // show error message
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Registration Error'),
            content: const Text(
                'An error occurred while registering your account. Please try again'),
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
                          const SizedBox(height: 20),
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
                            buttonText: 'Sign Up',
                            onTap: registerUser,
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
                                        TextSpan(text: '.'),
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
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  color: Colors.blue,
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
