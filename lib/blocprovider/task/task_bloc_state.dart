enum TaskBlocStatus {
  idle,
  savingLocal,
  syncingRemote,
  success,
  failure,
}

class TaskBlocState {
  final TaskBlocStatus status;
  final String? message;

  const TaskBlocState({
    required this.status,
    this.message,
  });

  factory TaskBlocState.initial() {
    return const TaskBlocState(status: TaskBlocStatus.idle);
  }

  TaskBlocState copyWith({
    TaskBlocStatus? status,
    String? message,
  }) {
    return TaskBlocState(
      status: status ?? this.status,
      message: message,
    );
  }
}
