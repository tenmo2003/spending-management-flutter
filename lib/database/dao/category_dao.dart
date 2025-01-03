import 'package:spending_management_app/model/category.dart';

import '../database_helper.dart';
import 'package:spending_management_app/model/transaction.dart' as model;
import 'package:spending_management_app/model/category_spending.dart';

class CategoryDao {
  static final CategoryDao instance = CategoryDao._init();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  CategoryDao._init();

  Future<int> addCategory(String name, model.TransactionType type) async {
    final db = await _databaseHelper.database;
    return await db.insert('categories', {'name': name, 'type': type.index});
  }

  Future<bool> addCategories(
      List<String> names, model.TransactionType type) async {
    final db = await _databaseHelper.database;
    try {
      await db.transaction((txn) async {
        final batch = txn.batch();
        for (String name in names) {
          batch.insert('categories', {'name': name, 'type': type.index});
        }
        await batch.commit();
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Category>> getCategories(
      {model.TransactionType? type}) async {
    final db = await _databaseHelper.database;
    List<Map<String, dynamic>> categories = await db.query('categories',
        where: type != null ? 'type = ?' : null,
        whereArgs: type != null ? [type.index] : null);
    return categories
        .map((e) => Category(
            name: e['name'] as String,
            type: model.TransactionType.values[e['type'] as int]))
        .toList();
  }

  Future<int> deleteCategory(String name, model.TransactionType type) async {
    final db = await _databaseHelper.database;
    return await db.delete('categories',
        where: 'name = ? AND type = ?', whereArgs: [name, type.index]);
  }

  Future<int> updateCategory(
      String oldName, String newName, model.TransactionType type) async {
    final db = await _databaseHelper.database;
    return await db.update('categories', {'name': newName},
        where: 'name = ? AND type = ?', whereArgs: [oldName, type.index]);
  }

  Future<List<CategorySpending>> getTopNCategories(
      int n, model.TransactionType type) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT category, SUM(amount) AS total_amount
      FROM transactions
      WHERE type = ?
      GROUP BY category
      ORDER BY total_amount DESC
      LIMIT ?
    ''', [
      type.index,
      n
    ]).then((value) => value
        .map((e) => CategorySpending(
            category: e['category'] as String,
            amount: e['total_amount'] as double))
        .toList());
  }

  Future<List<Map<String, dynamic>>> getCategoryPieData(
      model.TransactionType type) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE type = ?
      GROUP BY category
      ORDER BY total DESC
    ''', [type.index]);
  }
}
