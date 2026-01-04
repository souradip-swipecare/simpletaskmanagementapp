import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

import '../data/remote/firebase_auth_repository.dart';
import '../data/remote/firestore_users_repository.dart';
import '../core/token_storage.dart';
import '../data/local/hive_location_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuthRepository _repo;
  final FirestoreUsersRepository _usersRepo;
  final TokenStorage _tokenStorage;
  final HiveLocationRepository _locationRepo;

  AuthCubit(
    this._repo,
    this._usersRepo, {
    TokenStorage? tokenStorage,
    HiveLocationRepository? locationRepo,
  })  : _tokenStorage = tokenStorage ?? TokenStorage(),
        _locationRepo = locationRepo ?? HiveLocationRepository(),
        super(AuthState.initial()) {
    _listenToAuthChanges();
  }

  /// 🔁 Listen for auto-login / session restore
  void _listenToAuthChanges() {
    try {
      _repo.authStateChanges().listen((fb.User? user) async {
        if (user == null) {
          emit(AuthState.unauthenticated());
          return;
        }

        final valid = await _repo.isSessionValid();
        if (!valid) {
          await _repo.signOut();
          emit(AuthState.unauthenticated());
          return;
        }

        final role = await _fetchRole(user.uid);

        /// 📍 ASK LOCATION PERMISSION & SAVE
        await _locationRepo.saveLoginLocation(user.uid);

        emit(
          AuthState.authenticated(
            user.uid,
            user.displayName ?? user.email ?? '',
            role,
          ),
        );
      });
    } catch (_) {
      // Firebase not initialized (tests etc.)
    }
  }

  Future<String> _fetchRole(String uid) async {
    try {
      return await _usersRepo.getRole(uid);
    } catch (_) {
      return 'member';
    }
  }

  /// 🔐 SIGN IN
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final cred = await _repo.signInWithEmail(email, password);

      final token = await _repo.getIdToken();
      if (token != null) {
        await _tokenStorage.saveToken(token);
      }

      if (cred.user == null) {
        emit(AuthState.unauthenticated());
        return;
      }

      final role = await _fetchRole(cred.user!.uid);

      /// 📍 ASK LOCATION PERMISSION & SAVE
      await _locationRepo.saveLoginLocation(cred.user!.uid);

      emit(
        AuthState.authenticated(
          cred.user!.uid,
          cred.user!.displayName ?? cred.user!.email ?? '',
          role,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  /// 📝 SIGN UP
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
    String role = 'member',
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final cred = await _repo.signUpWithEmail(
        email,
        password,
        displayName: displayName,
        role: role,
      );

      await _repo.setUserRole(cred.user!.uid, role);

      final token = await _repo.getIdToken();
      if (token != null) {
        await _tokenStorage.saveToken(token);
      }

      final resolvedRole = await _fetchRole(cred.user!.uid);

      /// 📍 ASK LOCATION PERMISSION & SAVE
      await _locationRepo.saveLoginLocation(cred.user!.uid);

      emit(
        AuthState.authenticated(
          cred.user!.uid,
          cred.user!.displayName ?? cred.user!.email ?? '',
          resolvedRole,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  /// 🚪 SIGN OUT
  Future<void> signOut() async {
    await _repo.signOut();
    await _tokenStorage.deleteToken();
    emit(AuthState.unauthenticated());
  }
}
