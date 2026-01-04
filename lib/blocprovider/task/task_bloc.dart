import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanagementsouradip/blocprovider/task/task_bloc_state.dart';
import 'package:taskmanagementsouradip/blocprovider/task/task_event_bloc.dart';
import 'package:taskmanagementsouradip/data/local/hive_task_repository.dart';
import 'package:taskmanagementsouradip/data/remote/firestore_tasks_repository.dart';
import 'package:taskmanagementsouradip/domains/entities/task.dart';
import 'package:taskmanagementsouradip/services/connectivity.dart';

class TaskBloc extends Bloc<TaskEvent, TaskBlocState> {
  final FirestoreTasksRepository firestoreRepo;
  final HiveTaskRepository hiveRepo;
  final ConnectivityService connectivity;

  TaskBloc(
    this.firestoreRepo,
    this.hiveRepo,
    this.connectivity,
  ) : super(TaskBlocState.initial()) {

    on<CreateTaskRequested>(_onCreateTask);
    on<SyncPendingTasks>(_onSyncPending);
    on<NetworkRestored>((_, emit) {
      add(SyncPendingTasks());
    });
  }

  Future<void> _onCreateTask(
    CreateTaskRequested event,
    Emitter<TaskBlocState> emit,
  ) async {
    try {
      // 1️⃣ Save locally FIRST
      emit(state.copyWith(status: TaskBlocStatus.savingLocal));

      await hiveRepo.addTask(
        event.task.copyWith(isSynced: false) as TaskApp,
      );

      // 2️⃣ Try syncing if online
      if (await connectivity.isOnline) {
        add(SyncPendingTasks());
      } else {
        emit(state.copyWith(status: TaskBlocStatus.success));
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskBlocStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSyncPending(
    SyncPendingTasks event,
    Emitter<TaskBlocState> emit,
  ) async {
    emit(state.copyWith(status: TaskBlocStatus.syncingRemote));

    try {
      final pendingTasks = await hiveRepo.getPendingTasks();

      for (final task in pendingTasks) {
        try {
          // final docRef = await firestoreRepo.createTask(
          //   task.toFirestore(),
          // );

          // await hiveRepo.updateTask(
          //   task.copyWith(
          //     id: docRef.id,
          //     isSynced: true,
          //   ),
          // );
        } catch (_) {
          // keep task pending
        }
      }

      emit(state.copyWith(status: TaskBlocStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: TaskBlocStatus.failure,
          message: e.toString(),
        ),
      );
    }
  }
}


