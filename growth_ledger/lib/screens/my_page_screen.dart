import 'package:flutter/material.dart';
import 'package:growth_ledger/models/goal.dart';
import 'package:growth_ledger/models/user.dart';
import 'package:growth_ledger/services/user_service.dart';
import 'package:intl/intl.dart';

class MyPageScreen extends StatefulWidget {
  final User user;
  final List<Goal> goals;
  final ValueChanged<User> onUserUpdated;

  const MyPageScreen({
    super.key,
    required this.user,
    required this.goals,
    required this.onUserUpdated,
  });

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final UserService _userService = UserService();
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  void didUpdateWidget(covariant MyPageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _user = widget.user;
    }
  }

  int get _completedGoalsCount {
    return widget.goals.where((goal) {
      if (goal.subTasks.isEmpty) return false;
      final completedTasks = goal.subTasks.where((task) => task['isCompleted'] == true).length;
      return completedTasks == goal.subTasks.length;
    }).length;
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _user.name);
    final bioController = TextEditingController(text: _user.bio ?? '');

    final updated = await showModalBottomSheet<User>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('프로필 편집', style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                decoration: const InputDecoration(
                  labelText: '한 줄 소개',
                  hintText: '현재 목표나 관심사를 간단히 적어보세요.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  final trimmedName = nameController.text.trim();
                  if (trimmedName.isEmpty) {
                    ScaffoldMessenger.of(sheetContext).showSnackBar(
                      const SnackBar(content: Text('이름을 입력해주세요.')),
                    );
                    return;
                  }
                  Navigator.of(sheetContext).pop(
                    _user.copyWith(
                      name: trimmedName,
                      bio: bioController.text.trim().isEmpty ? null : bioController.text.trim(),
                    ),
                  );
                },
                child: const Text('저장하기'),
              ),
            ],
          ),
        );
      },
    );

    if (updated == null) return;

    await _userService.updateUser(updated);
    widget.onUserUpdated(updated);
    setState(() {
      _user = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final createdAtText = DateFormat('yyyy년 MM월 dd일').format(_user.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이 페이지'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '프로필 편집',
            onPressed: _editProfile,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                child: Text(
                  _user.name.characters.first,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_user.name, style: theme.textTheme.headlineSmall),
                    Text(_user.email, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      '가입일 $createdAtText',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_user.bio != null && _user.bio!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              _user.bio!,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 24),
          Text('나의 목표 현황', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _buildStatsRow(theme),
          if (_user.preferredCategories.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('관심 목표 유형', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _user.preferredCategories
                  .map((category) => Chip(label: Text(category)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: const Text('다음 목표는 무엇인가요?'),
              subtitle: const Text('관심 카테고리를 기반으로 새로운 목표를 추가해보세요.'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    final totalGoals = widget.goals.length;
    final completedGoals = _completedGoalsCount;
    final inProgress = totalGoals - completedGoals;

    return Row(
      children: [
        Expanded(
          child: _ProfileStatTile(
            label: '전체 목표',
            value: '$totalGoals',
            icon: Icons.flag_outlined,
          ),
        ),
        Expanded(
          child: _ProfileStatTile(
            label: '완료',
            value: '$completedGoals',
            icon: Icons.check_circle_outline,
          ),
        ),
        Expanded(
          child: _ProfileStatTile(
            label: '진행중',
            value: '$inProgress',
            icon: Icons.timelapse,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileStatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
