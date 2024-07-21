import 'package:bcp_app/pages/admin/pending_requests_page.dart';
import 'package:bcp_app/pages/admin/fixed_requests_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcp_app/pages/admin/admin_history_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../components/my_card.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({
    super.key,
  });

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  bool _isLoggingOut = false;
  String? userEmail;
  var height, width;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email;
    });

    print('User email: $userEmail');
  }

  Stream<Map<String, int>> getTotalRequestCounts() {
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
            .snapshots()
            .map((snapshot) {
          int pendingCount = 0;
          int fixedCount = 0;
          for (var doc in snapshot.docs) {
            String status = doc['Status'];
            if (status == 'Pending') {
              pendingCount++;
            } else if (status == 'Fixed') {
              fixedCount++;
            }
          }
          return {
            'Pending': pendingCount,
            'Fixed': fixedCount,
          };
        });
      } else {
        print('Admin document not found');
        return Stream.value({});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  void _assignTechnician(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const PendingRequestsPage();
        },
      ),
    );
  }

  void _verifyRequests(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const FixedRequestPage();
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {});
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
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(255, 154, 157, 50),
                ),
                child: Column(
                  children: [
                    SizedBox(
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
                                            const AdminHistoryPage(),
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
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      // height: height * 0.75,
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            StreamBuilder<Map<String, int>>(
                              stream: getTotalRequestCounts(),
                              builder: ((context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final counts = snapshot.data ?? {};
                                return GridView.count(
                                  padding: EdgeInsets.symmetric(vertical: 30.0),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    MyCard(
                                      icon: FontAwesomeIcons.personDigging,
                                      text: 'Pending Requests',
                                      onTap: () => _assignTechnician(context),
                                      requestCount: counts['Pending'] ?? 0,
                                    ),
                                    MyCard(
                                      icon: FontAwesomeIcons.flagCheckered,
                                      text: 'Fixed Requests',
                                      onTap: () => _verifyRequests(context),
                                      requestCount: counts['Fixed'] ?? 0,
                                    ),
                                  ],
                                );
                              }),
                            )
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
