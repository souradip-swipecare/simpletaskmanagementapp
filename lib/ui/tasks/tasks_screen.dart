import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodel/auth_cubit.dart';
import 'tasks_list.dart';
import 'task_form.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthCubit>().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
          Builder(
            builder: (ctx) {
              String? role = 'member';
              try {
                role = ctx.select((AuthCubit c) => c.state.role ?? 'member');
              } catch (_) {
                role = 'member';
              }
              if (role == 'admin') {
                return IconButton(
                  onPressed: () => {

                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Manage Users',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: const TasksListScreen(),
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final isAdmin = state.role == 'admin';
          if (!isAdmin) return const SizedBox.shrink();
          return FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const TaskFormScreen()),
              );
              if (created == true) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Task created')));
              }
            },
          );
        },
      ),
    );
  }
}
