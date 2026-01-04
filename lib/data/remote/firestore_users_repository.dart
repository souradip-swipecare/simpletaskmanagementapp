import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanagementsouradip/core/models/user_model.dart';

class FirestoreUsersRepository {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Stream<QuerySnapshot> usersStream() => _db.collection('users').snapshots();

 Future<List<UserModel>> fetchUsers() async {
    final snap = await _db.collection('users').where('role', isEqualTo: 'member').get();
    return snap.docs.map((d) {
      final data = d.data();
      return UserModel(
        id: d.id,
        name: data['name'] ?? '',
        role: data['role'] ?? 'member',
      );
    }).toList();
  }
  Future<void> setRole(String uid, String role) async {
    await _db.collection('users').doc(uid).set({
      'role': role,
    }, SetOptions(merge: true));
  }

  Future<String> getRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data();
    if (data != null && data['role'] != null) return data['role'] as String;
    return 'member';
  }
}
