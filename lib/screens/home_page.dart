import 'package:flutter/material.dart';
import '../widgets/summary_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_transactions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    loadSelectedCategories();
  }

  Future<void> loadSelectedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedCategories = prefs.getStringList('selectedCategories') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SummaryCard(categories: selectedCategories),
            QuickActions(categories: selectedCategories),
            const RecentTransactions(),
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

