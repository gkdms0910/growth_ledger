import 'package:flutter/material.dart';
import 'package:growth_ledger/screens/category_management_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) changeTheme;
  final VoidCallback onLogout;

  const SettingsScreen({super.key, required this.changeTheme, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('다크 모드'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                changeTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
              activeThumbColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('프로필'),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('알림'),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('카테고리 관리'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CategoryManagementScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
