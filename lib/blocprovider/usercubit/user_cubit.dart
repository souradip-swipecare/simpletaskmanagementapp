import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskmanagementsouradip/core/models/user_model.dart';
import 'package:taskmanagementsouradip/data/remote/firestore_users_repository.dart';

class UsersState {
  final bool loading;
  final List<UserModel> users;
  final String? error;

  UsersState({
    required this.loading,
    required this.users,
    this.error,
  });

  factory UsersState.initial() =>
      UsersState(loading: false, users: []);
}

class UsersCubit extends Cubit<UsersState> {
  final FirestoreUsersRepository repo;

  UsersCubit(this.repo) : super(UsersState.initial());

  Future<void> fetchUsers() async {
    emit(UsersState(loading: true, users: []));
    try {
      final users = await repo.fetchUsers();
      emit(UsersState(loading: false, users: users));
    } catch (e) {
      emit(UsersState(loading: false, users: [], error: e.toString()));
    }
  }
}
