import 'dart:convert';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';

class AuthService {
  static Database? _db;

  /// Initialize the database
  static Future<void> initDb() async {
    if (_db != null) return;

    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'app.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            username TEXT UNIQUE,
            password TEXT,
            salt TEXT
          )
        ''');
      },
    );
  }

  /// Generate a random salt
  static String _generateSalt([int length = 16]) {
    final rand = Random.secure();
    final values = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(values);
  }

  /// Hash password with SHA-256 + salt
  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Register new User
  static Future<int> registerUser(String email, String username, String password) async {
    await initDb();
    final salt = _generateSalt();
    final hashedPassword = _hashPassword(password, salt);

    try {
      return await _db!.insert(
        'users',
        {
          'email': email,
          'username': username,
          'password': hashedPassword,
          'salt': salt,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
    } catch (e) {
      throw Exception("User already exists or DB error: $e");
    }
  }

  /// Login user by email or username
  static Future<Map<String, dynamic>?> loginUser(String identifier, String password) async {
    await initDb();

    final result = await _db!.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [identifier, identifier],
    );

    if (result.isNotEmpty) {
      final user = result.first;
      final salt = user['salt'] as String;
      final hashedPassword = _hashPassword(password, salt);

      if (hashedPassword == user['password']) {
        return user;
      }
    }
    return null;
  }

  /// Delete user by ID
  static Future<int> deleteUser(int id) async {
    await initDb();
    return await _db!.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Update user password
  static Future<int> updatePassword(int id, String newPassword) async {
    await initDb();
    final newSalt = _generateSalt();
    final hashedPassword = _hashPassword(newPassword, newSalt);

    return await _db!.update(
      'users',
      {
        'password': hashedPassword,
        'salt': newSalt,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all users
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    await initDb();
    return await _db!.query('users');
  }

  /// Get a user by email or username
  static Future<Map<String, dynamic>?> getUserByIdentifier(String identifier) async {
    await initDb();
    final result = await _db!.query(
      'users',
      where: 'email = ? OR username = ?',
      whereArgs: [identifier, identifier],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
