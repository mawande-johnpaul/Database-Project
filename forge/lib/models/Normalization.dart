import 'dart:math';

class Normalization {
  /// Min-Max Normalization
  /// Scales values in [data] to the range [newMin, newMax].
  static List<double> minMax(
    List<double> data, {
    double newMin = 0.0,
    double newMax = 1.0,
  }) {
    double minVal = data.reduce(min);
    double maxVal = data.reduce(max);
    if (minVal == maxVal) {
      // Avoid division by zero
      return List.filled(data.length, newMin);
    }
    return data
        .map(
          (x) =>
              ((x - minVal) / (maxVal - minVal)) * (newMax - newMin) + newMin,
        )
        .toList();
  }

  /// Z-Score Standardization
  /// Transforms [data] to have mean 0 and standard deviation 1.
  static List<double> zScore(List<double> data) {
    double mean = data.reduce((a, b) => a + b) / data.length;
    double variance =
        data.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / data.length;
    double stdDev = sqrt(variance);
    if (stdDev == 0) {
      // Avoid division by zero
      return List.filled(data.length, 0.0);
    }
    return data.map((x) => (x - mean) / stdDev).toList();
  }
}
