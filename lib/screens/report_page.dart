import "dart:math" show pi;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spending_management_app/database/dao/category_dao.dart';
import 'package:spending_management_app/database/dao/transaction_dao.dart';
import 'package:spending_management_app/model/category_spending.dart';
import 'package:spending_management_app/model/monthly_category_spending.dart';
import 'package:spending_management_app/model/transaction.dart';
import 'package:spending_management_app/providers/currency_notifier.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage>
    with SingleTickerProviderStateMixin {
  final transactionDao = TransactionDao.instance;
  final categoryDao = CategoryDao.instance;
  List<CategorySpending> _topExpenseCategories = [];
  List<CategorySpending> _topIncomeCategories = [];
  double _totalExpenses = 0;
  double _totalIncome = 0;
  bool _isLoading = true;

  // New chart data variables
  List<MonthlySpending> _expenseMonthlyData = [];
  List<MonthlySpending> _incomeMonthlyData = [];
  List<CategorySpending> _expensePieData = [];
  List<CategorySpending> _incomePieData = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      // Load Expense Reports
      final topExpenseCategories =
          await transactionDao.getTopNCategories(3, TransactionType.expense);
      final totalExpenses =
          await transactionDao.getTotalAmount(type: TransactionType.expense);

      // Load Income Reports
      final topIncomeCategories =
          await transactionDao.getTopNCategories(3, TransactionType.income);
      final totalIncome =
          await transactionDao.getTotalAmount(type: TransactionType.income);

      // Load Monthly Transaction Data
      final expenseMonthlyData =
          await transactionDao.getMonthlyTransactions(TransactionType.expense);
      final incomeMonthlyData =
          await transactionDao.getMonthlyTransactions(TransactionType.income);

      // Load Pie Chart Data
      final expensePieData =
          await categoryDao.getCategoryPieData(TransactionType.expense);
      final incomePieData =
          await categoryDao.getCategoryPieData(TransactionType.income);

      if (mounted) {
        setState(() {
          _topExpenseCategories = topExpenseCategories;
          _topIncomeCategories = topIncomeCategories;
          _totalExpenses = totalExpenses;
          _totalIncome = totalIncome;

          // Set chart data
          _expenseMonthlyData = expenseMonthlyData;
          _incomeMonthlyData = incomeMonthlyData;
          _expensePieData = expensePieData;
          _incomePieData = incomePieData;

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading reports: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to create line chart
  Widget _buildLineChart(List<MonthlySpending> monthlyData) {
    // Convert monthly data to line chart points
    final List<FlSpot> chartPoints = monthlyData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data.amount);
    }).toList();

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minY: 0,
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 32,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < monthlyData.length) {
                      return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(monthlyData[value.toInt()].month,
                              style: const TextStyle(fontSize: 12)));
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 500,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: chartPoints,
                isCurved: true,
                color: Colors.blue,
                barWidth: 4,
                belowBarData: BarAreaData(
                    show: true, color: Colors.blue.withOpacity(0.3)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create pie chart
  Widget _buildPieChart(List<CategorySpending> pieData) {
    // Calculate total for percentage
    final total = pieData.fold(0.0, (sum, item) => sum + item.amount);

    return AspectRatio(
      aspectRatio: 1,
      child: PieChart(
        PieChartData(
          sections: pieData.map((item) {
            final amount = item.amount;
            final percentage = (amount / total) * 100;
            return PieChartSectionData(
              color: _getColorForCategory(item.categoryName),
              value: amount,
              title: '${item.categoryName}\n${percentage.toStringAsFixed(1)}%',
              titleStyle: const TextStyle(fontWeight: FontWeight.bold),
              radius: 120,
            );
          }).toList(),
          centerSpaceRadius: 40,
          sectionsSpace: 2,
        ),
      ),
    );
  }

  // Helper method to generate consistent colors for categories
  Color _getColorForCategory(String category) {
    // Simple color generation based on category name
    final hash = category.hashCode;
    return Color((hash & 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Financial Reports'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Expenses', icon: Icon(Icons.trending_down)),
              Tab(text: 'Income', icon: Icon(Icons.trending_up)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // TODO: Implement date range filtering
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Expenses Tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Expenses Summary
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Expenses',
                                          style: TextStyle(fontSize: 16)),
                                      Text(
                                          ref.watch(formattedAmountProvider(
                                              _totalExpenses)),
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Top Expense Categories',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // Replace SummaryCard with custom category list
                          ..._topExpenseCategories.map((category) => Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(category.categoryName),
                                  trailing: Text(
                                    ref.watch(formattedAmountProvider(
                                        category.amount)),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 16),
                          const Text('Monthly Expenses',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildLineChart(_expenseMonthlyData),
                          const SizedBox(height: 16),
                          const Text('Expense Categories',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildPieChart(_expensePieData),
                        ],
                      ),
                    ),
                  ),

                  // Income Tab
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total Income Summary
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Total Income',
                                          style: TextStyle(fontSize: 16)),
                                      Text(
                                          ref.watch(formattedAmountProvider(
                                              _totalIncome)),
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Top Income Categories',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // Replace SummaryCard with custom category list
                          ..._topIncomeCategories.map((category) => Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(category.categoryName),
                                  trailing: Text(
                                    ref.watch(formattedAmountProvider(
                                        category.amount)),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 16),
                          const Text('Monthly Income',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildLineChart(_incomeMonthlyData),
                          const SizedBox(height: 16),
                          const Text('Income Categories',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildPieChart(_incomePieData),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
