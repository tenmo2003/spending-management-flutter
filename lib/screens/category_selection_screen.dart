import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({Key? key}) : super(key: key);

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  final List<Map<String, dynamic>> categories = [
    {'name': 'Housing', 'icon': Icons.home},
    {'name': 'Transportation', 'icon': Icons.directions_car},
    {'name': 'Groceries', 'icon': Icons.shopping_cart},
    {'name': 'Food & Drink', 'icon': Icons.restaurant},
    {'name': 'Healthcare', 'icon': Icons.local_hospital},
    {'name': 'Entertainment', 'icon': Icons.movie},
    {'name': 'Clothing', 'icon': Icons.shopping_bag},
    {'name': 'Gift', 'icon': Icons.card_giftcard},
  ];

  final Set<String> selectedCategories = {};

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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Welcome to Your\nSpending Tracker!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select at least 3 categories that best match your spending habits:',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((category) {
                        final isSelected =
                            selectedCategories.contains(category['name']);
                        return FilterChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                category['icon'] as IconData,
                                size: 18,
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(width: 8),
                              Text(category['name'] as String),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedCategories
                                    .add(category['name'] as String);
                              } else {
                                selectedCategories
                                    .remove(category['name'] as String);
                              }
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.7),
                          selectedColor:
                              Theme.of(context).colorScheme.secondary,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedCategories.length >= 3
                        ? () async {
                            // final prefs = await SharedPreferences.getInstance();
                            // await prefs.setStringList('selectedCategories',
                            //     selectedCategories.toList());
                            // await prefs.setBool('isFirstTime', false);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Continue',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
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
