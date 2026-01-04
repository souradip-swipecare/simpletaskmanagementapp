part of 'tasks_cubit.dart';

enum TasksStatus { initial, loading, loaded, error }

@immutable
class TasksState {
  final TasksStatus status;
  final List<Map<String, dynamic>> tasks;
  final String? error;

  const TasksState({required this.status, this.tasks = const [], this.error});

  factory TasksState.initial() => const TasksState(status: TasksStatus.initial);

  TasksState copyWith({
    TasksStatus? status,
    List<Map<String, dynamic>>? tasks,
    String? error,
  }) {
    return TasksState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      error: error ?? this.error,
    );
  }
}
