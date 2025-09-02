import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profile'),
          subtitle: const Text('Edit your profile information'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          subtitle: const Text('Choose light or dark mode'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          subtitle: const Text('Manage notification preferences'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          subtitle: const Text('App version and info'),
          onTap: () {},
        ),
      ],
    );
  }
}