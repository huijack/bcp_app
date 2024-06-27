import 'package:flutter/material.dart';

class MyDropdown extends StatefulWidget {
  final IconData prefixIcon;
  final String hintText;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged; // Callback to notify changes

  const MyDropdown({
    super.key,
    required this.prefixIcon,
    required this.hintText,
    required this.items,
    required this.onChanged,
  });

  @override
  MyDropdownState createState() => MyDropdownState();
}

class MyDropdownState extends State<MyDropdown> {
  String? _selectedValue; // State variable to hold the selected value

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(240, 240, 240, 100),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon: Icon(widget.prefixIcon),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            hintText: widget.hintText,
          ),
          value: _selectedValue, // Current selected value
          items: widget.items, // Dropdown items
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
            widget.onChanged(value); // Notify parent widget of the change
          },
        ),
      ),
    );
  }
}
