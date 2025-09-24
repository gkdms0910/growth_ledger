import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  final Function(ThemeMode) changeTheme;
  const SettingsScreen({super.key, required this.changeTheme});

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
              activeColor: Theme.of(context).colorScheme.secondary,
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
        ],
      ),
    );
  }
}