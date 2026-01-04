import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsouradip/ui/login/login_screen.dart';
import 'package:taskmanagementsouradip/ui/tasks/tasks_screen.dart';

void main() {
  testWidgets('Login screen shows expected actions and guest navigates', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
        routes: {
          '/tasks': (_) => const Scaffold(
            body: Center(child: Text('Task list will appear here')),
          ),
          '/signup': (_) =>
              const Scaffold(body: Center(child: Text('Sign up'))),
        },
      ),
    );

    // Should show email & password fields and sign-in button
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);

    // Navigate to sign up
    await tester.tap(find.text("Don't have an account? Sign up"));
    await tester.pumpAndSettle();

    expect(find.text('Sign up'), findsOneWidget);
  });
}
