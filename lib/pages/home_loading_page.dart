import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin/admin_home_page.dart';
import 'client/home_page.dart';

class HomePageLoader extends StatefulWidget {
  @override
  _HomePageLoaderState createState() => _HomePageLoaderState();
}

class _HomePageLoaderState extends State<HomePageLoader> {
  String? _userName;
  String? _email;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.email}'); // Debug print

    if (user != null) {
      try {
        // Check if the user is admin
        if (user.email == 'admin@gmail.com') {
          print('Admin user detected'); // Debug print
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
          return;
        }

        print('Fetching user document for UID: ${user.uid}'); // Debug print
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        print('User document exists: ${userDoc.exists}'); // Debug print

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          print('User data: $userData'); // Debug print

          if (mounted) {
            setState(() {
              _userName = userData?['FullName'] as String?;
              _email = userData?['Email'] as String?;
              _loading = false;
            });
          }
          print('setState called with: $_userName, $_email'); // Debug print
        } else {
          print('User document does not exist'); // Debug print
          if (mounted) {
            setState(() {
              _loading = false;
              _userName = 'Unknown';
              _email = 'Unknown';
            });
          }
        }
      } catch (e) {
        print('Error fetching user data: $e');
        if (mounted) {
          setState(() {
            _loading = false;
            _userName = 'Error';
            _email = 'Error';
          });
        }
      }
    } else {
      print('No user is currently signed in'); // Debug print
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }

    print('_fetchUsername completed. Loading: $_loading'); // Debug print
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_loading) {
      print('Still loading...'); // Debug print
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if the user is admin
    if (user != null && user.email == 'admin@gmail.com') {
      print('Navigating to AdminHomePage'); // Debug print
      return const AdminHomePage();
    }

    print('Navigating to HomePage'); // Debug print
    return HomePage(
      userName: _userName,
      email: _email,
    );
  }
}
