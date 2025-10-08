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

    // Users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        password TEXT,
        team_id INTEGER
      )
    ''');

    // Teams
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');

    // Projects
    await db.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        team_id INTEGER
      )
    ''');

    // Datasets
    await db.execute('''
      CREATE TABLE IF NOT EXISTS datasets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        type TEXT,
        path TEXT,
        project_id INTEGER
      )
    ''');

    // Blueprints
    await db.execute('''
      CREATE TABLE IF NOT EXISTS blueprints (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        type TEXT,
        project_id INTEGER
      )
    ''');

    // Algorithms
    await db.execute('''
      CREATE TABLE IF NOT EXISTS algorithms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        description TEXT,
        code TEXT,
        parameters TEXT,
        blueprint_id INTEGER
      )
    ''');

    return db;
  }

  // User CRUD
  static Future<void> createUser(User user) async {
    final db = await connect();
    await db.insert('users', {
      'username': user.username,
      'email': user.email,
      'password': user.password,
      'team_id': user.teamId,
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
        teamId: row['team_id'] as int,
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
        'team_id': user.teamId,
      },
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  static Future<void> deleteUser(int id) async {
    final db = await connect();
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Team CRUD
  static Future<void> createTeam(Team team) async {
    final db = await connect();
    await db.insert('teams', {'name': team.name});
  }

  static Future<Team?> getTeam(int id) async {
    final db = await connect();
    var results = await db.query('teams', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      var row = results.first;
      return Team(
        id: row['id'] as int,
        name: row['name'] as String,
      );
    }
    return null;
  }

  static Future<void> updateTeam(Team team) async {
    final db = await connect();
    await db.update('teams', {'name': team.name}, where: 'id = ?', whereArgs: [team.id]);
  }

  static Future<void> deleteTeam(int id) async {
    final db = await connect();
    await db.delete('teams', where: 'id = ?', whereArgs: [id]);
  }

  // Project CRUD
  static Future<void> createProject(Project project) async {
    final db = await connect();
    await db.insert('projects', {
      'name': project.name,
      'description': project.description,
      'team_id': project.teamId,
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
        teamId: row['team_id'] as int,
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
        'team_id': project.teamId,
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
  static Future<void> createDataset(Dataset dataset) async {
    final db = await connect();
    await db.insert('datasets', {
      'name': dataset.name,
      'description': dataset.description,
      'type': dataset.type,
      'path': dataset.path,
      'project_id': dataset.projectId,
    });
  }

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

  // Blueprint CRUD
  static Future<void> createBlueprint(Blueprint blueprint) async {
    final db = await connect();
    await db.insert('blueprints', {
      'name': blueprint.name,
      'type': blueprint.type,
      'project_id': blueprint.projectId,
    });
  }

  static Future<Blueprint?> getBlueprint(int id) async {
    final db = await connect();
    var results = await db.query('blueprints', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      var row = results.first;
      return Blueprint(
        id: row['id'] as int,
        name: row['name'] as String,
        type: row['type'] as String,
        projectId: row['project_id'] as int,
      );
    }
    return null;
  }

  static Future<void> updateBlueprint(Blueprint blueprint) async {
    final db = await connect();
    await db.update(
      'blueprints',
      {
        'name': blueprint.name,
        'type': blueprint.type,
        'project_id': blueprint.projectId,
      },
      where: 'id = ?',
      whereArgs: [blueprint.id],
    );
  }

  static Future<void> deleteBlueprint(int id) async {
    final db = await connect();
    await db.delete('blueprints', where: 'id = ?', whereArgs: [id]);
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
    var results = await db.query('algorithms', where: 'id = ?', whereArgs: [id]);
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
}
