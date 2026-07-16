import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Sign in to AttendIQ',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Sign In (Demo)'),
            ),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}
