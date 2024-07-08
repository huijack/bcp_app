import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'request_details_page.dart';

class ViewPastRequestsPage extends StatelessWidget {
  const ViewPastRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not authenticated'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'Past Requests',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(191, 0, 6, 0.815),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Request')
                      .where('uId', isEqualTo: user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                          child: Text('No past requests found.'));
                    }

                    var requests = snapshot.data!.docs.toList();

                    requests.sort((a, b) {
                      var aId = a['Request ID'];
                      var bId = b['Request ID'];
                      if (aId is int && bId is int) {
                        return aId.compareTo(bId);
                      } else if (aId is String && bId is String) {
                        return aId.compareTo(bId);
                      } else {
                        return 0;
                      }
                    });

                    return ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: ((context, index) {
                        var request = requests[index];
                        var requestId = request['Request ID']?.toString() ?? '';
                        var requestDate =
                            request['timestamp']?.toDate() ?? DateTime.now();

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor:
                                  const Color.fromRGBO(191, 0, 6, 0.815),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text('REQUEST NO: $requestId'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DATE: ${DateFormat('dd-MM-yyyy').format(requestDate)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 36,
                                  width: 36,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(207, 136, 2, 6),
                                  ),
                                  child: IconButton(
                                    iconSize: 18,
                                    padding: const EdgeInsets.all(8),
                                    icon: const Icon(Icons.remove_red_eye,
                                        color: Colors.white),
                                    onPressed: () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        builder: (context) =>
                                            RequestDetailsPage(
                                                request: request),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Details',
                                  style: TextStyle(
                                    color: Color.fromARGB(207, 136, 2, 6),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
