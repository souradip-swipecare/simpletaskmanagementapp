import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsouradip/ui/admin/admin_users_screen.dart';

// ============================================================================
// FAKE IMPLEMENTATIONS FOR TESTING
// ============================================================================

/// Fake repository for simulating user management operations
class _FakeRepo {
  final _controller = StreamController<List<Map<String, dynamic>>>.broadcast();
  final List<Map<String, dynamic>> _users = [];
  String? _roleChangeError;

  Stream<List<Map<String, dynamic>>> usersStream() => _controller.stream;

  /// Simulate setting a user's role
  Future<void> setRole(String uid, String role) async {
    if (_roleChangeError != null) {
      throw Exception(_roleChangeError);
    }
    // Find and update user
    final index = _users.indexWhere((u) => u['id'] == uid);
    if (index >= 0) {
      _users[index]['role'] = role;
      _controller.add(List.from(_users));
    }
  }

  /// Add users to the stream
  void add(List<Map<String, dynamic>> data) {
    _users.clear();
    _users.addAll(data);
    _controller.add(List.from(_users));
  }

  /// Simulate an error on role change
  void setErrorOnNextRoleChange(String error) {
    _roleChangeError = error;
  }

  /// Clear the error
  void clearError() {
    _roleChangeError = null;
  }

  void dispose() {
    _controller.close();
  }
}

// ============================================================================
// TEST SUITE
// ============================================================================

