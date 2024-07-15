import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyAdminNavBar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int)? onTabChange;

  MyAdminNavBar({super.key, required this.onTabChange, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GNav(
        color: const Color.fromRGBO(0, 0, 0, 50),
        activeColor: Colors.red[900],
        tabBackgroundColor: Colors.grey.shade100,
        mainAxisAlignment: MainAxisAlignment.center,
        gap: 8,
        tabBorderRadius: 16,
        selectedIndex: selectedIndex,
        onTabChange: (value) => onTabChange!(value),
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.history,
            text: 'History',
          ),
        ],
      ),
    );
  }
}
