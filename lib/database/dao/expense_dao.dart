import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

class ExpenseDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insertExpense(String name, double amount, String category, String date) async {
    final db = await _databaseHelper.database;
    return await db.insert('expenses', {
      'name': name,
      'amount': amount,
      'category': category,
      'date': date,
    });
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await _databaseHelper.database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  Future<int> deleteExpense(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateExpense(int id, String name, double amount, String category, String date) async {
    final db = await _databaseHelper.database;
    return await db.update('expenses', {
      'name': name,
      'amount': amount,
      'category': category,
      'date': date,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory(String category) async {
    final db = await _databaseHelper.database;
    return await db.query('expenses', where: 'category = ?', whereArgs: [category], orderBy: 'date DESC');
  }
}

