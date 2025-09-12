import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold), // Consider theme for color
      ),
      style: ElevatedButton.styleFrom(
        // You can customize the button's appearance here
        backgroundColor: Theme.of(context).primaryColor, // Background color
        foregroundColor: Colors.black, // Text and icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // More generous padding
      ),
    );
  }
}