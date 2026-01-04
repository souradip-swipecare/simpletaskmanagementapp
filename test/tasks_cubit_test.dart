import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanagementsouradip/viewmodel/tasks_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanagementsouradip/data/remote/firestore_tasks_repository.dart';

class _FakeRepo extends FirestoreTasksRepository {
  @override
  Stream<QuerySnapshot> tasksStreamForUser(String userId) =>
      const Stream.empty();

  @override
  Future<void> updateTask(String id, Map<String, dynamic> data) async {}
}

void main() {
  test('tasks cubit initial state', () {
    final cubit = TasksCubit(_FakeRepo());
    expect(cubit.state.status, TasksStatus.initial);
  });
}
