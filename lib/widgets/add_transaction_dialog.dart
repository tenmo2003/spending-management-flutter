import 'package:flutter/material.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/category.dart';

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
            value: '${selectedCategory.name} - ${selectedCategory.type.name}',
            items: widget.categories.map((category) {
              return DropdownMenuItem<String>(
                value: '${category.name} - ${category.type.name}',
                child: Text('${category.name} - ${category.type.getName()}'),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedCategory = widget.categories.firstWhere((category) =>
                      '${category.name} - ${category.type.name}' == newValue);
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
