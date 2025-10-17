// ignore_for_file: depend_on_referenced_packages

import 'package:path/path.dart';
import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'datasheet.dart';

class SqfliteService {
  static Future<Database> connect() async {
    // For desktop (Windows/Linux) initialize the ffi implementation and
    // set the global databaseFactory before calling getDatabasesPath/openDatabase
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();

    final db = await openDatabase(
      join(dbPath, 'forge.db'),
      
      onCreate: (db, version) async {
        // initial creation handled below as well
      },
      version: 1,
    );

    // Ensure foreign keys and tables exist (handles existing DBs that may be missing tables)
    await db.execute('PRAGMA foreign_keys = ON');


    // Users table -added NOT NULL ,UNIQUE, and FOREIGN KEY constraints
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        team_id INTEGER,
        FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE SET NULL
      )
    ''');

    //UPDATED- Projects table - Linked to Teams table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        team_id INTEGER NOT NULL,
        FOREIGN KEY (team_id) REFERENCES teams(id) ON DELETE CASCADE
      )
    ''');

    //UPDATED- Datasets table -added foreign key and NOT NULL constraints
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

    //UPDATED: Algorithms table - added foreign key and NOT NULL fields
    await db.execute('''
      CREATE TABLE IF NOT EXISTS algorithms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        code TEXT,
        parameters TEXT,
        blueprint_id INTEGER NOT NULL,
        FOREIGN KEY (blueprint_id) REFERENCES blueprints(id) ON DELETE CASCADE
      )
    ''');

    //create Columns table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS columns (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        data_type TEXT NOT NULL,
        is_nullable INTEGER NOT NULL,
        is_primary_key INTEGER NOT NULL,
        dataset_id INTEGER NOT NULL,
        FOREIGN KEY (dataset_id) REFERENCES datasets(id) ON DELETE CASCADE
      )
    ''');

    // Create Cells table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cells (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        row_id INTEGER NOT NULL,
        is_outlier INTEGER NOT NULL,
        column_id INTEGER NOT NULL,
        value TEXT,
        FOREIGN KEY (column_id) REFERENCES columns(id) ON DELETE CASCADE
      )
    ''');

    return db;
  }

  // Dataset CRUD
  static Future<int> createDataset(Dataset dataset, String filePath) async {
    final db = await connect();
    return await db.insert('datasets', {
      'name': dataset.name,
      'description': dataset.description,
      'type': dataset.type,
      'path': filePath,
      'project_id': dataset.projectId,
    });
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

  // User CRUD
  static Future<void> createUser(User user) async {
    final db = await connect();
    await db.insert('users', {
      'username': user.username,
      'email': user.email,
      'password': user.password,
    });
  }

  static Future<User?> getUser(int id) async {
    final db = await connect();
    var results = await db.query('users', where: 'id = ?', whereArgs: [id]);
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
    await db.update(
      'users',
      {
        'username': user.username,
        'email': user.email,
        'password': user.password,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<void> deleteUser(int id) async {
    final db = await connect();
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Project CRUD
  static Future<void> createProject(Project project) async {
    final db = await connect();
    await db.insert('projects', {
      'id': project.id,
      'name': project.name,
      'description': project.description,
    });
  }

  static Future<Project?> getProject(int id) async {
    final db = await connect();
    var results = await db.query('projects', where: 'id = ?', whereArgs: [id]);
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
    await db.update(
      'projects',
      {
        'name': project.name,
        'description': project.description,
      },
      where: 'id = ?',
      whereArgs: [project.id],
    );
  }

  static Future<void> deleteProject(int id) async {
    final db = await connect();
    await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> getProjects() async {
    final db = await connect();
    var results = await db.query('projects');
    return results;
  }

  // Dataset CRUD

  static Future<Dataset?> getDataset(int id) async {
    final db = await connect();
    var results = await db.query('datasets', where: 'id = ?', whereArgs: [id]);
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
    await db.update(
      'datasets',
      {
        'name': dataset.name,
        'description': dataset.description,
        'type': dataset.type,
        'path': dataset.path,
        'project_id': dataset.projectId,
      },
      where: 'id = ?',
      whereArgs: [dataset.id],
    );
  }

  static Future<void> deleteDataset(int id) async {
    final db = await connect();
    await db.delete('datasets', where: 'id = ?', whereArgs: [id]);
  }

  // Algorithm CRUD
  static Future<void> createAlgorithm(Algorithm algorithm) async {
    final db = await connect();
    await db.insert('algorithms', {
      'name': algorithm.name,
      'description': algorithm.description,
      'code': algorithm.code,
      'parameters': algorithm.parameters,
      'blueprint_id': algorithm.blueprintId,
    });
  }

  static Future<Algorithm?> getAlgorithm(int id) async {
    final db = await connect();
    var results = await db.query(
      'algorithms',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      var row = results.first;
      return Algorithm(
        id: row['id'] as int,
        name: row['name'] as String,
        description: row['description'] as String,
        code: row['code'] as String,
        parameters: row['parameters'] as String,
        blueprintId: row['blueprint_id'] as int,
      );
    }
    return null;
  }

  static Future<void> updateAlgorithm(Algorithm algorithm) async {
    final db = await connect();
    await db.update(
      'algorithms',
      {
        'name': algorithm.name,
        'description': algorithm.description,
        'code': algorithm.code,
        'parameters': algorithm.parameters,
        'blueprint_id': algorithm.blueprintId,
      },
      where: 'id = ?',
      whereArgs: [algorithm.id],
    );
  }

  static Future<void> deleteAlgorithm(int id) async {
    final db = await connect();
    await db.delete('algorithms', where: 'id = ?', whereArgs: [id]);
  }

  // Get all datasets for a given project
  static Future<List<Map<String, dynamic>>> getDatasetsForProject(int projectId) async {
    final db = await connect();
    return await db.rawQuery('''
      SELECT name, description, type, path
      FROM datasets
      WHERE project_id = ?
    ''', [projectId]);
  }

  // Count total number of users
  static Future<int> getUserCount() async {
    final db = await connect();
    var result = await db.rawQuery('SELECT COUNT(*) AS total FROM users');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get all columns of a given dataset
  static Future<List<Map<String, dynamic>>> getColumnsForDataset(int datasetId) async {
    final db = await connect();
    return await db.rawQuery('''
      SELECT name, data_type, is_nullable, is_primary_key
      FROM columns
      WHERE dataset_id = ?
    ''', [datasetId]);
  }

  // Get all cells for a given column
  static Future<List<Map<String, dynamic>>> getCellsForColumn(int columnId) async {
    final db = await connect();
    return await db.rawQuery('''
      SELECT row_id, value, is_outlier
      FROM cells
      WHERE column_id = ?
    ''', [columnId]);
  }

  //Get null and empty cells count for a given column
  static Future<int> getNullAndEmptyCellCount(int columnId) async {
    final db = await connect();
    var result = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM cells
      WHERE column_id = ? AND (value IS NULL OR value = '')
    ''', [columnId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  //Get column data type distribution
  static Future<List<Map<String, dynamic>>> getColumnDataTypeDistribution(int datasetId) async {
    final db = await connect();
    return await db.rawQuery('''
      SELECT data_type, COUNT(*) AS count
      FROM columns
      WHERE dataset_id = ?
      GROUP BY data_type
    ''', [datasetId]);
  }

  


}
