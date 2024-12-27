import 'package:flutter/material.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/transaction.dart';
import 'package:sprintf/sprintf.dart';
import 'package:intl/intl.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> with AutomaticKeepAliveClientMixin {
  final transactionDao = TransactionDao.instance;
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  TransactionType _selectedType = TransactionType.expense;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await transactionDao.getAllTransactions(type: _selectedType);
      if (mounted) {
        setState(() {
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEditTransactionDialog(Transaction transaction) {
    final nameController = TextEditingController(text: transaction.name);
    final amountController = TextEditingController(text: transaction.amount.toString());
    final categoryController = TextEditingController(text: transaction.category);

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

                  // Refresh transactions
                  await _loadTransactions();

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
              onPressed: () async {
                // Show confirmation
                bool? confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Transaction'),
                      content: const Text(
                          'Are you sure you want to delete this transaction?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );

                // Proceed with deletion if confirmed
                if (confirmDelete == true) {
                  await transactionDao.deleteTransaction(transaction.id);
                  
                  // Refresh transactions
                  await _loadTransactions();

                  // Close both dialogs
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ToggleButtons(
                isSelected: [
                  _selectedType == TransactionType.expense,
                  _selectedType == TransactionType.income
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedType = index == 0 
                      ? TransactionType.expense 
                      : TransactionType.income;
                    _loadTransactions();
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Expenses'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Income'),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement advanced filtering
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(transaction.category[0].toUpperCase()),
                        ),
                        title: Text(transaction.name),
                        subtitle: Text(
                          '${transaction.category} • ${DateFormat('dd MMM yyyy').format(transaction.date)}',
                        ),
                        trailing: Text(
                          sprintf('\$%.2f', [transaction.amount]),
                          style: TextStyle(
                            color: transaction.type == TransactionType.expense 
                              ? Colors.red 
                              : Colors.green,
                          ),
                        ),
                        onTap: () => _showEditTransactionDialog(transaction),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add new transaction
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
