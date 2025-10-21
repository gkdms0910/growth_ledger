import 'package:flutter/material.dart';
import 'package:growth_ledger/models/goal.dart';
import 'package:growth_ledger/models/user.dart';
import 'package:growth_ledger/screens/home_screen.dart';
import 'package:growth_ledger/screens/login_screen.dart';
import 'package:growth_ledger/screens/usage_example_screen.dart';
import 'package:growth_ledger/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GrowthLedgerApp());
}

class GrowthLedgerApp extends StatefulWidget {
  final bool? testingIsLoggedIn;
  final List<Goal>? testingGoals;
  final User? testingUser;

  const GrowthLedgerApp({
    super.key,
    this.testingIsLoggedIn,
    this.testingGoals,
    this.testingUser,
  });

  @override
  State<GrowthLedgerApp> createState() => _GrowthLedgerAppState();
}

class _GrowthLedgerAppState extends State<GrowthLedgerApp> {
  final UserService _userService = UserService();

  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoggedIn = false;
  bool _hasCompletedUsageSetup = false;
  bool _isLoading = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    if (widget.testingIsLoggedIn != null) {
      _initializeForTesting();
    } else {
      _initializeFromPreferences();
    }
  }

  void _initializeForTesting() {
    _isLoggedIn = widget.testingIsLoggedIn ?? false;
    _hasCompletedUsageSetup = _isLoggedIn;
    _currentUser = widget.testingUser ??
        User(
          email: 'test@example.com',
          name: '테스트 사용자',
          passwordHash: '',
          createdAt: DateTime.now(),
        );
    _isLoading = false;
  }

  Future<void> _initializeFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString('currentUserEmail');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    User? user;
    bool hasCompletedSetup = false;
    if (storedEmail != null) {
      user = await _userService.findUserByEmail(storedEmail);
      hasCompletedSetup = prefs.getBool(_usageKeyFor(storedEmail)) ?? false;
    }

    setState(() {
      _currentUser = user;
      _isLoggedIn = isLoggedIn && user != null;
      _hasCompletedUsageSetup = _isLoggedIn ? hasCompletedSetup : false;
      _isLoading = false;
    });
  }

  String _usageKeyFor(String email) => 'hasCompletedUsageSetup_$email';

  Future<void> _handleLoginSuccess(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final usageKey = _usageKeyFor(user.email);
    final hasCompleted = prefs.getBool(usageKey) ?? user.preferredCategories.isNotEmpty;

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUserEmail', user.email);
    await prefs.setBool(usageKey, hasCompleted);

    setState(() {
      _currentUser = user;
      _isLoggedIn = true;
      _hasCompletedUsageSetup = hasCompleted;
    });
  }

  Future<void> _handleSignUpComplete(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final usageKey = _usageKeyFor(user.email);

    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('currentUserEmail', user.email);
    await prefs.setBool(usageKey, user.preferredCategories.isNotEmpty);

    setState(() {
      _currentUser = user;
      _isLoggedIn = true;
      _hasCompletedUsageSetup = user.preferredCategories.isNotEmpty;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUserEmail');

    setState(() {
      _isLoggedIn = false;
      _hasCompletedUsageSetup = false;
      _currentUser = null;
    });
  }

  Future<void> _completeUsageSetup(List<String> selectedCategories) async {
    if (_currentUser == null) return;

    await _userService.updatePreferredCategories(_currentUser!.email, selectedCategories);
    final refreshedUser = await _userService.findUserByEmail(_currentUser!.email);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_usageKeyFor(_currentUser!.email), true);

    setState(() {
      _currentUser = refreshedUser ?? _currentUser!..preferredCategories = selectedCategories;
      _hasCompletedUsageSetup = true;
    });
  }

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  void _handleUserUpdated(User updatedUser) {
    setState(() {
      _currentUser = updatedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Growth Ledger',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Pretendard',
        primaryColor: const Color(0xFF424242), // Dark Grey as primary
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light Grey background
        cardColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 1,
          titleTextStyle: TextStyle(
            color: const Color(0xFF424242),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pretendard',
          ),
          iconTheme: IconThemeData(color: const Color(0xFF424242)),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
          titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF616161)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF424242)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF616161)),
          bodySmall: TextStyle(fontSize: 12, color: Color(0xFF757575)),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF757575)),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF424242), // Dark Grey
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Pretendard'),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF424242),
            textStyle: const TextStyle(fontFamily: 'Pretendard'),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF424242),
            side: BorderSide(color: const Color(0xFF424242)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Pretendard'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: const Color(0xFF424242), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
          hintStyle: TextStyle(color: Colors.grey.shade400),
        ),
        colorScheme: ColorScheme.light().copyWith(
          primary: const Color(0xFF424242),
          onPrimary: Colors.white,
          secondary: const Color(0xFF607D8B),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF212121),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Pretendard',
        primaryColor: const Color(0xFFB0BEC5), // Light Blue Grey as primary
        scaffoldBackgroundColor: const Color(0xFF212121), // Dark background
        cardColor: const Color(0xFF2C2C2C),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF212121),
          elevation: 1,
          titleTextStyle: TextStyle(
            color: const Color(0xFFE0E0E0),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pretendard',
          ),
          iconTheme: IconThemeData(color: const Color(0xFFE0E0E0)),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE0E0E0)),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE0E0E0)),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFE0E0E0)),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFE0E0E0)),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFB0BEC5)),
          titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFFCFD8DC)),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFCFD8DC)),
          bodySmall: TextStyle(fontSize: 12, color: Color(0xFFB0BEC5)),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFB0BEC5)),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB0BEC5), // Light Blue Grey
            foregroundColor: const Color(0xFF212121),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Pretendard'),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFB0BEC5),
            textStyle: const TextStyle(fontFamily: 'Pretendard'),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFB0BEC5),
            side: BorderSide(color: const Color(0xFFB0BEC5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Pretendard'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: const Color(0xFFB0BEC5), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          labelStyle: TextStyle(color: Colors.grey.shade400),
          hintStyle: TextStyle(color: Colors.grey.shade600),
        ),
        colorScheme: ColorScheme.dark().copyWith(
          primary: const Color(0xFFB0BEC5),
          onPrimary: const Color(0xFF212121),
          secondary: const Color(0xFF90A4AE),
          onSecondary: const Color(0xFF212121),
          error: Colors.red,
          onError: const Color(0xFF212121),
          surface: const Color(0xFF2C2C2C),
          onSurface: const Color(0xFFE0E0E0),
        ),
      ),
      themeMode: _themeMode,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return LoginScreen(
        onLogin: _handleLoginSuccess,
        onSignUpComplete: _handleSignUpComplete,
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasCompletedUsageSetup) {
      return UsageExampleScreen(onComplete: _completeUsageSetup);
    }

    return HomeScreen(
      changeTheme: _changeTheme,
      onLogout: _logout,
      currentUser: _currentUser!,
      onUserUpdated: _handleUserUpdated,
      testingGoals: widget.testingGoals,
    );
  }
}