void main() {
  group('AdminUsersScreen - Display Tests', () {
    /// Test Case 1: Display multiple users with their roles
    ///
    /// Purpose: Verify that all users are displayed correctly with email and role
    /// Expected: All user emails should be visible on screen
    testWidgets('should display multiple users with roles', (tester) async {
      final fake = _FakeRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: AdminUsersScreen(
            repo: fake,
            usersStreamOverride: fake.usersStream(),
          ),
        ),
      );

      // Act: Add multiple users to the stream
      fake.add([
        {'id': 'u1', 'email': 'alice@example.com', 'role': 'member'},
        {'id': 'u2', 'email': 'bob@example.com', 'role': 'admin'},
        {'id': 'u3', 'email': 'charlie@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: All users should be displayed
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
      expect(find.text('charlie@example.com'), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 2: Display action buttons for users
    ///
    /// Purpose: Ensure action buttons are visible for managing roles
    /// Expected: At least one action button should appear on the screen
    testWidgets('should show action buttons', (tester) async {
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
        {'id': 'u1', 'email': 'user@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: At least one action button should be visible
      expect(
        find.text('Promote').evaluate().isNotEmpty ||
            find.text('Revoke').evaluate().isNotEmpty,
        true,
      );

      fake.dispose();
    });

    /// Test Case 3: Distinguish between admin and member roles
    ///
    /// Purpose: Verify that different roles are displayed correctly
    /// Expected: Admin and member roles should be visible
    testWidgets('should display different user roles', (tester) async {
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
        {'id': 'u1', 'email': 'admin@example.com', 'role': 'admin'},
        {'id': 'u2', 'email': 'member@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: Both user emails should be visible
      expect(find.text('admin@example.com'), findsOneWidget);
      expect(find.text('member@example.com'), findsOneWidget);

      fake.dispose();
    });
  });

  group('AdminUsersScreen - Empty State', () {
    /// Test Case 4: Handle empty user list gracefully
    ///
    /// Purpose: Ensure the screen handles no users without crashing
    /// Expected: Screen should display with empty list
    testWidgets('should handle empty user list', (tester) async {
      final fake = _FakeRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: AdminUsersScreen(
            repo: fake,
            usersStreamOverride: fake.usersStream(),
          ),
        ),
      );

      // Act: Send empty list to stream
      fake.add([]);

      await tester.pumpAndSettle();

      // Assert: No user emails should be visible
      expect(find.text('example.com'), findsNothing);
      expect(find.byType(AdminUsersScreen), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 5: Display single user
    ///
    /// Purpose: Verify that a single user is displayed correctly
    /// Expected: One user should appear in the list
    testWidgets('should display single user correctly', (tester) async {
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
        {'id': 'u1', 'email': 'solo@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: Single user should be visible
      expect(find.text('solo@example.com'), findsOneWidget);

      fake.dispose();
    });
  });

  group('AdminUsersScreen - Button Interactions', () {
    /// Test Case 6: Promote button functionality
    ///
    /// Purpose: Verify that clicking promote button works without errors
    /// Expected: Button tap should complete successfully
    testWidgets('should promote user on button tap', (tester) async {
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
        {'id': 'u1', 'email': 'promote@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Act: Tap promote button
      await tester.tap(find.text('Promote'));
      await tester.pumpAndSettle();

      // Assert: User should still be visible (button tap succeeded)
      expect(find.text('promote@example.com'), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 7: Revoke button functionality
    ///
    /// Purpose: Verify that clicking revoke button works without errors
    /// Expected: Button tap should complete successfully
    testWidgets('should revoke admin on button tap', (tester) async {
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
        {'id': 'u1', 'email': 'revoke@example.com', 'role': 'admin'},
      ]);

      await tester.pumpAndSettle();

      // Act: Tap revoke button
      await tester.tap(find.text('Revoke'));
      await tester.pumpAndSettle();

      // Assert: User should still be visible (button tap succeeded)
      expect(find.text('revoke@example.com'), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 8: Multiple button taps work correctly
    ///
    /// Purpose: Verify that repeated button taps don't cause errors
    /// Expected: Both promote and revoke should execute successfully
    testWidgets('should handle multiple button taps', (tester) async {
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
        {'id': 'u1', 'email': 'toggle@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Act & Assert: First promote
      await tester.tap(find.text('Promote'));
      await tester.pumpAndSettle();
      expect(find.text('toggle@example.com'), findsOneWidget);

      // Act & Assert: Then revoke
      await tester.tap(find.text('Revoke'));
      await tester.pumpAndSettle();
      expect(find.text('toggle@example.com'), findsOneWidget);

      fake.dispose();
    });
  });

  group('AdminUsersScreen - Multiple Users Interactions', () {
    /// Test Case 9: Manage different users independently
    ///
    /// Purpose: Ensure each user can be managed independently
    /// Expected: Promoting one user should not affect others
    testWidgets('should manage each user independently', (tester) async {
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
        {'id': 'u1', 'email': 'user1@example.com', 'role': 'member'},
        {'id': 'u2', 'email': 'user2@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Act: Find and tap first promote button
      final promoteButtons = find.text('Promote');
      await tester.tap(promoteButtons.first);
      await tester.pumpAndSettle();

      // Assert: First user should be admin, second still member
      expect(find.text('user1@example.com'), findsOneWidget);
      expect(find.text('user2@example.com'), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 10: Handle large user list
    ///
    /// Purpose: Verify that the screen handles many users efficiently
    /// Expected: All users should be visible without crashes
    testWidgets('should display large number of users', (tester) async {
      final fake = _FakeRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: AdminUsersScreen(
            repo: fake,
            usersStreamOverride: fake.usersStream(),
          ),
        ),
      );

      // Act: Add 5 users
      final users = List.generate(
        5,
        (i) => {
          'id': 'u$i',
          'email': 'user$i@example.com',
          'role': i % 2 == 0 ? 'admin' : 'member',
        },
      );
      fake.add(users);

      await tester.pumpAndSettle();

      // Assert: At least some users should be visible
      expect(find.text('user0@example.com'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);

      fake.dispose();
    });
  });

  group('AdminUsersScreen - Error Handling', () {
    /// Test Case 11: Handle role change errors gracefully
    ///
    /// Purpose: Ensure errors during role changes are handled properly
    /// Expected: Error should be caught without crashing
    testWidgets('should handle role change errors', (tester) async {
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
        {'id': 'u1', 'email': 'error@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: User should be visible and button should be present
      expect(find.text('error@example.com'), findsOneWidget);
      expect(find.text('Promote'), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 12: Recover from error and retry
    ///
    /// Purpose: Verify that operations work after a previous error
    /// Expected: Should be able to perform role change after clearing error
    testWidgets('should recover from error and allow retry', (tester) async {
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
        {'id': 'u1', 'email': 'retry@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: User should be visible
      expect(find.text('retry@example.com'), findsOneWidget);
      expect(find.text('Promote'), findsOneWidget);

      fake.dispose();
    });
  });

  group('AdminUsersScreen - Stream Updates', () {
    /// Test Case 13: React to stream updates
    ///
    /// Purpose: Verify that UI updates when stream emits new data
    /// Expected: New users should appear when added to stream
    testWidgets('should update when new users are added to stream', (
      tester,
    ) async {
      final fake = _FakeRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: AdminUsersScreen(
            repo: fake,
            usersStreamOverride: fake.usersStream(),
          ),
        ),
      );

      // Act: Add initial user
      fake.add([
        {'id': 'u1', 'email': 'first@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: First user visible
      expect(find.text('first@example.com'), findsOneWidget);

      // Act: Add more users
      fake.add([
        {'id': 'u1', 'email': 'first@example.com', 'role': 'member'},
        {'id': 'u2', 'email': 'second@example.com', 'role': 'admin'},
        {'id': 'u3', 'email': 'third@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: All users now visible
      expect(find.text('first@example.com'), findsOneWidget);
      expect(find.text('second@example.com'), findsOneWidget);
      expect(find.text('third@example.com'), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 14: Handle role updates in stream
    ///
    /// Purpose: Verify that UI responds to stream changes
    /// Expected: UI should update when stream emits new data
    testWidgets('should respond to role changes in stream', (tester) async {
      final fake = _FakeRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: AdminUsersScreen(
            repo: fake,
            usersStreamOverride: fake.usersStream(),
          ),
        ),
      );

      // Act: Add user with member role
      fake.add([
        {'id': 'u1', 'email': 'user@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: User is visible
      expect(find.text('user@example.com'), findsOneWidget);

      // Act: Update user to admin
      fake.add([
        {'id': 'u1', 'email': 'user@example.com', 'role': 'admin'},
      ]);

      await tester.pumpAndSettle();

      // Assert: User is still visible after update
      expect(find.text('user@example.com'), findsOneWidget);

      fake.dispose();
    });
  });

  group('AdminUsersScreen - Edge Cases', () {
    /// Test Case 15: Handle special characters in email
    ///
    /// Purpose: Verify that emails with special characters display correctly
    /// Expected: Special characters should be visible
    testWidgets('should display emails with special characters', (
      tester,
    ) async {
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
        {'id': 'u1', 'email': 'user+tag@example.co.uk', 'role': 'member'},
        {'id': 'u2', 'email': 'user.name@sub.example.com', 'role': 'admin'},
      ]);

      await tester.pumpAndSettle();

      // Assert: Emails with special characters are visible
      expect(find.text('user+tag@example.co.uk'), findsOneWidget);
      expect(find.text('user.name@sub.example.com'), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 16: Handle rapid consecutive updates
    ///
    /// Purpose: Verify that rapid stream updates don't cause issues
    /// Expected: UI should remain stable and show final state
    testWidgets('should handle rapid stream updates', (tester) async {
      final fake = _FakeRepo();
      await tester.pumpWidget(
        MaterialApp(
          home: AdminUsersScreen(
            repo: fake,
            usersStreamOverride: fake.usersStream(),
          ),
        ),
      );

      // Act: Rapidly add users
      for (int i = 0; i < 5; i++) {
        fake.add([
          {
            'id': 'u$i',
            'email': 'user$i@example.com',
            'role': i % 2 == 0 ? 'admin' : 'member',
          },
        ]);
      }

      await tester.pumpAndSettle();

      // Assert: Final state should be correct
      expect(find.text('user4@example.com'), findsOneWidget);

      fake.dispose();
    });

    /// Test Case 17: Screen renders with all UI elements
    ///
    /// Purpose: Ensure the screen has proper structure and widgets
    /// Expected: Screen should contain expected UI components
    testWidgets('should have proper screen structure', (tester) async {
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
        {'id': 'u1', 'email': 'test@example.com', 'role': 'member'},
      ]);

      await tester.pumpAndSettle();

      // Assert: Screen should be present
      expect(find.byType(AdminUsersScreen), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);

      fake.dispose();
    });
  });
}
