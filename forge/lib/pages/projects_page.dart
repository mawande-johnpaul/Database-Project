// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:forge/models/datasheet.dart' hide Column;
import 'package:forge/models/file_picker_service.dart';
import 'package:forge/models/io.dart';
import 'package:forge/models/sqflite_service.dart';
import 'package:forge/pages/data_page.dart';
import 'package:forge/widgets/button.dart';
import 'package:forge/widgets/sec_button.dart';
// import 'package:get/utils.dart';
import 'package:file_picker/file_picker.dart';

class ProjectsPage extends StatefulWidget {
  ProjectsPage({super.key, required this.appData, required this.selected});
  final dynamic appData;
  int selected;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  Future<Map<String, String>?> _showProjectDetailsDialog(
    BuildContext context,
  ) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Project Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Project Name'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Project Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'description': descController.text,
                });
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>?> _showDatasetDetailsDialog(
    BuildContext context,
  ) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Dataset Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Dataset Name'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Dataset Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(null),
            ),
            TextButton(
              child: Text('Continue'),
              onPressed: () {
                Navigator.of(context).pop({
                  'name': nameController.text,
                  'description': descController.text,
                });
              },
            ),
          ],
        );
      },
    );
  }

  int _refreshKey = 0;

  void _triggerRefresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to handle the asynchronous data fetching
    return FutureBuilder<List<Project>>(
      key: ValueKey(_refreshKey),
      future: getProjects().then((data) {
        return data
            .map(
              (item) => Project(
                id: item['id'],
                name: item['name'],
                description: item['description'],
              ),
            )
            .toList();
      }),
      builder: (context, snapshot) {
        List<Project> savedProjects = snapshot.data ?? [];
        DataPage page = DataPage(dataset: null, dataFile: null);

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: Text('No projects found.')),
              SizedBox(height: 20),
              Button(
                icon: Icons.add_rounded,
                title: "Create project",
                onPressed: () async {
                  final filePath = await FilePickerService.pickFile(
                    allowMultiple: false,
                    allowedExtensions: ['csv'],
                  );
                  if (filePath != null) {
                    try {
                      // Show saving project dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Creating Project'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Creating new project...'),
                              ],
                            ),
                          );
                        },
                      );
                      final projectDetails = await _showProjectDetailsDialog(
                        context,
                      );
                      if (projectDetails == null) return;
                      var newProject = Project(
                        id: DateTime.now().millisecondsSinceEpoch,
                        name: projectDetails['name'] ?? '',
                        description: projectDetails['description'] ?? '',
                      );
                      await createProject(newProject);
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Importing Dataset'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text('Importing dataset from CSV...'),
                              ],
                            ),
                          );
                        },
                      );
                      final datasetDetails = await _showDatasetDetailsDialog(
                        context,
                      );
                      if (datasetDetails == null) return;
                      var dataset = Dataset(
                        id: DateTime.now().millisecondsSinceEpoch + 1,
                        name: datasetDetails['name'] ?? '',
                        description: datasetDetails['description'] ?? '',
                        type: 'csv',
                        path: filePath,
                        projectId: newProject.id,
                      );
                      await createDataset(dataset, filePath);
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Success'),
                            content: Text(
                              'Project and dataset created successfully.',
                            ),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                      setState(() {});
                    } catch (e) {
                      debugPrint('Error importing CSV: $e');
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text(
                              'Failed to create project or import dataset: ${e.toString()}',
                            ),
                            actions: [
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ],
          );
        }
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Button(
                    icon: Icons.add_rounded,
                    title: 'Create',
                    onPressed: () async {
                      // Open file picker to select a CSV file
                      final filePath = await FilePickerService.pickFile(
                        allowMultiple: false,
                        allowedExtensions: ['csv'],
                      );

                      if (filePath != null) {
                        try {
                          // Show saving project dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Creating Project'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Creating new project...'),
                                  ],
                                ),
                              );
                            },
                          );

                          // Create a new project with the imported CSV data
                          _showProjectDetailsDialog(context).then((
                            projectDetails,
                          ) {
                            if (projectDetails == null) return;

                            var newProject = Project(
                              id: DateTime.now().millisecondsSinceEpoch,
                              name: projectDetails['name'] ?? '',
                              description: projectDetails['description'] ?? '',
                            );

                            // Save the project to the database
                            createProject(newProject).then((_) {
                              // Hide the project creation dialog
                              Navigator.of(context).pop();

                              // Show dataset import dialog
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Importing Dataset'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(height: 16),
                                        Text('Importing dataset from CSV...'),
                                      ],
                                    ),
                                  );
                                },
                              );

                              // After picking file, before creating dataset:
                              _showDatasetDetailsDialog(context).then((
                                datasetDetails,
                              ) {
                                if (datasetDetails == null) return;

                                // Create a dataset linked to this project
                                var dataset = Dataset(
                                  id: DateTime.now().millisecondsSinceEpoch + 1,
                                  name: datasetDetails['name'] ?? '',
                                  description:
                                      datasetDetails['description'] ?? '',
                                  type: 'csv',
                                  path: filePath,
                                  projectId: newProject.id,
                                );

                                // Save the dataset with the file path
                                createDataset(dataset, filePath).then((_) {
                                  // Hide the dataset import dialog
                                  Navigator.of(context).pop();

                                  // Show success message
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Success'),
                                        content: Text(
                                          'Project and dataset created successfully.',
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('OK'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  // Refresh the state to show the new project
                                  setState(() {
                                    // This will trigger a rebuild and fetch projects again
                                  });
                                });
                              });
                            });
                          });
                        } catch (e) {
                          debugPrint('Error importing CSV: $e');
                          // Show error dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Error'),
                                content: Text(
                                  'Failed to create project or import dataset: ${e.toString()}',
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  SecButton(
                    icon: Icons.folder_open,
                    title: 'Open',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              child: savedProjects.isNotEmpty
                  ? ListView.builder(
                      //PROJECT CARDS
                      itemCount: savedProjects.length,
                      itemBuilder: (context, index) {
                        final project = savedProjects[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.black, width: 1),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              // Set selected tab to data tab
                              widget.selected = 1;

                              try {
                                // Get datasets linked to this project
                                final datasets = await getDatasetsByProject(
                                  project.id,
                                );

                                if (datasets.isNotEmpty) {
                                  // Use the first dataset found
                                  final dataset = datasets.first;

                                  // Navigate to data page with the dataset and its file path
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => DataPage(
                                        dataset: dataset,
                                        dataFile: dataset.path != null
                                            ? getDataset(
                                                Future.value(dataset.path),
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                } else {
                                  // If no datasets found, create a basic dataset from project
                                  final dataset = Dataset(
                                    id: project.id,
                                    name: project.name,
                                    description: project.description,
                                    projectId: project.id,
                                  );

                                  // Navigate to data page
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => DataPage(
                                        dataset: dataset,
                                        dataFile: null,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint('Error loading datasets: $e');
                                // Fallback to basic navigation
                                final dataset = Dataset(
                                  id: project.id,
                                  name: project.name,
                                  description: project.description,
                                );

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DataPage(
                                      dataset: dataset,
                                      dataFile: null,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.name.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  FutureBuilder<List<Dataset>>(
                                    future: getDatasetsByProject(project.id),
                                    builder: (context, dsSnap) {
                                      String datasetTitle = '';
                                      if (dsSnap.hasData &&
                                          dsSnap.data!.isNotEmpty) {
                                        datasetTitle = dsSnap.data!.first.name;
                                      }
                                      return Text(
                                        datasetTitle,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        child: Text('Edit'),
                                        onPressed: () {
                                          // TODO: Implement edit dialog if needed
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () async {
                                          await SqfliteService.deleteProject(
                                            project.id,
                                          );
                                          // Remove from appData if present
                                          if (widget.appData != null &&
                                              widget.appData['projects'] !=
                                                  null) {
                                            widget.appData['projects']
                                                .removeWhere(
                                                  (p) => p['id'] == project.id,
                                                );
                                          }
                                          _triggerRefresh();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : page,
            ),
          ],
        );
      },
    );
  }
}
