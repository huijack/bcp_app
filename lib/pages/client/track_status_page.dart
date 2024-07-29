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
        centerTitle: true,
        title: const Text(
          'Track Request Status',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(191, 0, 6, 0.815),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                RequestCountsCard(userId: userId),
                const SizedBox(height: 20),
                const MyTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
