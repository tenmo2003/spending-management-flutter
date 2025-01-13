import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_management_app/model/category_spending.dart';
import 'package:spending_management_app/providers/currency_notifier.dart';

class SummaryCard extends ConsumerWidget {
  final double balance;
  final double totalSpent;
  final double totalIncome;
  final List<CategorySpending> topCategories;

  const SummaryCard(
      {super.key,
      required this.topCategories,
      required this.balance,
      required this.totalSpent,
      required this.totalIncome});

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
                  'Balance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  ref.watch(formattedAmountProvider(balance)),
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(spacing: 10, children: [
                  Expanded(
                      child: _buildCategorySpending(
                          category: "Expense",
                          amount: totalSpent,
                          ref: ref,
                          color: const Color.fromARGB(255, 238, 102, 102))),
                  Expanded(
                      child: _buildCategorySpending(
                          category: "Income",
                          amount: totalIncome,
                          ref: ref,
                          color: const Color.fromARGB(255, 121, 247, 186))),
                ]),
                const SizedBox(height: 16),
                Row(
                  spacing: 8,
                  children: topCategories
                      .map((category) => Expanded(
                          child: _buildCategorySpending(
                              category: category.name,
                              amount: category.amount,
                              ref: ref)))
                      .toList(),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildCategorySpending(
      {required String category,
      required double amount,
      required WidgetRef ref,
      Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color ?? Colors.blue.withOpacity(0.1),
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
