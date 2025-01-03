import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spending_management_app/database/dao/category_dao.dart';
import 'package:spending_management_app/model/transaction.dart';
import 'package:spending_management_app/screens/main_navigation_page.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> expenseCategories = [
    {'name': 'Housing', 'icon': Icons.home},
    {'name': 'Transportation', 'icon': Icons.directions_car},
    {'name': 'Groceries', 'icon': Icons.shopping_cart},
    {'name': 'Food & Drink', 'icon': Icons.restaurant},
    {'name': 'Healthcare', 'icon': Icons.local_hospital},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Clothing', 'icon': Icons.shopping_bag},
    {'name': 'Gift', 'icon': Icons.card_giftcard},
  ];

  final List<Map<String, dynamic>> incomeCategories = [
    {'name': 'Salary', 'icon': Icons.account_balance_wallet},
    {'name': 'Bonus', 'icon': Icons.stars},
    {'name': 'Investment', 'icon': Icons.trending_up},
    {'name': 'Gift', 'icon': Icons.redeem},
  ];

  final Set<String> selectedExpenseCategories = {};
  final Set<String> selectedIncomeCategories = {};
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  bool showingIncomeSelection = false;
  final categoryDao = CategoryDao.instance;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showIncomeSelection() {
    setState(() {
      showingIncomeSelection = true;
    });
    _animationController.forward();
  }

  void _showExpenseSelection() {
    setState(() {
      showingIncomeSelection = false;
    });
    _animationController.reverse();
  }

  bool get canProceedToIncome => selectedExpenseCategories.length >= 3;
  bool get canFinish => selectedIncomeCategories.length >= 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
              Theme.of(context).colorScheme.secondary.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Welcome to Your\nSpending Tracker!',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  showingIncomeSelection
                      ? 'Select at least 1 income category that matches your income sources.'
                      : 'Select at least 3 expense categories that best match your spending habits.',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Stack(
                    children: [
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset.zero,
                          end: const Offset(-1.0, 0.0),
                        ).animate(_animation),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: expenseCategories.map((category) {
                                final isSelected = selectedExpenseCategories
                                    .contains(category['name']);
                                return FilterChip(
                                  showCheckmark: false,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category['icon'] as IconData,
                                        size: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category['name'] as String),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedExpenseCategories
                                            .add(category['name'] as String);
                                      } else {
                                        selectedExpenseCategories
                                            .remove(category['name'] as String);
                                      }
                                    });
                                  },
                                  backgroundColor:
                                      Colors.white.withOpacity(0.7),
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(_animation),
                        child: FadeTransition(
                          opacity: ReverseAnimation(_fadeAnimation),
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: incomeCategories.map((category) {
                                final isSelected = selectedIncomeCategories
                                    .contains(category['name']);
                                return FilterChip(
                                  showCheckmark: false,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category['icon'] as IconData,
                                        size: 18,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(category['name'] as String),
                                    ],
                                  ),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        selectedIncomeCategories
                                            .add(category['name'] as String);
                                      } else {
                                        selectedIncomeCategories
                                            .remove(category['name'] as String);
                                      }
                                    });
                                  },
                                  backgroundColor:
                                      Colors.white.withOpacity(0.7),
                                  selectedColor:
                                      Theme.of(context).colorScheme.primary,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: [
                      if (showingIncomeSelection)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _showExpenseSelection,
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Back to Expense Categories'),
                            ),
                          ),
                        ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: showingIncomeSelection
                              ? (canFinish
                                  ? () async {
                                      // Save expense categories
                                      await categoryDao.addCategories(
                                          selectedExpenseCategories.toList(),
                                          TransactionType.expense);

                                      // Save income categories
                                      await categoryDao.addCategories(
                                          selectedIncomeCategories.toList(),
                                          TransactionType.income);

                                      // Mark first time setup as complete
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool('isFirstTime', false);

                                      if (mounted) {
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const MainNavigationPage(),
                                          ),
                                        );
                                      }
                                    }
                                  : null)
                              : (canProceedToIncome
                                  ? _showIncomeSelection
                                  : null),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              showingIncomeSelection ? 'Get Started' : 'Next',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
