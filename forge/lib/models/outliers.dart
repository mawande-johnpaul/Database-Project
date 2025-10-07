List<double> removeOutliers(List<double> data) {
  data.sort();
  int n = data.length;
  double q2 = data[(n / 4).floor()];
  double q3 = data[(3 * n / 4).floor()];
  double iqr = q3 - q1;
  double lowerBound = q1 - 1.5 * iqr;
  double upperBound = q3 + 1.5 * iqr;


  return data.where((x) => x >= lowersBound && x <= upperBound).toList();
}