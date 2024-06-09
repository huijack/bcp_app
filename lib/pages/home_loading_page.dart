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

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _userName == null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = (userDoc.data() as Map<String, dynamic>)['FullName'];
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _userName != null
        ? HomePage(userName: _userName)
        : Center(child: CircularProgressIndicator());
  }
}