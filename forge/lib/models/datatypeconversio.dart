import 'package:intl/intl.dart';

class DataTypeConversion {
  // Converts a list of string columns to categorical variables (as enums)
  static List<T> toCategorical<T>(List<String> values, List<T> categories) {
    return values.map((v) {
      final idx = categories
          .map((e) => e.toString().split('.').last)
          .toList()
          .indexOf(v);
      if (idx != -1) {
        return categories[idx];
      }
      throw ArgumentError('Value $v not found in categories');
    }).toList();
  }

  // Converts a list of strings to integers
  static List<int> toIntList(List<String> values) {
    return values.map((v) => int.tryParse(v) ?? 0).toList();
  }

  // Converts a list of strings to doubles
  static List<double> toDoubleList(List<String> values) {
    return values.map((v) => double.tryParse(v) ?? 0.0).toList();
  }

  // Converts a list of strings to DateTime objects
  static List<DateTime?> toDateTimeList(
    List<String> values, {
    String format = 'yyyy-MM-dd',
  }) {
    final formatter = DateFormat(format);
    return values.map((v) {
      try {
        return formatter.parse(v);
      } catch (_) {
        return null;
      }
    }).toList();
  }

  // Example: Convert a column based on type
  static dynamic convertColumn(
    List<String> values,
    String type, {
    List<dynamic>? categories,
    String? dateFormat,
  }) {
    switch (type) {
      case 'int':
        return toIntList(values);
      case 'double':
        return toDoubleList(values);
      case 'datetime':
        return toDateTimeList(values, format: dateFormat ?? 'yyyy-MM-dd');
      case 'categorical':
        if (categories == null)
          throw ArgumentError(
            'Categories must be provided for categorical conversion',
          );
        return toCategorical(values, categories);
      default:
        return values;
    }
  }
}
