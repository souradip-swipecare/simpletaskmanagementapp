import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanagementsouradip/domains/enums/enums.dart';
import 'package:taskmanagementsouradip/domains/entities/checkin.dart';
import '../local/hive_boxes.dart';

class CheckinSyncService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Attempts to find pending check-ins in Hive and upload them to Firestore.
  Future<void> syncPending() async {
    final box = await Hive.openBox<CheckIn>(HiveBoxes.checkins);
    for (final checkin in box.values) {
      if (checkin.syncStatus == SyncStatus.pending) {
        try {
          final data = {
            'id': checkin.id,
            'taskId': checkin.taskId,
            'notes': checkin.notes,
            'category': checkin.category.name,
            'lat': checkin.lat,
            'lng': checkin.lng,
            'createdAt': checkin.createdAt.toIso8601String(),
          };
          await _db.collection('checkins').add(data);

          final updated = CheckIn(
            id: checkin.id,
            taskId: checkin.taskId,
            notes: checkin.notes,
            category: checkin.category,
            lat: checkin.lat,
            lng: checkin.lng,
            syncStatus: SyncStatus.synced,
            createdAt: checkin.createdAt,
          );
          await box.put(checkin.id, updated);
        } catch (e) {
          final failed = CheckIn(
            id: checkin.id,
            taskId: checkin.taskId,
            notes: checkin.notes,
            category: checkin.category,
            lat: checkin.lat,
            lng: checkin.lng,
            syncStatus: SyncStatus.failed,
            createdAt: checkin.createdAt,
          );
          await box.put(checkin.id, failed);
        }
      }
    }
  }
}
