import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import '../data/remote/firestore_tasks_repository.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final FirestoreTasksRepository _repo;
  StreamSubscription<QuerySnapshot>? _sub;

  TasksCubit(this._repo) : super(TasksState.initial());

  void subscribeForUser(String userId) {
    emit(state.copyWith(status: TasksStatus.loading));
    _sub?.cancel();
    _sub = _repo.tasksStreamForUser(userId).listen(
      (snapshot) {
        final items = snapshot.docs
            .map(
              (d) => {
                'id': d.id,
                'title': d['title'],
                'status': d['status'],
                'priority': d['priority'],
                'dueDate': d['dueDate'],
                'assignedTo': d['assignedTo'],
                'createdAt': d['createdAt'],
                'updatedAt': d['updatedAt'],
                'deletedAt': d['deletedAt'],
              },
            )
            .toList();
        emit(state.copyWith(status: TasksStatus.loaded, tasks: items));
      },
      onError: (e) =>
          emit(state.copyWith(status: TasksStatus.error, error: e.toString())),
    );
  }

  void dispose() {
    _sub?.cancel();
  }

  Future<void> markStatus(String id, String status) async {
    try {
      await _repo.updateTask(id, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(state.copyWith(status: TasksStatus.error, error: e.toString()));
    }
  }

  Future<void> deleteTask(String id, {String? requesterId}) async {
    try {
      await _repo.deleteTask(id, requesterId: requesterId);
    } catch (e) {
      emit(state.copyWith(status: TasksStatus.error, error: e.toString()));
    }
  }
}
