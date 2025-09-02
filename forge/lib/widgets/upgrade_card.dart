import 'package:flutter/material.dart';

class UpgradeCard extends StatelessWidget {
  const UpgradeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            'Upgrade To Pro',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Get access to additional features and content',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
          SizedBox(height: 10),
          ElevatedButton(onPressed: () {}, child: Text('Upgrade')),
        ],
      ),
    );
  }
}
