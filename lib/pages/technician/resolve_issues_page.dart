import 'package:bcp_app/components/my_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../image_viewer_page.dart';

class ResolveIssuesPage extends StatefulWidget {
  final Function(XFile? image)? onImagePicked;

  final QueryDocumentSnapshot request;

  const ResolveIssuesPage({
    super.key,
    required this.request,
    this.onImagePicked,
  });

  @override
  State<ResolveIssuesPage> createState() => _ResolveIssuesPageState();
}

class _ResolveIssuesPageState extends State<ResolveIssuesPage> {
  String? _imageFormat;
  String? _imageName; // Variable to store image name
  final ImagePicker _picker = ImagePicker();
  bool _isImagePickerActive = false;
  XFile? _pickedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImage() async {
    if (_isImagePickerActive) return;

    setState(() {
      _isImagePickerActive = true;
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        String specificFileName = basename(image.path);

        // Copy the image to a new file with the specific name
        final String directory =
            (await getApplicationDocumentsDirectory()).path;
        final String newPath = '$directory/$specificFileName';
        final File newFile = File(newPath);
        await newFile.writeAsBytes(await image.readAsBytes());

        setState(() {
          _pickedImage =
              XFile(newPath); // Update the XFile to point to the new path
          _imageFormat = _pickedImage?.mimeType;
          _imageName = specificFileName; // Update the image name
        });

        // Call callback function if provided
        if (widget.onImagePicked != null) {
          widget.onImagePicked!(_pickedImage);
        }

        print('Image picked: ${_pickedImage?.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      setState(() {
        _isImagePickerActive = false;
      });
    }
  }

  Future<void> resolveRequest(BuildContext context) async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      final userId = FirebaseAuth.instance.currentUser!.uid;

      if (user == null) {
        print('User is not authenticated');
        return;
      }

      DocumentSnapshot staffDoc = await FirebaseFirestore.instance
          .collection('MaintenanceStaff')
          .doc(user.uid)
          .get();
      String staffName = staffDoc['Name'] ?? 'Unknown';

      String downloadURL = '';
      if (_pickedImage != null) {
        String fileName = basename(_pickedImage!.path);
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('images/$userId')
            .child(fileName);
        await ref.putFile(File(_pickedImage!.path));
        downloadURL = await ref.getDownloadURL();
      }

      // Update the request in Firestore
      await FirebaseFirestore.instance
          .collection('Request')
          .doc(widget.request.id)
          .update({
        'Status': 'Fixed',
        'Resolved By': staffName,
        'Resolved Image URL': downloadURL,
        'Resolved Date': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('MaintenanceStaff')
          .doc(user.uid)
          .update({'Availability': 'Yes'});

      // Show success message
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Request Resolved'),
            content: const Text('The request has been resolved successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error resolving request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.image, color: Colors.red[900], size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Picture of the resolved issue',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _imageName ?? 'No image selected',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text(
                      _pickedImage == null ? 'Select Image' : 'Change Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[900],
            ),
          ),
        ),
        ...children,
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.red[900], size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var roomNo = widget.request['Room No'] ?? 'Unknown';
    var equipment = widget.request['Equipment'] ?? 'Unknown';
    var issues = widget.request['Issues'] ?? 'No issues provided';
    var importance = widget.request['Importance'] ?? 'Unknown';
    var imageUrl = widget.request['Image URL'] ?? '';
    var remarks = widget.request['Remarks'] ?? '';

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.red[900],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Resolve Issues',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoSection(
                    'Assigned Request',
                    [
                      _buildInfoItem('Room', roomNo, Icons.room),
                      _buildInfoItem('Equipment', equipment, Icons.build),
                      _buildInfoItem('Issues', issues, Icons.error),
                      _buildInfoItem(
                          'Importance', importance, Icons.priority_high),
                      if (remarks.isNotEmpty)
                        _buildInfoItem('Remarks', remarks, Icons.comment),
                      if (imageUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageViewerPage(
                                  imageUrl: imageUrl,
                                ),
                              ),
                            );
                          },
                          child: _buildInfoItem(
                              'Image', 'Tap to view', Icons.image),
                        ),
                    ],
                  ),
                  Divider(),
                  _buildInfoSection(
                    'Resolve Requests',
                    [
                      _buildImagePicker(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    Container(
                      padding: const EdgeInsets.all(25),
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(191, 0, 7, 100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ),
                  if (!isLoading)
                    MyButton(
                        onTap: () => resolveRequest(context),
                        buttonText: 'Resolve Request'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}