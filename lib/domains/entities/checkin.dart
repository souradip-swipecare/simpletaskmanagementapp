
import 'package:taskmanagementsouradip/domains/enums/enums.dart';

class CheckIn {
  final String id;
  final String taskId;
  final String notes;
  final CheckInCategory category;
  final double lat;
  final double lng;
  final SyncStatus syncStatus;
  final DateTime createdAt;

  CheckIn({
    required this.id,
    required this.taskId,
    required this.notes,
    required this.category,
    required this.lat,
    required this.lng,
    required this.syncStatus,
    required this.createdAt,
  });
}
