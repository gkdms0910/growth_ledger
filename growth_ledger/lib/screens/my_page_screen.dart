import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이 페이지'),
      ),
      body: const Center(
        child: Text(
          '마이 페이지가 여기에 표시됩니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
