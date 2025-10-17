import 'package:collection/collection.dart';

class DuplicateDataHandler<T> {
  /// Identifies exact duplicate rows in a list of maps (e.g., database rows).
  List<Map<String, dynamic>> findExactDuplicates(
    List<Map<String, dynamic>> rows,
  ) {
    final seen = <String, int>{};
    final duplicates = <Map<String, dynamic>>[];

    for (var row in rows) {
      final key = row.entries.map((e) => '${e.key}:${e.value}').join('|');
      if (seen.containsKey(key)) {
        duplicates.add(row);
      } else {
        seen[key] = 1;
      }
    }
    return duplicates;
  }

  /// Drops exact duplicate rows, keeping only the first occurrence.
  List<Map<String, dynamic>> dropExactDuplicates(
    List<Map<String, dynamic>> rows,
  ) {
    final seen = <String, bool>{};
    final result = <Map<String, dynamic>>[];

    for (var row in rows) {
      final key = row.entries.map((e) => '${e.key}:${e.value}').join('|');
      if (!seen.containsKey(key)) {
        seen[key] = true;
        result.add(row);
      }
    }
    return result;
  }

  /// Checks for near duplicates using a custom similarity function.
  /// [similarity] should return true if two rows are considered near duplicates.
  List<List<Map<String, dynamic>>> findNearDuplicates(
    List<Map<String, dynamic>> rows,
    bool Function(Map<String, dynamic>, Map<String, dynamic>) similarity,
  ) {
    final visited = List<bool>.filled(rows.length, false);
    final nearDuplicates = <List<Map<String, dynamic>>>[];

    for (int i = 0; i < rows.length; i++) {
      if (visited[i]) continue;
      final group = <Map<String, dynamic>>[rows[i]];
      visited[i] = true;
      for (int j = i + 1; j < rows.length; j++) {
        if (!visited[j] && similarity(rows[i], rows[j])) {
          group.add(rows[j]);
          visited[j] = true;
        }
      }
      if (group.length > 1) {
        nearDuplicates.add(group);
      }
    }
    return nearDuplicates;
  }
}

// Example similarity function for near duplicates (case-insensitive string comparison)
bool nearDuplicateExample(Map<String, dynamic> a, Map<String, dynamic> b) {
  final eq = const DeepCollectionEquality();
  // Compare all keys except 'id', and ignore case for string values
  for (final key in a.keys) {
    if (key == 'id') continue;
    final valA = a[key];
    final valB = b[key];
    if (valA is String && valB is String) {
      if (valA.toLowerCase() != valB.toLowerCase()) return false;
    } else if (!eq.equals(valA, valB)) {
      return false;
    }
  }
  return true;
}
