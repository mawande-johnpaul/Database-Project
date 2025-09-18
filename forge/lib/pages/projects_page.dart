// ignore_for_file: dead_code

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forge/models/datasheet.dart';
import 'package:forge/models/io.dart';
import 'package:forge/pages/data_page.dart';
import 'package:forge/widgets/button.dart';
import 'package:forge/widgets/sec_button.dart';

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
    // Dummy list of saved projects for demonstration
    var savedProjects = getProjects(widget.appData);
    var isOpen = false;
    DataPage page = DataPage(dataset: null, dataFile: null);

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
                        writeJsonToFile(widget.appData);
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
          child: savedProjects.isNotEmpty & !isOpen
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
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  project.description.toString(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Button(
                                      icon: Icons.open_in_new_rounded,
                                      title: 'Open dataset',
                                      onPressed: () async {
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: ['csv'],
                                            );

                                        if (result != null) {
                                          // A file was selected.
                                          PlatformFile file =
                                              result.files.first;

                                          var dataset = Dataset(
                                            id: 1,
                                            name: file.name,
                                            description:
                                                "Olive oils and their fluorescence",
                                            type: "csv",
                                            path: file.path,
                                            projectId: project.id,
                                          );

                                          var datasetFile = getDataset(
                                            file.path!,
                                          );

                                          page = DataPage(
                                            dataset: dataset,
                                            dataFile: datasetFile,
                                          );
                                        } else {}
                                      },
                                    ),
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
  }
}
