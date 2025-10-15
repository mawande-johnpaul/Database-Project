import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  // Example data
  final List<double> dataValues = [12, 18, 14, 20, 16, 22, 19];

  double get average => dataValues.reduce((a, b) => a + b) / dataValues.length;
  double get maxValue => dataValues.reduce((a, b) => a > b ? a : b);
  double get minValue => dataValues.reduce((a, b) => a < b ? a : b);

  String get insight {
    if (average > 18) return "Data shows strong positive performance.";
    if (average < 14) return "Data indicates possible inefficiencies.";
    return "Data is within normal range.";
  }

  String get recommendation {
    if (average > 18) return "Maintain current strategy — performance is good.";
    if (average < 14) return "Review and optimize data sources.";
    return "Monitor trends regularly for stability.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Analysis"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Summary",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSummaryCard(),

              const SizedBox(height: 20),
              const Text(
                "Data Graph",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildLineChart(),

              const SizedBox(height: 20),
              const Text(
                "Insights",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(insight, style: const TextStyle(fontSize: 16)),

              const SizedBox(height: 20),
              const Text(
                "Recommendations",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(recommendation, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem("Avg", average.toStringAsFixed(1)),
            _summaryItem("Max", maxValue.toStringAsFixed(1)),
            _summaryItem("Min", minValue.toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                dataValues.length,
                (i) => FlSpot(i.toDouble(), dataValues[i]),
              ),
              isCurved: true,
              colors: [Colors.blue],
              barWidth: 3,
              belowBarData: BarAreaData(show: true, colors: [Colors.blue.withOpacity(0.3)]),
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }
}