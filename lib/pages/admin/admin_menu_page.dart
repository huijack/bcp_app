import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bcp_app/components/my_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'blockA_page.dart';
import 'blockB_page.dart';
import 'blockC_page.dart';
import 'blockE_page.dart';
import 'blockG_page.dart';

class AdminMenuPage extends StatefulWidget {
  const AdminMenuPage({super.key});

  @override
  State<AdminMenuPage> createState() => _AdminMenuPageState();
}

class _AdminMenuPageState extends State<AdminMenuPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _blockA(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockAPage();
        },
      ),
    );
  }

  void _blockB(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return BlockBPage();
        },
      ),
    );
  }

  void _blockC(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockCPage();
        },
      ),
    );
  }

  void _blockE(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockEPage();
        },
      ),
    );
  }

  void _blockG(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockGPage();
        },
      ),
    );
  }

  Stream<Map<String, int>> getPendingRequestCounts() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value({});
    }

    final userId = user.uid;

    return FirebaseFirestore.instance
        .collection('Admin')
        .doc(userId)
        .get()
        .asStream()
        .asyncExpand((adminDoc) {
      if (adminDoc.exists) {
        return FirebaseFirestore.instance
            .collection('Request')
            .where('Status', isEqualTo: 'Pending')
            .snapshots()
            .map((snapshot) {
          Map<String, int> counts = {
            'Block A': 0,
            'Block B': 0,
            'Block C': 0,
            'Block E': 0,
            'Block G': 0,
          };
          for (var doc in snapshot.docs) {
            String building = doc['Building'];
            counts[building] = (counts[building] ?? 0) + 1;
          }
          return counts;
        });
      } else {
        return Stream.value({});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); 

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Pending Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[900],
              ),
            ),
            const SizedBox(height: 10),
            StreamBuilder<Map<String, int>>(
              stream: getPendingRequestCounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final counts = snapshot.data ?? {};
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    MyCard(
                      icon: FontAwesomeIcons.a,
                      text: 'Block A',
                      onTap: () => _blockA(context),
                      requestCount: counts['Block A'] ?? 0,
                    ),
                    MyCard(
                      icon: FontAwesomeIcons.b,
                      text: 'Block B',
                      onTap: () => _blockB(context),
                      requestCount: counts['Block B'] ?? 0,
                    ),
                    MyCard(
                      icon: FontAwesomeIcons.c,
                      text: 'Block C',
                      onTap: () => _blockC(context),
                      requestCount: counts['Block C'] ?? 0,
                    ),
                    MyCard(
                      icon: FontAwesomeIcons.e,
                      text: 'Block E',
                      onTap: () => _blockE(context),
                      requestCount: counts['Block E'] ?? 0,
                    ),
                    MyCard(
                      icon: FontAwesomeIcons.g,
                      text: 'Block G',
                      onTap: () => _blockG(context),
                      requestCount: counts['Block G'] ?? 0,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
