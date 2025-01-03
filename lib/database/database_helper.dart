import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('spending_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        name TEXT NOT NULL,
        type INTEGER NOT NULL,
        PRIMARY KEY (name, type)
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop tables and recreate
      await db.execute('DROP TABLE categories');
      await db.execute('DROP TABLE transactions');

      // Recreate tables
      await _onCreate(db, 2);
    }
  }


}

