import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsouradip/ui/admin/admin_users_screen.dart';

class _FakeRepo {
  final _controller = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> usersStream() => _controller.stream;
  Future<void> setRole(String uid, String role) async {
    // no-op for test
  }

  void add(List<Map<String, dynamic>> data) => _controller.add(data);
}

void main() {
  testWidgets('Admin users screen shows users and buttons', (tester) async {
    final fake = _FakeRepo();
    await tester.pumpWidget(
      MaterialApp(
        home: AdminUsersScreen(
          repo: fake,
          usersStreamOverride: fake.usersStream(),
        ),
      ),
    );

    fake.add([
      {'id': 'u1', 'email': 'a@example.com', 'role': 'member'},
      {'id': 'u2', 'email': 'b@example.com', 'role': 'admin'},
    ]);

    await tester.pumpAndSettle();

    expect(find.text('a@example.com'), findsOneWidget);
    expect(find.text('b@example.com'), findsOneWidget);
    expect(find.text('Promote'), findsOneWidget);
    expect(find.text('Revoke'), findsOneWidget);
  });
}
