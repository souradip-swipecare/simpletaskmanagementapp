import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firestore_users_repository.dart';
import 'exceptions.dart';

class FirestoreTasksRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  final FirestoreUsersRepository _usersRepo;

  FirestoreTasksRepository({FirestoreUsersRepository? usersRepo})
    : _usersRepo = usersRepo ?? FirestoreUsersRepository();

  CollectionReference get tasks => _db.collection('tasks');

  Stream<QuerySnapshot> tasksStreamForUser(String userId) {
    return tasks.where('assignedTo', isEqualTo: userId).snapshots();
  }

  Stream<QuerySnapshot> tasksStreamForAdmin() {
    return tasks.snapshots();
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    final docData = Map<String, dynamic>.from(data);
    docData['updatedAt'] = FieldValue.serverTimestamp();
    await tasks.doc(id).update(docData);
  }

  /// Soft-delete a task by setting `deletedAt`. Requires admin role if requesterId provided.
  Future<void> deleteTask(String id, {String? requesterId}) async {
    if (requesterId != null) {
      final role = await _usersRepo.getRole(requesterId);
      if (role != 'admin') {
        throw Exception('Only admins can delete tasks');
      }
    }
    await tasks.doc(id).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> fetchTasks({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) {
    Query q = tasks.orderBy('dueDate', descending: false).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    return q.get();
  }

  Future<DocumentSnapshot> getTask(String id) => tasks.doc(id).get();
  Future<DocumentReference> createTask(
    Map<String, dynamic> data, {
    String? requesterId,
  }) async {
    // 🔒 Validation
    final title = data['title'] as String?;
    final priority = data['priority'] as int?;
    final assignedTo = data['assignedTo'] as String?;
    if (title == null || title.trim().isEmpty) {
      throw Exception('Title is required');
    }

    if (priority == null) {
      throw Exception('Priority must be selected');
    }

    if (assignedTo == null || assignedTo.trim().isEmpty) {
      throw Exception('Assigned user is required');
    }

    // 🔐 Authorization (optional)
    if (requesterId != null) {
      final role = await _usersRepo.getRole(requesterId);
      debugPrint(role);
      if (role != 'admin') {
        throw Exception('Only admins can create tasks');
      }
    }

    final now = FieldValue.serverTimestamp();
    debugPrint("test");
    final docData = {
      'title': title.trim(),
      'description': data['description'] ?? '',
      'status': data['status'] ?? 'pending',
      'priority': priority,
      'assignedTo': assignedTo,
      'dueDate': data['dueDate'],
      'createdAt': now,
      'updatedAt': now,
      if (data['deletedAt'] != null) 'deletedAt': data['deletedAt'],
    };

    return tasks.add(docData);
  }
}
