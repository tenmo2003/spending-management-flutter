import 'package:flutter/material.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/transaction.dart' as model;

class QuickActions extends StatelessWidget {
  final List<String> categories;
  final Function onExpenseAdded;

  const QuickActions(
      {super.key, required this.categories, required this.onExpenseAdded});

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

  Widget _buildQuickActionButton(
      BuildContext context, IconData icon, String label) {
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
        return AddExpenseDialog(
            categories: categories, onExpenseAdded: onExpenseAdded);
      },
    );
  }
}

class AddExpenseDialog extends StatefulWidget {
  final List<String> categories;
  final Function onExpenseAdded;

  const AddExpenseDialog(
      {super.key, required this.categories, required this.onExpenseAdded});

  @override
  _AddExpenseDialogState createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  late String selectedCategory;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Expense'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Expense Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedCategory,
            items: widget.categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedCategory = newValue;
                });
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
          onPressed: () async {
            if (nameController.text.isNotEmpty &&
                amountController.text.isNotEmpty) {
              final name = nameController.text;
              final amount = double.parse(amountController.text);
              final expenseDao = TransactionDao.instance;
              await expenseDao.addTransaction(
                  name: name,
                  amount: amount,
                  category: selectedCategory,
                  date: DateTime.now(),
                  type: model.TransactionType.expense);
              widget.onExpenseAdded();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
