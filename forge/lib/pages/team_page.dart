import 'package:flutter/material.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Team information will be shown here.',
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}