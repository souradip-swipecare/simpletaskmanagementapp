import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanagementsouradip/utils/util.dart';

import '../../../blocprovider/task/task_cubit.dart';
import '../../../blocprovider/task/task_state.dart';
import '../../../components/custom_app_bar.dart';
import '../../../components/widgets.dart';
import '../../../core/models/task_model.dart';
import '../../../utils/color_palette.dart';
import '../../../utils/font_sizes.dart';

class UpdateTaskScreen extends StatefulWidget {
  final TaskModel taskModel;

  const UpdateTaskScreen({
    super.key,
    required this.taskModel,
  });

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  late String _status;
  late int _priority;

  @override
  void initState() {
    super.initState();
    _status = widget.taskModel.status;
    _priority = widget.taskModel.priority;
  }

  void _updateTask(BuildContext context) {
    final updatedTask = widget.taskModel.copyWith(
      status: _status,
      priority: _priority, isSynced: false,
    );

    context.read<TasksCubit>().updateStatus(widget.taskModel.id,_status);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: kWhiteColor,
        appBar: const CustomAppBar(title: 'Update Task'),

        body: BlocListener<TasksCubit, TasksState>(
          listener: (context, state) {
            if (state.status == TasksStatus.loading) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state.status == TasksStatus.success) {
              Navigator.pop(context); // close loader
              Navigator.pop(context); // close screen
            }

            if (state.status == TasksStatus.error) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                getSnackBar(
                  state.error ?? 'Failed to update task',
                  kRed,
                ),
              );
            }
          },

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                /// 🔒 READ-ONLY INFO
                _infoTile('Title', widget.taskModel.title),
                _infoTile('Description', widget.taskModel.description),
                _infoTile(
                  'Assigned To',
                  widget.taskModel.assignedTo,
                ),

                const SizedBox(height: 30),

                /// 🔁 STATUS (EDITABLE)
                buildText(
                  'Status',
                  kBlackColor,
                  textMedium,
                  FontWeight.bold,
                  TextAlign.start,
                  TextOverflow.clip,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _status = value!);
                  },
                ),

                const SizedBox(height: 20),

                /// ⭐ PRIORITY (EDITABLE)
                buildText(
                  'Priority',
                  kBlackColor,
                  textMedium,
                  FontWeight.bold,
                  TextAlign.start,
                  TextOverflow.clip,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _priority,
                  items: const [
                    DropdownMenuItem(
                      value: 0,
                      child: Text('High'),
                    ),
                    DropdownMenuItem(
                      value: 1,
                      child: Text('Medium'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text('Low'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _priority = value!);
                  },
                ),

                const SizedBox(height: 40),

                /// 💾 UPDATE BUTTON
                BlocBuilder<TasksCubit, TasksState>(
                  builder: (context, state) {
                    final isLoading =
                        state.status == TasksStatus.loading;

                    return ElevatedButton(
                      onPressed:
                          isLoading ? null : () => _updateTask(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : buildText(
                              'Update',
                              kWhiteColor,
                              textMedium,
                              FontWeight.w600,
                              TextAlign.center,
                              TextOverflow.clip,
                            ),
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

  /// 🔒 READ-ONLY TILE
  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildText(
          label,
          kBlackColor,
          textSmall,
          FontWeight.bold,
          TextAlign.start,
          TextOverflow.clip,
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: buildText(
            value,
            kBlackColor,
            textSmall,
            FontWeight.w400,
            TextAlign.start,
            TextOverflow.clip,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
