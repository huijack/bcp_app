import 'package:bcp_app/pages/admin/assign_technician_page.dart';
import 'package:bcp_app/pages/technician/resolve_issues_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'my_adminsizedBox.dart';

class MyBuilding extends StatefulWidget {
  final String buildingName;
  final String status;
  final List<String> equipmentOrder;

  const MyBuilding({
    Key? key,
    required this.buildingName,
    required this.status,
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
        .where('Status', isEqualTo: widget.status)
        .snapshots();
  }

  List<QueryDocumentSnapshot> _sortRequests(
      List<QueryDocumentSnapshot> requests) {
    requests.sort((a, b) {
      if (widget.status == 'Assigned') {
        // First, sort by its importance
        var aImportance = a['Importance'] as String;
        var bImportance = b['Importance'] as String;

        var importanceOrder = ['High', 'Medium', 'Low'];
        var importanceComparison = importanceOrder
            .indexOf(aImportance)
            .compareTo(importanceOrder.indexOf(bImportance));
        if (importanceComparison != 0) return importanceComparison;

        // If importance is the same, sort by equipment priority
        var aEquipment = a['Equipment'] as String;
        var bEquipment = b['Equipment'] as String;
        var equipmentComparison = widget.equipmentOrder
            .indexOf(aEquipment)
            .compareTo(widget.equipmentOrder.indexOf(bEquipment));
        if (equipmentComparison != 0) return equipmentComparison;

        // If equipment is the same, sort by Request ID (latest first)
        var aId = int.tryParse(a['Request ID'].toString()) ?? 0;
        var bId = int.tryParse(b['Request ID'].toString()) ?? 0;
        return bId.compareTo(aId);
      } else {
        var aEquipment = a['Equipment'] as String;
        var bEquipment = b['Equipment'] as String;
        var equipmentComparison = widget.equipmentOrder
            .indexOf(aEquipment)
            .compareTo(widget.equipmentOrder.indexOf(bEquipment));
        if (equipmentComparison != 0) return equipmentComparison;

        var aId = int.tryParse(a['Request ID'].toString()) ?? 0;
        var bId = int.tryParse(b['Request ID'].toString()) ?? 0;
        return bId.compareTo(aId);
      }
    });
    return requests;
  }

  Widget _buildRequestList(List<QueryDocumentSnapshot> requests) {
    if (widget.status == 'Assigned') {
      var now = DateTime.now();
      var overdueRequests = requests
          .where((r) => (r['Due Date'] as Timestamp).toDate().isBefore(now))
          .toList();
      var activeRequests = requests
          .where((r) => !(r['Due Date'] as Timestamp).toDate().isBefore(now))
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overdueRequests.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Overdue Requests',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            _buildRequestCards(overdueRequests, isOverdue: true),
          ],
          if (activeRequests.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      'Active Requests',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
            _buildRequestCards(activeRequests),
          ],
        ],
      );
    } else {
      return _buildRequestCards(requests);
    }
  }

  Widget _buildRequestCards(List<QueryDocumentSnapshot> requests,
      {bool isOverdue = false}) {
    // Group requests by equipment or importance based on status
    Map<String, List<QueryDocumentSnapshot>> groupedRequests = {};
    for (var request in requests) {
      var key = widget.status == 'Assigned'
          ? request['Importance'] as String
          : request['Equipment'] as String;
      if (!groupedRequests.containsKey(key)) {
        groupedRequests[key] = [];
      }
      groupedRequests[key]!.add(request);
    }

    // Define the order of keys
    List<String> keyOrder = widget.status == 'Assigned'
        ? ['High', 'Medium', 'Low']
        : widget.equipmentOrder;

    return Column(
      children: keyOrder.map((key) {
        var keyRequests = groupedRequests[key] ?? [];
        if (keyRequests.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Text(
                key,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isOverdue
                      ? Colors.red
                      : const Color.fromRGBO(191, 0, 6, 0.815),
                ),
              ),
            ),
            ...keyRequests.asMap().entries.map((entry) {
              var idx = entry.key;
              var request = entry.value;

              var requestId = request['Request ID']?.toString() ?? '';
              var requestDate =
                  request['Submitted Date']?.toDate() ?? DateTime.now();

              var dueDate = request['Due Date'] is Timestamp
                  ? (request['Due Date'] as Timestamp).toDate()
                  : null;


              var fixedDate = request['Resolved Date'] is Timestamp
                  ? (request['Resolved Date'] as Timestamp).toDate()
                  : null;

              var verifiedDate = request['Verified Date'] is Timestamp
                  ? (request['Verified Date'] as Timestamp).toDate()
                  : null;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromRGBO(191, 0, 6, 0.815),
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text('REQUEST NO: $requestId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.status == 'Fixed'
                            ? 'FIXED DATE: ${fixedDate != null ? DateFormat('dd-MM-yyyy').format(fixedDate) : 'Not set'}'
                            : widget.status == 'Assigned'
                                ? dueDate != null
                                    ? 'DUE DATE: ${DateFormat('dd-MM-yyyy').format(dueDate)}'
                                    : 'DUE DATE: Not set'
                                : widget.status == 'Verified'
                                    ? verifiedDate != null
                                        ? 'VERIFIED DATE: ${DateFormat('dd-MM-yyyy').format(verifiedDate)}'
                                        : 'VERIFIED DATE: Not set'
                                    : 'SUBMITTED DATE: ${DateFormat('dd-MM-yyyy').format(requestDate)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                          icon: Icon(
                            widget.status == 'Pending' ||
                                    widget.status == 'Assigned'
                                ? Icons.arrow_forward
                                : Icons.remove_red_eye,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            if (widget.status == 'Pending') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AssignTechnicianPage(request: request),
                                ),
                              );
                            } else if (widget.status == 'Assigned') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ResolveIssuesPage(request: request)),
                              );
                            } else {
                              final result = await showModalBottomSheet<bool>(
                                context: context,
                                builder: (context) =>
                                    MyAdminSizedBox(request: request),
                              );
                              if (result == true) {
                                setState(() {
                                  _initRequestsStream();
                                });
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.status == 'Pending' ||
                                widget.status == 'Assigned'
                            ? 'View'
                            : 'Details',
                        style: const TextStyle(
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
      }).toList(),
    );
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
              return Center(
                child: Text(
                    'No ${widget.status.toLowerCase()} requests found for this building.'),
              );
            }

            var requests = _sortRequests(snapshot.data!.docs);
            return SingleChildScrollView(child: _buildRequestList(requests));
          },
        ),
      ),
    );
  }
}
