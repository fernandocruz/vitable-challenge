part of 'auth_cubit.dart';

enum AuthStatus {
  unknown,
  unauthenticated,
  registering,
  otpSent,
  verifying,
  authenticated,
  error,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.patient,
    this.email,
    this.error,
  });

  final AuthStatus status;
  final Patient? patient;
  final String? email;
  final String? error;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && patient != null;

  AuthState copyWith({
    AuthStatus? status,
    Patient? patient,
    String? email,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      patient: patient ?? this.patient,
      email: email ?? this.email,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, patient, email, error];
}
