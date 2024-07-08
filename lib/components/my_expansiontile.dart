import 'package:flutter/material.dart';

class MyExpansionTile extends StatelessWidget {
  final String title;
  final String content;

  const MyExpansionTile(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(191, 0, 6, 0.815),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
          backgroundColor: Colors.grey[50],
          collapsedBackgroundColor: Colors.white,
          iconColor: const Color.fromRGBO(191, 0, 6, 0.815),
          collapsedIconColor: Colors.grey,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
