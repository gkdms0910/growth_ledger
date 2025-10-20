import 'package:flutter/material.dart';
import 'package:growth_ledger/models/goal.dart';
import 'package:growth_ledger/models/progress_record.dart';
import 'package:intl/intl.dart'; // For date formatting

class GoalDetailScreen extends StatefulWidget {
  final Goal goal;
  final VoidCallback onUpdate; // Callback to notify parent of changes

  const GoalDetailScreen({
    super.key,
    required this.goal,
    required this.onUpdate,
  });

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  late Goal _currentGoal;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _currentGoal = widget.goal;
    _titleController = TextEditingController(text: _currentGoal.title);
    _descriptionController = TextEditingController(
      text: _currentGoal.description,
    );
    _selectedCategory = _currentGoal.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _triggerUpdate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _currentGoal.title = _titleController.text;
        _currentGoal.description = _descriptionController.text;
        _currentGoal.category = _selectedCategory;
      });
      widget.onUpdate(); // Notify parent to save changes
    }
  }

  void _addProgressRecord() async {
    final newProgressValue = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('진행 상황 추가'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '진행 값 (예: 1.0, 0.5)'),
          onSubmitted: (value) => Navigator.of(ctx).pop(double.tryParse(value)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final textField =
                  (ctx.findAncestorWidgetOfExactType<AlertDialog>()!.content
                      as TextField);
              Navigator.of(
                ctx,
              ).pop(double.tryParse(textField.controller!.text));
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );

    if (newProgressValue != null) {
      setState(() {
        _currentGoal.progressRecords.add(
          ProgressRecord(recordedAt: DateTime.now(), value: newProgressValue),
        );
        _currentGoal.progressRecords.sort(
          (a, b) => a.recordedAt.compareTo(b.recordedAt),
        ); // Sort by date
      });
      widget.onUpdate(); // Notify parent to save changes
    }
  }

  Widget _buildTargetProgressBar() {
    if (_currentGoal.targetValue == null || _currentGoal.targetValue! <= 0) {
      return const SizedBox.shrink();
    }
    final totalProgress = _currentGoal.progressRecords.fold(
      0.0,
      (sum, record) => sum + record.value,
    );
    final targetValue = _currentGoal.targetValue!;
    final progressPercentage = (totalProgress / targetValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '수치 목표 진행률',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressPercentage,
          backgroundColor: Colors.grey[300],
          color: Theme.of(context).colorScheme.secondary,
          minHeight: 10,
        ),
        const SizedBox(height: 5),
        Text(
          '${(progressPercentage * 100).toStringAsFixed(1)}% (${totalProgress.toStringAsFixed(1)} / ${targetValue.toStringAsFixed(1)}) ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSubTaskProgressBar() {
    if (_currentGoal.subTasks.isEmpty) {
      return const SizedBox.shrink();
    }
    final completedTasks = _currentGoal.subTasks
        .where((task) => task['isCompleted'] == true)
        .length;
    final totalTasks = _currentGoal.subTasks.length;
    final progressPercentage = totalTasks > 0
        ? completedTasks / totalTasks
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '세부 계획 진행률',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progressPercentage,
          backgroundColor: Colors.grey[300],
          color: Colors.green,
          minHeight: 10,
        ),
        const SizedBox(height: 5),
        Text(
          '${(progressPercentage * 100).toStringAsFixed(1)}% ($completedTasks / $totalTasks)',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSubTasks() {
    if (_currentGoal.subTasks.isEmpty) {
      return const Text('세부 계획이 없습니다.');
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _currentGoal.subTasks.length,
      itemBuilder: (context, index) {
        final subTask = _currentGoal.subTasks[index];
        return CheckboxListTile(
          title: Text(
            subTask['task'],
            style: TextStyle(
              decoration: subTask['isCompleted']
                  ? TextDecoration.lineThrough
                  : null,
              color: subTask['isCompleted'] ? Colors.grey : null,
            ),
          ),
          value: subTask['isCompleted'],
          onChanged: (bool? value) {
            setState(() {
              subTask['isCompleted'] = value!;
            });
            _triggerUpdate();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentGoal.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: '목표 제목'),
                onChanged: (value) => _triggerUpdate(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '설명'),
                maxLines: 3,
                onChanged: (value) => _triggerUpdate(),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '목표 값 (선택 사항)'),
                initialValue: _currentGoal.targetValue?.toString(),
                onSaved: (value) {
                  _currentGoal.targetValue = double.tryParse(value ?? '');
                },
                onChanged: (value) => _triggerUpdate(),
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: '카테고리'),
                items:
                    <String>[
                      'General',
                      'Health',
                      'Finance',
                      'Learning',
                      'Personal Growth',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                  _triggerUpdate();
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '생성일: ${DateFormat('yyyy년 MM월 dd일').format(_currentGoal.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (_currentGoal.deadline != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.flag, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Text(
                        '기한: ${DateFormat('yyyy년 MM월 dd일').format(_currentGoal.deadline!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              _buildSubTaskProgressBar(),
              const SizedBox(height: 10),
              _buildTargetProgressBar(),
              const SizedBox(height: 20),
              const Text(
                '세부 계획',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildSubTasks(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '수치 기록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addProgressRecord,
                  ),
                ],
              ),
              _currentGoal.progressRecords.isEmpty
                  ? const Text('아직 진행 상황이 기록되지 않았습니다.')
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _currentGoal.progressRecords.length,
                      itemBuilder: (context, index) {
                        final record = _currentGoal.progressRecords[index];
                        return ListTile(
                          title: Text(
                            DateFormat(
                              'yyyy-MM-dd HH:mm',
                            ).format(record.recordedAt),
                          ),
                          trailing: Text(record.value.toString()),
                        );
                      },
                    ),
              const SizedBox(height: 20),
              _buildProactiveAdvice(),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic>? _getAdvice() {
    // Sub-task progress
    final totalTasks = _currentGoal.subTasks.length;
    final completedTasks = _currentGoal.subTasks
        .where((t) => t['isCompleted'] == true)
        .length;
    final subTaskProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    // Target value progress
    final totalProgress = _currentGoal.progressRecords.fold(
      0.0,
      (sum, record) => sum + record.value,
    );
    final targetValue = _currentGoal.targetValue;
    final targetValueProgress = (targetValue != null && targetValue > 0)
        ? (totalProgress / targetValue).clamp(0.0, 1.0)
        : 0.0;

    // 1. Goal Completion Check
    bool isSubTasksCompleted = subTaskProgress == 1.0;
    bool isTargetValueMet =
        targetValue == null || targetValue <= 0 || targetValueProgress >= 1.0;
    if (isSubTasksCompleted && isTargetValueMet) {
      return {'message': '축하합니다! 목표를 완벽하게 달성했어요! 🎉', 'color': Colors.green};
    }

    // 2. Deadline Check
    if (_currentGoal.deadline != null) {
      final daysRemaining = _currentGoal.deadline!
          .difference(DateTime.now())
          .inDays;
      if (daysRemaining >= 0 && daysRemaining <= 3) {
        return {
          'message': '마감일이 ${daysRemaining + 1}일 남았어요! 조금만 더 힘내세요!',
          'color': Colors.redAccent,
        };
      }
    }

    // 3. Sub-task Progress Check
    if (totalTasks > 0 && subTaskProgress > 0.5 && subTaskProgress < 1.0) {
      return {
        'message': '세부 계획의 절반 이상을 완료했어요! 거의 다 왔습니다!',
        'color': Colors.blue,
      };
    }

    // 4. Target Value Progress Check (existing logic)
    if (targetValue != null && targetValue > 0) {
      if (targetValueProgress >= 1.2) {
        return {
          'message': '이번 목표를 초과 달성했어요! 다음 목표치를 조금 높여보는 건 어떨까요?',
          'color': Colors.green,
        };
      } else if (targetValueProgress >= 0.8 && targetValueProgress < 1.0) {
        return {'message': '목표 달성이 코앞이에요! 조금만 더 힘내세요!', 'color': Colors.blue};
      } else if (totalProgress > 0 && targetValueProgress < 0.5) {
        return {
          'message': '현재 속도라면 목표 달성이 어려울 수 있어요. 주간 목표를 조금 줄여보는 건 어떨까요?',
          'color': Colors.orange,
        };
      }
    }

    return null; // No advice
  }

  Widget _buildProactiveAdvice() {
    final advice = _getAdvice();

    if (advice == null) {
      return const SizedBox.shrink();
    }

    final String adviceMessage = advice['message'];
    final Color adviceColor = advice['color'];

    return Card(
      color: adviceColor.withAlpha((255 * 0.1).round()),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: adviceColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                adviceMessage,
                style: TextStyle(
                  color: adviceColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
