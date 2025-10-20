import 'package:flutter/material.dart';
import 'package:growth_ledger/models/goal.dart';
import 'package:growth_ledger/screens/goal_detail_screen.dart';

class GoalListScreen extends StatelessWidget {
  final List<Goal> goals;
  final VoidCallback onAddGoal;
  final VoidCallback onUpdateGoal;
  final Function(String) onDeleteGoal;

  const GoalListScreen({
    super.key,
    required this.goals,
    required this.onAddGoal,
    required this.onUpdateGoal,
    required this.onDeleteGoal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('목표 설정'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAddGoal,
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
                    onDeleteGoal(goal.id);
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
                            builder: (ctx) => GoalDetailScreen(goal: goal, onUpdate: onUpdateGoal),
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
