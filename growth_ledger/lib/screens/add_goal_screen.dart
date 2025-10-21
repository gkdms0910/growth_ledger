import 'package:flutter/material.dart';
import 'package:growth_ledger/models/goal.dart';
import 'package:growth_ledger/services/storage_service.dart'; // Import StorageService
import 'package:uuid/uuid.dart'; // For generating unique IDs
import 'package:intl/intl.dart'; // For date formatting

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService(); // Initialize StorageService
  final TextEditingController _titleController = TextEditingController();
  String? _description;
  String _category = 'General'; // Default category
  double? _targetValue;
  DateTime? _deadline;
  final List<TextEditingController> _subTaskControllers = [];
  List<String> _categories = []; // To store fetched categories

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _titleController.addListener(() {
      setState(() {}); // To update the visibility of the AI button
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _subTaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final storedCategories = await _storageService.readCategories();
    setState(() {
      _categories = storedCategories.isEmpty ? ['General', 'Health', 'Finance', 'Learning', 'Personal Growth'] : storedCategories;
      if (!_categories.contains(_category)) {
        _category = _categories.first; // Set default if current category is not in list
      }
    });
  }

  void _addSubTask({String text = ''}) {
    setState(() {
      _subTaskControllers.add(TextEditingController(text: text));
    });
  }

  void _removeSubTask(int index) {
    setState(() {
      _subTaskControllers[index].dispose();
      _subTaskControllers.removeAt(index);
    });
  }

  List<String> _getAISuggestions(String title) {
    final suggestions = <String>[];
    final lowerCaseTitle = title.toLowerCase();

    // Rule for books
    final bookRegex = RegExp(r'(\d+)\s*권');
    final bookMatch = bookRegex.firstMatch(lowerCaseTitle);
    if (bookMatch != null) {
      final count = int.tryParse(bookMatch.group(1)!) ?? 0;
      for (int i = 1; i <= count; i++) {
        suggestions.add('$i번째 책 읽기');
      }
      return suggestions;
    }

    // Rule for exercise
    final exerciseRegex = RegExp(r'(주|일)\s*(\d+)\s*번');
    final exerciseMatch = exerciseRegex.firstMatch(lowerCaseTitle);
    if (exerciseMatch != null) {
      final count = int.tryParse(exerciseMatch.group(2)!) ?? 0;
      for (int i = 1; i <= count; i++) {
        suggestions.add('$i번째 운동하기');
      }
      return suggestions;
    }

    // Default generic plan
    return ['자료 조사하기', '계획 세우기', '실행하기', '중간 점검하기', '마무리하기'];
  }

  void _generateSubTasks() {
    final title = _titleController.text;
    if (title.isEmpty) return;

    final suggestions = _getAISuggestions(title);

    // Clear existing sub-tasks and controllers
    for (var controller in _subTaskControllers) {
      controller.dispose();
    }
    _subTaskControllers.clear();

    // Add new sub-tasks
    for (var suggestion in suggestions) {
      _addSubTask(text: suggestion);
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final subTasks = _subTaskControllers
          .map((controller) => controller.text)
          .where((task) => task.isNotEmpty)
          .map((task) => {'task': task, 'isCompleted': false})
          .toList();

      final newGoal = Goal(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _description,
        category: _category,
        createdAt: DateTime.now(),
        targetValue: _targetValue,
        deadline: _deadline,
        subTasks: subTasks,
      );
      Navigator.of(context).pop(newGoal);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('새 목표 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                key: const ValueKey('goal_title_field'),
                controller: _titleController,
                decoration: const InputDecoration(labelText: '목표 제목'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '설명 (선택 사항)'),
                maxLines: 3,
                onSaved: (value) {
                  _description = value;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: '목표 값 (선택 사항)'),
                onSaved: (value) {
                  _targetValue = double.tryParse(value ?? '');
                },
              ),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: '카테고리'),
                items: _categories
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _category = newValue!;
                  });
                },
                onSaved: (value) {
                  _category = value!;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('목표 기한'),
                subtitle: Text(
                  _deadline == null
                      ? '기한 없음'
                      : DateFormat('yyyy년 MM월 dd일').format(_deadline!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('세부 계획', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  if (_titleController.text.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text('AI 추천 받기'),
                      onPressed: _generateSubTasks,
                    ),
                ],
              ),
              ..._subTaskControllers.asMap().entries.map((entry) {
                int index = entry.key;
                TextEditingController controller = entry.value;
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        decoration: InputDecoration(labelText: '세부 계획 ${index + 1}'),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeSubTask(index),
                    ),
                  ],
                );
              }),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('세부 계획 추가'),
                onPressed: () => _addSubTask(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGoal,
                child: const Text('목표 추가'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
