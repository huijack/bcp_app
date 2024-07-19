import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageViewerPage extends StatelessWidget {
  final String imageUrl;

  const ImageViewerPage({super.key, required this.imageUrl});

  Future<bool> hasViewPermission() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // First, check if the user is MaintenanceStaff
    final maintenanceStaffDoc = await FirebaseFirestore.instance
        .collection('MaintenanceStaff')
        .doc(user.uid)
        .get();

    if (maintenanceStaffDoc.exists) return true;

    // If not staff, check if they're User
    final userDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(user.uid)
        .get();
      
    if (userDoc.exists) return true; 

    // If not user, check if they're Admin
    final adminDoc = await FirebaseFirestore.instance
        .collection('Admin')
        .doc(user.uid)
        .get();

    return adminDoc.exists;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: hasViewPermission(),
          builder: (context, permissionSnapshot) {
            if (permissionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (permissionSnapshot.data != true) {
              return const Center(
                child: Text(
                  'Unauthorized: You do not have permission to view this image.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Stack(
              children: [
                Center(
                  child: Image.network(
                    imageUrl,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Text(
                          'Failed to load image. Please check your internet connection.',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
