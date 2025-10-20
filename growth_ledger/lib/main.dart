import 'package:flutter/material.dart';
import 'package:growth_ledger/screens/home_screen.dart';
import 'package:growth_ledger/screens/login_screen.dart';
import 'package:growth_ledger/screens/usage_example_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GrowthLedgerApp());
}

class GrowthLedgerApp extends StatefulWidget {
  const GrowthLedgerApp({super.key});

  @override
  State<GrowthLedgerApp> createState() => _GrowthLedgerAppState();
}

class _GrowthLedgerAppState extends State<GrowthLedgerApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoggedIn = false;
  bool _hasCompletedUsageSetup = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _hasCompletedUsageSetup = prefs.getBool('hasCompletedUsageSetup') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    setState(() {
      _isLoggedIn = true;
      _hasCompletedUsageSetup = prefs.getBool('hasCompletedUsageSetup') ?? false;
    });
  }

  Future<void> _handleSignUp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('hasCompletedUsageSetup', false);
    setState(() {
      _isLoggedIn = true;
      _hasCompletedUsageSetup = false;
    });
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    setState(() {
      _isLoggedIn = false;
    });
  }

  Future<void> _completeUsageSetup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedUsageSetup', true);
    setState(() {
      _hasCompletedUsageSetup = true;
    });
  }

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growth Ledger',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.light,
        ).copyWith(primary: Colors.black, secondary: Colors.blueAccent),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
        ).copyWith(primary: Colors.white, secondary: Colors.lightBlueAccent),
      ),
      themeMode: _themeMode,
      home: _isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : !_isLoggedIn
              ? LoginScreen(onLogin: _login, onSignUpComplete: _handleSignUp)
              : !_hasCompletedUsageSetup
                  ? UsageExampleScreen(onComplete: _completeUsageSetup)
                  : HomeScreen(changeTheme: _changeTheme, onLogout: _logout),
    );
  }
}
