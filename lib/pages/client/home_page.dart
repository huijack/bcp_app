import 'package:bcp_app/pages/client/menu_page.dart';
import 'package:flutter/material.dart';
import 'package:bcp_app/components/my_bottomnavbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'faq_page.dart';
import 'profile_page.dart';
import 'submit_feedback_page.dart';

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
  bool _isLoggingOut = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }


  Future<void> showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                await performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> performLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Handle any errors here
      print('Error logging out: $e');
    } finally {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 0) {
          await showLogoutConfirmation();
          return false;
        }
        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
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
                      _pageController.jumpToPage(0);
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
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubmitFeedbackPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.question_answer,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'FAQs',
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FaqPage(),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
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
                      Navigator.pop(context);
                      showLogoutConfirmation();
                    },
                  ),
                ],
              ),
            ),
            body: GestureDetector(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: const [
                  MenuPage(),
                  ProfilePage(),
                ],
              ),
            ),
            bottomNavigationBar: MyBottomNavBar(
              selectedIndex: _selectedIndex,
              onTabChange: (index) => navigateBottomBar(index),
            ),
          ),
          if (_isLoggingOut)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}