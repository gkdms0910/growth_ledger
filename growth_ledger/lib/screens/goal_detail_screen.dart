import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/progress_record.dart';

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  final Function onUpdate; // Callback to save all goals

  const GoalDetailScreen({super.key, required this.goal, required this.onUpdate});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {

  void _addProgressRecord(String note) {
    if (note.isEmpty) return;

    final newRecord = ProgressRecord(
      id: const Uuid().v4(),
      goalId: widget.goal.id,
      note: note,
      recordedAt: DateTime.now(),
    );
    setState(() {
      widget.goal.progressRecords.insert(0, newRecord); // Add to the top
    });
    widget.onUpdate(); // Trigger a save for all goals
    Navigator.of(context).pop(); // Close the dialog
  }

  void _showAddProgressDialog() {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('진행 기록 추가'),
        content: TextField(
          controller: noteController,
          autofocus: true,
          decoration: const InputDecoration(labelText: '오늘의 활동'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('취소')),
          ElevatedButton(onPressed: () => _addProgressRecord(noteController.text), child: const Text('저장')),
        ],
      ),
    );
  }

  void _deleteProgressRecord(int index) {
    setState(() {
      widget.goal.progressRecords.removeAt(index);
    });
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리: ${widget.goal.category}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Text(
              '진행 기록',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: widget.goal.progressRecords.isEmpty
                  ? const Center(child: Text('아직 진행 기록이 없어요.'))
                  : ListView.builder(
                      itemCount: widget.goal.progressRecords.length,
                      itemBuilder: (context, index) {
                        final record = widget.goal.progressRecords[index];
                        return Dismissible(
                          key: Key(record.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) => _deleteProgressRecord(index),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(record.note),
                              subtitle: Text(record.recordedAt.toString().substring(0, 10)), // YYYY-MM-DD
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProgressDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}