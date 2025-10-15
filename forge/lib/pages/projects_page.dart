// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:forge/models/datasheet.dart';
import 'package:forge/models/file_picker_service.dart';
import 'package:forge/models/io.dart';
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
  @override
  Widget build(BuildContext context) {
    // Use FutureBuilder to handle the asynchronous data fetching
    return FutureBuilder<List<Project>>(
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
        List<Project> savedProjects = snapshot.data!;
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
                onPressed: () {
                  //open a file manager window to select a csv file
                  try {
                    // Get file path and load dataset
                    final fileFuture = FilePickerService.pickFile(
                      allowMultiple: false,
                      allowedExtensions: ['csv'],
                    );
                    getDataset(fileFuture).then((dataset) {
                      if (dataset.isNotEmpty) {
                        // Create new project with the dataset
                        var newProject = Project(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: 'New Project',
                          description: 'A newly created project',
                        );

                        // Save the project and update UI
                        createProject(newProject).then((_) {
                          setState(() {
                            // This will trigger a rebuild and fetch projects again
                          });
                        });
                      }
                    });
                  } catch (e) {
                    debugPrint('Error importing CSV: $e');
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
                          // Create a new project with the imported CSV data
                          var newProject = Project(
                            id: DateTime.now().millisecondsSinceEpoch,
                            name: 'Project from CSV',
                            description: 'Imported from CSV file',
                          );

                          // Save the project to the database
                          await createProject(newProject);

                          // Create a dataset linked to this project
                          var dataset = Dataset(
                            id: DateTime.now().millisecondsSinceEpoch + 1,
                            name: 'Dataset from CSV',
                            description:
                                'Imported from ${filePath.split('\\').last}',
                            type: 'csv',
                            path: filePath,
                            projectId: newProject.id,
                          );

                          // Save the dataset with the file path
                          await createDataset(dataset, filePath);

                          // Refresh the state to show the new project
                          setState(() {
                            // This will trigger a rebuild and fetch projects again
                          });
                        } catch (e) {
                          debugPrint('Error importing CSV: $e');
                          // Show error message if needed
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
                                  Text(
                                    project.description.toString(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Button to open dataset removed (FilePicker dependency)
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
