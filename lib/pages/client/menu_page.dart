import 'package:bcp_app/components/my_card.dart';
import 'package:bcp_app/components/my_requestcounts.dart';
import 'package:bcp_app/pages/client/submit_request_page.dart';
import 'package:bcp_app/pages/client/view_request_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile_page.dart';
import 'track_status_page.dart';

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

  void _trackRequestStatus(BuildContext context) {
    // navigate to the track request status page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackRequestStatusPage(),
      ),
    );
  }

  void _viewPastRequests(BuildContext context) {
    // navigate to the view past requests page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewPastRequestsPage(),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    // navigate to the edit profile page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(),
      ),
    );
  }

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
              physics:
                  NeverScrollableScrollPhysics(), // Disable scrolling for GridView
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
                  text: "View Past Requests",
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
            const SizedBox(height: 20),
            RequestCountsCard(userId: userId),
          ],
        ),
      ),
    );
  }
}
