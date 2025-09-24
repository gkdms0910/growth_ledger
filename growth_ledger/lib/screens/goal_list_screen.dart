import 'package:flutter/material.dart';
import 'package:growth_ledger/models/goal.dart';
import 'package:growth_ledger/screens/add_goal_screen.dart';
import 'package:growth_ledger/screens/goal_detail_screen.dart';

class GoalListScreen extends StatelessWidget {
  final List<Goal> goals;
  final Function(List<Goal>) onUpdate;

  const GoalListScreen({super.key, required this.goals, required this.onUpdate});

  void _navigateToAddGoalScreen(BuildContext context) async {
    final newGoal = await Navigator.of(context).push<Goal>(
      MaterialPageRoute(builder: (ctx) => const AddGoalScreen()),
    );

    if (newGoal != null) {
      goals.add(newGoal);
      onUpdate(goals);
    }
  }

  void _deleteGoal(int index) {
    goals.removeAt(index);
    onUpdate(goals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 목표'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddGoalScreen(context),
          ),
        ],
      ),
      body: goals.isEmpty
          ? const Center(
              child: Text(
                '아직 목표가 없어요.\n오른쪽 위의 + 버튼으로 첫 목표를 추가해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return Dismissible(
                  key: Key(goal.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteGoal(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('목표가 삭제되었습니다.')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: ListTile(
                      title: Text(goal.title),
                      subtitle: Text(goal.category),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => GoalDetailScreen(goal: goal, onUpdate: () => onUpdate(goals)),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}