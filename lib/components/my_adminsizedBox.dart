import 'package:bcp_app/pages/admin/admin_imageViewer_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class MyAdminSizedBox extends StatefulWidget {
  final QueryDocumentSnapshot request;

  const MyAdminSizedBox({super.key, required this.request});

  @override
  State<MyAdminSizedBox> createState() => _MyAdminSizedBoxState();
}

class _MyAdminSizedBoxState extends State<MyAdminSizedBox> {
  late String status;

  Future<void> updateStatus() async {
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Status Update'),
          content: const Text(
              'Are you sure you want to mark this request as Fixed?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    // If confirmed, update the status
    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('Request')
            .doc(widget.request.id)
            .update({'Status': 'Fixed'});

        // show success dialog
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Status has been updated successfully.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the sizedbox
                  },
                ),
              ],
            );
          },
        );

        // Notify the parent widget to refresh the list
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var status = widget.request['Status'] ?? 'Unknown';
    var equipment = widget.request['Equipment'] ?? 'Unknown';
    var issues = widget.request['Issues'] ?? 'No issues provided';
    var imageUrl = widget.request['Image URL'] ?? '';
    var remarks = widget.request['Remarks'] ?? '';
    var roomNo = widget.request['Room No'] ?? 'Unknown';
    var reporterName = widget.request['Reporter Name'] ?? '';

    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Request Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 212, 212, 212),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text(
                              'Reporter Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(reporterName),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text(
                              'Room No',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(roomNo),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text(
                              'Equipment',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(equipment),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              status,
                              style: TextStyle(
                                color: status == 'Fixed'
                                    ? Colors.green
                                    : Colors.red[900],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListTile(
                      title: const Text(
                        'Issues',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(issues),
                    ),
                    ListTile(
                      title: const Text(
                        'Remarks',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(remarks),
                    ),
                    if (imageUrl.isNotEmpty)
                      ListTile(
                        title: const Text(
                          'Image',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AdminImageViewerPage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: const Text(
                            'Tap to view image',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton(
                        onPressed: status == 'Fixed' ? null : updateStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(191, 0, 6, 0.815),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          status == 'Fixed' ? 'Request Fixed' : 'Mark as Fixed',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
