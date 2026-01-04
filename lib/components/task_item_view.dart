import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:taskmanagementsouradip/blocprovider/task/task_cubit.dart';
import 'package:taskmanagementsouradip/blocprovider/task/task_state.dart';
import 'package:taskmanagementsouradip/core/models/task_model.dart';
import 'package:taskmanagementsouradip/ui/tasks/update_task_screen.dart';
import 'package:taskmanagementsouradip/viewmodel/auth_cubit.dart';

import '../../../components/widgets.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';
import '../../../utils/util.dart';

class TaskItemView extends StatelessWidget {
  final TaskModel taskModel;

  const TaskItemView({super.key, required this.taskModel});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = taskModel.status == 'completed';

    return BlocListener<TasksCubit, TasksState>(
      listener: (context, state) {
        if (state.status == TasksStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            getSnackBar(state.error ?? 'Something went wrong', kRed),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ STATUS CHECKBOX
            BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                final isLoading = state.status == TasksStatus.loading;

                return Checkbox(
                  value: isCompleted,
                  onChanged: isLoading
                      ? null
                      : (_) {
                          context.read<TasksCubit>().updateStatus(
                            taskModel.id,
                            isCompleted ? 'pending' : 'completed',
                          );
                        },
                );
              },
            ),

            const SizedBox(width: 8),

            /// 🔹 CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title + Menu
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildText(
                          taskModel.title,
                          kBlackColor,
                          textMedium,
                          FontWeight.w600,
                          TextAlign.start,
                          TextOverflow.ellipsis,
                        ),
                      ),
                      _TaskMenu(taskModel: taskModel),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// Priority + Status
                  Row(
                    children: [
                      _PriorityBadge(priority: taskModel.priority),
                      const SizedBox(width: 8),
                      _StatusBadge(status: taskModel.status),
                    ],
                  ),

                  /// Description
                  if (taskModel.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    buildText(
                      taskModel.description,
                      kGrey1,
                      textSmall,
                      FontWeight.normal,
                      TextAlign.start,
                      TextOverflow.ellipsis,
                    ),
                  ],

                  /// Due date
                  if (taskModel.dueDate != null) ...[
                    const SizedBox(height: 10),
                    _DueDateChip(dueDate: taskModel.dueDate!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskMenu extends StatelessWidget {
  final TaskModel taskModel;

  const _TaskMenu({required this.taskModel});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: kWhiteColor,
      elevation: 2,
      onSelected: (value) async {
        if (value == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UpdateTaskScreen(taskModel: taskModel),
            ),
          );
        } else if (value == 1) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            final role = context.read<AuthCubit>().state.role!;
            if (role == 'admin') {
              context.read<TasksCubit>().delete(taskModel.id);
            }
            return;
          }
        }
      },
      itemBuilder: (_) => [
        _menuItem(
          icon: 'assets/svgs/edit.svg',
          label: 'Edit task',
          color: kBlackColor,
          value: 0,
        ),
        // _menuItem(
        //   icon: 'assets/svgs/delete.svg',
        //   label: 'Delete task',
        //   color: kRed,
        //   value: 1,
        // ),
      ],
      child: SvgPicture.asset('assets/svgs/vertical_menu.svg', width: 20),
    );
  }

  PopupMenuItem<int> _menuItem({
    required String icon,
    required String label,
    required Color color,
    required int value,
  }) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          SvgPicture.asset(icon, width: 18),
          const SizedBox(width: 10),
          buildText(
            label,
            color,
            textMedium,
            FontWeight.normal,
            TextAlign.start,
            TextOverflow.clip,
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final int priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final text = priority == 0
        ? 'High'
        : priority == 1
        ? 'Medium'
        : 'Low';

    final color = priority == 0
        ? Colors.red
        : priority == 1
        ? Colors.orange
        : Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: textSmall,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final completed = status == 'completed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.withOpacity(.12)
            : Colors.blue.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: textSmall - 1,
          fontWeight: FontWeight.w600,
          color: completed ? Colors.green : Colors.blue,
        ),
      ),
    );
  }
}

class _DueDateChip extends StatelessWidget {
  final DateTime dueDate;
  const _DueDateChip({required this.dueDate});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/svgs/calender.svg', width: 12),
          const SizedBox(width: 8),
          buildText(
            formatDate(dateTime: dueDate.toIso8601String()),
            kBlackColor,
            textTiny,
            FontWeight.w400,
            TextAlign.start,
            TextOverflow.clip,
          ),
        ],
      ),
    );
  }
}
