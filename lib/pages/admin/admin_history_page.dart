import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../components/my_adminsizedBox.dart';

class AdminHistoryPage extends StatefulWidget {
  const AdminHistoryPage({super.key});

  @override
  State<AdminHistoryPage> createState() => _AdminHistoryPageState();
}

class _AdminHistoryPageState extends State<AdminHistoryPage> with AutomaticKeepAliveClientMixin{
  @override
  bool get wantKeepAlive => true;
  
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Request')
            .where('Status', isEqualTo: 'Fixed')
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
              child: Text('No fixed requests found.'),
            );
          }

          var requests = snapshot.data!.docs.toList();

          // Sort requests by timestamp
          requests.sort((a, b) {
            var aTimestamp = a['timestamp']?.toDate() ?? DateTime.now();
            var bTimestamp = b['timestamp']?.toDate() ?? DateTime.now();
            return bTimestamp.compareTo(aTimestamp);
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Fixed Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    var request = requests[index];
                    var requestId = request['Request ID']?.toString() ?? '';
                    var requestDate =
                        request['timestamp']?.toDate() ?? DateTime.now();
                    var equipment = request['Equipment'] ?? 'Unknown';
                    var issues = request['Issues'] ?? 'No issues provided';
                    var imageUrl = request['Image URL'] ?? '';
                    var remarks = request['Remarks'] ?? '';
                    var roomNo = request['Room No'] ?? 'Unknown';
                    var reporterName = request['Reporter Name'] ?? '';

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.green[800],
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[900],
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
                                        MyAdminSizedBox(request: request),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Details',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
