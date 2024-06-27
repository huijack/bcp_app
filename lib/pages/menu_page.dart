import 'package:bcp_app/components/my_card.dart';
import 'package:bcp_app/components/my_requestcounts.dart';
import 'package:bcp_app/pages/submit_request_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _submitRequest(BuildContext context) {
    // navigate to the submit request page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubmitRequestPage(),
      ),
    );
  }

  void _trackRequestStatus() {}

  void _viewPastRequests() {}

  void _editProfile() {}

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              shrinkWrap: true, // Use shrinkWrap to take the natural size
              physics: NeverScrollableScrollPhysics(), // Disable scrolling for GridView
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
                  onTap: _trackRequestStatus,
                ),

                // View Past Requests
                MyCard(
                  icon: Icons.history,
                  text: "View Past Requests",
                  onTap: _viewPastRequests,
                ),

                // Edit Profile
                MyCard(
                  icon: Icons.person_2_outlined,
                  text: "Edit Profile",
                  onTap: _editProfile,
                ),
              ],
            ),
            const SizedBox(height: 20),
            RequestCountsCard(userId: userId),
          ],
        ),
      ),
    );
  }
}
