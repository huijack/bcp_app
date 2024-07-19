import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../components/my_card.dart';
import 'blockA_status_page.dart';
import 'blockB_status_page.dart';
import 'blockC_status_page.dart';
import 'blockE_status_page.dart';
import 'blockG_status_page.dart';

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  void _blockA(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockAStatusPage(
            status: 'Pending',
          );
        },
      ),
    );
  }

  void _blockB(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockBStatusPage(
            status: 'Pending',
          );
        },
      ),
    );
  }

  void _blockC(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockCStatusPage(
            status: 'Pending',
          );
        },
      ),
    );
  }

  void _blockE(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockEStatusPage(
            status: 'Pending',
          );
        },
      ),
    );
  }

  void _blockG(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const BlockGStatusPage(
            status: 'Pending',
          );
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        title: const Text(
          'Pending Requests',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(191, 0, 6, 0.815),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            StreamBuilder<Map<String, int>>(
              stream: getPendingRequestCounts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final counts = snapshot.data ?? {};
                return GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                    MyCard(
                      icon: FontAwesomeIcons.question,
                      text: 'More Info',
                      onTap: () {},
                      requestCount: 0,
                    )
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
