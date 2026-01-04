part of 'auth_cubit.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

@immutable
class AuthState {
  final AuthStatus status;
  final String? uid;
  final String? displayName;
  final String? role;
  final String? error;

  const AuthState({
    required this.status,
    this.uid,
    this.displayName,
    this.role,
    this.error,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.authenticated(
    String uid,
    String displayName,
    String role,
  ) => AuthState(
    status: AuthStatus.authenticated,
    uid: uid,
    displayName: displayName,
    role: role,
  );

  AuthState copyWith({
    AuthStatus? status,
    String? uid,
    String? displayName,
    String? role,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      error: error ?? this.error,
    );
  }
}
