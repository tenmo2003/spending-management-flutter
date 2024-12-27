import 'package:spending_management_app/database/database_helper.dart';
import 'package:spending_management_app/model/category_spending.dart';
import 'package:spending_management_app/model/transaction.dart' as model;

class TransactionDao {
  static final TransactionDao instance = TransactionDao._init();
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  TransactionDao._init();

  Future<model.Transaction> addTransaction({
    required String name,
    required String category,
    required double amount,
    required DateTime date,
    required model.TransactionType type,
  }) async {
    final db = await _databaseHelper.database;
    final id = await db.insert('transactions', {
      'name': name,
      'category': category,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'type': type.index,
    });
    return model.Transaction(
      id: id,
      name: name,
      category: category,
      amount: amount,
      date: date,
      type: type,
    );
  }

  Future<List<model.Transaction>> getAllTransactions({
    model.TransactionType? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    // Build where clause dynamically
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (type != null) {
      whereClauses.add('type = ?');
      whereArgs.add(type.index);
    }

    if (category != null) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    String whereClause =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : '';

    final queryResult = await db.query('transactions',
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date DESC');

    return queryResult.map((e) => model.Transaction.fromMap(e)).toList();
  }

  Future<double> getTotalAmount({
    model.TransactionType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _databaseHelper.database;

    // Build where clause dynamically
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    if (type != null) {
      whereClauses.add('type = ?');
      whereArgs.add(type.index);
    }

    if (startDate != null) {
      whereClauses.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereClauses.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    String query = 'SELECT SUM(amount) as total FROM transactions';
    if (whereClauses.isNotEmpty) {
      query += ' WHERE ${whereClauses.join(' AND ')}';
    }

    final result = await db.rawQuery(query, whereArgs);
    return (result[0]['total'] as num?)?.toDouble() ?? 0.0;
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

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await _databaseHelper.database;
    return await db.update('transactions', transaction.toMap(),
        where: 'id = ?', whereArgs: [transaction.id]);
  }

  Future<int> deleteTransaction(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getMonthlyTransactions(
      model.TransactionType type) async {
    final db = await _databaseHelper.database;
    return await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', date) as month,
        SUM(amount) as total
      FROM transactions
      WHERE type = ?
      GROUP BY strftime('%Y-%m', date)
      ORDER BY month DESC
    ''', [type.index]);
  }
}
