import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsouradip/viewmodel/auth_cubit.dart';
import 'package:taskmanagementsouradip/viewmodel/task_form_cubit.dart';
import 'package:taskmanagementsouradip/data/remote/firestore_tasks_repository.dart';
import 'package:taskmanagementsouradip/data/remote/firestore_users_repository.dart';
import 'package:bloc/bloc.dart';

// ============================================================================
// FAKE IMPLEMENTATIONS FOR TESTING
// ============================================================================

/// Fake DocumentReference for testing - behaves like a real Firestore reference
class _FakeDocRef implements DocumentReference {
  final String _id;

  _FakeDocRef(this._id);

  @override
  String get id => _id;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Mock repository that simulates successful task creation
class _FakeTaskRepository extends FirestoreTasksRepository {
  _FakeTaskRepository() : super(usersRepo: _FakeUsersRepository());

  @override
  Future<DocumentReference> createTask(
    Map<String, dynamic> data, {
    String? requesterId,
  }) async {
    // Validate title (mirrors real implementation)
    final title = data['title'] as String?;
    if (title == null || title.trim().isEmpty) {
      throw Exception('Title is required');
    }

    // Validate priority (can be String from cubit or int from direct calls)
    final priority = data['priority'];
    if (priority == null) {
      throw Exception('Priority must be selected');
    }

    // If priority is a string (from cubit), validate it's not empty
    if (priority is String && priority.trim().isEmpty) {
      throw Exception('Priority must be selected');
    }

    // Validate assignedTo (mirrors real implementation)
    final assignedTo = data['assignedTo'] as String?;
    if (assignedTo == null || assignedTo.trim().isEmpty) {
      throw Exception('Assigned user is required');
    }

    // Check admin authorization if requesterId provided
    // In our fake repo, any non-empty requesterId is allowed for testing
    // (In real app, the _usersRepo checks the role)
    if (requesterId == null) {
      throw Exception('User is not authenticated');
    }

    // Simulate successful task creation
    return _FakeDocRef('task-id-${DateTime.now().millisecondsSinceEpoch}');
  }
}

/// Fake users repository for testing
class _FakeUsersRepository extends FirestoreUsersRepository {
  @override
  Future<String> getRole(String uid) async {
    return 'user'; // Default role for testing
  }
}

/// Mock repository that simulates network errors
class _FakeNetworkErrorRepository extends FirestoreTasksRepository {
  _FakeNetworkErrorRepository() : super(usersRepo: _FakeUsersRepository());

  @override
  Future<DocumentReference> createTask(
    Map<String, dynamic> data, {
    String? requesterId,
  }) async {
    // Simulate network failure
    throw Exception('Network error: Failed to connect to Firestore');
  }
}

/// Mock repository that simulates authorization errors
class _FakeAuthorizationErrorRepository extends FirestoreTasksRepository {
  _FakeAuthorizationErrorRepository()
    : super(usersRepo: _FakeUsersRepository());

  @override
  Future<DocumentReference> createTask(
    Map<String, dynamic> data, {
    String? requesterId,
  }) async {
    // Simulate authorization failure
    throw Exception('Only admins can create tasks');
  }
}

/// Fake authentication cubit for testing
class _FakeAuthCubit extends Cubit<AuthState> {
  _FakeAuthCubit() : super(AuthState.initial());

