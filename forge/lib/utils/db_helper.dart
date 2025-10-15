import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> initDB() async {
    if (_db != null) return _db!;
    String path = join(await getDatabasesPath(), 'app_data.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE data(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            value REAL
          )
        ''');
      },
    );
    return _db!;
  }

  static Future<List<double>> fetchDataValues() async {
    final db = await initDB();
    final result = await db.query('data');
    return result.map((row) => row['value'] as double).toList();
  }
}
