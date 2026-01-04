import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsouradip/viewmodel/task_form_cubit.dart';
import 'package:taskmanagementsouradip/data/remote/firestore_tasks_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:taskmanagementsouradip/viewmodel/auth_state.dart';

class _FakeRepo extends FirestoreTasksRepository {
  _FakeRepo() : super();

  @override
  Future createTask(Map<String, dynamic> data, {String? requesterId}) async {
    // Simulate a simple create returning a fake doc ref
    return _FakeDocRef('fake-id');
  }
}

class _FakeRepoWithAuth extends FirestoreTasksRepository {
  _FakeRepoWithAuth() : super();

  @override
  Future createTask(Map<String, dynamic> data, {String? requesterId}) async {
    if (requesterId != 'admin') throw Exception('Only admins can create tasks');
    return _FakeDocRef('fake-id');
  }
}

class _FakeDocRef {
  final String id;
  _FakeDocRef(this.id);
}

class _FakeAuthCubit extends Cubit<AuthState> {
  _FakeAuthCubit() : super(AuthState.initial());

  void setUid(String uid) {
    emit(state.copyWith(uid: uid));
  }
}

void main() {
  test('invalid when title empty', () async {
    final auth = _FakeAuthCubit();
    auth.setUid('u1');
    final cubit = TaskFormCubit(_FakeRepo(), auth);
    await cubit.createTask(
      title: '',
      description: 'desc',
      assignedTo: 'u1',
      priority: 'medium',
      dueDate: DateTime.now(),
    );
    final state = cubit.state;
    expect(state.error, 'Title is required');
  });

  test('non-admin cannot create', () async {
    final auth = _FakeAuthCubit();
    auth.setUid('not-admin');
    final repo = _FakeRepoWithAuth();
    final cubit = TaskFormCubit(repo, auth);

    await cubit.createTask(
      title: 'T1',
      description: 'd',
      assignedTo: 'u1',
      priority: 'medium',
      dueDate: DateTime.now(),
    );

    final state = cubit.state;
    expect(state.error, contains('Only admins'));
  });
}