  /// Set the current user ID and role to simulate different authenticated users
  void setUid(String uid) {
    emit(state.copyWith(uid: uid));
  }
}

// ============================================================================
// TEST SUITE
// ============================================================================

void main() {
  group('TaskFormCubit - Input Validation Tests', () {
    /// Test Case 1: Validate that empty title is rejected
    ///
    /// Purpose: Ensure the cubit validates required fields BEFORE making API calls
    /// This prevents unnecessary network requests for invalid data
    /// Expected: State should emit error with message 'Title is required'
    test('should emit error when title is empty', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Attempt to create a task with empty title
      await cubit.createTask(
        title: '', // ❌ Invalid: empty title
        description: 'Task description',
        assignedTo: 'user-002',
        priority: 'high',
        dueDate: DateTime.now().add(Duration(days: 7)),
      );

      // Assert: Verify error state
      expect(cubit.state.error, equals('Title is required'));
      expect(cubit.state.success, false);
      expect(cubit.state.loading, false);
    });

    /// Test Case 2: Validate that whitespace-only title is rejected
    ///
    /// Purpose: Trim and validate titles - prevent tasks with only spaces
    /// Expected: State should emit error 'Title is required'
    test('should emit error when title is only whitespace', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Attempt to create a task with whitespace-only title
      await cubit.createTask(
        title: '   ', // ❌ Invalid: whitespace only
        description: 'Task description',
        assignedTo: 'user-002',
        priority: 'medium',
        dueDate: DateTime.now().add(Duration(days: 5)),
      );

      // Assert
      expect(cubit.state.error, equals('Title is required'));
    });

    /// Test Case 3: Validate that priority must be provided
    ///
    /// Purpose: Priority is a required field for task classification
    /// Expected: State should emit error 'Priority must be selected'
    test('should emit error when priority is empty', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Attempt to create a task without priority
      await cubit.createTask(
        title: 'Complete API Integration',
        description: 'Integrate with external payment API',
        assignedTo: 'user-002',
        priority: '', // ❌ Invalid: empty priority
        dueDate: DateTime.now().add(Duration(days: 3)),
      );

      // Assert
      expect(cubit.state.error, equals('Priority must be selected'));
    });

