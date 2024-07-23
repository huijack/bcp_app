import 'package:bcp_app/components/my_card.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../admin/admin_history_page.dart';
import '../admin/blockA_status_page.dart';
import '../admin/blockB_status_page.dart';
import '../admin/blockC_status_page.dart';
import '../admin/blockE_status_page.dart';
import '../admin/blockG_status_page.dart';

class MyTechnicianHomePage extends StatefulWidget {
  final String? userName;
  final String? email;

  const MyTechnicianHomePage({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  State<MyTechnicianHomePage> createState() => _MyTechnicianHomePageState();
}

class _MyTechnicianHomePageState extends State<MyTechnicianHomePage> {
  var height, width;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {});
  }

  Stream<List<QueryDocumentSnapshot>> getOverdueRequests() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    final userId = user.uid;
    final now = DateTime.now().toUtc();
    const localOffset = Duration(hours: 8);
    final localNow = now.add(localOffset);

    return FirebaseFirestore.instance
        .collection('Request')
        .where('Status', isEqualTo: 'Assigned')
        .where('Assigned To', isEqualTo: userId)
        .where('Due Date', isLessThan: localNow)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  Widget _buildOverdueRequestsContainer() {
    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: getOverdueRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final overdueRequests = snapshot.data ?? [];

        if (overdueRequests.isEmpty) {
          return const SizedBox
              .shrink(); // Don't show anything if there are no overdue requests
        }

        return Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[900]!, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overdue Requests',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
              const SizedBox(height: 8),
              ...overdueRequests.map((request) {
                final requestId = request['Request ID'];
                final dueDate = (request['Due Date'] as Timestamp).toDate();
                final building = request['Building'];
                return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: RichText(
                        text: TextSpan(
                      text: 'Request ID: ',
                      style: TextStyle(
                        color: Colors.red[900],
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: requestId.toString(),
                          style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: ' - Due Date: ',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: DateFormat.yMd().format(dueDate),
                          style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: ' - Building: ',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: building,
                          style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    )));
              }),
            ],
          ),
        );
      },
    );
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
      debugPrint('Error logging out: $e');
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
          return const BlockAStatusPage(
            status: 'Assigned',
          );
        },
      ),
    );
  }

  void _blockB(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockBStatusPage(
            status: 'Assigned',
          );
        },
      ),
    );
  }

  void _blockC(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockCStatusPage(
            status: 'Assigned',
          );
        },
      ),
    );
  }

  void _blockE(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockEStatusPage(
            status: 'Assigned',
          );
        },
      ),
    );
  }

  void _blockG(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockGStatusPage(
            status: 'Assigned',
          );
        },
      ),
    );
  }

  Stream<Map<String, int>> getAssignedRequestCounts() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value({});
    }

    final userId = user.uid;

    return FirebaseFirestore.instance
        .collection('Request')
        .where('Status', isEqualTo: 'Assigned')
        .where('Assigned To', isEqualTo: userId)
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
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        await showLogoutConfirmation();
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
                accountName: Text(
                  widget.userName ?? 'Technician',
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
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(context);
                  showLogoutConfirmation();
                },
              ),
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
                                          const AdminHistoryPage(
                                            isAdmin: false,
                                          ),
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
                                    widget.userName ?? 'Mr. Technician',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildOverdueRequestsContainer(),
                          StreamBuilder<Map<String, int>>(
                            stream: getAssignedRequestCounts(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              final counts = snapshot.data ?? {};
                              return GridView.count(
                                padding: const EdgeInsets.symmetric(vertical: 30.0),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
