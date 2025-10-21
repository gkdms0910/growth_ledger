import 'package:flutter/material.dart';
import 'package:growth_ledger/models/user.dart';
import 'package:growth_ledger/screens/category_management_screen.dart';
import 'package:growth_ledger/services/storage_service.dart';
import 'package:growth_ledger/services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) changeTheme;
  final VoidCallback onLogout;
  final User currentUser;
  final ValueChanged<User> onUserUpdated;

  const SettingsScreen({
    super.key,
    required this.changeTheme,
    required this.onLogout,
    required this.currentUser,
    required this.onUserUpdated,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  late User _user;
  bool _notificationsEnabled = true;
  bool _emailSummaryEnabled = false;

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser;
    _notificationsEnabled = _user.notificationsEnabled;
    _emailSummaryEnabled = _user.emailSummaryEnabled;
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentUser != widget.currentUser) {
      _user = widget.currentUser;
      _notificationsEnabled = _user.notificationsEnabled;
      _emailSummaryEnabled = _user.emailSummaryEnabled;
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<User?> _updateNotificationPreference({bool? notifications, bool? emailSummary}) async {
    try {
      final updated = await _userService.updateNotificationPreferences(
        email: _user.email,
        notificationsEnabled: notifications,
        emailSummaryEnabled: emailSummary,
      );
      if (updated == null) {
        if (!mounted) return null;
        _showSnack('사용자 정보를 불러오지 못했습니다.');
        return null;
      }
      return updated;
    } catch (_) {
      if (!mounted) return null;
      _showSnack('설정을 저장하는 중 문제가 발생했습니다. 다시 시도해주세요.');
      return null;
    }
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    final previousNotifications = _notificationsEnabled;
    setState(() {
      _notificationsEnabled = value;
    });

    final updatedUser = await _updateNotificationPreference(notifications: value);
    if (!mounted) return;

    if (updatedUser == null) {
      setState(() {
        _notificationsEnabled = previousNotifications;
      });
      return;
    }

    setState(() {
      _user = updatedUser;
      _notificationsEnabled = updatedUser.notificationsEnabled;
      _emailSummaryEnabled = updatedUser.emailSummaryEnabled;
    });
    widget.onUserUpdated(updatedUser);
  }

  Future<void> _setEmailSummaryEnabled(bool value) async {
    final previousEmailSummary = _emailSummaryEnabled;
    setState(() {
      _emailSummaryEnabled = value;
    });

    final updatedUser = await _updateNotificationPreference(emailSummary: value);
    if (!mounted) return;

    if (updatedUser == null) {
      setState(() {
        _emailSummaryEnabled = previousEmailSummary;
      });
      return;
    }

    setState(() {
      _user = updatedUser;
      _notificationsEnabled = updatedUser.notificationsEnabled;
      _emailSummaryEnabled = updatedUser.emailSummaryEnabled;
    });
    widget.onUserUpdated(updatedUser);
  }

  Future<void> _editPreferredCategories() async {
    final storedCategories = await _storageService.readCategories();
    final options = storedCategories.isEmpty
        ? const ['General', 'Health', 'Finance', 'Learning', 'Personal Growth']
        : storedCategories;
    final selected = {..._user.preferredCategories};

    if (!mounted) return;

    final updated = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setStateDialog) {
            return AlertDialog(
              title: const Text('관심 목표 유형 선택'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: options
                      .map(
                        (category) => CheckboxListTile(
                          value: selected.contains(category),
                          title: Text(category),
                          onChanged: (checked) {
                            setStateDialog(() {
                              if (checked == true) {
                                selected.add(category);
                              } else {
                                selected.remove(category);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(statefulContext).pop(),
                  child: const Text('취소'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(statefulContext).pop(selected.toList());
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == null) return;

    final updatedUser = _user.copyWith(preferredCategories: updated);
    await _userService.updateUser(updatedUser);
    if (!mounted) return;
    widget.onUserUpdated(updatedUser);
    setState(() {
      _user = updatedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('다크 모드'),
            subtitle: const Text('테마를 라이트/다크 모드로 전환합니다.'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) {
                widget.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
              },
              thumbColor: WidgetStateProperty.resolveWith<Color?>(
                (states) =>
                    states.contains(WidgetState.selected) ? Theme.of(context).colorScheme.secondary : null,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('앱 알림'),
            subtitle: const Text('목표 일정과 소셜 피드를 위한 알림을 받습니다.'),
            value: _notificationsEnabled,
            onChanged: (value) {
              _setNotificationsEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.email_outlined),
            title: const Text('주간 이메일 요약'),
            subtitle: const Text('주간 목표 요약과 추천 콘텐츠를 이메일로 받습니다.'),
            value: _emailSummaryEnabled,
            onChanged: (value) {
              _setEmailSummaryEnabled(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('카테고리 관리'),
            subtitle: const Text('목표에 사용할 카테고리 목록을 편집합니다.'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CategoryManagementScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: const Text('관심 목표 다시 선택'),
            subtitle: const Text('온보딩에서 선택한 목표 유형을 수정합니다.'),
            onTap: _editPreferredCategories,
          ),
          if (_user.preferredCategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '선호 목표 유형',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _user.preferredCategories
                        .map((category) => Chip(label: Text(category)))
                        .toList(),
                  ),
                ],
              ),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: widget.onLogout,
          ),
        ],
      ),
    );
  }
}
