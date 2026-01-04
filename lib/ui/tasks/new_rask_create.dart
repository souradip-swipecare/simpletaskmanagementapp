import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:taskmanagementsouradip/blocprovider/usercubit/user_cubit.dart';

import 'package:taskmanagementsouradip/components/build_text_field.dart';
import 'package:taskmanagementsouradip/components/custom_app_bar.dart';
import 'package:taskmanagementsouradip/components/widgets.dart';
import 'package:taskmanagementsouradip/core/models/task_model.dart';
import 'package:taskmanagementsouradip/utils/color_palette.dart';
import 'package:taskmanagementsouradip/utils/font_sizes.dart';
import 'package:taskmanagementsouradip/utils/util.dart';
import 'package:taskmanagementsouradip/viewmodel/auth_cubit.dart';

import '../../blocprovider/task/task_cubit.dart';
import '../../blocprovider/task/task_state.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? _assignedUserId;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveTask(BuildContext context) {
    final auth = context.read<AuthCubit>().state;

    final assignedTo = auth.role == 'admin'
        ? _assignedUserId
        : auth.uid;

    if (assignedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        getSnackBar('Please select a user', kRed),
      );
      return;
    }

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        getSnackBar('Title cannot be empty', kRed),
      );
      return;
    }

    final task = TaskModel(
      id: '',
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      status: 'pending',
      priority: 0,
      assignedTo: assignedTo,
      dueDate: _selectedDay, isSynced: false,
    );

    context.read<TasksCubit>().create(task);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: kWhiteColor,
        appBar: const CustomAppBar(title: 'Create New Task'),
        body: BlocListener<TasksCubit, TasksState>(
          listener: (context, state) {
            if (state.status == TasksStatus.creating) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (state.status == TasksStatus.success) {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                getSnackBar('Task created successfully', Colors.green),
              );
            }

            if (state.status == TasksStatus.error) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                getSnackBar(
                  state.error ?? 'Something went wrong',
                  kRed,
                ),
              );
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  TableCalendar(
                    calendarFormat: _calendarFormat,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                      CalendarFormat.week: 'Week',
                    },
                    focusedDay: _focusedDay,
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2030, 1, 1),
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: buildText(
                      _selectedDay != null
                          ? 'Due on ${formatDate(dateTime: _selectedDay!.toIso8601String())}'
                          : 'Select a due date',
                      kPrimaryColor,
                      textSmall,
                      FontWeight.w400,
                      TextAlign.start,
                      TextOverflow.clip,
                    ),
                  ),

                  const SizedBox(height: 20),

                  BlocBuilder<UsersCubit, UsersState>(
                    builder: (context, state) {
                      if (state.loading) {
                        return const CircularProgressIndicator();
                      }

                      final auth = context.read<AuthCubit>().state;

                      if (auth.role != 'admin') {
                        _assignedUserId = auth.uid;
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildText(
                            'Assign To',
                            kBlackColor,
                            textMedium,
                            FontWeight.bold,
                            TextAlign.start,
                            TextOverflow.clip,
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: _assignedUserId,
                            hint: const Text('Select user'),
                            items: state.users.map((user) {
                              return DropdownMenuItem(
                                value: user.id,
                                child: Text(user.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _assignedUserId = value);
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),

                  buildText(
                    'Title',
                    kBlackColor,
                    textMedium,
                    FontWeight.bold,
                    TextAlign.start,
                    TextOverflow.clip,
                  ),
                  const SizedBox(height: 10),
                  BuildTextField(
                    hint: "Task Title",
                    controller: titleController,
                    inputType: TextInputType.text,
                    fillColor: kWhiteColor,
                    onChange: (_) {},
                  ),

                  const SizedBox(height: 20),

                  buildText(
                    'Description',
                    kBlackColor,
                    textMedium,
                    FontWeight.bold,
                    TextAlign.start,
                    TextOverflow.clip,
                  ),
                  const SizedBox(height: 10),
                  BuildTextField(
                    hint: "Task Description",
                    controller: descriptionController,
                    inputType: TextInputType.multiline,
                    fillColor: kWhiteColor,
                    onChange: (_) {},
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: buildText(
                            'Cancel',
                            kBlackColor,
                            textMedium,
                            FontWeight.w600,
                            TextAlign.center,
                            TextOverflow.clip,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: BlocBuilder<TasksCubit, TasksState>(
                          builder: (context, state) {
                            final isLoading =
                                state.status == TasksStatus.creating;

                            return ElevatedButton(
                              onPressed:
                                  isLoading ? null : () => _saveTask(context),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(15),
                                backgroundColor: kPrimaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : buildText(
                                      'Save',
                                      kWhiteColor,
                                      textMedium,
                                      FontWeight.w600,
                                      TextAlign.center,
                                      TextOverflow.clip,
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
