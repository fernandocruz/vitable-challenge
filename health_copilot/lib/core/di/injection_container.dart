import 'package:get_it/get_it.dart';
import 'package:health_copilot/core/api/api_client.dart';
import 'package:health_copilot/core/observability/observability.dart';
import 'package:health_copilot/features/appointments/data/datasource/appointment_remote_data_source.dart';
import 'package:health_copilot/features/appointments/data/repositories/appointment_repository_impl.dart';
import 'package:health_copilot/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:health_copilot/features/appointments/domain/usecases/create_appointment.dart';
import 'package:health_copilot/features/appointments/domain/usecases/get_appointments.dart';
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

final sl = GetIt.instance;

void initDependencies() {
  _initObservability();
  _initCore();
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
        ObservabilityInterceptor(
          logger: sl(),
          errorReporter: sl(),
        ),
      ],
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
    ..registerLazySingleton(() => CreateConversation(sl()))
    ..registerLazySingleton(() => SendMessage(sl()))
    ..registerLazySingleton(() => GetConversation(sl()));
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
    ..registerLazySingleton(() => CreateAppointment(sl()))
    ..registerLazySingleton(() => GetAppointments(sl()));
}
