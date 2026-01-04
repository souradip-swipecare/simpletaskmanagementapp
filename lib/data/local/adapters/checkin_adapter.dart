import 'package:hive/hive.dart';
import 'package:taskmanagementsouradip/domains/entities/checkin.dart';
import 'package:taskmanagementsouradip/domains/enums/enums.dart';

class CheckinAdapter extends TypeAdapter<CheckIn> {
  @override
  final int typeId = 2;

  @override
  CheckIn read(BinaryReader reader) {
    final id = reader.readString();
    final taskId = reader.readString();
    final notes = reader.readString();
    final category = CheckInCategory.values[reader.readInt()];
    final lat = reader.readDouble();
    final lng = reader.readDouble();
    final syncStatus = SyncStatus.values[reader.readInt()];
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return CheckIn(
      id: id,
      taskId: taskId,
      notes: notes,
      category: category,
      lat: lat,
      lng: lng,
      syncStatus: syncStatus,
      createdAt: createdAt,
    );
  }

  @override
  void write(BinaryWriter writer, CheckIn obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.taskId);
    writer.writeString(obj.notes);
    writer.writeInt(obj.category.index);
    writer.writeDouble(obj.lat);
    writer.writeDouble(obj.lng);
    writer.writeInt(obj.syncStatus.index);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
