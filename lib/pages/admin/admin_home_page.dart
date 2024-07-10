import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bcp_app/components/my_adminnavbar.dart';
import 'package:bcp_app/pages/admin/admin_history_page.dart';
import 'package:bcp_app/pages/admin/admin_menu_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({
    super.key,
  });

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  bool _isLoggingOut = false;
  late PageController _pageController;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email;
    });

    print('User email: $userEmail');
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
        await showLogoutConfirmation();
        return false;
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
                      offset:
                          const Offset(0, 3), // shadow direction: bottom right
                    ),
                  ],
                ),
                child: AppBar(
                  centerTitle: true,
                  backgroundColor: const Color.fromRGBO(255, 154, 157, 50),
                  title: const Text(
                    'UCSI Report Admin',
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
                    accountName: const Text(
                      'Admin',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    accountEmail: Text(
                      userEmail ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () {
                      showLogoutConfirmation();
                    },
                  )
                ],
              ),
            ),
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: const [
                AdminMenuPage(),
                AdminHistoryPage(),
              ],
            ),
            bottomNavigationBar: MyAdminNavBar(
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
