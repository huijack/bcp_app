import 'package:bcp_app/pages/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:bcp_app/components/my_bottomnavbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'history_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final String? userName;
  final String? email;

  const HomePage({
    super.key,
    required this.userName,
    required this.email,
  });

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

  // pages to display
  final List<Widget> _pages = [
    // Menu Page
    const MenuPage(),

    // History Page
    const HistoryPage(),

    // Profile Page
    const ProfilePage(),
  ];

  void signUserOut() {
    // sign user out
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // shadow direction: bottom right
              ),
            ],
          ),
          child: AppBar(
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(255, 154, 157, 50),
            leading: Builder(builder: (context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu),
              );
            }),
            title: const Text(
              'UCSI Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromRGBO(255, 154, 157, 60),
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(191, 0, 7, 20),
              ),
              accountName: Text(
                widget.userName ?? 'User',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                widget.email ?? '',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.home,
                color: Colors.white,
              ),
              title: const Text(
                'Home',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              onTap: () {
                setState(() {
                  _selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.feedback,
                color: Colors.white,
              ),
              title: const Text(
                'Submit Feedback',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              onTap: () {
                // Navigate to feedback page or function
              },
            ),
            const Spacer(), // Takes up all remaining space
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: const Text(
                'Logout',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              onTap: () {
                signUserOut();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
    );
  }
}
