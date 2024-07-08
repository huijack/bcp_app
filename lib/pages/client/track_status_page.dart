import 'package:bcp_app/components/my_table.dart';
import 'package:flutter/material.dart';
import 'package:bcp_app/components/my_requestcounts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TrackRequestStatusPage extends StatelessWidget {
  const TrackRequestStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Track Request Status',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(191, 0, 6, 0.815),
                ),
              ),
              const SizedBox(height: 10),
              RequestCountsCard(userId: userId),
              const SizedBox(height: 20),
              MyTable(),
            ],
          ),
        ),
      ),
    );
  }
}
