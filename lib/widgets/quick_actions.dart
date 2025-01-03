import 'package:flutter/material.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/category.dart';

class QuickActions extends StatelessWidget {
  final List<Category> categories;
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
              _buildQuickActionButton(
                  context, Icons.receipt, 'Add Transaction'),
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
            if (label == 'Add Transaction') {
              _showAddTransactionDialog(context);
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

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddTransactionDialog(
            categories: categories, onTransactionAdded: onExpenseAdded);
      },
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final List<Category> categories;
  final Function onTransactionAdded;

  const AddTransactionDialog(
      {super.key, required this.categories, required this.onTransactionAdded});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late Category selectedCategory;
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
      title: const Text('Add Transaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Transaction Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: selectedCategory.name,
            items: widget.categories.map((category) {
              return DropdownMenuItem<String>(
                value: '${category.name} - ${category.type}',
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedCategory = widget.categories.firstWhere((category) =>
                      '${category.name} - ${category.type}' == newValue);
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
              final transactionDao = TransactionDao.instance;
              await transactionDao.addTransaction(
                  name: name,
                  amount: amount,
                  category: selectedCategory.name,
                  date: DateTime.now(),
                  type: selectedCategory.type);
              widget.onTransactionAdded();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
