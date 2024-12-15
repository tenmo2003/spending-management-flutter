import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

class CategoryDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertCategory(String name) async {
    final db = await _databaseHelper.database;
    return await db.insert('categories', {'name': name}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await _databaseHelper.database;
    return await db.query('categories');
  }

  Future<int> deleteCategory(String name) async {
    final db = await _databaseHelper.database;
    return await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }

  Future<int> updateCategory(String oldName, String newName) async {
    final db = await _databaseHelper.database;
    return await db.update('categories', {'name': newName}, where: 'name = ?', whereArgs: [oldName]);
  }
}
