import 'dart:convert';

class Cleaner {
  /// Removes rows with any null values from a list of maps (dataset).
  static List<Map<String, dynamic>> removeNullRows(List<Map<String, dynamic>> data) {
    return data.where((row) => !row.values.any((value) => value == null)).toList();
  }

  /// Trims whitespace from all string values in the dataset.
  static List<Map<String, dynamic>> trimStrings(List<Map<String, dynamic>> data) {
    return data.map((row) {
      return row.map((key, value) {
        if (value is String) {
          return MapEntry(key, value.trim());
        }
        return MapEntry(key, value);
      });
    }).toList();
  }

  /// Removes duplicate rows from the dataset.
  static List<Map<String, dynamic>> removeDuplicates(List<Map<String, dynamic>> data) {
    final seen = <String>{};
    return data.where((row) {
      final jsonRow = jsonEncode(row);
      if (seen.contains(jsonRow)) {
        return false;
      }
      seen.add(jsonRow);
      return true;
    }).toList();
  }

  /// Converts all string values to lowercase.
  static List<Map<String, dynamic>> lowercaseStrings(List<Map<String, dynamic>> data) {
    return data.map((row) {
      return row.map((key, value) {
        if (value is String) {
          return MapEntry(key, value.toLowerCase());
        }
        return MapEntry(key, value);
      });
    }).toList();
  }
}