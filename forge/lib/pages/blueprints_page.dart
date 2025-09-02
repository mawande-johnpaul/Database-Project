import 'package:flutter/material.dart';

class BlueprintsPage extends StatefulWidget {
  const BlueprintsPage({super.key});

  @override
  State<BlueprintsPage> createState() => _BlueprintsPageState();
}

class _BlueprintsPageState extends State<BlueprintsPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Blueprints will be shown here.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}