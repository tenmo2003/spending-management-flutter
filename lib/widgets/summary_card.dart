import 'package:flutter/material.dart';
import 'package:spending_management_app/model/category_spending.dart';
import 'package:sprintf/sprintf.dart';

class SummaryCard extends StatelessWidget {
  final double totalSpent;
  final List<CategorySpending> topCategories;

  const SummaryCard(
      {super.key, required this.topCategories, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Spent This Month',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  sprintf('\$%.2f', [totalSpent]),
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  spacing: 8,
                  children: topCategories
                      .map((category) => Expanded(
                          child: _buildCategorySpending(
                              category.category, category.amount)))
                      .toList(),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildCategorySpending(String category, double amount) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
