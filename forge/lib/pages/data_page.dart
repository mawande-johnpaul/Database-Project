import 'package:flutter/material.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  // Dummy variable to represent if a project is open
  final bool hasProject = true; // Set to true to simulate open project
  final Map<String, dynamic> projectData = const {
    'name': 'Project Alpha',
    'description': 'A sample project',
    'created': '2025-08-29',
    'status': 'Active',
  };

  @override
  Widget build(BuildContext context) {
    if (!hasProject) {
      return Center(
        child: Text(
          'No project opened. Please open or create a project to view data.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Project: \\${projectData['name']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Description: \\${projectData['description']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Created: \\${projectData['created']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Status: \\${projectData['status']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
