import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanagementsouradip/blocprovider/task/task_state.dart';
import 'package:taskmanagementsouradip/core/models/task_model.dart';
import 'package:taskmanagementsouradip/data/remote/firestore_tasks_repository.dart';

class TasksCubit extends Cubit<TasksState> {
  final FirestoreTasksRepository _repo;
  StreamSubscription<QuerySnapshot>? _sub;

  TasksCubit(this._repo) : super(TasksState.initial());
  void subscribeall() {
    emit(state.copyWith(status: TasksStatus.loading, error: null));

    _sub?.cancel();
    _sub = _repo.tasksStreamForAdmin().listen(
      (snapshot) {
        final allTasks = snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();

        emit(
          state.copyWith(
            status: TasksStatus.loaded,
            allTasks: allTasks,
            visibleTasks: _applyFilters(
              allTasks,
              state.searchKey,
              state.sortOption,
            ),
          ),
        );
      },
      onError: (e) {
        emit(
          state.copyWith(
            status: TasksStatus.error,
            error: e.toString(),
          ),
        );
      },
    );
  }

  void subscribe(String userId) {
    emit(state.copyWith(status: TasksStatus.loading, error: null));

    _sub?.cancel();
    _sub = _repo.tasksStreamForUser(userId).listen(
      (snapshot) {
        final allTasks = snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList();

        emit(
          state.copyWith(
            status: TasksStatus.loaded,
            allTasks: allTasks,
            visibleTasks: _applyFilters(
              allTasks,
              state.searchKey,
              state.sortOption,
            ),
          ),
        );
      },
      onError: (e) {
        emit(
          state.copyWith(
            status: TasksStatus.error,
            error: e.toString(),
          ),
        );
      },
    );
  }

  void search(String keyword) {
    emit(
      state.copyWith(
        searchKey: keyword,
        visibleTasks: _applyFilters(
          state.allTasks,
          keyword,
          state.sortOption,
        ),
      ),
    );
  }

  void sort(int option) {
    emit(
      state.copyWith(
        sortOption: option,
        visibleTasks: _applyFilters(
          state.allTasks,
          state.searchKey,
          option,
        ),
      ),
    );
  }

  List<TaskModel> _applyFilters(
    List<TaskModel> source,
    String searchKey,
    int sortOption,
  ) {
    var list = [...source];

    if (searchKey.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(searchKey.toLowerCase()))
          .toList();
    }

    switch (sortOption) {
      case 1:
        list = list.where((t) => t.status == 'completed').toList();
        break;
      case 2:
        list = list.where((t) => t.status == 'pending').toList();
        break;
      default:
        list.sort((a, b) => a.priority.compareTo(b.priority));
    }

    return list;
  }

  Future<void> updateStatus(String id, String status) async {
    try{
emit(state.copyWith(
    status: TasksStatus.loading,
    error: null,
  ));
await _repo.updateTask(id, {
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    emit(state.copyWith(status: TasksStatus.success));

    }catch(e){
emit(
      state.copyWith(
        status: TasksStatus.error,
        error: e.toString(),
      ),
    );
    }
    
  }

  Future<void> delete(String id) async {
    emit(state.copyWith(
    status: TasksStatus.loading,
    error: null,
  ));
  try{
await _repo.deleteTask(id);
emit(state.copyWith(status: TasksStatus.success));

  }catch(e){
emit(
      state.copyWith(
        status: TasksStatus.error,
        error: e.toString(),
      ),
    );
  }
    
  }

  Future<void> create(TaskModel task) async {
    emit(state.copyWith(status: TasksStatus.creating, error: null));

    try {
      await _repo.createTask(task.toMap());
      emit(state.copyWith(status: TasksStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TasksStatus.error, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
