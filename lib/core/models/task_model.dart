import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final int priority;
  final DateTime? dueDate;
  final String assignedTo;

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.assignedTo,
    this.dueDate, required bool isSynced,
  });

  /// ✅ THIS IS WHAT YOUR CUBIT NEEDS
  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'pending',
      priority: data['priority'] ?? 0,
      assignedTo: data['assignedTo'] ?? '',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(), isSynced: false,
    );
  }

  /// Optional but VERY useful
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
      'dueDate': dueDate,
    };
  }
  Map<String, dynamic> toFirestore() {
  return {
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'assignedTo': assignedTo,
    'dueDate': dueDate,
  };
}

  /// Optional but recommended
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    int? priority,
    DateTime? dueDate,
    String? assignedTo, required bool isSynced,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate, isSynced: false,
    );
  }
}
