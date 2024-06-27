import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class HomePageLoader extends StatefulWidget {
  @override
  _HomePageLoaderState createState() => _HomePageLoaderState();
}

class _HomePageLoaderState extends State<HomePageLoader> {
  String? _userName;
  String? _email;
  bool _loading = true; // Add a loading state

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              _userName = (userDoc.data() as Map<String, dynamic>)['FullName'];
              _email = (userDoc.data() as Map<String, dynamic>)['Email'];
              _loading = false; // Update loading state
            });
          }
        } else {
          // Handle case where document doesn't exist
          if (mounted) {
            setState(() {
              _loading = false; // Update loading state
              _userName = 'Unknown';
              _email = 'Unknown';
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
        if (mounted) {
          setState(() {
            _loading = false; // Update loading state
            _userName = 'Error';
            _email = 'Error';
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _loading = false; // Update loading state
        });
      }
    }
  }

  @override
  void dispose() {
    // You can cancel any subscriptions or timers here if necessary.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : HomePage(
                userName: _userName,
                email: _email,
              ),
      ),
    );
  }
}
