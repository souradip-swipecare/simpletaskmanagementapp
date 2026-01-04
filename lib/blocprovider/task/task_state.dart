// import 'package:taskmanagementsouradip/core/models/task_model.dart';

// enum TasksStatus { initial, loading, loaded, error }

// class TasksState {
//   final TasksStatus status;

//   // 🔑 IMPORTANT
//   final List<TaskModel> allTasks;
//   final List<TaskModel> visibleTasks;

//   final String searchKey;
//   final int sortOption;
//   final String? error;

//   const TasksState({
//     required this.status,
//     required this.allTasks,
//     required this.visibleTasks,
//     this.searchKey = '',
//     this.sortOption = 0,
//     this.error,
//   });

//   factory TasksState.initial() {
//     return const TasksState(
//       status: TasksStatus.initial,
//       allTasks: [],
//       visibleTasks: [],
//     );
//   }

//   TasksState copyWith({
//     TasksStatus? status,
//     List<TaskModel>? allTasks,
//     List<TaskModel>? visibleTasks,
//     String? searchKey,
//     int? sortOption,
//     String? error,
//   }) {
//     return TasksState(
//       status: status ?? this.status,
//       allTasks: allTasks ?? this.allTasks,
//       visibleTasks: visibleTasks ?? this.visibleTasks,
//       searchKey: searchKey ?? this.searchKey,
//       sortOption: sortOption ?? this.sortOption,
//       error: error,
//     );
//   }
// }
import 'package:taskmanagementsouradip/core/models/task_model.dart';

enum TasksStatus {
  initial,
  loading,
  loaded,
  creating,
  success,
  error,
}

class TasksState {
  final TasksStatus status;
  final List<TaskModel> allTasks;
  final List<TaskModel> visibleTasks;
  final String searchKey;
  final int sortOption;
  final String? error;

  const TasksState({
    required this.status,
    required this.allTasks,
    required this.visibleTasks,
    this.searchKey = '',
    this.sortOption = 0,
    this.error,
  });

  factory TasksState.initial() {
    return const TasksState(
      status: TasksStatus.initial,
      allTasks: [],
      visibleTasks: [],
    );
  }

  TasksState copyWith({
    TasksStatus? status,
    List<TaskModel>? allTasks,
    List<TaskModel>? visibleTasks,
    String? searchKey,
    int? sortOption,
    String? error,
  }) {
    return TasksState(
      status: status ?? this.status,
      allTasks: allTasks ?? this.allTasks,
      visibleTasks: visibleTasks ?? this.visibleTasks,
      searchKey: searchKey ?? this.searchKey,
      sortOption: sortOption ?? this.sortOption,
      error: error,
    );
  }
}
