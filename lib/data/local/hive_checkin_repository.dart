import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../local/hive_boxes.dart';
import '../../domains/entities/checkin.dart';
import '../../domains/enums/enums.dart';

class HiveCheckinRepository {
  final _uuid = const Uuid();
  late final Box<CheckIn> _box;


  Future<void> init() async {
    _box = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
  }

  Future<CheckIn> createCheckin({
    required String taskId,
    required String notes,
    required CheckInCategory category,
    required double lat,
    required double lng,
  }) async {
    final box = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
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
    await box.put(id, checkin);
    return checkin;
  }

  Future<List<CheckIn>> getPending() async {
    final box = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
    return box.values.where((c) => c.syncStatus == SyncStatus.pending).toList();
  }

  Future<void> update(CheckIn checkin) async {
    final box = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
    await box.put(checkin.id, checkin);
  }
}
