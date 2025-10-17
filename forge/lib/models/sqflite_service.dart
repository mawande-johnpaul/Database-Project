// ignore_for_file: depend_on_referenced_packages

import 'package:path/path.dart';
import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'datasheet.dart';

class SqfliteService {
  // Cached single Database instance to avoid multiple simultaneous connections
  static Database? _dbInstance;

  // Small helper to retry writes in case of transient SQLITE_BUSY (locked)
  static Future<T> _withRetry<T>(Future<T> Function() action, {int tries = 3, Duration delay = const Duration(milliseconds: 100)}) async {
    int attempt = 0;
    while (true) {
      try {
        return await action();
      } catch (e) {
        attempt++;
        // check for sqlite busy/locked - sqflite ffi throws DatabaseException with message containing 'database is locked'
        final msg = e.toString().toLowerCase();
        if (attempt >= tries || !(msg.contains('database is locked') || msg.contains('database is busy') || msg.contains('sqlitebusy') || msg.contains('sqlitevbusy'))) rethrow;
        await Future.delayed(delay * attempt);
      }
    }
  }
  static Future<Database> connect() async {
    // For desktop (Windows/Linux) initialize the ffi implementation and
    // set the global databaseFactory before calling getDatabasesPath/openDatabase
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'forge.db');
    // Print the full database path for debugging (where sqflite stores the file)
    print('sqflite database path: $fullPath');

    // Return cached instance if already opened
    if (_dbInstance != null) {
      return _dbInstance!;
    }

    _dbInstance = await openDatabase(
      fullPath,
      version: 2,
      onCreate: (db, version) async {
        await _createSchemaV2(db);
      },
    );

    // Ensure foreign keys and tables exist
    await _dbInstance!.execute('PRAGMA foreign_keys = ON');
    await _createSchemaV2(_dbInstance!);

