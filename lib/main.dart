import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:taskmanagementsouradip/blocprovider/task/task_cubit.dart';
import 'package:taskmanagementsouradip/ui/tasks/update_task_screen.dart';
import 'package:taskmanagementsouradip/blocprovider/usercubit/user_cubit.dart';
import 'package:taskmanagementsouradip/data/local/hive_checkin_repository.dart';
import 'package:taskmanagementsouradip/data/local/hive_location_repository.dart';
import 'package:taskmanagementsouradip/data/local/hive_task_repository.dart';
import 'package:taskmanagementsouradip/ui/tasks/new_rask_create.dart';
import 'firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/remote/firebase_auth_repository.dart';
import 'data/remote/firestore_tasks_repository.dart';
import 'data/local/adapters/user_adapter.dart';
import 'data/local/adapters/task_adapter.dart';
import 'data/local/adapters/checkin_adapter.dart';
import 'data/local/adapters/location_adapter.dart';
import 'viewmodel/auth_cubit.dart';
import 'data/remote/firestore_users_repository.dart';
import 'data/sync/checkin_sync_service.dart';
import 'data/sync/sync_manager.dart';
import 'ui/login/login_screen.dart';
import 'ui/login/signup_screen.dart';
import 'ui/splash/splash_screen.dart';
import 'ui/tasks/task_screen_all.dart';

import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();
  // Register adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(CheckinAdapter());
  Hive.registerAdapter(LocationAdapter());
  // 📦 Init Hive repositories
  final hiveTaskRepo = HiveTaskRepository();
  final hiveCheckinRepo = HiveCheckinRepository();
  final hiveLocationRepo = HiveLocationRepository();

  await hiveTaskRepo.init();
  await hiveCheckinRepo.init();
  await hiveLocationRepo.init();
  // Start sync manager
  final syncManager = SyncManager(CheckinSyncService());
  syncManager.start();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) =>
              AuthCubit(FirebaseAuthRepository(), FirestoreUsersRepository()),
        ),
        BlocProvider<TasksCubit>(
          create: (_) => TasksCubit(FirestoreTasksRepository()),
        ),
      ],
      child: MaterialApp(
        title: 'Task Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/splash',
        routes: {
  '/splash': (_) => const SplashScreen(),
  '/': (_) => _RootRouter(),
  '/tasks': (_) => const TasksScreen(),
  '/admin/screen': (_) => const TasksScreen(),
  '/new/task': (_) => BlocProvider(
        create: (_) =>
            UsersCubit(FirestoreUsersRepository())..fetchUsers(),
        child: const NewTaskScreen(),
      ),
  '/login': (_) => const LoginScreen(),
  '/signup': (_) => const SignUpScreen(),
},

      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.loading ||
            state.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AuthStatus.authenticated) {
          return const TasksScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
