import 'package:taskmanagementsouradip/core/models/task_model.dart';

abstract class TaskEvent {}

class CreateTaskRequested extends TaskEvent {
  final TaskModel task;
  CreateTaskRequested(this.task);
}

class SyncPendingTasks extends TaskEvent {}

class NetworkRestored extends TaskEvent {}