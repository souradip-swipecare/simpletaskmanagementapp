import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/remote/firestore_users_repository.dart';

class AdminUsersScreen extends StatelessWidget {
  final dynamic repo;
  final Stream<List<Map<String, dynamic>>>? usersStreamOverride;

  AdminUsersScreen({super.key, dynamic? repo, this.usersStreamOverride})
    : repo = repo ?? FirestoreUsersRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: usersStreamOverride != null
          ? StreamBuilder<List<Map<String, dynamic>>>(
              stream: usersStreamOverride,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                final list = snap.data ?? [];
                if (list.isEmpty) return const Center(child: Text('No users'));
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final d = list[index];
                    final role = d['role'] ?? 'member';
                    final email = d['email'] ?? '';
                    final uid = d['id'] ?? '';
                    return ListTile(
                      title: Text(email),
                      subtitle: Text('Role: $role'),
                      trailing: ElevatedButton(
                        child: Text(role == 'admin' ? 'Revoke' : 'Promote'),
                        onPressed: () async {
                          final newRole = role == 'admin' ? 'member' : 'admin';
                          await repo.setRole(uid, newRole);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Set role to $newRole')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            )
          : StreamBuilder<QuerySnapshot>(
              stream: repo.usersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData)
                  return const Center(child: Text('No users'));
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index];
                    final role =
                        (d.data() as Map<String, dynamic>?)?['role'] ??
                        'member';
                    final email =
                        (d.data() as Map<String, dynamic>?)?['email'] ?? '';
                    return ListTile(
                      title: Text(email),
                      subtitle: Text('Role: $role'),
                      trailing: ElevatedButton(
                        child: Text(role == 'admin' ? 'Revoke' : 'Promote'),
                        onPressed: () async {
                          final newRole = role == 'admin' ? 'member' : 'admin';
                          await repo.setRole(d.id, newRole);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Set role to $newRole')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
