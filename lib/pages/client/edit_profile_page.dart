import 'package:bcp_app/components/my_button.dart';
import 'package:bcp_app/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final postcodeController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  bool isLoading = false;

  // Initialize the Future directly
  late final Future<DocumentSnapshot> userDataFuture = fetchUserData();

  Future<DocumentSnapshot> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance.collection('User').doc(user.uid).get();
    } else {
      throw Exception('No user logged in');
    }
  }

  void populateControllers(DocumentSnapshot userData) {
    fullNameController.text = userData['FullName'] ?? '';
    emailController.text = userData['Email'] ?? '';
    phoneController.text = userData['Phone'] ?? '';
    addressController.text = userData['Address'] ?? '';
    postcodeController.text = userData['Postcode'] ?? '';
    cityController.text = userData['City'] ?? '';
    stateController.text = userData['State'] ?? '';
  }

  Future<void> updateProfile(BuildContext context) async {

    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .update({
          'FullName': fullNameController.text,
          'Email': emailController.text,
          'Phone': phoneController.text,
          'Address': addressController.text,
          'Postcode': postcodeController.text,
          'City': cityController.text,
          'State': stateController.text,
        });
        // Alert dialog to show success message
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Profile Updated'),
              content: const Text('Your profile has been updated successfully'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );

        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(191, 0, 6, 0.815),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot>(
          future: userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text('No user data found'));
            } else {
              populateControllers(snapshot.data!);
              return buildProfileForm();
            }
          },
        ),
      ),
    );
  }

  Widget buildProfileForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Form(
            child: Column(
              children: [
                MyTextField(
                  controller: fullNameController,
                  hintText: 'Full Name',
                  obscureText: false,
                  prefixIcon: Icons.person,
                  enabled: false,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                  prefixIcon: Icons.email,
                  enabled: false,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: phoneController,
                  hintText: 'Phone',
                  obscureText: false,
                  prefixIcon: Icons.phone,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: addressController,
                  hintText: 'Address',
                  obscureText: false,
                  prefixIcon: Icons.home,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: postcodeController,
                  hintText: 'Postcode',
                  obscureText: false,
                  prefixIcon: Icons.location_on,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: cityController,
                  hintText: 'City',
                  obscureText: false,
                  prefixIcon: Icons.location_city,
                ),
                SizedBox(height: 20),
                MyTextField(
                  controller: stateController,
                  hintText: 'State',
                  obscureText: false,
                  prefixIcon: Icons.location_history,
                ),
                SizedBox(height: 30),
                MyButton(
                  onTap: () => updateProfile(context),
                  buttonText: 'Update Profile',
                  isLoading: isLoading,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
