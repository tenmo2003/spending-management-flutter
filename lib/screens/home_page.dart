import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:spending_management_app/database/dao/category_dao.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/category_spending.dart';
import 'package:spending_management_app/model/transaction.dart';
import 'package:spending_management_app/widgets/quick_actions.dart';
import 'package:spending_management_app/widgets/recent_transactions.dart';
import 'package:spending_management_app/widgets/summary_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  List<Transaction> _recentTransactions = [];
  List<CategorySpending> topCategories = [];
  List<String> categories = [];
  double totalSpent = 0;
  bool _isLoading = true;
  bool _dataLoaded = false;

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
  }

  Future<void> _loadData() async {
    // Only load data if it hasn't been loaded before
    if (_dataLoaded) return;

    try {
      await Future.wait([
        _loadRecentTransactions(),
        _loadTopCategories(),
        _loadTotalSpent(),
        _loadAllCategories(),
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
    final transactions = await transactionDao.getAllTransactions(
      type: TransactionType.expense,
      // Limit to last 5 recent transactions
    );
    setState(() {
      _recentTransactions =
          transactions.take(numberOfRecentTransaction).toList();
    });
  }

  Future<void> _loadTopCategories() async {
    topCategories = await transactionDao.getTopNCategories(
        numberOfTopCategories, TransactionType.expense);
  }

  Future<void> _loadTotalSpent() async {
    totalSpent =
        await transactionDao.getTotalAmount(type: TransactionType.expense);
  }

  Future<void> _loadAllCategories() async {
    categories = await categoryDao.getCategoriesByType(TransactionType.expense);
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

  Widget _buildShimmerQuickActions() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 100,
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
                  _buildShimmerQuickActions(),
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
                    totalSpent: totalSpent,
                  ),
                  QuickActions(
                    categories: categories,
                    onExpenseAdded: _refreshData,
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
          // TODO: Implement add new transaction
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
