import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageViewerPage extends StatelessWidget {
  final String userId;
  final String imageName;

  const ImageViewerPage({Key? key, required this.userId, required this.imageName}) : super(key: key);

  Future<String?> getImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    final storage = FirebaseStorage.instance;

    if (user == null) {
      print('User is not authenticated');
      return 'unauthenticated';
    }

    String? fileName;

    if (imageName.startsWith('http')) {
      // Extract the file name from the URL
      Uri uri = Uri.parse(imageName);
      List<String> segments = uri.pathSegments;
      fileName = segments.isNotEmpty ? segments.last : null;
    } else {
      fileName = imageName;
    }

    if (fileName == null) {
      print('Failed to extract file name from URL');
      return null;
    }

    try {
      final ref = storage.ref('$fileName');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting image URL: $e');
      if (e is FirebaseException && e.code == 'unauthorized') {
        return 'unauthorized';
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder<String?>(
              future: getImageUrl(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data == 'unauthenticated') {
                  return const Center(
                    child: Text(
                      'You are not logged in. Please log in to view this image.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (snapshot.data == 'unauthorized') {
                  return const Center(
                    child: Text(
                      'Unauthorized: You do not have permission to view this image.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(
                    child: Text(
                      'Failed to load image. Please try again later.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return Center(
                  child: Image.network(
                    snapshot.data!,
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
                );
              },
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
        ),
      ),
    );
  }
}