    /// Test Case 4: Validate that assigned user must be specified
    ///
    /// Purpose: Every task must be assigned to someone
    /// Expected: State should emit error 'Assigned user is required'
    test('should emit error when assignedTo is empty', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Attempt to create a task without assigning it to anyone
      await cubit.createTask(
        title: 'Review Code',
        description: 'Review pull requests from team',
        assignedTo: '', // ❌ Invalid: no assignee
        priority: 'medium',
        dueDate: DateTime.now().add(Duration(days: 2)),
      );

      // Assert
      expect(cubit.state.error, equals('Assigned user is required'));
    });
  });

  group('TaskFormCubit - Successful Task Creation', () {
    /// Test Case 5: Successful task creation with all valid inputs
    ///
    /// Purpose: Verify happy path - task is successfully created with proper data
    /// Expected: State should emit success with a non-null task ID
    test('should successfully create task with valid inputs', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-admin-123');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      final dueDate = DateTime.now().add(Duration(days: 7));

      // Act: Create a task with all valid data
      await cubit.createTask(
        title: 'Implement User Authentication', // ✅ Valid title
        description: 'Setup Firebase authentication with phone number',
        assignedTo: 'user-developer-456', // ✅ Valid assignee
        priority: 'high', // ✅ Valid priority
        dueDate: dueDate,
      );

      // Assert: Verify success state
      expect(cubit.state.success, true);
      expect(cubit.state.error, isNull);
      expect(cubit.state.id, isNotEmpty);
      expect(cubit.state.loading, false);
    });

    /// Test Case 6: Task creation with optional description omitted
    ///
    /// Purpose: Ensure description field is optional
    /// Expected: Task should be created successfully without description
    test('should create task without description', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Create task without description
      await cubit.createTask(
        title: 'Bug Fix: Login Page',
        description: null, // 📝 Optional field - null is allowed
        assignedTo: 'user-002',
        priority: 'medium',
        dueDate: DateTime.now().add(Duration(days: 1)),
      );

      // Assert: Verify success even without description
      expect(cubit.state.success, true);
      expect(cubit.state.error, isNull);
    });

    /// Test Case 7: Task creation with valid but minimal title
    ///
    /// Purpose: Ensure single word titles are accepted
    /// Expected: Task should be created successfully
    test('should create task with minimal valid title', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Create task with minimal single-word title
      await cubit.createTask(
        title: 'Testing', // ✅ Minimal but valid
        description: 'Test single word title',
        assignedTo: 'user-002',
        priority: 'low',
        dueDate: DateTime.now().add(Duration(days: 10)),
      );

      // Assert
      expect(cubit.state.success, true);
    });
  });

  group('TaskFormCubit - Loading State Management', () {
    /// Test Case 8: Verify loading state is emitted during task creation
    ///
    /// Purpose: Ensure UI can show loading indicator during async API call
    /// This helps provide feedback to users during task submission
    /// Expected: Loading state should be emitted before success
    test('should emit loading state during task creation', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act & Assert: Collect all state changes
      final states = <TaskFormState>[];
      cubit.stream.listen((state) {
        states.add(state);
      });

      await cubit.createTask(
        title: 'Setup Database',
        description: 'Configure PostgreSQL database',
        assignedTo: 'user-002',
        priority: 'high',
        dueDate: DateTime.now().add(Duration(days: 5)),
      );

      // Assert: Verify that loading state was emitted at some point
      expect(
        states.any((s) => s.loading == true),
        true,
        reason: 'Loading state should be emitted during task creation',
      );
    });

    /// Test Case 9: Verify final state after successful task creation
    ///
    /// Purpose: Ensure loading state is cleared after success
    /// Expected: Final state should have loading=false and success=true
    test('should clear loading state after success', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Create task
      await cubit.createTask(
        title: 'Final State Test',
        description: 'Verify loading is cleared',
        assignedTo: 'user-002',
        priority: 'medium',
        dueDate: DateTime.now().add(Duration(days: 3)),
      );

      // Assert: Final state should not be loading
      expect(
        cubit.state.loading,
        false,
        reason: 'Loading should be false after task creation completes',
      );
      expect(
        cubit.state.success,
        true,
        reason: 'Success should be true for valid task',
      );
    });
  });

  group('TaskFormCubit - Error Handling', () {
    /// Test Case 10: Handle network errors gracefully
    ///
    /// Purpose: Ensure network errors from repository are properly caught and emitted
    /// This allows UI to show error messages to users
    /// Expected: State should emit error message from exception
    test('should emit error when network fails', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final repoWithError = _FakeNetworkErrorRepository();
      final cubit = TaskFormCubit(repoWithError, auth);

      // Act: Attempt to create task when network is down
      await cubit.createTask(
        title: 'Valid Task Title',
        description: 'Task description',
        assignedTo: 'user-002',
        priority: 'medium',
        dueDate: DateTime.now().add(Duration(days: 3)),
      );

      // Assert: Verify error state is properly set
      expect(cubit.state.success, false);
      expect(cubit.state.error, isNotNull);
      expect(cubit.state.error, contains('Network error'));
      expect(cubit.state.loading, false);
    });

    /// Test Case 11: Handle authorization errors
    ///
    /// Purpose: Ensure only authorized users can create tasks
    /// Expected: State should emit authorization error message
    test('should emit error when user is not authorized', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('non-admin-user');
      final repoWithAuthError = _FakeAuthorizationErrorRepository();
      final cubit = TaskFormCubit(repoWithAuthError, auth);

      // Act: Non-admin attempts to create task
      await cubit.createTask(
        title: 'Restricted Task',
        description: 'Only admins can create',
        assignedTo: 'user-002',
        priority: 'high',
        dueDate: DateTime.now().add(Duration(days: 1)),
      );

      // Assert: Verify authorization error
      expect(cubit.state.success, false);
      expect(cubit.state.error, isNotNull);
      expect(cubit.state.error, contains('Only admins'));
    });
  });

  group('TaskFormCubit - Priority Values', () {
    /// Test Case 12: Verify high priority tasks are accepted
    ///
    /// Purpose: Test one priority level to ensure validation works
    /// Expected: Task should be created successfully
    test('should create task with high priority', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Create high priority task
      await cubit.createTask(
        title: 'Critical Bug Fix',
        description: 'Fix production issue',
        assignedTo: 'user-002',
        priority: 'high', // 🔴 High priority
        dueDate: DateTime.now().add(Duration(hours: 1)),
      );

      // Assert
      expect(cubit.state.success, true);
      expect(cubit.state.error, isNull);
    });

    /// Test Case 13: Verify medium priority tasks are accepted
    ///
    /// Purpose: Test normal priority level
    /// Expected: Task should be created successfully
    test('should create task with medium priority', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Create medium priority task
      await cubit.createTask(
        title: 'Feature Implementation',
        description: 'Add new feature',
        assignedTo: 'user-002',
        priority: 'medium', // 🟡 Medium priority
        dueDate: DateTime.now().add(Duration(days: 7)),
      );

      // Assert
      expect(cubit.state.success, true);
    });

    /// Test Case 14: Verify low priority tasks are accepted
    ///
    /// Purpose: Test low priority level
    /// Expected: Task should be created successfully
    test('should create task with low priority', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Create low priority task
      await cubit.createTask(
        title: 'Documentation Update',
        description: 'Update API documentation',
        assignedTo: 'user-002',
        priority: 'low', // 🟢 Low priority
        dueDate: DateTime.now().add(Duration(days: 30)),
      );

      // Assert
      expect(cubit.state.success, true);
    });
  });

  group('TaskFormCubit - Edge Cases', () {
    /// Test Case 15: Title with leading/trailing whitespace
    ///
    /// Purpose: Ensure title trimming works correctly
    /// Expected: Task should be created after trimming whitespace
    test('should trim title and create task successfully', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Create task with whitespace around title
      await cubit.createTask(
        title: '  Trimmed Title  ', // Spaces will be trimmed
        description: 'Test whitespace trimming',
        assignedTo: 'user-002',
        priority: 'medium',
        dueDate: DateTime.now().add(Duration(days: 5)),
      );

      // Assert: Task should be created successfully
      expect(cubit.state.success, true);
      expect(cubit.state.error, isNull);
    });

    /// Test Case 16: Very long task title
    ///
    /// Purpose: Ensure system can handle lengthy titles
    /// Expected: Task should be created successfully
    test('should create task with very long title', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      final longTitle =
          'Implement comprehensive user authentication system with Firebase, including phone number verification, OTP validation, and multi-device session management';

      // Act: Create task with very long title
      await cubit.createTask(
        title: longTitle,
        description: 'Test long title handling',
        assignedTo: 'user-002',
        priority: 'high',
        dueDate: DateTime.now().add(Duration(days: 7)),
      );

      // Assert
      expect(cubit.state.success, true);
    });

    /// Test Case 17: Task with special characters in title
    ///
    /// Purpose: Ensure special characters are handled properly
    /// Expected: Task should be created successfully
    test('should create task with special characters in title', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // Act: Create task with special characters
      await cubit.createTask(
        title: 'Fix: @API #123 & Dashboard {UI/UX}',
        description: 'Test special characters',
        assignedTo: 'user-002',
        priority: 'medium',
        dueDate: DateTime.now().add(Duration(days: 3)),
      );

      // Assert
      expect(cubit.state.success, true);
    });

    /// Test Case 18: Verify state resets between operations
    ///
    /// Purpose: Ensure previous state doesn't affect new operations
    /// Expected: Each operation should have independent state
    test('should reset state for new task creation', () async {
      final auth = _FakeAuthCubit();
      auth.setUid('user-001');
      final cubit = TaskFormCubit(_FakeTaskRepository(), auth);

      // First operation with invalid title
      await cubit.createTask(
        title: '',
        description: 'Invalid',
        assignedTo: 'user-002',
        priority: 'medium',
        dueDate: DateTime.now(),
      );

      expect(cubit.state.error, isNotNull);

      // Second operation with valid title
      await cubit.createTask(
        title: 'Valid Task',
        description: 'Valid task',
        assignedTo: 'user-002',
        priority: 'medium',
        dueDate: DateTime.now(),
      );

      // Assert: New state should be success
      expect(cubit.state.success, true);
      expect(cubit.state.error, isNull);
    });
  });
}
