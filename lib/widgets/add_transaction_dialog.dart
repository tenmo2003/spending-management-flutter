import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/category.dart';
import 'package:spending_management_app/model/group_item.dart';
import 'package:spending_management_app/model/transaction.dart';
import 'package:spending_management_app/providers/category_notifier.dart';
import 'package:spending_management_app/widgets/grouped_dropdown_button.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final Function onTransactionAdded;

  const AddTransactionDialog({super.key, required this.onTransactionAdded});

  @override
  _AddTransactionDialogState createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  late Category selectedCategory;
  late List<Category> categories;

  @override
  void initState() {
    super.initState();
    categories = ref.read(categoryNotifierProvider);
    selectedCategory = categories.first;
  }

  @override
  Widget build(BuildContext context) {
    final displayCategories = <DropdownGroupItem>[];
    displayCategories.add(DropdownGroupItem(
        label: "Expense",
        children: categories
            .where((category) => category.type == TransactionType.expense)
            .map((category) => DropdownItem(
                value: "${category.name}-${category.type.name}",
                label: category.name))
            .toList()));

    displayCategories.add(DropdownGroupItem(
        label: "Income",
        children: categories
            .where((category) => category.type == TransactionType.income)
            .map((category) => DropdownItem(
                value: "${category.name}-${category.type.name}",
                label: category.name))
            .toList()));

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
          GroupedDropdownButton(
            items: displayCategories,
            selectedItemValue:
                "${selectedCategory.name}-${selectedCategory.type.name}",
            onChanged: (item) => {
              setState(() {
                if (item == null) return;

                selectedCategory = categories.firstWhere((category) =>
                    "${category.name}-${category.type.name}" == item);
              })
            },
          )
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
