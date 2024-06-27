import 'package:bcp_app/components/my_button.dart';
import 'package:bcp_app/components/my_dropdown.dart';
import 'package:bcp_app/components/my_textfield.dart';
import 'package:bcp_app/components/my_uploadimage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import dart:io
import 'package:path/path.dart'; // Import path package
import 'package:firebase_storage/firebase_storage.dart'; // Import firebase_storage

class SubmitRequestPage extends StatefulWidget {
  const SubmitRequestPage({super.key});

  @override
  State<SubmitRequestPage> createState() => _SubmitRequestPageState();
}

class _SubmitRequestPageState extends State<SubmitRequestPage> {
  String? _selectedBuilding;
  String? _selectedEquipment;
  bool _hasImage = false;
  XFile? _pickedImage; // Store the picked image here

  void _handleBuildingChange(String? newValue) {
    setState(() {
      _selectedBuilding = newValue;
    });
  }

  void _handleEquipmentChange(String? newValue) {
    setState(() {
      _selectedEquipment = newValue;
    });
  }

  void _handleImagePicked(XFile? image) {
    setState(() {
      _hasImage = image != null;
      _pickedImage = image;
    });
  }

  Future<void> submitRequest(BuildContext context) async {
    if (_selectedBuilding == null || _selectedEquipment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a building and equipment'),
        ),
      );
      return;
    }

    if (roomNoController.text.isEmpty || issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a room number and issue'),
        ),
      );
      return;
    }

    if (!_hasImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload an image'),
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // get current user ID
      final userId = FirebaseAuth.instance.currentUser!.uid;

      if (userId == null) {
        // Close loading dialog
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: User is not authenticated.'),
          ),
        );
        return;
      }

      // Upload image to Firebase Storage
      String downloadURL = '';
      if (_hasImage && _pickedImage != null) {
        String fileName = basename(_pickedImage!.path);
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('images/$userId') // Add the user ID to the path
            .child(fileName);
        await ref.putFile(File(_pickedImage!.path));
        downloadURL = await ref.getDownloadURL();
      }

      // Add data to Firestore
      await FirebaseFirestore.instance.collection('Request').add({
        'Building': _selectedBuilding,
        'Equipment': _selectedEquipment,
        'Room No': roomNoController.text,
        'Issues': issueController.text,
        'Remarks': remarksController.text,
        'Image URL': downloadURL, // Store the image URL in Firestore
        'Status': 'pending',
        'uId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request submitted successfully'),
        ),
      );

      // Clear form
      roomNoController.clear();
      issueController.clear();
      remarksController.clear();
      setState(() {
        _selectedBuilding = null;
        _selectedEquipment = null;
        _hasImage = false;
        _pickedImage = null; // Clear the image
      });
    } catch (error) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error submitting request. Please try again'),
        ),
      );
    }
  }

  final roomNoController = TextEditingController();
  final issueController = TextEditingController();
  final remarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const Text(
                  'Submit a Request',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(191, 0, 6, 0.815),
                  ),
                ),
                const SizedBox(height: 30),
                MyDropdown(
                  prefixIcon: FontAwesomeIcons.building,
                  hintText: 'Choose a building',
                  items: const [
                    DropdownMenuItem(
                      value: 'blockA',
                      child: Text('Block A'),
                    ),
                    DropdownMenuItem(
                      value: 'blockB',
                      child: Text('Block B'),
                    ),
                    DropdownMenuItem(
                      value: 'blockC',
                      child: Text('Block C'),
                    ),
                    DropdownMenuItem(
                      value: 'blockE',
                      child: Text('Block E'),
                    ),
                    DropdownMenuItem(
                      value: 'blockG',
                      child: Text('Block G'),
                    ),
                  ],
                  onChanged: _handleBuildingChange,
                ),
                const SizedBox(height: 25),
                MyDropdown(
                  prefixIcon: Icons.priority_high,
                  hintText: "Choose an equipment",
                  items: const [
                    DropdownMenuItem(
                      value: 'projector',
                      child: Text('Projector'),
                    ),
                    DropdownMenuItem(
                      value: 'aircon',
                      child: Text('Air Conditioner'),
                    ),
                    DropdownMenuItem(
                      value: 'light',
                      child: Text('Light'),
                    ),
                    DropdownMenuItem(
                      value: 'fan',
                      child: Text('Fan'),
                    ),
                    DropdownMenuItem(
                      value: 'door',
                      child: Text('Door'),
                    ),
                    DropdownMenuItem(
                      value: 'others',
                      child: Text('Others'),
                    )
                  ],
                  onChanged: _handleEquipmentChange,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: roomNoController,
                  hintText: "Room No.",
                  obscureText: false,
                  prefixIcon: Icons.house,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: issueController,
                  hintText: "Issues",
                  obscureText: false,
                  prefixIcon: Icons.error,
                ),
                const SizedBox(height: 25),
                MyUploadImage(
                  onImagePicked: _handleImagePicked,
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: remarksController,
                  hintText: "Remarks",
                  obscureText: false,
                  prefixIcon: Icons.note,
                ),
                const SizedBox(height: 40),
                MyButton(
                  onTap: () => submitRequest(context),
                  buttonText: "Submit Request",
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
