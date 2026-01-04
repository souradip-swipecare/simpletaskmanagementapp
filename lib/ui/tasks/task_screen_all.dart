import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taskmanagementsouradip/blocprovider/task/task_cubit.dart';
import 'package:taskmanagementsouradip/blocprovider/task/task_state.dart';

import 'package:taskmanagementsouradip/components/build_text_field.dart';
import 'package:taskmanagementsouradip/components/custom_app_bar.dart';
import 'package:taskmanagementsouradip/components/task_item_view.dart';
import 'package:taskmanagementsouradip/components/widgets.dart';
import 'package:taskmanagementsouradip/ui/admin/admin_users_screen.dart';
import 'package:taskmanagementsouradip/utils/color_palette.dart';
import 'package:taskmanagementsouradip/utils/font_sizes.dart';
import 'package:taskmanagementsouradip/viewmodel/auth_cubit.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

enum TaskSort { date, completed, pending }

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  bool _subscribed = false;
  String role = '';
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_subscribed) return;

      final userId = context.read<AuthCubit>().state.uid!;
      role = context.read<AuthCubit>().state.role!;
      if (role == 'admin') {
        context.read<TasksCubit>().subscribeall();
      } else {
        context.read<TasksCubit>().subscribe(userId);
      }

      _subscribed = true;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      context.read<TasksCubit>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: kWhiteColor,
        appBar: CustomAppBar(
          title: 'Hello ${context.watch<AuthCubit>().state.displayName ?? ''}',
          showBackArrow: false,
          actionWidgets: [
            BlocBuilder<AuthCubit, AuthState>(
              buildWhen: (prev, curr) => prev.role != curr.role,
              builder: (context, state) {
                if (state.role != 'admin') {
                  return const SizedBox.shrink();
                }

                return IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin/screen');
                    // TODO: Navigate to manage users
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Manage Users',
                );
              },
            ),

            /// 🔽 Sort menu
            PopupMenuButton<TaskSort>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
              color: kWhiteColor,
              onSelected: (sort) {
                context.read<TasksCubit>().sort(sort.index);
              },
              itemBuilder: (_) => [
                _TaskMenuItem(
                  value: TaskSort.date,
                  label: 'Sort by date',
                  icon: 'assets/svgs/calender.svg',
                ),
                _TaskMenuItem(
                  value: TaskSort.completed,
                  label: 'Completed tasks',
                  icon: 'assets/svgs/task_checked.svg',
                ),
                _TaskMenuItem(
                  value: TaskSort.pending,
                  label: 'Pending tasks',
                  icon: 'assets/svgs/task.svg',
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: SvgPicture.asset('assets/svgs/filter.svg'),
              ),
            ),

            /// 🚪 Logout
            IconButton(
              onPressed: () =>{ 
                context.read<AuthCubit>().signOut(),
                Navigator.pushNamed(context, '/login'),
                
              
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                if (state.status == TasksStatus.initial ||
                    state.status == TasksStatus.loading) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                if (state.status == TasksStatus.error) {
                  return Center(
                    child: buildText(
                      state.error ?? 'Something went wrong',
                      kBlackColor,
                      textMedium,
                      FontWeight.normal,
                      TextAlign.center,
                      TextOverflow.clip,
                    ),
                  );
                }

                if (state.visibleTasks.isEmpty) {
                  return _EmptyTasksView(size: size);
                }

                return Column(
                  children: [
                    BuildTextField(
                      hint: "Search recent task",
                      controller: searchController,
                      inputType: TextInputType.text,
                      prefixIcon: const Icon(Icons.search, color: kGrey2),
                      fillColor: kWhiteColor,
                      onChange: _onSearchChanged,
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: state.visibleTasks.length,
                        itemBuilder: (context, index) {
                          return TaskItemView(
                            taskModel: state.visibleTasks[index],
                          );
                        },
                        separatorBuilder: (_, __) =>
                            const Divider(color: kGrey3),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        floatingActionButton: role == 'admin'
            ? FloatingActionButton(
                onPressed: () {
                  if (role == 'admin') {
                    Navigator.pushNamed(context, '/new/task');
                  }
                },
                child: const Icon(Icons.add_circle, color: kPrimaryColor),
              )
            : null,
      ),
    );
  }
}

class _TaskMenuItem extends PopupMenuItem<TaskSort> {
  _TaskMenuItem({
    required TaskSort value,
    required String label,
    required String icon,
  }) : super(
         value: value,
         child: Row(children: [const SizedBox(width: 10), Text(label)]),
       );
}

class _EmptyTasksView extends StatelessWidget {
  const _EmptyTasksView({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/svgs/tasks.svg',
            height: size.height * .20,
            width: size.width,
          ),
          const SizedBox(height: 40),
          buildText(
            'Schedule your tasks',
            kBlackColor,
            textBold,
            FontWeight.w600,
            TextAlign.center,
            TextOverflow.clip,
          ),
          buildText(
            'Manage your task schedule easily\nand efficiently',
            kBlackColor.withOpacity(.5),
            textSmall,
            FontWeight.normal,
            TextAlign.center,
            TextOverflow.clip,
          ),
        ],
      ),
    );
  }
}
