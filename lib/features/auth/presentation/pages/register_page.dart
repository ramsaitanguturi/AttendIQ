import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Create AttendIQ Account',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Register and Log In'),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
