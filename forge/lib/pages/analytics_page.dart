import 'package:flutter/material.dart';
import 'package:forge/widgets/heading.dart';
import 'package:forge/widgets/insight_card.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Heading(title: 'Insights'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InsightCard(value: 2, label: 'Orphan cells', color: Colors.red),
              InsightCard(value: 27, label: 'Empty cells', color: Colors.pink),
              InsightCard(value: 2367, label: 'Outliers', color: Colors.teal),
              InsightCard(value: 4, label: '123 records', color: Colors.yellow),
            ],
          ),
          Heading(title: 'Graphs'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InsightCard(value: 2, label: 'Orphan cells', color: Colors.red),
              InsightCard(value: 27, label: 'Empty cells', color: Colors.pink),
              InsightCard(value: 2367, label: 'Outliers', color: Colors.teal),
              InsightCard(value: 4, label: '123 records', color: Colors.yellow),
            ],
          ),
        ],
      ),
    );
  }
}
