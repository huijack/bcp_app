import 'package:bcp_app/components/my_adminsizedBox.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MyBuilding extends StatefulWidget {
  final String buildingName;
  final List<String> equipmentOrder;

  const MyBuilding({
    Key? key,
    required this.buildingName,
    required this.equipmentOrder,
  }) : super(key: key);

  @override
  State<MyBuilding> createState() => _MyBuildingState();
}

class _MyBuildingState extends State<MyBuilding> {
  late Stream<QuerySnapshot> _requestsStream;

  @override
  void initState() {
    super.initState();
    _initRequestsStream();
  }

  void _initRequestsStream() {
    _requestsStream = FirebaseFirestore.instance
        .collection('Request')
        .where('Building', isEqualTo: widget.buildingName)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text('User not authenticated'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        title: Text(
          widget.buildingName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(191, 0, 6, 0.815),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _requestsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child:
                        Text('No pending requests found for this building.'));
              }

              var requests = snapshot.data!.docs
                  .where((request) => request['Status'] != 'Fixed')
                  .toList();

              if (requests.isEmpty) {
                return const Center(
                    child:
                        Text('No pending requests found for this building.'));
              }

              // Sort requests by equipment priority and then by Request ID
              requests.sort((a, b) {
                var aEquipment = a['Equipment'] as String;
                var bEquipment = b['Equipment'] as String;
                var aIndex = widget.equipmentOrder.indexOf(aEquipment);
                var bIndex = widget.equipmentOrder.indexOf(bEquipment);
                if (aIndex != bIndex) {
                  return aIndex.compareTo(bIndex);
                } else {
                  var aId = a['Request ID'];
                  var bId = b['Request ID'];
                  // Convert to int if possible, otherwise use string comparison
                  int? aIntId = int.tryParse(aId.toString());
                  int? bIntId = int.tryParse(bId.toString());
                  if (aIntId != null && bIntId != null) {
                    return bIntId
                        .compareTo(aIntId); // Reverse order for latest first
                  } else {
                    return bId.toString().compareTo(
                        aId.toString()); // Reverse order for latest first
                  }
                }
              });

              // Group requests by equipment
              Map<String, List<QueryDocumentSnapshot>> groupedRequests = {};
              for (var request in requests) {
                var equipment = request['Equipment'] as String;
                if (!groupedRequests.containsKey(equipment)) {
                  groupedRequests[equipment] = [];
                }
                groupedRequests[equipment]!.add(request);
              }

              return ListView.builder(
                itemCount: widget.equipmentOrder.length,
                itemBuilder: ((context, index) {
                  var equipment = widget.equipmentOrder[index];
                  var equipmentRequests = groupedRequests[equipment] ?? [];

                  if (equipmentRequests.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          equipment,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(191, 0, 6, 0.815),
                          ),
                        ),
                      ),
                      ...equipmentRequests.asMap().entries.map((entry) {
                        var idx = entry.key;
                        var request = entry.value;

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
                                '${idx + 1}',
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
                                    onPressed: () async {
                                      final result =
                                          await showModalBottomSheet<bool>(
                                        context: context,
                                        builder: (context) =>
                                            MyAdminSizedBox(request: request),
                                      );
                                      if (result == true) {
                                        setState(() {
                                          _initRequestsStream();
                                        });
                                      }
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
                      }).toList(),
                    ],
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}
