import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _hasProfileData(Map<String, dynamic> userData) {
    return userData.containsKey('Phone') &&
            userData['Phone'] != null &&
            userData['Phone'].toString().isNotEmpty ||
        userData.containsKey('Address') &&
            userData['Address'] != null &&
            userData['Address'].toString().isNotEmpty ||
        userData.containsKey('Postcode') &&
            userData['Postcode'] != null &&
            userData['Postcode'].toString().isNotEmpty ||
        userData.containsKey('City') &&
            userData['City'] != null &&
            userData['City'].toString().isNotEmpty ||
        userData.containsKey('State') &&
            userData['State'] != null &&
            userData['State'].toString().isNotEmpty;
  }

  Widget _buildProfileHeader(String name, String email) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.red[900],
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          email,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildInfoCardIfPresent(
      String title, Map<String, dynamic> userData, IconData icon) {
    if (userData.containsKey(title) &&
        userData[title] != null &&
        userData[title].toString().isNotEmpty) {
      return Column(
        children: [
          _buildInfoCard(title, userData[title].toString(), icon),
          SizedBox(height: 16),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: Colors.red[900]),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No user profile data found'));
          }

          Map<String, dynamic> userData =
              snapshot.data!.data() as Map<String, dynamic>;

          bool hasProfileData = _hasProfileData(userData);

          return Column(
            children: [
              SizedBox(height: 40),
              _buildProfileHeader(
                  userData['FullName'] ?? 'N/A', userData['Email'] ?? 'N/A'),
              SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: !hasProfileData
                      ? Text(
                          'No profile data found',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoCardIfPresent(
                                    'Phone', userData, Icons.phone),
                                _buildInfoCardIfPresent(
                                    'Address', userData, Icons.home),
                                _buildInfoCardIfPresent(
                                    'Postcode', userData, Icons.location_on),
                                _buildInfoCardIfPresent(
                                    'City', userData, Icons.location_city),
                                _buildInfoCardIfPresent(
                                    'State', userData, Icons.map),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
