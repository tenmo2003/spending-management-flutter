import 'package:flutter/material.dart';
import 'package:spending_management_app/model/transaction.dart';

IconData getIcon(String categoryName, TransactionType type) {
  switch (categoryName) {
    case 'Housing':
      return Icons.home;
    case 'Transportation':
      return Icons.directions_car;
    case 'Groceries':
      return Icons.shopping_cart;
    case 'Food & Drink':
      return Icons.restaurant;
    case 'Healthcare':
      return Icons.local_hospital;
    case 'Entertainment':
      return Icons.movie;
    case 'Clothing':
      return Icons.shopping_bag;
    case 'Gift':
      return Icons.card_giftcard;
    case 'Salary':
      return Icons.account_balance_wallet;
    case 'Bonus':
      return Icons.stars;
    case 'Investment':
      return Icons.trending_up;
    default:
      return Icons.question_mark;
  }
}
