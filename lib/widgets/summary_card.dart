import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_management_app/model/category_spending.dart';
import 'package:spending_management_app/providers/currency_notifier.dart';

class SummaryCard extends ConsumerWidget {
  final double totalSpent;
  final List<CategorySpending> topCategories;

  const SummaryCard(
      {super.key, required this.topCategories, required this.totalSpent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  ref.watch(formattedAmountProvider(totalSpent)),
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  spacing: 8,
                  children: topCategories
                      .map((category) => Expanded(
                          child: _buildCategorySpending(
                              category.category, category.amount, ref)))
                      .toList(),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildCategorySpending(String category, double amount, WidgetRef ref) {
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
            ref.watch(formattedAmountProvider(amount)),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
