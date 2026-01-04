import 'package:hive/hive.dart';
import 'package:taskmanagementsouradip/domains/entities/location.dart';

class LocationAdapter extends TypeAdapter<LoginLocation> {
  @override
  final int typeId = 4;

  @override
  LoginLocation read(BinaryReader reader) {
    final id = reader.readString();
    final userId = reader.readString();
    final latitude = reader.readDouble();
    final longitude = reader.readDouble();
    final timestamp = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return LoginLocation(
      id: id,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
    );
  }

  @override
  void write(BinaryWriter writer, LoginLocation obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.userId);
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
    writer.writeInt(obj.timestamp.millisecondsSinceEpoch);
  }
}
