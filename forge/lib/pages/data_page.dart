import 'package:flutter/material.dart';
import 'package:forge/models/datasheet.dart';
import 'package:forge/widgets/button.dart';

class DataPage extends StatefulWidget {
  Dataset? dataset;
  Future<List<String>>? dataFile;
  DataPage({super.key, this.dataset, this.dataFile});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  Widget build(BuildContext context) {
    var dataset = widget.dataset;
    var dataFile = widget.dataFile;

    if (dataFile == null || dataset == null) {
      return Center(
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
              onPressed: () {
                // Open window to select dataset file
              },
            ),
          ],
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
                  'Project: \\${dataset.name}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Description: \\${dataset.description}',
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
