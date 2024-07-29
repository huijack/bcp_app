import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class MyUploadImage extends StatefulWidget {
  final Function(XFile? image)? onImagePicked;

  const MyUploadImage({super.key, this.onImagePicked});

  @override
  State<MyUploadImage> createState() => _MyUploadImageState();
}

class _MyUploadImageState extends State<MyUploadImage> {
  String? _imageFormat;
  String? _imageName; // Variable to store image name
  final ImagePicker _picker = ImagePicker();
  bool _isImagePickerActive = false;
  XFile? _image;

  Future<void> _pickImage() async {
    if (_isImagePickerActive) return;

    setState(() {
      _isImagePickerActive = true;
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // String specificFileName = 'specific_name.jpg';
        String specificFileName = basename(image.path);

        // Copy the image to a new file with the specific name
        final String directory = (await getApplicationDocumentsDirectory()).path;
        final String newPath = '$directory/$specificFileName';
        final File newFile = File(newPath);
        await newFile.writeAsBytes(await image.readAsBytes());

        setState(() {
          _image = XFile(newPath); // Update the XFile to point to the new path
          _imageFormat = _image?.mimeType;
          _imageName = specificFileName; // Update the image name
        });

        // Call callback function if provided
        if (widget.onImagePicked != null) {
          widget.onImagePicked!(_image);
        }
        
        debugPrint('Image picked: ${_image?.path}');
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      setState(() {
        _isImagePickerActive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(240, 240, 240, 1.0),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: _pickImage,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.camera_alt),
                const SizedBox(width: 10),
                Text(
                  _imageName == null
                      ? 'Pictures of Proof'
                      : 'Image name: $_imageName', // Show the image name
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _imageName == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
