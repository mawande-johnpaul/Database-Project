import 'package:flutter/material.dart';
import 'package:forge/models/datasheet.dart';
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
  @override
  Widget build(BuildContext context) {
    // Dummy list of saved projects for demonstration
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
                onPressed: () {
                  var id, name, description, team;
                  if (savedProjects.isNotEmpty()) {
                    id = 1;
                  } else {
                    id = savedProjects.length() + 1;
                  }
                  Project(
                    id: id,
                    name: name,
                    description: description,
                    team: team,
                    datasets: [],
                    blueprints: [],
                  );
                },
              ),
              const SizedBox(width: 12),
              SecButton(
                icon: Icons.folder_open,
                title: 'Open',
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              SecButton(
                icon: Icons.group_add_rounded,
                title: 'New team',
                onPressed: () {},
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
                        title: Text((project.name).toString()),
                        subtitle: Text((project.description).toString()),
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
                    onPressed: () {},
                  ),
                ),
        ),
      ],
    );
  }
}