    return _dbInstance!;
  }

  static Future<void> _createSchemaV2(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');

    // Users table (removed team_id)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    // Projects table (removed team_id)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Datasets table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS datasets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        type TEXT,
        path TEXT,
        project_id INTEGER NOT NULL,
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    // Algorithms table (removed blueprint_id)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS algorithms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        code TEXT,
        parameters TEXT
      )
    ''');

    // Logs table: timestamp as id, algorithm_id, result, line_number
    await db.execute('''
      CREATE TABLE IF NOT EXISTS logs (
        id INTEGER PRIMARY KEY, -- store epoch millis timestamp
        algorithm_id INTEGER,
        result TEXT,
        line_number INTEGER,
        FOREIGN KEY (algorithm_id) REFERENCES algorithms(id) ON DELETE SET NULL
      )
    ''');

    // Columns table: standalone id so columns can be referenced by cells.column_id
    await db.execute('''
      CREATE TABLE IF NOT EXISTS columns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dataset_id INTEGER NOT NULL,
        name TEXT,
        data_type TEXT,
        ordinal INTEGER,
        FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON DELETE CASCADE
      )
    ''');

    // Cells table: each cell has its own id, dataset_id, column_id, optional row_id, value, numeric_value and is_outlier
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cells (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dataset_id INTEGER NOT NULL,
        column_id INTEGER NOT NULL,
        row_id INTEGER,
        value TEXT,
        numeric_value REAL,
        is_outlier INTEGER DEFAULT 0,
        algorithm_id INTEGER,
        FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON DELETE CASCADE,
        FOREIGN KEY (column_id) REFERENCES columns(id) ON DELETE CASCADE,
        FOREIGN KEY (algorithm_id) REFERENCES algorithms(id) ON DELETE SET NULL
      )
    ''');
  }

  // User CRUD using raw SQL
  static Future<void> createUser(User user) async {
    final db = await connect();
    await _withRetry(() => db.execute('''
      INSERT INTO users (username, email, password)
      VALUES (?, ?, ?)
    ''', [user.username, user.email, user.password]));
  }

  static Future<User?> getUser(int id) async {
    final db = await connect();
    var results = await db.rawQuery('''
      SELECT id, username, email, password
      FROM users
      WHERE id = ?
    ''', [id]);
    
    if (results.isNotEmpty) {
      var row = results.first;
      return User(
        id: row['id'] as int,
        username: row['username'] as String,
        email: row['email'] as String,
        password: row['password'] as String,
      );
    }
    return null;
  }

  static Future<void> updateUser(User user) async {
    final db = await connect();
    await db.execute('''
      UPDATE users
      SET username = ?,
          email = ?,
          password = ?
      WHERE id = ?
    ''', [user.username, user.email, user.password, user.id]);
  }

  static Future<void> deleteUser(int id) async {
    final db = await connect();
    await _withRetry(() => db.execute('DELETE FROM users WHERE id = ?', [id]));
  }

  // Project CRUD
  static Future<void> createProject(Project project) async {
    final db = await connect();
    if (project.id != null) {
      await _withRetry(() => db.execute('''
        INSERT INTO projects (id, name, description)
        VALUES (?, ?, ?)
      ''', [project.id, project.name, project.description]));
    } else {
      await _withRetry(() => db.execute('''
        INSERT INTO projects (name, description)
        VALUES (?, ?)
      ''', [project.name, project.description]));
    }
  }

  static Future<Project?> getProject(int id) async {
    final db = await connect();
    var results = await db.rawQuery('''
      SELECT id, name, description
      FROM projects
      WHERE id = ?
    ''', [id]);
    
    if (results.isNotEmpty) {
      var row = results.first;
      return Project(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String,
      );
    }
    return null;
  }

  static Future<void> updateProject(Project project) async {
    final db = await connect();
    await db.execute('''
      UPDATE projects
      SET name = ?,
          description = ?
      WHERE id = ?
    ''', [project.name, project.description, project.id]);
  }

  static Future<void> deleteProject(int id) async {
    final db = await connect();
    await _withRetry(() => db.execute('DELETE FROM projects WHERE id = ?', [id]));
  }

  static Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await connect();
    return await db.rawQuery('''
      SELECT id, name, description
      FROM projects
      ORDER BY name
    ''');
  }

  // Dataset CRUD

    // Dataset CRUD
  static Future<int> createDataset(Dataset dataset, String filePath) async {
    final db = await connect();
    return await db.rawInsert(
      '''
      INSERT INTO datasets (name, description, type, path, project_id)
      VALUES (?, ?, ?, ?, ?)
      ''',
      [
        dataset.name,
        dataset.description,
        dataset.type,
        filePath,
        dataset.projectId,
      ],
    );

  }

  static Future<List<Dataset>> getDatasetsByProject(int projectId) async {
    final db = await connect();
    final List<Map<String, dynamic>> maps = await db.query(
      'datasets',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    return List.generate(maps.length, (i) {
      return Dataset(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        type: maps[i]['type'],
        path: maps[i]['path'],
        projectId: maps[i]['project_id'],
      );
    });
  }

  static Future<Dataset?> getDataset(int id) async {
    final db = await connect();
    var results = await db.rawQuery('''
      SELECT id, name, description, type, path, project_id
      FROM datasets
      WHERE id = ?
    ''', [id]);
    
    if (results.isNotEmpty) {
      var row = results.first;
      return Dataset(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String,
        type: row['type'] as String,
        path: row['path'] as String?,
        projectId: row['project_id'] as int,
      );
    }
    return null;
  }

  static Future<void> updateDataset(Dataset dataset) async {
    final db = await connect();
    await _withRetry(() => db.execute('''
      UPDATE datasets
      SET name = ?,
          description = ?,
          type = ?,
          path = ?,
          project_id = ?
      WHERE id = ?
    ''', [
      dataset.name,
      dataset.description,
      dataset.type,
      dataset.path,
      dataset.projectId,
      dataset.id
    ]));
  }

  static Future<void> deleteDataset(int id) async {
    final db = await connect();
    await _withRetry(() => db.execute('DELETE FROM datasets WHERE id = ?', [id]));
  }

  // Algorithm CRUD
  static Future<void> createAlgorithm(Algorithm algorithm) async {
    final db = await connect();
    await _withRetry(() => db.execute('''
      INSERT INTO algorithms (name, description, code, parameters)
      VALUES (?, ?, ?, ?)
    ''', [
      algorithm.name,
      algorithm.description,
      algorithm.code,
      algorithm.parameters
    ]));
  }

  static Future<Algorithm?> getAlgorithm(int id) async {
    final db = await connect();
    var results = await db.rawQuery('''
      SELECT id, name, description, code, parameters
      FROM algorithms
      WHERE id = ?
    ''', [id]);
    
    if (results.isNotEmpty) {
      var row = results.first;
      return Algorithm(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String,
        code: row['code'] as String,
        parameters: row['parameters'] as String,
      );
    }
    return null;
  }

  static Future<void> updateAlgorithm(Algorithm algorithm) async {
    final db = await connect();
    await db.execute('''
      UPDATE algorithms
      SET name = ?,
          description = ?,
          code = ?,
          parameters = ?
      WHERE id = ?
    ''', [
      algorithm.name,
      algorithm.description,
      algorithm.code,
      algorithm.parameters,
      algorithm.id
    ]);
  }

  static Future<void> deleteAlgorithm(int id) async {
    final db = await connect();
    await _withRetry(() => db.execute('DELETE FROM algorithms WHERE id = ?', [id]));
  }

  // Get all datasets for a given project
  static Future<List<Map<String, dynamic>>> getDatasetsForProject(
    int projectId,
  ) async {
    final db = await connect();
    return await db.rawQuery(
      '''
      SELECT name, description, type, path
      FROM datasets
      WHERE project_id = ?
    ''',
      [projectId],
    );
  }

  // Count total number of users
  static Future<int> getUserCount() async {
    final db = await connect();
    var result = await db.rawQuery('SELECT COUNT(*) AS total FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Optional helpers for new tables
  static Future<void> insertLog({
    required int id,
    int? algorithmId,
    String? result,
    int? lineNumber,
  }) async {
    final db = await connect();
    await db.insert('logs', {
      'id': id,
      'algorithm_id': algorithmId,
      'result': result,
      'line_number': lineNumber,
    });
  }

  static Future<void> upsertColumn({
    required int datasetId,
    required int columnId,
  }) async {
    final db = await connect();
    // Try to insert with explicit id; ignore conflicts
    try {
      await _withRetry(() => db.execute('''
        INSERT INTO columns (id, dataset_id)
        VALUES (?, ?)
      ''', [columnId, datasetId]));
    } catch (_) {
      // fallback to inserting dataset-scoped column without explicit id
      await _withRetry(() => db.execute('''
        INSERT INTO columns (dataset_id)
        VALUES (?)
      ''', [datasetId]));
    }
  }

  static Future<void> insertCell({
    required int datasetId,
    required int columnId,
    int? rowId,
    String? value,
    int? algorithmId,
  }) async {
    final db = await connect();
    await _withRetry(() => db.execute('''
      INSERT INTO cells (dataset_id, column_id, row_id, value, algorithm_id)
      VALUES (?, ?, ?, ?, ?)
    ''', [datasetId, columnId, rowId, value, algorithmId]));
  }

  // New helpers requested by the script
  static Future<List<Map<String, dynamic>>> getProjectsForUser(
    int userId,
  ) async {
    final db = await connect();
    return await db.rawQuery(
      'SELECT id, name, description FROM projects WHERE owner_id = ?',
      [userId],
    );
  }

  static Future<List<Map<String, dynamic>>> getColumnsForDataset(
    int datasetId,
  ) async {
    final db = await connect();
    return await db.rawQuery('SELECT id, dataset_id, name, data_type, ordinal FROM columns WHERE dataset_id = ? ORDER BY ordinal, name', [datasetId]);
  }

  static Future<List<Map<String, dynamic>>> getCellsForDataset(
    int datasetId, {
    int? columnId,
  }) async {
    final db = await connect();
    if (columnId != null) {
      return await db.rawQuery('SELECT * FROM cells WHERE dataset_id = ? AND column_id = ? ORDER BY row_id, column_id', [datasetId, columnId]);
    }
    return await db.rawQuery('SELECT * FROM cells WHERE dataset_id = ? ORDER BY row_id, column_id', [datasetId]);
  }

  // Null/empty cell summary per column
  static Future<List<Map<String, dynamic>>> getEmptyNullSummary(
    int datasetId,
  ) async {
    final db = await connect();
    return await db.rawQuery(
      '''
      SELECT co.id AS column_id,
             co.name AS column_name,
             COUNT(ce.id) AS total_cells,
             SUM(CASE WHEN ce.value IS NULL OR TRIM(ce.value) = '' THEN 1 ELSE 0 END) AS empty_or_null_count,
             ROUND((SUM(CASE WHEN ce.value IS NULL OR TRIM(ce.value) = '' THEN 1 ELSE 0 END) * 100.0) / COUNT(ce.id), 2) AS empty_or_null_percentage
      FROM columns co
      LEFT JOIN cells ce ON ce.column_id = co.id AND ce.dataset_id = ?
      WHERE co.dataset_id = ?
      GROUP BY co.id, co.name
      ORDER BY empty_or_null_percentage DESC
    ''',
      [datasetId, datasetId],
    );
  }

  static Future<List<Map<String, dynamic>>> getEmptyNullDetails(
    int datasetId,
  ) async {
    final db = await connect();
    return await db.rawQuery(
      '''
      SELECT ce.id AS cell_id, ce.column_id, co.name AS column_name, ce.row_id, ce.value
      FROM cells ce
      JOIN columns co ON ce.column_id = co.id
      WHERE ce.dataset_id = ?
        AND (ce.value IS NULL OR TRIM(ce.value) = '')
      ORDER BY co.name, ce.row_id
    ''',
      [datasetId],
    );
  }

  // Identify numeric columns by proportion of numeric_value populated
  static Future<List<Map<String, dynamic>>> getNumericColumnStats(
    int datasetId,
  ) async {
    final db = await connect();
    return await db.rawQuery(
      '''
      SELECT co.id AS column_id,
             co.name AS column_name,
             COUNT(ce.id) AS total_cells,
             SUM(CASE WHEN ce.numeric_value IS NOT NULL THEN 1 ELSE 0 END) AS numeric_populated,
             ROUND((SUM(CASE WHEN ce.numeric_value IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / COUNT(ce.id), 2) AS numeric_percentage
      FROM columns co
      LEFT JOIN cells ce ON ce.column_id = co.id AND ce.dataset_id = ?
      WHERE co.dataset_id = ?
      GROUP BY co.id, co.name
      HAVING COUNT(ce.id) > 0
      ORDER BY numeric_percentage DESC
    ''',
      [datasetId, datasetId],
    );
  }

  // Populate numeric_value for cells in a dataset by simple heuristic parsing.
  // This is application-layer preferred: handles locales and edge cases.
  static Future<void> populateNumericValuesForDataset(int datasetId) async {
    final db = await connect();
    final rows = await db.rawQuery('''
      SELECT id, value 
      FROM cells 
      WHERE dataset_id = ?
    ''', [datasetId]);
    await db.transaction((txn) async {
      for (final r in rows) {
        final id = r['id'] as int;
        final raw = r['value'] as String?;
        double? parsed;
        if (raw == null) {
          parsed = null;
        } else {
          final s = raw.trim();
          if (s.isEmpty) {
            parsed = null;
          } else {
            // Heuristic: if contains both '.' and ',' treat commas as thousands separator
            String candidate = s;
            if (candidate.contains('.') && candidate.contains(',')) {
              candidate = candidate.replaceAll(',', '');
            } else if (candidate.contains(',') && !candidate.contains('.')) {
              // treat comma as decimal separator
              candidate = candidate.replaceAll(',', '.');
            }
            // Remove common currency symbols and spaces
            candidate = candidate.replaceAll(RegExp(r'[\$€£\s]'), '');
            try {
              parsed = double.parse(candidate);
            } catch (_) {
              parsed = null;
            }
          }
        }
        await txn.execute('''
          UPDATE cells 
          SET numeric_value = ?
          WHERE id = ?
        ''', [parsed, id]);
      }
    });
  }

  // Compute quartiles (Q1, Q3) for a given column within a dataset using application code
  static Future<Map<String, double>?> computeQuartilesForColumn(
    int datasetId,
    int columnId,
  ) async {
    final db = await connect();
    final rows = await db.rawQuery(
      'SELECT numeric_value FROM cells WHERE dataset_id = ? AND column_id = ? AND numeric_value IS NOT NULL ORDER BY numeric_value ASC',
      [datasetId, columnId],
    );
    final values = rows
        .map((r) => (r['numeric_value'] as num).toDouble())
        .toList();
    if (values.isEmpty) return null;

    double percentile(List<double> sorted, double p) {
      final n = sorted.length;
      final rank = p * (n - 1);
      final lower = rank.floor();
      final upper = rank.ceil();
      if (lower == upper) return sorted[lower];
      final weight = rank - lower;
      return sorted[lower] * (1 - weight) + sorted[upper] * weight;
    }

    final q1 = percentile(values, 0.25);
    final q3 = percentile(values, 0.75);
    return {'q1': q1, 'q3': q3};
  }

  // Mark outliers using IQR method for a column; computes quartiles and updates is_outlier
  static Future<void> markOutliersForColumn(int datasetId, int columnId) async {
    final db = await connect();
    final stats = await computeQuartilesForColumn(datasetId, columnId);
    if (stats == null) return;
    final q1 = stats['q1']!;
    final q3 = stats['q3']!;
    final iqr = q3 - q1;
    final lower = q1 - 1.5 * iqr;
    final upper = q3 + 1.5 * iqr;
    await _withRetry(() => db.execute('''
      UPDATE cells
      SET is_outlier = 0
      WHERE dataset_id = ? AND column_id = ?
    ''', [datasetId, columnId]));
    
    await _withRetry(() => db.execute('''
      UPDATE cells
      SET is_outlier = 1
      WHERE dataset_id = ? 
        AND column_id = ? 
        AND numeric_value IS NOT NULL 
        AND (numeric_value < ? OR numeric_value > ?)
    ''', [datasetId, columnId, lower, upper]));
  }

  // Update a single cell's value (and recompute numeric_value and reset outlier flag)
  static Future<void> updateCellValue(int cellId, String? newValue) async {
    final db = await connect();
    double? parsed;
    if (newValue == null || newValue.trim().isEmpty) {
      parsed = null;
    } else {
      var candidate = newValue.trim();
      if (candidate.contains('.') && candidate.contains(',')) {
        candidate = candidate.replaceAll(',', '');
      } else if (candidate.contains(',') && !candidate.contains('.')) {
        candidate = candidate.replaceAll(',', '.');
      }
      candidate = candidate.replaceAll(RegExp(r'[\$€£\s]'), '');
      try {
        parsed = double.parse(candidate);
      } catch (_) {
        parsed = null;
      }
    }
    await _withRetry(() => db.execute('''
      UPDATE cells
      SET value = ?,
          numeric_value = ?,
          is_outlier = 0
      WHERE id = ?
    ''', [newValue, parsed, cellId]));
  }

  // Column-level bulk updates: fill nulls or apply numeric transform example
  static Future<void> fillColumnNulls(
    int datasetId,
    int columnId,
    String defaultValue,
  ) async {
    final db = await connect();
    await _withRetry(() => db.execute('''
      UPDATE cells
      SET value = ?
      WHERE dataset_id = ? 
        AND column_id = ? 
        AND (value IS NULL OR TRIM(value) = '')
    ''', [defaultValue, datasetId, columnId]));
  }

  static Future<void> multiplyNumericColumn(
    int datasetId,
    int columnId,
    double factor,
  ) async {
    final db = await connect();
    await db.transaction((txn) async {
      final rows = await txn.rawQuery('''
        SELECT id, numeric_value
        FROM cells
        WHERE dataset_id = ? 
          AND column_id = ? 
          AND numeric_value IS NOT NULL
      ''', [datasetId, columnId]);
      for (final r in rows) {
        final id = r['id'] as int;
        final numVal = (r['numeric_value'] as num).toDouble();
        final newNum = numVal * factor;
        await _withRetry(() => txn.execute('''
          UPDATE cells
          SET numeric_value = ?,
              value = ?
          WHERE id = ?
        ''', [newNum, newNum.toString(), id]));
      }
    });
  }
}
