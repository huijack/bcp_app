import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const MyCard({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
          
        ),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.red[900]),
                const SizedBox(height: 10),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.red[900],
                      height: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
