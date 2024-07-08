import 'package:bcp_app/components/my_expansiontile.dart';
import 'package:flutter/material.dart';

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'FAQ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(191, 0, 6, 0.815),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: const [
                  MyExpansionTile(
                    title: 'What is UCSI Report?',
                    content:
                        'UCSI Report is a platform for UCSI lecturers to submit maintenance requests for faulty equipment or facilities. The platform is designed to streamline the process of reporting issues and to ensure that they are resolved in a timely manner.',
                  ),
                  SizedBox(height: 16),
                  MyExpansionTile(
                    title: 'How do I submit a report?',
                    content:
                        'To submit a report, log in to the UCSI Report platform, click on "Submit a Request", fill in the required details about the issue, and submit the form. You can then track the status of your report by clicking "Track Request Status".',
                  ),
                  SizedBox(height: 16),
                  MyExpansionTile(
                    title: 'How long does it take to resolve an issue?',
                    content:
                        'Resolution times vary depending on the nature and complexity of the issue. Generally, we aim to address urgent matters within 24-48 hours and less critical issues within 3-5 business days. You will receive a notification once the issue has been resolved.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
