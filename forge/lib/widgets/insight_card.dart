import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withAlpha(70),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            style: TextStyle(fontSize: 32, color: Colors.white54),
          ),
          SizedBox(height: 10.0),
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
