import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forge/models/io.dart';
import 'package:forge/widgets/button.dart';
import 'package:forge/widgets/sec_button.dart';
<<<<<<< Updated upstream
import 'package:forge/widgets/tr_button.dart';
=======
// import 'package:get/utils.dart';
>>>>>>> Stashed changes

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key, required this.appData});
  final dynamic appData;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

// A small stateful scope that holds the currently selected Dataset and its dataFile
// so other pages can access them without needing them passed explicitly.
class DatasetScope extends StatefulWidget {
  const DatasetScope({super.key, required this.child});
  final Widget child;

  static DatasetScopeState? of(BuildContext context) =>
      context.findAncestorStateOfType<DatasetScopeState>();

  @override
  DatasetScopeState createState() => DatasetScopeState();
}

class DatasetScopeState extends State<DatasetScope> {
  Dataset? dataset;
  Future<List<String>>? dataFile;

  void setDataset(Dataset? ds, [Future<List<String>>? df]) {
    setState(() {
      dataset = ds;
      dataFile = df;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ProjectsPageState extends State<ProjectsPage> {
  Future<void> _showCreateProjectDialog() async {
    final _formKey = GlobalKey<FormState>();
    String projectName = '';
    String projectDescription = '';

<<<<<<< Updated upstream
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a new project'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Project Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a project name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    projectName = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Project Description',
=======
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
                  // Ask user for project name/description before optionally importing CSV
                  final nameController = TextEditingController();
                  final descController = TextEditingController();

                  final create = await showDialog<bool?>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Create project'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Project name',
                            ),
                          ),
                          TextField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: 'Description (optional)',
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (nameController.text.trim().isEmpty) {
                              // simple validation: require a name
                              return;
                            }
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  );

                  if (create != true) return;

                  // Create project now
                  final newProject = Project(
                    id: DateTime.now().millisecondsSinceEpoch,
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                  );

                  await createProject(newProject);

                  // Optionally import CSV immediately
                  final importCsv = await showDialog<bool?>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Import CSV?'),
                      content: const Text('Would you like to import a CSV to create a dataset for this project now?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('No'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );

                  if (importCsv == true) {
                    try {
                      final filePath = await FilePickerService.pickFile(
                        allowMultiple: false,
                        allowedExtensions: ['csv'],
                      );

                      if (filePath != null) {
                        // Ask for dataset metadata
                        final dsNameController = TextEditingController(text: '${newProject.name} dataset');
                        final dsDescController = TextEditingController(text: 'Imported from ${filePath.split('\\').last}');

                        final dsCreate = await showDialog<bool?>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Dataset info'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: dsNameController,
                                  decoration: const InputDecoration(labelText: 'Dataset name'),
                                ),
                                TextField(
                                  controller: dsDescController,
                                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Create')),
                            ],
                          ),
                        );

                        if (dsCreate == true) {
                          final dataset = Dataset(
                            id: DateTime.now().millisecondsSinceEpoch + 1,
                            name: dsNameController.text.trim(),
                            description: dsDescController.text.trim(),
                            type: 'csv',
                            path: filePath,
                            projectId: newProject.id,
                          );

                          await createDataset(dataset, filePath);
                        }
                      }
                    } catch (e) {
                      debugPrint('Error importing CSV: $e');
                    }
                  }

                  setState(() {});
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

                      if (filePath == null) return;

