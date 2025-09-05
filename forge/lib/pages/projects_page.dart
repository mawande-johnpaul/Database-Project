import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forge/models/io.dart';
import 'package:forge/widgets/button.dart';
import 'package:forge/widgets/sec_button.dart';
import 'package:forge/widgets/tr_button.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key, required this.appData});
  final dynamic appData;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  Future<void> _showCreateProjectDialog() async {
    final _formKey = GlobalKey<FormState>();
    String projectName = '';
    String projectDescription = '';

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
