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
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).primaryColor,
          border: Border.all(color: Theme.of(context).primaryColor, width: 2.0)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            SizedBox(width: 5.0),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
