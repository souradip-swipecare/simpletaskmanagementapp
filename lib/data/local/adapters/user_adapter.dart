import 'package:hive/hive.dart';
import 'package:taskmanagementsouradip/domains/entities/user.dart';
import 'package:taskmanagementsouradip/domains/enums/enums.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final id = reader.readString();
    final email = reader.readString();
    final name = reader.readString();
    final role = UserRole.values[reader.readInt()];
    final password = reader.readString();
    final lat = reader.readString();
    final lng = reader.readString();
    return User(id, email, name, role, password, lat, lng);
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.email);
    writer.writeString(obj.name);
    writer.writeInt(obj.role.index);
    writer.writeString(obj.password);
    writer.writeString(obj.lattitude);
    writer.writeString(obj.longitude);
  }
}
