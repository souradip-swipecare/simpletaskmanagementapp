// import 'package:hive/hive.dart';
// import 'package:taskmanagementsouradip/domains/entities/checkin.dart';
// import 'package:taskmanagementsouradip/domains/enums/enums.dart';
// import 'package:uuid/uuid.dart';
// import '../local/hive_boxes.dart';
// import '../../domains/entities/task.dart';

// class HiveTaskRepository {
//     final _uuid = const Uuid();
// late final Box<TaskApp> _box;
// Future<void> init() async {
//     _box = await Hive.openBox<TaskApp>(HiveBoxes.tasks);
//   }

//   Future<void> addTask(TaskApp task) async {
//     final box = await Hive.openBox<TaskApp>(HiveBoxes.tasks);
//     await box.put(task.id, task);
//   }

//   Future<List<TaskApp>> getTasksForUser(String userId) async {
//     final box = await Hive.openBox<TaskApp>(HiveBoxes.tasks);
//     return box.values.where((t) => t.assignuser == userId).toList();
//   }

//   Future<void> updateTask(TaskApp task) async {
//     final box = await Hive.openBox<TaskApp>(HiveBoxes.tasks);
//     await box.put(task.id, task);
//   }
//   Future<CheckIn> createCheckin({
//     required String taskId,
//     required String notes,
//     required CheckInCategory category,
//     required double lat,
//     required double lng,
//   }) async {
//     final box = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
//     final id = _uuid.v4();
//     final now = DateTime.now();
//     final checkin = CheckIn(
//       id: id,
//       taskId: taskId,
//       notes: notes,
//       category: category,
//       lat: lat,
//       lng: lng,
//       syncStatus: SyncStatus.pending,
//       createdAt: now,
//     );
//     await box.put(id, checkin);
//     return checkin;
//   }

//   Future<List<CheckIn>> getPending() async {
//     final box = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
//     return box.values.where((c) => c.syncStatus == SyncStatus.pending).toList();
//   }
// List<TaskApp> getPendingTasks() {
//     return _box.values.where((t) => !t.isSynced).toList();
//   }
//   Future<void> update(CheckIn checkin) async {
//     final box = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
//     await box.put(checkin.id, checkin);
//   }
// }
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domains/entities/task.dart';
import '../../domains/entities/checkin.dart';
import '../../domains/enums/enums.dart';
import '../local/hive_boxes.dart';

class HiveTaskRepository {
  final _uuid = const Uuid();

  late final Box<TaskApp> _box;
  late final Box<CheckIn> _checkinBox;

  /// 🔑 MUST be called once at app startup
  Future<void> init() async {
    _box = await Hive.openBox<TaskApp>(HiveBoxes.tasks);
    _checkinBox = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
  }

  // ───────────── TASKS ─────────────

  Future<void> addTask(TaskApp task) async {
    await _box.put(task.id, task);
  }

  List<TaskApp> getTasksForUser(String userId) {
    return _box.values.where((t) => t.assignuser == userId).toList();
  }

  Future<void> updateTask(TaskApp task) async {
    await _box.put(task.id, task);
  }

  List<TaskApp> getPendingTasks() {
    return _box.values.where((t) => !t.isSynced).toList();
  }

  // ───────────── CHECKINS ─────────────

  Future<CheckIn> createCheckin({
    required String taskId,
    required String notes,
    required CheckInCategory category,
    required double lat,
    required double lng,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    final checkin = CheckIn(
      id: id,
      taskId: taskId,
      notes: notes,
      category: category,
      lat: lat,
      lng: lng,
      syncStatus: SyncStatus.pending,
      createdAt: now,
    );

    await _checkinBox.put(id, checkin);
    return checkin;
  }

  List<CheckIn> getPendingCheckins() {
    return _checkinBox.values
        .where((c) => c.syncStatus == SyncStatus.pending)
        .toList();
  }

  Future<void> updateCheckin(CheckIn checkin) async {
    await _checkinBox.put(checkin.id, checkin);
  }
}
