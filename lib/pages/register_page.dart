import 'package:bcp_app/components/my_button.dart';
import 'package:bcp_app/components/my_textfield.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({super.key});

  // text editing controller
  final fullnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

  // register function
  void registerUser() {
    final fullname = fullnameController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final confirmpassword = confirmpasswordController.text;

    if (fullname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmpassword.isEmpty) {
      // show error message
      return;
    }

    // register user
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
          child: Center(
            child: Column(
              children: [
                const Text(
                  'Set up your account',
                  style: TextStyle(
                    color: Color.fromRGBO(191, 0, 7, 100),
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
                ),
          
                const SizedBox(height: 25),
          
                // email input
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  prefixIcon: Icons.mail,
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'By signing up, you agree to our '),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(fontWeight: FontWeight.bold),
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
          ),
        ),
      ),
    );
  }
}