                      try {
                        // Ask for project metadata
                        final projNameCtrl = TextEditingController(text: filePath.split('\\').last.replaceAll('.csv', ''));
                        final projDescCtrl = TextEditingController();

                        final projCreate = await showDialog<bool?>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Project info'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: projNameCtrl, decoration: const InputDecoration(labelText: 'Project name')),
                                TextField(controller: projDescCtrl, decoration: const InputDecoration(labelText: 'Description (optional)')),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () {
                                if (projNameCtrl.text.trim().isEmpty) return; // require name
                                Navigator.of(context).pop(true);
                              }, child: const Text('Create')),
                            ],
                          ),
                        );

                        if (projCreate != true) return;

                        final newProject = Project(
                          id: DateTime.now().millisecondsSinceEpoch,
                          name: projNameCtrl.text.trim(),
                          description: projDescCtrl.text.trim(),
                        );

                        // Save the project to the database
                        await createProject(newProject);

                        // Ask for dataset metadata
                        final dsNameCtrl = TextEditingController(text: '${newProject.name} dataset');
                        final dsDescCtrl = TextEditingController(text: 'Imported from ${filePath.split('\\').last}');

                        final dsCreate = await showDialog<bool?>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Dataset info'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(controller: dsNameCtrl, decoration: const InputDecoration(labelText: 'Dataset name')),
                                TextField(controller: dsDescCtrl, decoration: const InputDecoration(labelText: 'Description (optional)')),
                              ],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () {
                                if (dsNameCtrl.text.trim().isEmpty) return; // require dataset name
                                Navigator.of(context).pop(true);
                              }, child: const Text('Create')),
                            ],
                          ),
                        );

                        if (dsCreate == true) {
                          final dataset = Dataset(
                            id: DateTime.now().millisecondsSinceEpoch + 1,
                            name: dsNameCtrl.text.trim(),
                            description: dsDescCtrl.text.trim(),
                            type: 'csv',
                            path: filePath,
                            projectId: newProject.id,
                          );

                          // Save the dataset with the file path
                          await createDataset(dataset, filePath);
                        }

                        // Refresh the state to show the new project
                        setState(() {});
                      } catch (e) {
                        debugPrint('Error importing CSV: $e');
                      }
                    },
>>>>>>> Stashed changes
                  ),
                  onSaved: (value) {
                    projectDescription = value!;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  String? selectedDirectory = await FilePicker.platform
                      .getDirectoryPath();

                  if (selectedDirectory != null) {
                    final projectDir = Directory(
                      '$selectedDirectory/$projectName',
                    );
                    await projectDir.create();

<<<<<<< Updated upstream
                    final dbDir = Directory('${projectDir.path}/db');
                    await dbDir.create();

                    final forgeFile = File(
                      '${projectDir.path}/$projectName.forge',
                    );
                    final projectData = {
                      'name': projectName,
                      'description': projectDescription,
                      'createdAt': DateTime.now().toIso8601String(),
                    };
                    await forgeFile.writeAsString(jsonEncode(projectData));

                    setState(() {
                      widget.appData['projects'].add(projectData);
                    });
                    writeJsonToFile(widget.appData);

                    Navigator.of(context).pop();
                  }
                }
              },
=======
                                  // Set dataset in shared scope so other pages can access it
                                  final scope = DatasetScope.of(context);
                                  if (scope != null) {
                                    scope.setDataset(dataset, dataset.path != null ? getDataset(Future.value(dataset.path)) : null);
                                  }

                                  // Navigate to data page with the dataset
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => DataPage(dataset: dataset),
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

                                  // Set dataset in scope and navigate
                                  final scope = DatasetScope.of(context);
                                  if (scope != null) {
                                    scope.setDataset(dataset, null);
                                  }

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => DataPage(dataset: dataset),
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

                                // Set dataset in scope and navigate
                                final scope = DatasetScope.of(context);
                                if (scope != null) {
                                  scope.setDataset(dataset, null);
                                }

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DataPage(dataset: dataset),
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
>>>>>>> Stashed changes
            ),
          ],
        );
      },
    );
  }

  Future<void> _openProject() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['forge'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      final projectData = jsonDecode(await file.readAsString());

      // TODO: Open the project
    }
  }

  @override
  Widget build(BuildContext context) {
    var savedProjects = getProjects(widget.appData);

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
                onPressed: _showCreateProjectDialog,
              ),
              const SizedBox(width: 12),
              SecButton(
                icon: Icons.folder_open,
                title: 'Open',
                onPressed: _openProject,
              ),
              const SizedBox(width: 12),
              SecButton(
                icon: Icons.group_add_rounded,
                title: 'New team',
                onPressed: () {
                  //TODO: Dialog for team options
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: savedProjects.isNotEmpty
              ? ListView.builder(
                  itemCount: savedProjects.length,
                  itemBuilder: (context, index) {
                    final project = savedProjects[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text((project['name']).toString()),
                        subtitle: Text((project['description']).toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            // TODO: Open this project
                          },
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: TrButton(
                    icon: Icons.add_rounded,
                    title: 'Create a new project here',
                    onPressed: _showCreateProjectDialog,
                  ),
                ),
        ),
      ],
    );
  }
}
