import 'package:flutter/material.dart';
<<<<<<< Updated upstream
=======
import 'package:forge/models/datasheet.dart';
import 'package:forge/models/io.dart';
import 'package:forge/models/file_picker_service.dart';
import 'package:forge/widgets/button.dart';
import 'package:pluto_grid/pluto_grid.dart';
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
<<<<<<< Updated upstream
  //TODO: Add proper project data
  final bool hasProject = true; // Set to true to simulate open project
  final Map<String, dynamic> projectData = const {
    'name': 'Project Alpha',
    'description': 'A sample project',
    'created': '2025-08-29',
    'status': 'Active',
  };
=======
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  bool isLoading = true;
  List<String> columnNames = [];
  List<List<String>> data = [];
  Map<String, int> nullCellsPerColumn = {};
  Map<String, String> columnDataTypes = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If dataset/dataFile were not passed in, try to read from DatasetScope
    final scope = DatasetScope.of(context);
    if ((widget.dataset == null || widget.dataFile == null) && scope != null) {
      setState(() {
        if (widget.dataset == null) widget.dataset = scope.dataset;
        if (widget.dataFile == null) widget.dataFile = scope.dataFile;
      });
    }
    // Load data now that dataset may have been provided
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.dataset == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // If dataFile is provided, use it directly
      List<String> csvData = [];
      if (widget.dataFile != null) {
        csvData = await widget.dataFile!;
      } else {
        // Try to load dataset from the database using project ID
        String? filePath;

        if (widget.dataset!.path != null) {
          // If dataset already has a path, use it
          filePath = widget.dataset!.path;
        } else if (widget.dataset!.projectId != null) {
          // Otherwise, try to find datasets linked to this project
          final datasets = await getDatasetsByProject(
            widget.dataset!.projectId!,
          );
          if (datasets.isNotEmpty) {
            // Use the first dataset found
            filePath = datasets.first.path;
          }
        }

        // If we have a file path, load the dataset
        if (filePath != null) {
          csvData = await getDataset(Future.value(filePath));
        }
      }

      if (csvData.isNotEmpty) {
        // Parse CSV data
        _parseCSVData(csvData);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _parseCSVData(List<String> csvData) {
    // Parse header row to get column names
    if (csvData.isNotEmpty) {
      final headerRow = csvData[0].split(',');
      columnNames = headerRow.map((name) => name.trim()).toList();

      // Create PlutoGrid columns
      columns = columnNames.map((name) {
        return PlutoColumn(
          title: name,
          field: name,
          type: PlutoColumnType.text(),
        );
      }).toList();

      // Parse data rows
      data = [];
      for (int i = 1; i < csvData.length; i++) {
        if (csvData[i].trim().isNotEmpty) {
          final rowValues = csvData[i].split(',');
          data.add(rowValues.map((value) => value.trim()).toList());
        }
      }

      // Create PlutoGrid rows
      rows = [];
      for (var rowData in data) {
        final Map<String, PlutoCell> cells = {};

        for (int i = 0; i < columnNames.length && i < rowData.length; i++) {
          cells[columnNames[i]] = PlutoCell(value: rowData[i]);
        }

        rows.add(PlutoRow(cells: cells));
      }
    }
  }
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
          //TODO: Add more project data visualizations
          //TODO: Button to import data
        ],
=======
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.dataset!.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            // Data table
            Column(
              children: [
                Text(
                  'Data Preview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: PlutoGrid(
                    columns: columns,
                    rows: rows,
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      // You can access the grid controller via event.gridController
                    },
                    configuration: PlutoGridConfiguration(
                      columnFilter: PlutoGridColumnFilterConfig(
                        filters: const [...FilterHelper.defaultFilters],
                      ),
                    ),
                  ),
                ),
              ],
            ),
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
      ),
    );
  }
}
