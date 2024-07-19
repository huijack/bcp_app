import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'my_statuscircle.dart';

class RequestCountsCard extends StatelessWidget {
  final String userId;

  const RequestCountsCard({
    super.key,
    required this.userId,
  });

  Stream<Map<String, int>> _requestCountsStream() {
    return FirebaseFirestore.instance
        .collection('Request')
        .where('uId', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) {
      int pendingCount = 0;
      int fixedCount = 0;

      for (var doc in querySnapshot.docs) {
        final status = doc['User Status'];
        if (status == 'Pending') {
          pendingCount++;
        } else if (status == 'Fixed') {
          fixedCount++;
        }
      }

      return {
        'pending': pendingCount,
        'fixed': fixedCount,
        'total': pendingCount + fixedCount,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: _requestCountsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Text('Error loading request counts');
        } else if (!snapshot.hasData) {
          return const Text('No request counts available');
        }

        final counts = snapshot.data!;
        return Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatusCircle(
                    title: "Pending",
                    count: counts['pending'] ?? 0,
                    color: Colors.red,
                  ),
                  StatusCircle(
                    title: "Fixed",
                    count: counts['fixed'] ?? 0,
                    color: Colors.green,
                  ),
                  StatusCircle(
                    title: "Total",
                    count: counts['total'] ?? 0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
