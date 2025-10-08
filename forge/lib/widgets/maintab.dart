import 'package:flutter/material.dart';
import 'package:forge/pages/analytics_page.dart';
import 'package:forge/pages/editor_page.dart';
import 'package:forge/pages/projects_page.dart';

class Maintab extends StatefulWidget {
  Maintab({super.key, required this.selected, required this.appData});

  final int selected;
  late dynamic appData;

  @override
  State<Maintab> createState() => _MaintabState();
}

class _MaintabState extends State<Maintab> {
  @override
  Widget build(BuildContext context) {
    // The main tab content is built based on the parent's selected index.
    if (widget.appData == null) {
      return const Center(child: Text('Loading...'));
    }

    return IndexedStack(
      index: widget.selected,
      children: [
        ProjectsPage(appData: widget.appData, selected: widget.selected),
        Editor(initialCode: '# Your code here'),
        AnalyticsPage(),
        const Center(child: Text('Team Content')),
        const Center(child: Text('Settings Content')),
      ],
    );
  }
}
