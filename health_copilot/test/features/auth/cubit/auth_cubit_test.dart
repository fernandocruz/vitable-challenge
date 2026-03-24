import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/features/auth/domain/entities/patient.dart';
import 'package:health_copilot/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_copilot/features/auth/domain/usecases/get_current_patient.dart';
import 'package:health_copilot/features/auth/domain/usecases/register_patient.dart';
import 'package:health_copilot/features/auth/domain/usecases/send_otp.dart';
import 'package:health_copilot/features/auth/domain/usecases/verify_otp.dart';
import 'package:health_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterPatient extends Mock
    implements RegisterPatient {}

class _MockSendOtp extends Mock implements SendOtp {}

class _MockVerifyOtp extends Mock implements VerifyOtp {}

class _MockGetCurrentPatient extends Mock
    implements GetCurrentPatient {}

class _MockAuthRepository extends Mock
    implements AuthRepository {}

void main() {
  late _MockRegisterPatient registerPatient;
  late _MockSendOtp sendOtp;
  late _MockVerifyOtp verifyOtp;
  late _MockGetCurrentPatient getCurrentPatient;
  late _MockAuthRepository authRepository;

  final patient = Patient(
    id: 1,
    name: 'John',
    email: 'john@test.com',
    phone: '+1',
    dateOfBirth: DateTime(1990),
    isVerified: true,
  );

  setUp(() {
    registerPatient = _MockRegisterPatient();
    sendOtp = _MockSendOtp();
    verifyOtp = _MockVerifyOtp();
    getCurrentPatient = _MockGetCurrentPatient();
    authRepository = _MockAuthRepository();
  });

  AuthCubit buildCubit() => AuthCubit(
        registerPatient: registerPatient,
        sendOtp: sendOtp,
        verifyOtp: verifyOtp,
        getCurrentPatient: getCurrentPatient,
        authRepository: authRepository,
      );

  group('AuthCubit', () {
    blocTest<AuthCubit, AuthState>(
      'checkAuthStatus with no token emits unauthenticated',
      setUp: () => when(() => authRepository.getStoredToken())
          .thenAnswer((_) async => null),
      build: buildCubit,
      act: (c) => c.checkAuthStatus(),
      expect: () => [
        const AuthState(
          status: AuthStatus.unauthenticated,
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'checkAuthStatus with valid token emits authenticated',
      setUp: () {
        when(() => authRepository.getStoredToken())
            .thenAnswer((_) async => 'token123');
        when(() => getCurrentPatient())
            .thenAnswer((_) async => patient);
      },
      build: buildCubit,
      act: (c) => c.checkAuthStatus(),
      expect: () => [
        AuthState(
          status: AuthStatus.authenticated,
          patient: patient,
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'checkAuthStatus with expired token clears and emits unauthenticated',
      setUp: () {
        when(() => authRepository.getStoredToken())
            .thenAnswer((_) async => 'expired');
        when(() => getCurrentPatient())
            .thenThrow(Exception('401'));
        when(() => authRepository.clearToken())
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      act: (c) => c.checkAuthStatus(),
      expect: () => [
        const AuthState(
          status: AuthStatus.unauthenticated,
        ),
      ],
      verify: (_) {
        verify(() => authRepository.clearToken()).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'register emits registering then otpSent',
      setUp: () => when(
        () => registerPatient(
          name: any(named: 'name'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      ).thenAnswer(
        (_) async => (patient: patient, otp: '111111'),
      ),
      build: buildCubit,
      act: (c) => c.register(
        name: 'John',
        email: 'john@test.com',
        phone: '+1',
        dateOfBirth: '1990-01-01',
      ),
      expect: () => [
        const AuthState(status: AuthStatus.registering),
        const AuthState(
          status: AuthStatus.otpSent,
          email: 'john@test.com',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'register error emits error',
      setUp: () => when(
        () => registerPatient(
          name: any(named: 'name'),
          email: any(named: 'email'),
          phone: any(named: 'phone'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      ).thenThrow(Exception('fail')),
      build: buildCubit,
      act: (c) => c.register(
        name: 'John',
        email: 'john@test.com',
        phone: '+1',
        dateOfBirth: '1990-01-01',
      ),
      expect: () => [
        const AuthState(status: AuthStatus.registering),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.error,
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'loginWithOtp emits otpSent',
      setUp: () => when(
        () => sendOtp(email: any(named: 'email')),
      ).thenAnswer((_) async => '111111'),
      build: buildCubit,
      act: (c) =>
          c.loginWithOtp(email: 'john@test.com'),
      expect: () => [
        const AuthState(status: AuthStatus.registering),
        const AuthState(
          status: AuthStatus.otpSent,
          email: 'john@test.com',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'loginWithOtp error emits error',
      setUp: () => when(
        () => sendOtp(email: any(named: 'email')),
      ).thenThrow(Exception('fail')),
      build: buildCubit,
      act: (c) =>
          c.loginWithOtp(email: 'john@test.com'),
      expect: () => [
        const AuthState(status: AuthStatus.registering),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.error,
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'verifyOtp saves token and emits authenticated',
      setUp: () {
        when(
          () => verifyOtp(
            email: any(named: 'email'),
            code: any(named: 'code'),
          ),
        ).thenAnswer(
          (_) async => (token: 'tok', patient: patient),
        );
        when(() => authRepository.saveToken('tok'))
            .thenAnswer((_) async {});
      },
      build: buildCubit,
      seed: () => const AuthState(
        status: AuthStatus.otpSent,
        email: 'john@test.com',
      ),
      act: (c) => c.verifyOtp('111111'),
      expect: () => [
        const AuthState(
          status: AuthStatus.verifying,
          email: 'john@test.com',
        ),
        AuthState(
          status: AuthStatus.authenticated,
          patient: patient,
          email: 'john@test.com',
        ),
      ],
      verify: (_) {
        verify(
          () => authRepository.saveToken('tok'),
        ).called(1);
      },
    );

    blocTest<AuthCubit, AuthState>(
      'verifyOtp error emits error',
      setUp: () => when(
        () => verifyOtp(
          email: any(named: 'email'),
          code: any(named: 'code'),
        ),
      ).thenThrow(Exception('invalid')),
      build: buildCubit,
      seed: () => const AuthState(
        status: AuthStatus.otpSent,
        email: 'john@test.com',
      ),
      act: (c) => c.verifyOtp('999999'),
      expect: () => [
        const AuthState(
          status: AuthStatus.verifying,
          email: 'john@test.com',
        ),
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.error,
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'logout clears token and emits unauthenticated',
      setUp: () => when(() => authRepository.clearToken())
          .thenAnswer((_) async {}),
      build: buildCubit,
      seed: () => AuthState(
        status: AuthStatus.authenticated,
        patient: patient,
      ),
      act: (c) => c.logout(),
      expect: () => [
        const AuthState(
          status: AuthStatus.unauthenticated,
        ),
      ],
      verify: (_) {
        verify(() => authRepository.clearToken()).called(1);
      },
    );
  });
}
