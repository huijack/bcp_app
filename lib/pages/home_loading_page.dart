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
    if (user != null) {
      try {
        // Check if the user is admin
        if (user.email == 'admin@gmail.com') {
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
          return; // Exit early, we don't need to fetch user data for admin
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          if (mounted) {
            setState(() {
              _userName = (userDoc.data() as Map)['FullName'];
              _email = (userDoc.data() as Map)['Email'];
              _loading = false;
            });
          }
        } else {
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
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if the user is admin
    if (user != null && user.email == 'admin@gmail.com') {
      return const AdminHomePage();
    }

    return HomePage(
      userName: _userName,
      email: _email,
    );
  }
}
