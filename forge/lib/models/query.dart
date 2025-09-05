// ignore_for_file: depend_on_referenced_packages

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'APPDB.db');

    return await openDatabase(path, version: 1, onCreate: onCreate);
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    return await db.update('users', user, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      email TEXT NOT NULL,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      teamId INTEGER,
      FOREIGN KEY (teamId) REFERENCES teams (id)
    )
  ''');

    await db.execute('''
    CREATE TABLE teams (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE datasets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      type TEXT NOT NULL,
      path TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE projects (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      teamId INTEGER,
      FOREIGN KEY (teamId) REFERENCES teams (id)
    )
  ''');

    await db.execute('''
    CREATE TABLE algorithms (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      parameters TEXT,
      code TEXT NOT NULL,
      projectId INTEGER,
      FOREIGN KEY (projectId) REFERENCES projects (id)
    )
  ''');

    await db.execute('''
    CREATE TABLE logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      timestamp TEXT NOT NULL,
      lineNumber INTEGER NOT NULL,
      status TEXT NOT NULL,
      result INTEGER NOT NULL,
      projectId INTEGER,
      FOREIGN KEY (projectId) REFERENCES projects (id)
    )
  ''');
  }

  /* Example usage:
ElevatedButton(
  onPressed: () async {
    final dbHelper = DatabaseHelper();
    await dbHelper.insertUser({'name': 'John', 'email': 'john@mail.com'});
    final users = await dbHelper.getUsers();
    print(users);
  },
  child: Text("Add User"),
)
*/
}
