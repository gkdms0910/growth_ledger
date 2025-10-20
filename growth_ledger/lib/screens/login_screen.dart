import 'package:flutter/material.dart';
import 'package:growth_ledger/screens/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  final VoidCallback onLogin;
  final Future<void> Function() onSignUpComplete;

  const LoginScreen({super.key, required this.onLogin, required this.onSignUpComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Growth Ledger',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '이메일',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('로그인'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SignUpScreen(onSignUp: onSignUpComplete),
                    ),
                  );
                },
                child: const Text('계정이 없으신가요? 가입하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
