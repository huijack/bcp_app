import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin/admin_home_page.dart';
import 'client/home_page.dart';
import 'technician/technician_home_page.dart';

class HomePageLoader extends StatefulWidget {
  @override
  _HomePageLoaderState createState() => _HomePageLoaderState();
}

class _HomePageLoaderState extends State<HomePageLoader> {
  String? _userName;
  String? _email;
  bool _loading = true;
  bool _isTechnician = false;

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
          if (mounted) {
            setState(() {
              _loading = false;
            });
          }
          return;
        }

        // Check if the user is a technician
        DocumentSnapshot technicianDoc = await FirebaseFirestore.instance
            .collection('MaintenanceStaff')
            .doc(user.uid)
            .get();

        if (technicianDoc.exists) {
          final technicianData = technicianDoc.data() as Map<String, dynamic>?;
          if (mounted) {
            setState(() {
              _userName = technicianData?['Name'] as String?;
              _email = technicianData?['Email'] as String?;
              _loading = false;
              _isTechnician = true;
            });
          }
          return;
        }

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>?;
          if (mounted) {
            setState(() {
              _userName = userData?['FullName'] as String?;
              _email = userData?['Email'] as String?;
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

    // Check if the user is a technician
    if (_isTechnician) {
      return MyTechnicianHomePage(
        userName: _userName,
        email: _email,
      );
    }

    print('Navigating to HomePage'); // Debug print
    return HomePage(
      userName: _userName,
      email: _email,
    );
  }
}
