import 'package:flutter/material.dart';
import 'package:forge/pages/analytics_page.dart';
import 'package:forge/pages/data_page.dart';
import 'package:forge/pages/editor_page.dart';
import 'package:forge/pages/projects_page.dart';

class Maintab extends StatefulWidget {
  Maintab({super.key, required this.selected, required this.appData});

  final int selected;
  late Map<String, dynamic> appData;

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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
    
    return IndexedStack(
      index: widget.selected,
      children: [
        ProjectsPage(appData: widget.appData,),
        DataPage(),
        Editor(initialCode: '# Your code here',),
        AnalyticsPage(),
        const Center(child: Text('Blueprints Content')),
        const Center(child: Text('Team Content')),
        const Center(child: Text('Settings Content')),
      ],
=======
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

    // Wrap the main tab content in a DatasetScope so all tab pages can access
    // the currently selected dataset and its file without requiring explicit
    // constructor parameters.
    return DatasetScope(
      child: IndexedStack(
        index: widget.selected,
        children: [
          ProjectsPage(appData: widget.appData, selected: widget.selected),
          Editor(initialCode: '# Your code here'),
          DataPage(),
          const Center(child: Text('Team Content')),
          const Center(child: Text('Settings Content')),
        ],
      ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    );
  }
}
