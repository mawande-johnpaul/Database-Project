import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final bool isExpanded;
  const Logo({super.key, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Icon(Icons.qr_code_rounded, weight: 700),
          ),
          SizedBox(width: isExpanded ? 10.0 : 0),
          isExpanded
              ? Text(
                  'FORGE',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                    fontFamily: 'RobotoCondensed',
                    color: Colors.white54,
                  ),
                )
              : SizedBox(width: 0),
        ],
      ),
    );
  }
}
