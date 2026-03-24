import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:health_copilot/core/api/api_client.dart';
import 'package:health_copilot/core/api/auth_interceptor.dart';
import 'package:health_copilot/core/observability/observability.dart';
import 'package:health_copilot/features/appointments/data/datasource/appointment_remote_data_source.dart';
import 'package:health_copilot/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:health_copilot/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:health_copilot/features/appointments/domain/usecases/create_appointment.dart';
import 'package:health_copilot/features/appointments/domain/usecases/get_appointments.dart';
import 'package:health_copilot/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:health_copilot/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:health_copilot/features/auth/domain/repositories/auth_repository.dart';
import 'package:health_copilot/features/auth/domain/usecases/get_current_patient.dart';
import 'package:health_copilot/features/auth/domain/usecases/register_patient.dart';
import 'package:health_copilot/features/auth/domain/usecases/send_otp.dart';
import 'package:health_copilot/features/auth/domain/usecases/verify_otp.dart';
import 'package:health_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:health_copilot/features/chat/data/datasource/copilot_remote_data_source.dart';
import 'package:health_copilot/features/chat/data/repositories/copilot_repository_impl.dart';
import 'package:health_copilot/features/chat/domain/repositories/copilot_repository.dart';
import 'package:health_copilot/features/chat/domain/usecases/create_conversation.dart';
import 'package:health_copilot/features/chat/domain/usecases/get_conversation.dart';
import 'package:health_copilot/features/chat/domain/usecases/send_message.dart';
import 'package:health_copilot/features/scheduling/data/datasource/scheduling_remote_data_source.dart';
import 'package:health_copilot/features/scheduling/data/repositories/scheduling_repository_impl.dart';
import 'package:health_copilot/features/scheduling/domain/repositories/scheduling_repository.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_doctor_slots.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_doctors.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_specialties.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => prefs);

  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton(() => secureStorage);

  _initObservability();
  _initCore();
  _initAuth();
  _initChat();
  _initScheduling();
  _initAppointments();
}

void _initObservability() {
  sl
    ..registerLazySingleton<AppLogger>(
      ConsoleLogger.new,
    )
    ..registerLazySingleton<ErrorReporter>(
      NoopErrorReporter.new,
    )
    ..registerLazySingleton<EventTracker>(
      NoopEventTracker.new,
    );
}

void _initCore() {
  sl.registerLazySingleton(
    () => ApiClient(
      interceptors: [
        AuthInterceptor(secureStorage: sl()),
        ObservabilityInterceptor(
          logger: sl(),
          errorReporter: sl(),
        ),
      ],
    ),
  );
}

void _initAuth() {
  sl
    ..registerLazySingleton(
      () => AuthRemoteDataSource(apiClient: sl()),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        dataSource: sl(),
        secureStorage: sl(),
      ),
    )
    ..registerLazySingleton(() => RegisterPatient(sl()))
    ..registerLazySingleton(() => SendOtp(sl()))
    ..registerLazySingleton(() => VerifyOtp(sl()))
    ..registerLazySingleton(
      () => GetCurrentPatient(sl()),
    )
    ..registerLazySingleton(
      () => AuthCubit(
        registerPatient: sl(),
        sendOtp: sl(),
        verifyOtp: sl(),
        getCurrentPatient: sl(),
        authRepository: sl(),
      ),
    );
}

void _initChat() {
  sl
    ..registerLazySingleton(
      () => CopilotRemoteDataSource(apiClient: sl()),
    )
    ..registerLazySingleton<CopilotRepository>(
      () => CopilotRepositoryImpl(dataSource: sl()),
    )
    ..registerLazySingleton(
      () => CreateConversation(sl()),
    )
    ..registerLazySingleton(() => SendMessage(sl()))
    ..registerLazySingleton(
      () => GetConversation(sl()),
    );
}

void _initScheduling() {
  sl
    ..registerLazySingleton(
      () => SchedulingRemoteDataSource(apiClient: sl()),
    )
    ..registerLazySingleton<SchedulingRepository>(
      () => SchedulingRepositoryImpl(dataSource: sl()),
    )
    ..registerLazySingleton(() => GetSpecialties(sl()))
    ..registerLazySingleton(() => GetDoctors(sl()))
    ..registerLazySingleton(() => GetDoctorSlots(sl()));
}

void _initAppointments() {
  sl
    ..registerLazySingleton(
      () => AppointmentRemoteDataSource(apiClient: sl()),
    )
    ..registerLazySingleton<AppointmentRepository>(
      () => AppointmentRepositoryImpl(dataSource: sl()),
    )
    ..registerLazySingleton(
      () => CreateAppointment(sl()),
    )
    ..registerLazySingleton(() => GetAppointments(sl()));
}
