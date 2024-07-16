import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../components/my_adminsizedBox.dart';
import '../../components/my_debouncer.dart';
import '../../components/my_searchbar.dart'; // Import your search bar widget here

class AdminHistoryPage extends StatefulWidget {
  const AdminHistoryPage({super.key});

  @override
  State<AdminHistoryPage> createState() => _AdminHistoryPageState();
}

class _AdminHistoryPageState extends State<AdminHistoryPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController =
      SearchController(); // Use your search controller
  String _searchText = '';
  final Debouncer _debouncer = Debouncer(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        title: const Text(
          'View History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(191, 0, 6, 0.815),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0),
            child: MySearchBar(
              controller: _searchController,
              onChanged: (value) {
                _debouncer.run(() {
                  setState(() {
                    _searchText = value;
                  });
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Request')
                  .where('Status', isEqualTo: 'Fixed')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No fixed requests found.'),
                  );
                }

                var requests = snapshot.data!.docs.toList();

                // Filter requests based on search text
                if (_searchText.isNotEmpty) {
                  requests = requests.where((request) {
                    var requestId = request['Request ID']?.toString() ?? '';
                    return requestId.contains(_searchText);
                  }).toList();
                }

                // Sort requests by timestamp
                requests.sort((a, b) {
                  var aTimestamp = a['timestamp']?.toDate() ?? DateTime.now();
                  var bTimestamp = b['timestamp']?.toDate() ?? DateTime.now();
                  return bTimestamp.compareTo(aTimestamp);
                });

                return ListView.builder(
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
                          backgroundColor: Colors.green[800],
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
