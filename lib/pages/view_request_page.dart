import 'package:flutter/material.dart';

class ViewPastRequestsPage extends StatelessWidget {
  const ViewPastRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        scrolledUnderElevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Center(
                child: const Text(
                  'Past Requests',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(191, 0, 6, 0.815),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
