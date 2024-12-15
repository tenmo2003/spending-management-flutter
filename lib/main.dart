import 'package:flutter/material.dart';
import 'package:spending_management_app/screens/home_page.dart';
import 'screens/category_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spending Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FirstTimeCheck(),
    );
  }
}

class FirstTimeCheck extends StatefulWidget {
  const FirstTimeCheck({super.key});

  @override
  _FirstTimeCheckState createState() => _FirstTimeCheckState();
}

class _FirstTimeCheckState extends State<FirstTimeCheck> {
  @override
  void initState() {
    super.initState();
    checkFirstTime();
  }

  Future<void> checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (mounted) {
      if (isFirstTime) {
        // First time user, show category selection screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => const CategorySelectionScreen()),
        );
      } else {
        // Returning user, show home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
