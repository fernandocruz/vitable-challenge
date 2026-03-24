import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_copilot/features/auth/domain/entities/patient.dart';
import 'package:health_copilot/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_copilot/features/auth/domain/usecases/get_current_patient.dart';
import 'package:health_copilot/features/auth/domain/usecases/register_patient.dart';
import 'package:health_copilot/features/auth/domain/usecases/send_otp.dart';
import 'package:health_copilot/features/auth/domain/usecases/verify_otp.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required RegisterPatient registerPatient,
    required SendOtp sendOtp,
    required VerifyOtp verifyOtp,
    required GetCurrentPatient getCurrentPatient,
    required AuthRepository authRepository,
  })  : _registerPatient = registerPatient,
        _sendOtp = sendOtp,
        _verifyOtp = verifyOtp,
        _getCurrentPatient = getCurrentPatient,
        _authRepository = authRepository,
        super(const AuthState());

  final RegisterPatient _registerPatient;
  final SendOtp _sendOtp;
  final VerifyOtp _verifyOtp;
  final GetCurrentPatient _getCurrentPatient;
  final AuthRepository _authRepository;

  Future<void> checkAuthStatus() async {
    final token = await _authRepository.getStoredToken();
    if (token == null) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
        ),
      );
      return;
    }

    try {
      final patient = await _getCurrentPatient();
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          patient: patient,
        ),
      );
    } catch (_) {
      await _authRepository.clearToken();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
        ),
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
  }) async {
    emit(state.copyWith(status: AuthStatus.registering));
    try {
      await _registerPatient(
        name: name,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
      emit(
        state.copyWith(
          status: AuthStatus.otpSent,
          email: email,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: 'Registration failed. Please try again.',
        ),
      );
    }
  }

  Future<void> loginWithOtp({required String email}) async {
    emit(state.copyWith(status: AuthStatus.registering));
    try {
      await _sendOtp(email: email);
      emit(
        state.copyWith(
          status: AuthStatus.otpSent,
          email: email,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: 'Could not send OTP. Check your email.',
        ),
      );
    }
  }

  Future<void> verifyOtp(String code) async {
    if (state.email == null) return;
    emit(state.copyWith(status: AuthStatus.verifying));
    try {
      final result = await _verifyOtp(
        email: state.email!,
        code: code,
      );
      await _authRepository.saveToken(result.token);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          patient: result.patient,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          error: 'Invalid or expired OTP.',
        ),
      );
    }
  }

  Future<void> logout() async {
    await _authRepository.clearToken();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }
}
