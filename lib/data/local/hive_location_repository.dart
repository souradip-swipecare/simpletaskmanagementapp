import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../../domains/entities/location.dart';
import 'hive_boxes.dart';

class HiveLocationRepository {
  late final Box<LoginLocation> _box;
   Future<void> init() async {
    _box = await Hive.openBox<LoginLocation>(HiveBoxes.locations);
  }
  Future<void> saveLoginLocation(String userId) async {
    try {
      // Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Permission denied — do not throw, just skip saving location.
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final box = await Hive.openBox<LoginLocation>(HiveBoxes.locations);
      final id = const Uuid().v4();
      final loc = LoginLocation(
        id: id,
        userId: userId,
        latitude: pos.latitude,
        longitude: pos.longitude,
        timestamp: DateTime.now(),
      );
      await box.put(id, loc);
    } catch (_) {
      // Swallow any location errors; saving location is best-effort.
    }
  }

  Future<List<LoginLocation>> getLocationsForUser(String userId) async {
    final box = await Hive.openBox<LoginLocation>(HiveBoxes.locations);
    return box.values.where((l) => l.userId == userId).toList();
  }
}
