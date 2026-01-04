part of 'task_form_cubit.dart';

@immutable
class TaskFormState {
  final bool loading;
  final bool success;
  final String? error;
  final String? id;

  const TaskFormState({
    this.loading = false,
    this.success = false,
    this.error,
    this.id,
  });

  factory TaskFormState.initial() => const TaskFormState();
  factory TaskFormState.loading() => const TaskFormState(loading: true);
  factory TaskFormState.success(String id) =>
      TaskFormState(success: true, id: id);
  factory TaskFormState.error(String message) => TaskFormState(error: message);
  factory TaskFormState.invalid(String message) =>
      TaskFormState(error: message);
}
