
import 'package:flutter/material.dart';
import 'package:growth_ledger/models/goal.dart';
import 'package:growth_ledger/screens/dashboard_screen.dart';
import 'package:growth_ledger/screens/goal_list_screen.dart';
import 'package:growth_ledger/screens/settings_screen.dart';
import 'package:growth_ledger/services/storage_service.dart';

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
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        ),
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.light).copyWith(
          primary: Colors.black,
          secondary: Colors.blueAccent,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
          primary: Colors.white,
          secondary: Colors.lightBlueAccent,
        ),
      ),
      themeMode: _themeMode,
      home: HomeScreen(changeTheme: _changeTheme),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) changeTheme;
  const HomeScreen({super.key, required this.changeTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Goal> _goals = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _storageService.readGoals();
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  Future<void> _updateGoals() async {
    // This function now just saves the current state of _goals
    await _storageService.writeGoals(_goals);
    // We might want to refetch or just trust the current state
    setState(() {}); // Refresh UI
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      DashboardScreen(goals: _goals),
      GoalListScreen(goals: _goals, onUpdate: (updatedGoals) {
        setState(() { _goals = updatedGoals; });
        _storageService.writeGoals(_goals);
      }),
      SettingsScreen(changeTheme: widget.changeTheme),
    ];

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: '대시보드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_outlined),
            label: '목표',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: '설정',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Theme-aware colors will be picked up automatically
        // selectedItemColor: Colors.black,
        // unselectedItemColor: Colors.grey[400],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        // backgroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}
