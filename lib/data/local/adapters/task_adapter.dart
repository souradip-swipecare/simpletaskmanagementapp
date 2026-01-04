import 'package:hive/hive.dart';
import 'package:taskmanagementsouradip/domains/entities/task.dart';
import 'package:taskmanagementsouradip/domains/enums/enums.dart';

class TaskAdapter extends TypeAdapter<TaskApp> {
  @override
  final int typeId = 1;

  @override
  TaskApp read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final description = reader.readString();
    final assignuser = reader.readString();
    final taskstatus = TaskStatus.values[reader.readInt()];
    final priority = TaskPriority.values[reader.readInt()];
    final dueDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final updatedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasDeleted = reader.readBool();
    final deletedAt = hasDeleted
        ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
        : null;
    return TaskApp(
      id: id,
      title: title,
      description: description,
      assignuser: assignuser,
      taskstatus: taskstatus,
      priority: priority,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  @override
  void write(BinaryWriter writer, TaskApp obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.assignuser);
    writer.writeInt(obj.taskstatus.index);
    writer.writeInt(obj.priority.index);
    writer.writeInt(obj.dueDate.millisecondsSinceEpoch);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
    writer.writeBool(obj.deletedAt != null);
    if (obj.deletedAt != null)
      writer.writeInt(obj.deletedAt!.millisecondsSinceEpoch);
  }
}
