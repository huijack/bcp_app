import 'package:flutter/material.dart';

class StatusCircle extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const StatusCircle({
    super.key,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
