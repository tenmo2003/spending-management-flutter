import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/transaction.dart';
import 'package:spending_management_app/providers/currency_notifier.dart';

class RecentTransactions extends ConsumerStatefulWidget {
  final List<Transaction> recentTransactions;
  final VoidCallback onTransactionsChanged;

  const RecentTransactions(
      {super.key,
      required this.recentTransactions,
      required this.onTransactionsChanged});

  @override
  _RecentTransactionsState createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends ConsumerState<RecentTransactions> {
  final transactionDao = TransactionDao.instance;

  void _showTransactionOptions(BuildContext context, Transaction transaction) {
    _showEditTransactionDialog(transaction);
  }

  void _showEditTransactionDialog(Transaction transaction) {
    final nameController = TextEditingController(text: transaction.name);
    final amountController =
        TextEditingController(text: transaction.amount.toString());
    final categoryController =
        TextEditingController(text: transaction.category);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                // Validate inputs
                if (nameController.text.isEmpty ||
                    amountController.text.isEmpty ||
                    categoryController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  // Create updated transaction
                  final updatedTransaction = Transaction(
                    id: transaction.id,
                    name: nameController.text,
                    amount: double.parse(amountController.text),
                    category: categoryController.text,
                    date: transaction.date,
                    type: transaction.type,
                  );

                  // Update in database
                  await transactionDao.updateTransaction(updatedTransaction);

                  // Notify parent to refresh data
                  widget.onTransactionsChanged();

                  // Close dialog
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating transaction: $e')),
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => _deleteTransaction(transaction),
            ),
          ],
        );
      },
    );
  }

  void _deleteTransaction(Transaction transaction) async {
    try {
      // Show confirmation dialog
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Transaction'),
            content:
                const Text('Are you sure you want to delete this transaction?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      // Proceed with deletion if confirmed
      if (confirmDelete == true) {
        await transactionDao.deleteTransaction(transaction.id);

        // Notify parent to refresh data
        widget.onTransactionsChanged();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting transaction: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          widget.recentTransactions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No recent transactions')),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.recentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = widget.recentTransactions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(transaction.category[0].toUpperCase()),
                      ),
                      title: Text(transaction.name),
                      subtitle: Text(
                        '${transaction.category} • ${DateFormat('dd MMM yyyy').format(transaction.date)}',
                      ),
                      trailing: Text(
                        ref.watch(formattedAmountProvider(transaction.amount)),
                        style: TextStyle(
                          color: transaction.type == TransactionType.expense
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      onTap: () =>
                          _showTransactionOptions(context, transaction),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
