import 'package:taskmanagementsouradip/domains/enums/enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskApp {
  final String id;
  final String title;
  final String description;

  final String assignuser;
  final TaskStatus taskstatus;
  final TaskPriority priority;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  TaskApp({
    required this.id,
    required this.title,
    required this.description,
    required this.assignuser,
    this.taskstatus = TaskStatus.pending,
    required this.priority,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory TaskApp.fromMap(String id, Map<String, dynamic> data) {
    DateTime _parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is Timestamp) return v.toDate();
      if (v is String)
        return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return TaskApp(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      assignuser: data['assignedTo'] ?? '',
      taskstatus: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (data['status'] ?? 'pending'),
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == (data['priority'] ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      dueDate: _parseDate(data['dueDate']),
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
      deletedAt: data['deletedAt'] != null
          ? _parseDate(data['deletedAt'])
          : null,
    );
  }

  bool get isSynced => false;

  // Map<String, dynamic> toMap() => {
  //   'title': title,
  //   'description': description,
  //   'assignedTo': assignuser,
  //   'status': taskstatus.toString().split('.').last,
  //   'priority': priority.toString().split('.').last,
  //   'dueDate': dueDate.toIso8601String(),
  //   'createdAt': createdAt.toIso8601String(),
  //   'updatedAt': updatedAt.toIso8601String(),
  //   if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
  // };
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'status': taskstatus,
      'priority': priority,
      'assignedTo': assignuser,
      'dueDate': dueDate,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
