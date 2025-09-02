import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 18, 0, 10),
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
    );
  }
}
