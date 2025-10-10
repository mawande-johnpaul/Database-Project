// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:forge/models/datasheet.dart';
import 'package:forge/models/io.dart';
import 'package:forge/pages/data_page.dart';
import 'package:forge/widgets/button.dart';
import 'package:forge/widgets/sec_button.dart';
// import 'package:get/utils.dart';
// import 'package:file_picker/file_picker.dart';

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
                teamId: item['team_id'],
              ),
            )
            .toList();
      }),
      builder: (context, snapshot) {
        List<Project> savedProjects = snapshot.data!;

        var isOpen = false;
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
                  
                  var newProject = Project(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: 'New Project',
                    description: 'A newly created project',
                    teamId: 1, // Default team ID
                  );
                  setState(() {
                    savedProjects.add(newProject);
                  });

                  isOpen = true;
                },
              ),
            ],
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: !isOpen
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Button(
                          icon: Icons.add_rounded,
                          title: 'Create',
                          onPressed: () {
                            var newProject = Project(
                              id: DateTime.now().millisecondsSinceEpoch,
                              name: 'New Project',
                              description: 'A newly created project',
                              teamId: 1, // Default team ID
                            );
                            setState(() {
                              savedProjects.add(newProject);
                            });

                            isOpen = true;
                          },
                        ),
                        const SizedBox(width: 12),
                        SecButton(
                          icon: Icons.folder_open,
                          title: 'Open',
                          onPressed: () {
                            isOpen = true;
                          },
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            //TODO: Empty cells
                          },
                          icon: Icon(Icons.cancel_presentation_outlined),
                        ),
                        IconButton(
                          onPressed: () {
                            //TODO: Outliers
                          },
                          icon: Icon(Icons.outlined_flag_rounded),
                        ),
                        IconButton(
                          onPressed: () {
                            //TODO: case lowering
                          },
                          icon: Icon(Icons.abc_rounded),
                        ),
                        IconButton(
                          onPressed: () {
                            //TODO: Empty cells
                          },
                          icon: Icon(Icons.cancel_presentation_outlined),
                        ),
                      ],
                    ),
            ),
            Expanded(
              child: savedProjects.isEmpty && !isOpen
                  ? ListView.builder(
                      //PROJECT CARDS
                      itemCount: savedProjects.length,
                      itemBuilder: (context, index) {
                        final project = savedProjects[index];
                        return GestureDetector(
                          onTap: () {
                            widget.selected = 1;
                          },
                          child: Card(
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
                              onTap: () {
                                // TODO: Open this project
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
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
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
