import 'package:flutter/material.dart';
import 'task_form.dart';

class TaskDetailScreen extends StatelessWidget {
  final Map<String, dynamic> task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(task['title'] ?? 'Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${task['title'] ?? ''}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Description: ${task['description'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Assigned to: ${task['assignedTo'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Priority: ${task['priority'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Status: ${task['status'] ?? ''}'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TaskFormScreen(id: task['id'], initial: task),
                      ),
                    );
                  },
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // placeholder for status change or other actions
                  },
                  child: const Text('Mark Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
