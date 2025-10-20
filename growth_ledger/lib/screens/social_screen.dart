import 'package:flutter/material.dart';

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소셜'),
      ),
      body: const Center(
        child: Text(
          '소셜 기능이 여기에 표시됩니다.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
