import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final List<String> categories;

  const QuickActions({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickActionButton(context, Icons.receipt, 'Add Expense'),
              _buildQuickActionButton(context, Icons.bar_chart, 'View Reports'),
              _buildQuickActionButton(context, Icons.category, 'Categories'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            if (label == 'Add Expense') {
              _showAddExpenseDialog(context);
            } else {
              // TODO: Implement other actions
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedCategory = categories.first;
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    selectedCategory = newValue;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                // TODO: Implement adding expense
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

