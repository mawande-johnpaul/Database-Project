import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';

class AuthService{
  static Database? _db;

  //Initialize the database
  static Future<void> initDb() async{
    if (_db != null) return;

    String dbPath = await getDatabasesPath();
    String path = join(dbpath, 'app.db');

    _db = await openDatabase(
      path,
      version:1;
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT,
          role TEXT
        )
        ''');
      },
    );
  }

  ///Hash password with SHA-256
  static String _hashPassword(String password){
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  ///Register new User
  static Future<int> registerUser(String username, String password, {String role = "user"}) async {
    await initDb();
    final hashedPassword = _hashPassword(password);
    
    return await _db!.insert(
      'users',
      {
        'username':username,
        'password':hashedPassword,
        'role':role,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );}

    ///Login user
    static Future<Map<String, dynamic>?> loginUser(String username, String password) async {
      await initDb();
      final hashedPassword = _hashPassword(password);

      final List<Map<string, dynamic>> result = await _db!.query(
        'users',
        where:'username = ? AND password = ?',
        whereArgs:[username,hashedPassword],
      );

      if (result.isNotEmpty){
        return result.first;
      }
      return null;
      }

      ///Delete user by ID
      static Future<int> deleteUser(int id) async {
        await initDb();
        return await _db!.delete(
          'users',
          where: 'id = ?',whereArgs:[id],
        );
      }

      /// Update user password
  static Future<int> updatePassword(int id, String newPassword) async {
    await initDb();
    final hashedPassword = _hashPassword(newPassword);

    return await _db!.update(
      'users',
      {'password': hashedPassword},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    await initDb();
    return await _db!.query('users');
  }

  /// Get a user by username
  static Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    await initDb();
    final result = await _db!.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
