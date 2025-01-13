import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spending_management_app/database/dao/category_dao.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/category_spending.dart';
import 'package:spending_management_app/model/transaction.dart';
import 'package:spending_management_app/providers/category_notifier.dart';
import 'package:spending_management_app/providers/transaction_notifier.dart';
import 'package:spending_management_app/widgets/add_transaction_dialog.dart';
import 'package:spending_management_app/widgets/recent_transactions.dart';
import 'package:spending_management_app/widgets/summary_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<Transaction> _recentTransactions = [];
  List<CategorySpending> topCategories = [];
  double totalSpent = 0;
  double totalIncome = 0;
  double balance = 0;
  bool _isLoading = true;
  bool _dataLoaded = false;

  int lastUpdateTransaction = 0;

  static const numberOfTopCategories = 3;
  static const numberOfRecentTransaction = 5;

  final transactionDao = TransactionDao.instance;
  final categoryDao = CategoryDao.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();

    _loadCategoryProviderState();
  }

  Future<void> _loadCategoryProviderState() async {
    await ref.read(categoryNotifierProvider.notifier).loadSavedCategories();
  }

  Future<void> _loadData() async {
    // Only load data if it hasn't been loaded before or there are new updates
    if (_dataLoaded) return;

    try {
      await Future.wait([
        _loadRecentTransactions(),
        _loadTopCategories(),
        _loadBalance(),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _dataLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadRecentTransactions() async {
    final transactions = await transactionDao.getAllTransactions(limit: 5);
    setState(() {
      _recentTransactions =
          transactions.take(numberOfRecentTransaction).toList();
    });
  }

  Future<void> _loadTopCategories() async {
    topCategories = await transactionDao.getTopNCategories(
        numberOfTopCategories, TransactionType.expense);
  }

  Future<void> _loadBalance() async {
    totalSpent =
        await transactionDao.getTotalAmount(type: TransactionType.expense);

    totalIncome =
        await transactionDao.getTotalAmount(type: TransactionType.income);

    balance = totalIncome - totalSpent;
  }

  // Refresh method to be called when new expense is added
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _dataLoaded = false;
    });

    await _loadData();
  }

  Widget _buildShimmerSummaryCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.all(16),
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildShimmerRecentTransactions() {
    return Column(
      children: List.generate(3, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(transactionLastUpdateNotifierProvider, (previous, next) {
      if (next > lastUpdateTransaction) {
        lastUpdateTransaction = next;
        _refreshData();
      }
    });

    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Spending'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Implement settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerSummaryCard(),
                  _buildShimmerRecentTransactions(),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryCard(
                    topCategories: topCategories,
                    balance: balance,
                    totalIncome: totalIncome,
                    totalSpent: totalIncome,
                  ),
                  RecentTransactions(
                    recentTransactions: _recentTransactions,
                    onTransactionsChanged: _refreshData,
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddTransactionDialog(onTransactionAdded: _refreshData);
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
