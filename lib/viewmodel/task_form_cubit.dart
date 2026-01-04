import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'auth_cubit.dart';
import '../data/remote/firestore_tasks_repository.dart';
import '../data/remote/exceptions.dart';

part 'task_form_state.dart';

class TaskFormCubit extends Cubit<TaskFormState> {
  final FirestoreTasksRepository _repo;
  final Cubit<AuthState> _auth;

  TaskFormCubit(this._repo, this._auth) : super(TaskFormState.initial());

  Future<void> createTask({
    required String title,
    String? description,
    required String assignedTo,
    required String priority,
    required DateTime dueDate,
  }) async {
    if (title.trim().isEmpty) {
      emit(TaskFormState.invalid('Title is required'));
      return;
    }
    if (priority.trim().isEmpty) {
      emit(TaskFormState.invalid('Priority must be selected'));
      return;
    }
    if (assignedTo.trim().isEmpty) {
      emit(TaskFormState.invalid('Assigned user is required'));
      return;
    }

    emit(TaskFormState.loading());
    try {
      final data = {
        'title': title.trim(),
        'description': description ?? '',
        'assignedTo': assignedTo,
        'priority': priority,
        // status will default to 'pending' on the server
        'dueDate': dueDate.toIso8601String(),
      };
      final requester = _auth.state.uid;
      final docRef = await _repo.createTask(data, requesterId: requester);
      emit(TaskFormState.success(docRef.id));
    } on AuthorizationException catch (e) {
      emit(TaskFormState.error(e.message));
    } catch (e) {
      emit(TaskFormState.error(e.toString()));
    }
  }

  Future<void> updateTask(
    String id, {
    required String title,
    String? description,
    required String assignedTo,
    required String priority,
    required DateTime dueDate,
    required String status,
  }) async {
    if (title.trim().isEmpty) {
      emit(TaskFormState.invalid('Title is required'));
      return;
    }

    emit(TaskFormState.loading());
    try {
      final data = {
        'title': title.trim(),
        'description': description ?? '',
        'assignedTo': assignedTo,
        'priority': priority,
        'status': status,
        'dueDate': dueDate.toIso8601String(),
      };
      await _repo.updateTask(id, data);
      emit(TaskFormState.success(id));
    } on AuthorizationException catch (e) {
      emit(TaskFormState.error(e.message));
    } catch (e) {
      emit(TaskFormState.error(e.toString()));
    }
  }
}
