import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../viewmodel/task_form_cubit.dart';
import '../../data/remote/firestore_tasks_repository.dart';

class TaskFormScreen extends StatefulWidget {
  final String? id;
  final Map<String, dynamic>? initial;
  const TaskFormScreen({super.key, this.id, this.initial});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _assigned = TextEditingController();
  String _priority = 'medium';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      _title.text = widget.initial!['title'] ?? '';
      _desc.text = widget.initial!['description'] ?? '';
      _assigned.text = widget.initial!['assignedTo'] ?? '';
      _priority = widget.initial!['priority'] ?? 'medium';
      try {
        _dueDate = DateTime.parse(widget.initial!['dueDate']);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskFormCubit(FirestoreTasksRepository(), context.read()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.id == null ? 'Create Task' : 'Edit Task'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Title is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _desc,
                  decoration: const InputDecoration(labelText: 'Description'),
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _assigned,
                  decoration: const InputDecoration(
                    labelText: 'Assign to (user id)',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Assigned user is required'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _priority,
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _priority = v);
                  },
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Priority must be selected'
                      : null,
                  decoration: const InputDecoration(labelText: 'Priority'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Due: ${_dueDate.toLocal().toString().split(' ').first}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 5),
                          ),
                        );
                        if (d != null) setState(() => _dueDate = d);
                      },
                      child: const Text('Pick Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                BlocConsumer<TaskFormCubit, TaskFormState>(
                  listener: (context, state) {
                    if (state.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task saved')),
                      );
                      Navigator.of(context).pop(true);
                    }
                    if (state.error != null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error!)));
                    }
                  },
                  builder: (context, state) {
                    if (state.loading) return const CircularProgressIndicator();
                    return ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) return;
                        if (widget.id == null) {
                          context.read<TaskFormCubit>().createTask(
                            title: _title.text,
                            description: _desc.text,
                            assignedTo: _assigned.text,
                            priority: _priority,
                            dueDate: _dueDate,
                          );
                        } else {
                          final currentStatus =
                              widget.initial?['status'] ?? 'open';
                          context.read<TaskFormCubit>().updateTask(
                            widget.id!,
                            title: _title.text,
                            description: _desc.text,
                            assignedTo: _assigned.text,
                            priority: _priority,
                            dueDate: _dueDate,
                            status: currentStatus,
                          );
                        }
                      },
                      child: const Text('Save'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
