import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bcp_app/components/my_adminnavbar.dart';
import 'package:bcp_app/pages/admin/admin_history_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../components/my_card.dart';
import 'blockA_page.dart';
import 'blockB_page.dart';
import 'blockC_page.dart';
import 'blockE_page.dart';
import 'blockG_page.dart';

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
  var height, width;

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

  void _blockA(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockAPage();
        },
      ),
    );
  }

  void _blockB(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return BlockBPage();
        },
      ),
    );
  }

  void _blockC(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockCPage();
        },
      ),
    );
  }

  void _blockE(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockEPage();
        },
      ),
    );
  }

  void _blockG(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockGPage();
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2));

    setState(() {});
  }

  Stream<Map<String, int>> getPendingRequestCounts() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value({});
    }

    final userId = user.uid;

    return FirebaseFirestore.instance
        .collection('Admin')
        .doc(userId)
        .get()
        .asStream()
        .asyncExpand((adminDoc) {
      if (adminDoc.exists) {
        return FirebaseFirestore.instance
            .collection('Request')
            .where('Status', isEqualTo: 'Pending')
            .snapshots()
            .map((snapshot) {
          Map<String, int> counts = {
            'Block A': 0,
            'Block B': 0,
            'Block C': 0,
            'Block E': 0,
            'Block G': 0,
          };
          for (var doc in snapshot.docs) {
            String building = doc['Building'];
            counts[building] = (counts[building] ?? 0) + 1;
          }
          return counts;
        });
      } else {
        return Stream.value({});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    bool isKeyBoardOpen = MediaQuery.of(context).viewInsets.bottom != 0.0;

    return WillPopScope(
      onWillPop: () async {
        await showLogoutConfirmation();
        return false;
      },
      child: Scaffold(
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
          body: RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.red[900],
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 154, 157, 50),
                ),
                child: Column(
                  children: [
                    Container(
                      height: height * 0.25,
                      width: width,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 50,
                              left: 15,
                              right: 15,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Builder(builder: (context) {
                                  return InkWell(
                                    onTap: () {
                                      Scaffold.of(context).openDrawer();
                                    },
                                    child: const Icon(
                                      Icons.sort,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  );
                                }),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AdminHistoryPage(),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.history,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 30,
                              right: 30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, ',
                                      style: TextStyle(
                                        color: Colors.red[900],
                                        fontSize: 26,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Admin',
                                      style: TextStyle(
                                        color: Colors.red[900],
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      height: height * 0.75,
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            StreamBuilder<Map<String, int>>(
                              stream: getPendingRequestCounts(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final counts = snapshot.data ?? {};
                                return GridView.count(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  children: [
                                    MyCard(
                                      icon: FontAwesomeIcons.a,
                                      text: 'Block A',
                                      onTap: () => _blockA(context),
                                      requestCount: counts['Block A'] ?? 0,
                                    ),
                                    MyCard(
                                      icon: FontAwesomeIcons.b,
                                      text: 'Block B',
                                      onTap: () => _blockB(context),
                                      requestCount: counts['Block B'] ?? 0,
                                    ),
                                    MyCard(
                                      icon: FontAwesomeIcons.c,
                                      text: 'Block C',
                                      onTap: () => _blockC(context),
                                      requestCount: counts['Block C'] ?? 0,
                                    ),
                                    MyCard(
                                      icon: FontAwesomeIcons.e,
                                      text: 'Block E',
                                      onTap: () => _blockE(context),
                                      requestCount: counts['Block E'] ?? 0,
                                    ),
                                    MyCard(
                                      icon: FontAwesomeIcons.g,
                                      text: 'Block G',
                                      onTap: () => _blockG(context),
                                      requestCount: counts['Block G'] ?? 0,
                                    ),
                                    MyCard(
                                      icon: FontAwesomeIcons.question,
                                      text: 'More Info',
                                      onTap: () {},
                                      requestCount: 0,
                                    )
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
