import 'package:flutter/material.dart';
import 'package:bcp_app/components/my_bottomnavbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  final String? userName;

  const HomePage({super.key, required this.userName});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void navigateBottomBar(int index) {
    // navigate to the bottom bar
    setState(() {
      _selectedIndex = index;
    });
  }

  void signUserOut() {
    // sign user out
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          toolbarHeight: 120,
          actions: [
            IconButton(
              onPressed: signUserOut,
              icon: const Icon(Icons.logout),
            )
          ],
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome Back,",
                style: TextStyle(
                  fontSize: 26,
                  color: Color.fromRGBO(191, 0, 7, 1),
                ),
              ),
              Text(
                widget.userName ?? "User",
                style: const TextStyle(
                  fontSize: 26,
                  color: Color.fromRGBO(191, 0, 7, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: const Center(
        child: Text('LOGGED IN!'),
      ),
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
    );
  }
}
