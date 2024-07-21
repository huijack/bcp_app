import 'package:bcp_app/pages/image_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot request;

  const RequestDetailsPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    var building = request['Building'] ?? 'Unknown';
    var equipment = request['Equipment'] ?? 'Unknown';
    var issues = request['Issues'] ?? 'No issues provided';
    var imageName = request['Image URL'] ?? '';
    var resolvedImageName = request['Resolved Image URL'] ?? '';
    var remarks = request['Remarks'] ?? '';
    var roomNo = request['Room No'] ?? 'Unknown';
    var userStatus = request['User Status'] ?? 'Pending';

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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ),
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
                              'Building',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(building),
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
                              userStatus,
                              style: TextStyle(
                                color: userStatus == 'Pending'
                                    ? Colors.red
                                    : Colors.green,
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
                    Row(
                      children: [
                        Expanded(
                            child: ListTile(
                          title: const Text(
                            'Submitted Image',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ImageViewerPage(imageUrl: imageName)),
                              );
                            },
                            child: const Row(
                              children: [
                                Text(
                                  'Tap to view image',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward,
                                    size: 16, color: Colors.blue),
                              ],
                            ),
                          ),
                        )),
                        Expanded(
                          child: ListTile(
                            title: const Text(
                              'Resolved Image',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerPage(
                                      imageUrl: resolvedImageName,
                                    ),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'Tap to view image',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward,
                                      size: 16, color: Colors.blue),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListTile(
                      title: const Text(
                        'Remarks',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(remarks),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
