import 'package:flutter/material.dart';

class AssignButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String buttonText;
  final bool isLoading;

  const AssignButton({
    Key? key,
    required this.onTap,
    required this.buttonText,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onTap,
      style: TextButton.styleFrom(
        backgroundColor: const Color.fromRGBO(191, 0, 7, 1),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Container(
        width: double.infinity,
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}