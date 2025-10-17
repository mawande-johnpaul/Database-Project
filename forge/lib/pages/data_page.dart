import 'package:flutter/material.dart';
import 'package:forge/models/datasheet.dart' hide Column;
import 'package:forge/models/io.dart';
import 'package:forge/models/file_picker_service.dart';
import 'package:forge/widgets/button.dart';
import 'package:pluto_grid/pluto_grid.dart';

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}

class DataPage extends StatefulWidget {
  Dataset? dataset;
  Future<List<String>>? dataFile;
  DataPage({super.key, this.dataset, this.dataFile});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
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

      // Analyze data for visualizations
      _analyzeData();
    }
  }

  void _analyzeData() {
    // Reset analysis data
    nullCellsPerColumn = {};
    columnDataTypes = {};

    // Initialize counters for null/empty cells
    for (var column in columnNames) {
      nullCellsPerColumn[column] = 0;
    }

    // Analyze each column
    for (int colIndex = 0; colIndex < columnNames.length; colIndex++) {
      String columnName = columnNames[colIndex];
      List<String> columnValues = [];

      // Collect all values for this column
      for (var row in data) {
        if (colIndex < row.length) {
          String value = row[colIndex];
          columnValues.add(value);

          // Count null/empty cells
          if (value.isEmpty) {
            nullCellsPerColumn[columnName] =
                (nullCellsPerColumn[columnName] ?? 0) + 1;
          }
        }
      }

      // Determine column data type
      columnDataTypes[columnName] = _determineColumnType(columnValues);
    }
  }

  // Calculate total number of rows
  int get totalRows => data.length;

  // Calculate total number of columns
  int get totalColumns => columnNames.length;

  // Calculate total number of cells
  int get totalCells => totalRows * totalColumns;

  // Calculate total number of empty cells
  int get totalEmptyCells =>
      nullCellsPerColumn.values.fold(0, (sum, count) => sum + count);

  // Calculate percentage of empty cells
  double get emptyPercentage =>
      totalCells > 0 ? (totalEmptyCells / totalCells) * 100 : 0;

  // Get column with most empty cells
  String get columnWithMostEmptyCells {
    if (nullCellsPerColumn.isEmpty) return "None";
    return nullCellsPerColumn.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  // Count columns by data type
  Map<String, int> get dataTypeDistribution {
    Map<String, int> distribution = {'numeric': 0, 'datetime': 0, 'text': 0};
    columnDataTypes.values.forEach((type) {
      distribution[type] = (distribution[type] ?? 0) + 1;
    });
    return distribution;
  }

  String _determineColumnType(List<String> values) {
    bool couldBeNumeric = true;
    bool couldBeDateTime = true;

    for (var value in values) {
      if (value.isEmpty) continue;

      // Check if numeric
      if (couldBeNumeric) {
        if (double.tryParse(value) == null) {
          couldBeNumeric = false;
        }
      }

      // Check if date/time (simple check)
      if (couldBeDateTime) {
        if (DateTime.tryParse(value) == null) {
          couldBeDateTime = false;
        }
      }

      // If neither, break early
      if (!couldBeNumeric && !couldBeDateTime) {
        break;
      }
    }

    if (couldBeNumeric) return 'numeric';
    if (couldBeDateTime) return 'datetime';
    return 'text';
  }

  // Helper method to build insight card
  Widget _buildInsightCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.dataset == null || columns.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.dataset?.name ?? 'Data Viewer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No dataset opened. Please open one',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Button(
                  icon: Icons.open_in_new_rounded,
                  title: 'Open dataset',
                  onPressed: () async {
                    // Open file picker to select a CSV file
                    final filePath = await FilePickerService.pickFile(
                      allowMultiple: false,
                      allowedExtensions: ['csv'],
                    );

                    if (filePath != null) {
                      try {
                        // Load the dataset from the selected file
                        final csvData = await getDataset(
                          Future.value(filePath),
                        );

                        // Update the dataset path if it exists
                        if (widget.dataset != null) {
                          // Create a dataset with the file path
                          final updatedDataset = Dataset(
                            id: widget.dataset!.id,
                            name: widget.dataset!.name,
                            description: widget.dataset!.description,
                            type: 'csv',
                            path: filePath,
                            projectId: widget.dataset!.projectId,
                          );

                          // Save the dataset with the file path if it has a project ID
                          if (updatedDataset.projectId != null) {
                            await createDataset(updatedDataset, filePath);
                          }

                          // Update the widget dataset
                          widget.dataset = updatedDataset;
                        }

                        // Parse the CSV data
                        _parseCSVData(csvData);

                        // Update the UI
                        setState(() {});
                      } catch (e) {
                        print('Error loading dataset: $e');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.dataset!.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Insights', icon: Icon(Icons.insights)),
              Tab(text: 'Preview', icon: Icon(Icons.table_chart)),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TabBarView(
            children: [
              // Insights Tab
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dataset!.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Dataset Insights',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 800,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GridView.count(
                                crossAxisCount: 3,
                                childAspectRatio: 2.0,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                children: [
                                  _buildInsightCard(
                                    'Total Rows',
                                    totalRows.toString(),
                                    Icons.table_rows,
                                    Colors.blue,
                                  ),
                                  _buildInsightCard(
                                    'Total Columns',
                                    totalColumns.toString(),
                                    Icons.view_column,
                                    Colors.green,
                                  ),
                                  _buildInsightCard(
                                    'Empty Cells',
                                    '$totalEmptyCells (${emptyPercentage.toStringAsFixed(1)}%)',
                                    Icons.space_bar,
                                    Colors.orange,
                                  ),
                                  _buildInsightCard(
                                    'Most Empty Column',
                                    columnWithMostEmptyCells,
                                    Icons.warning_amber,
                                    Colors.red,
                                  ),
                                  _buildInsightCard(
                                    'Numeric Columns',
                                    dataTypeDistribution['numeric'].toString(),
                                    Icons.numbers,
                                    Colors.purple,
                                  ),
                                  _buildInsightCard(
                                    'Text Columns',
                                    dataTypeDistribution['text'].toString(),
                                    Icons.text_fields,
                                    Colors.teal,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Data Preview Tab
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: PlutoGrid(
                  columns: columns,
                  rows: rows,
                  onLoaded: (PlutoGridOnLoadedEvent event) {},
                  configuration: PlutoGridConfiguration(
                    columnFilter: PlutoGridColumnFilterConfig(
                      filters: const [...FilterHelper.defaultFilters],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
