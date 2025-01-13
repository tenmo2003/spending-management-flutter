import 'package:spending_management_app/helper/string_extension.dart';

enum TransactionType {
  expense,
  income;

  String getName() {
    return name.capitalize();
  }
}

class Transaction {
  final int id;
  final String name;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
  });

  // Helper method to convert to map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'date': date.toUtc().toIso8601String(),
      'type': type.index,
    };
  }

  // Helper method to create from map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      amount: map['amount'] as double,
      date: DateTime.parse(map['date'] as String),
      type: TransactionType.values[map['type'] as int],
    );
  }

  double getValue() {
    if (type == TransactionType.expense) {
      return -amount;
    } else {
      return amount;
    }
  }
}
