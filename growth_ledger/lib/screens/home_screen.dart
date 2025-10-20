import 'package:flutter/material.dart';
import 'package:growth_ledger/models/goal.dart';
import 'package:growth_ledger/screens/add_goal_screen.dart';
import 'package:growth_ledger/screens/goal_list_screen.dart';
import 'package:growth_ledger/screens/my_page_screen.dart';
import 'package:growth_ledger/screens/settings_screen.dart';
import 'package:growth_ledger/screens/social_screen.dart';
import 'package:growth_ledger/screens/statistics_screen.dart';
import 'package:growth_ledger/services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) changeTheme;
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.changeTheme, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Goal> _goals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goals = await _storageService.readGoals();
    if (!mounted) return;
    setState(() {
      _goals = goals;
      _isLoading = false;
    });
  }

  Future<void> _saveGoals() async {
    await _storageService.writeGoals(_goals);
  }

  Future<void> _addGoal(BuildContext context) async {
    final newGoal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute(builder: (ctx) => const AddGoalScreen()),
    );
    if (newGoal != null) {
      setState(() {
        _goals.add(newGoal);
      });
      await _saveGoals();
    }
  }

  void _updateGoal() {
    _saveGoals();
    setState(() {});
  }

  void _deleteGoal(String id) {
    setState(() {
      _goals.removeWhere((goal) => goal.id == id);
    });
    _saveGoals();
  }

  Future<void> _openGoalSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (goalContext) => GoalListScreen(
          goals: _goals,
          onAddGoal: () => _addGoal(goalContext),
          onUpdateGoal: _updateGoal,
          onDeleteGoal: _deleteGoal,
        ),
      ),
    );
    await _loadGoals();
  }

  Future<void> _openStatistics() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StatisticsScreen(goals: _goals),
      ),
    );
  }

  Future<void> _openMyPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MyPageScreen(),
      ),
    );
  }

  Future<void> _openSocial() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SocialScreen(),
      ),
    );
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(changeTheme: widget.changeTheme, onLogout: widget.onLogout),
      ),
    );
  }

  int get _completedGoalsCount {
    return _goals.where((goal) {
      if (goal.subTasks.isEmpty) {
        return false;
      }
      final completedTasks = goal.subTasks.where((task) => task['isCompleted'] == true).length;
      return completedTasks == goal.subTasks.length;
    }).length;
  }

  Widget _buildSummaryCard(BuildContext context) {
    final remainingGoals = _goals.length - _completedGoalsCount;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '오늘의 한눈에 보기',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: '전체 목표',
                    value: '${_goals.length}',
                    icon: Icons.flag_outlined,
                  ),
                ),
                Expanded(
                  child: _SummaryTile(
                    label: '완료',
                    value: '$_completedGoalsCount',
                    icon: Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: _SummaryTile(
                    label: '진행중',
                    value: '$remainingGoals',
                    icon: Icons.timelapse,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('한눈에 보기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '목표 추가',
            onPressed: () => _addGoal(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadGoals,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  _buildSummaryCard(context),
                  const SizedBox(height: 16),
                  _NavigationCard(
                    icon: Icons.person_outline,
                    title: '마이 페이지',
                    description: '프로필과 개인 설정을 확인하세요.',
                    onTap: _openMyPage,
                  ),
                  _NavigationCard(
                    icon: Icons.playlist_add_check_outlined,
                    title: '목표 설정',
                    description: '새로운 목표를 세우고 세부 계획을 관리하세요.',
                    onTap: _openGoalSetup,
                  ),
                  _NavigationCard(
                    icon: Icons.settings_outlined,
                    title: '환경 설정',
                    description: '앱 환경과 알림을 취향대로 조절하세요.',
                    onTap: _openSettings,
                  ),
                  _NavigationCard(
                    icon: Icons.groups_outlined,
                    title: '소셜',
                    description: '비슷한 목표를 가진 사람들과 진행 상황을 나눠요.',
                    onTap: _openSocial,
                  ),
                  _NavigationCard(
                    icon: Icons.bar_chart_outlined,
                    title: '목표 달성 현황',
                    description: '누적 데이터와 통계를 한 눈에 살펴보세요.',
                    onTap: _openStatistics,
                  ),
                ],
              ),
            ),
    );
  }
}

class _NavigationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
