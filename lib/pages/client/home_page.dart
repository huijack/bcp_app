import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

import '../../components/my_card.dart';
import '../../components/my_requestcounts.dart';
import 'edit_profile_page.dart';
import 'faq_page.dart';
import 'profile_page.dart';
import 'submit_feedback_page.dart';
import 'submit_request_page.dart';
import 'track_status_page.dart';
import 'view_request_page.dart';

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
  bool _isLoggingOut = false;
  late PageController _pageController;
  var height, width;

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

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {});
  }

  void _submitRequest(BuildContext context) {
    // navigate to the submit request page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubmitRequestPage(),
      ),
    );
  }

  void _trackRequestStatus(BuildContext context) {
    // navigate to the track request status page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrackRequestStatusPage(),
      ),
    );
  }

  void _viewPastRequests(BuildContext context) {
    // navigate to the view past requests page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ViewPastRequestsPage(),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    // navigate to the edit profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }

  final String userId = FirebaseAuth.instance.currentUser!.uid;

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
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

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
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                onTap: () {
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
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
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
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
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
                                      builder: (context) => ProfilePage(),
                                    ),
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red[900],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 40,
                                  ),
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
                                    widget.userName ?? 'User',
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
                        )),
                    // height: height * 0.75,
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GridView.count(
                                padding: EdgeInsets.only(top: 30.0),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                shrinkWrap:
                                    true, // Use shrinkWrap to take the natural size
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  // Submit a Request
                                  MyCard(
                                    icon: Icons.file_copy_outlined,
                                    text: "Submit a Request",
                                    onTap: () => _submitRequest(context),
                                  ),

                                  // Track Request Status
                                  MyCard(
                                    icon: Icons.local_shipping_outlined,
                                    text: "Track Request Status",
                                    onTap: () => _trackRequestStatus(context),
                                  ),

                                  // View Past Requests
                                  MyCard(
                                    icon: Icons.history,
                                    text: "Past Fixed Requests",
                                    onTap: () => _viewPastRequests(context),
                                  ),

                                  // Edit Profile
                                  MyCard(
                                    icon: Icons.person_2_outlined,
                                    text: "Edit Profile",
                                    onTap: () => _editProfile(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RequestCountsCard(userId: userId),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
