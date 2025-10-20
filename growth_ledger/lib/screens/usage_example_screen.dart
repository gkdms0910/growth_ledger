import 'package:flutter/material.dart';

class UsageExampleScreen extends StatefulWidget {
  final Future<void> Function() onComplete;

  const UsageExampleScreen({super.key, required this.onComplete});

  @override
  State<UsageExampleScreen> createState() => _UsageExampleScreenState();
}

class _UsageExampleScreenState extends State<UsageExampleScreen> {
  final Map<String, bool> _selectedExamples = {
    '3개월 안에 10km 마라톤 완주하기': true,
    '한 달 동안 독서 5권 읽기': false,
    '매주 두 번 영어 스피킹 스터디 참여': false,
    '체중 5kg 감량을 위한 식단 관리': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용 예시 설정'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '관심 있는 목표 유형을 선택해주세요.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _selectedExamples.entries.map((entry) {
                  return Card(
                    child: CheckboxListTile(
                      title: Text(entry.key),
                      value: entry.value,
                      onChanged: (value) {
                        setState(() {
                          _selectedExamples[entry.key] = value ?? false;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await widget.onComplete();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}
