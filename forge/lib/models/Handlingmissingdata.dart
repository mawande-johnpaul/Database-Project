import 'dart:math';

class DataCleaner {
  /// Removes rows with more than [rowThreshold] missing values.
  static List<List<dynamic>> removeRowsWithMissing(
      List<List<dynamic>> data, int rowThreshold) {
    return data.where((row) {
      int missingCount = row.where((v) => v == null).length;
      return missingCount <= rowThreshold;
    }).toList();
  }

  /// Removes columns with more than [colThreshold] missing values.
  static List<List<dynamic>> removeColumnsWithMissing(
      List<List<dynamic>> data, int colThreshold) {
    if (data.isEmpty) return data;
    int cols = data[0].length;
    List<int> keepCols = [];
    for (int c = 0; c < cols; c++) {
      int missingCount = 0;
      for (var row in data) {
        if (row[c] == null) missingCount++;
      }
      if (missingCount <= colThreshold) keepCols.add(c);
    }
    return data
        .map((row) => [for (var c in keepCols) row[c]])
        .toList();
  }

  /// Imputes missing values with column mean (for numeric columns).
  static List<List<dynamic>> imputeMissingWithMean(List<List<dynamic>> data) {
    if (data.isEmpty) return data;
    int cols = data[0].length;
    List<double?> means = List.filled(cols, null);

    // Calculate means
    for (int c = 0; c < cols; c++) {
      double sum = 0;
      int count = 0;
      for (var row in data) {
        var v = row[c];
        if (v is num) {
          sum += v;
          count++;
        }
      }
      means[c] = count > 0 ? sum / count : null;
    }

    // Impute missing
    return data
        .map((row) => [
              for (int c = 0; c < cols; c++)
                row[c] ?? means[c]
            ])
        .toList();
  }
}