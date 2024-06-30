import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class MyTable extends StatefulWidget {
  const MyTable({Key? key}) : super(key: key);

  @override
  _MyTableState createState() => _MyTableState();
}

class _MyTableState extends State<MyTable> {
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  String formatDate(Timestamp timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  void _sort<T>(Comparable<T> Function(QueryDocumentSnapshot doc) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _isAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Request')
          .where('uId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No requests found'));
        }

        List<QueryDocumentSnapshot> sortedDocs = snapshot.data!.docs.toList();
        sortedDocs.sort((a, b) {
          final aValue = a[_getColumnField(_sortColumnIndex)];
          final bValue = b[_getColumnField(_sortColumnIndex)];
          return _isAscending
              ? Comparable.compare(aValue, bValue)
              : Comparable.compare(bValue, aValue);
        });

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _isAscending,
            columnSpacing: 40,
            dataRowHeight: 60,
            headingRowHeight: 60,
            horizontalMargin: 20,
            columns: [
              DataColumn(
                label: const Text('Request No.',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                onSort: (columnIndex, ascending) =>
                    _sort((doc) => doc['Request ID'], columnIndex, ascending),
              ),
              DataColumn(
                label: const Text('Building',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                onSort: (columnIndex, ascending) =>
                    _sort((doc) => doc['Building'], columnIndex, ascending),
              ),
              DataColumn(
                label: const Text('Room No.',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                onSort: (columnIndex, ascending) =>
                    _sort((doc) => doc['Room No'], columnIndex, ascending),
              ),
              DataColumn(
                label: const Text('Date',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                onSort: (columnIndex, ascending) =>
                    _sort((doc) => doc['timestamp'], columnIndex, ascending),
              ),
              DataColumn(
                label: const Text('Status',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                onSort: (columnIndex, ascending) =>
                    _sort((doc) => doc['Status'], columnIndex, ascending),
              ),
            ],
            rows: sortedDocs.asMap().entries.map((entry) {
              int index = entry.key;
              QueryDocumentSnapshot doc = entry.value;
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              bool isEven = index % 2 == 0; // Check if the index is even

              return DataRow(
                color: isEven
                    ? MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08);
                        }
                        return Colors.white; // Set the color for even rows
                      })
                    : MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08);
                        }
                        return Colors
                            .grey.shade100; // Set the color for odd rows
                      }),
                cells: [
                  DataCell(Text(data['Request ID']?.toString() ?? '',
                      style: const TextStyle(fontSize: 16))),
                  DataCell(Text(data['Building'] ?? '',
                      style: const TextStyle(fontSize: 16))),
                  DataCell(Text(data['Room No'] ?? '',
                      style: const TextStyle(fontSize: 16))),
                  DataCell(Text(formatDate(data['timestamp']),
                      style: const TextStyle(fontSize: 16))),
                  DataCell(Text(data['Status'] ?? '',
                      style: const TextStyle(fontSize: 16))),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getColumnField(int index) {
    switch (index) {
      case 0:
        return 'Request ID';
      case 1:
        return 'Building';
      case 2:
        return 'Room No';
      case 3:
        return 'timestamp';
      case 4:
        return 'Status';
      default:
        return '';
    }
  }
}
