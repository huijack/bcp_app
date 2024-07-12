import 'dart:async';
import 'package:bcp_app/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OTPVerifyPage extends StatefulWidget {
  final String initialOTP;
  final Function(String) resendOTP;
  final String email;
  final String fullName;
  final String password;

  const OTPVerifyPage({
    super.key,
    required this.initialOTP,
    required this.resendOTP,
    required this.email,
    required this.fullName,
    required this.password,
  });

  @override
  State<OTPVerifyPage> createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerifyPage> {
  String enteredOTP = '';
  String currentOTP = '';
  int _resendCooldown = 0;
  late Timer _resendTimer;
  late Timer _otpTimeoutTimer;
  bool _isOTPValid = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentOTP = widget.initialOTP;
    _resendTimer = Timer(Duration.zero, () {});
    startOTPTimeout();
  }

  void startOTPTimeout() {
    _otpTimeoutTimer = Timer(const Duration(minutes: 5), () {
      if (mounted) {
        setState(() {
          _isOTPValid = false;
        });
      }
    });
  }

  void startResendCooldown() {
    if (mounted) {
      setState(() {
        _resendCooldown = 60;
      });
    }
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCooldown > 0) {
            _resendCooldown--;
          } else {
            _resendTimer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> verifyOTP() async {
    if (!_isOTPValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('OTP has expired. Please request a new OTP instead.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    if (enteredOTP == currentOTP) {
      _otpTimeoutTimer.cancel();

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.email,
          password: widget.password,
        );

        String uid = userCredential.user!.uid;

        await FirebaseFirestore.instance
            .collection('User')
            .doc(userCredential.user!.uid)
            .set({
          'FullName': widget.fullName,
          'Email': widget.email,
          'Phone': '',
          'Address': '',
          'Postcode': '',
          'City': '',
          'State': '',
          'uId': uid,
          'isAdmin': false,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account Created'),
            content: const Text(
                'Your account has been created successfully. You will now be redirected to home page.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                      (route) => false);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handleResendOTP() async {
    if (_resendCooldown == 0) {
      String newOTP = await widget.resendOTP(currentOTP);
      setState(() {
        currentOTP = newOTP;
        _isOTPValid = true;
      });
      startResendCooldown();
      startOTPTimeout();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New OTP sent. Please check your email.')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Do you want to cancel the OTP verification?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void dispose() {
    _resendTimer.cancel();
    _otpTimeoutTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final result = await _onWillPop();
        if (result) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          scrolledUnderElevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _onWillPop().then(
              (value) => {
                if (value) {Navigator.of(context).pop()}
              },
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 30),
                const Icon(
                  Icons.password,
                  size: 100,
                  color: Color.fromRGBO(191, 0, 6, 0.815),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(191, 0, 6, 0.815),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter the 4-digit code sent to your email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                OtpTextField(
                  numberOfFields: 4,
                  borderWidth: 3.0,
                  borderColor: Colors.black,
                  focusedBorderColor: const Color.fromRGBO(191, 0, 6, 0.815),
                  showFieldAsBox: true,
                  onSubmit: (String verificationCode) {
                    // Capture the OTP entered by the user
                    setState(() {
                      enteredOTP = verificationCode;
                    });
                  }, // end onSubmit
                ),
                const SizedBox(height: 40),
                if (isLoading)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 75, vertical: 15),
                    margin: const EdgeInsets.symmetric(horizontal: 50),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(191, 0, 6, 0.815),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                if (!isLoading)
                  ElevatedButton(
                    onPressed: verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(191, 0, 6, 0.815),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 70, vertical: 15),
                    ),
                    child: const Text(
                      'Verify',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _resendCooldown == 0 ? handleResendOTP : null,
                  child: Text(
                    _resendCooldown == 0
                        ? 'Resend OTP'
                        : 'Resend OTP ($_resendCooldown)',
                    style: TextStyle(
                      color: _resendCooldown == 0
                          ? const Color.fromRGBO(191, 0, 6, 0.815)
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
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
