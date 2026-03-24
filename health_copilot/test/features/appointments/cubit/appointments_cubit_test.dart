import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:health_copilot/features/appointments/domain/usecases/get_appointments.dart';
import 'package:health_copilot/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetAppointments extends Mock
    implements GetAppointments {}

void main() {
  late _MockGetAppointments getAppointments;

  final appointments = [
    Appointment(
      id: 1,
      patientName: 'John',
      doctorName: 'Dr. Brain',
      specialtyName: 'Neurology',
      startTime: DateTime(2026, 4, 1, 9),
      symptomsSummary: 'headaches',
      urgencyLevel: 'medium',
      status: 'confirmed',
      createdAt: '2026-01-01',
    ),
    Appointment(
      id: 2,
      patientName: 'John',
      doctorName: 'Dr. Heart',
      specialtyName: 'Cardiology',
      startTime: DateTime(2026, 4, 2, 14),
      symptomsSummary: 'chest pain',
      urgencyLevel: 'high',
      status: 'confirmed',
      createdAt: '2026-01-02',
    ),
  ];

  setUp(() {
    getAppointments = _MockGetAppointments();
  });

  AppointmentsCubit buildCubit() => AppointmentsCubit(
        getAppointments: getAppointments,
      );

  group('AppointmentsCubit', () {
    blocTest<AppointmentsCubit, AppointmentsState>(
      'loadAppointments emits loaded with list',
      setUp: () => when(() => getAppointments())
          .thenAnswer((_) async => appointments),
      build: buildCubit,
      act: (c) => c.loadAppointments(),
      expect: () => [
        const AppointmentsState(
          status: AppointmentsStatus.loading,
        ),
        AppointmentsState(
          status: AppointmentsStatus.loaded,
          appointments: appointments,
        ),
      ],
    );

    blocTest<AppointmentsCubit, AppointmentsState>(
      'loadAppointments emits loaded with empty list',
      setUp: () => when(() => getAppointments())
          .thenAnswer((_) async => []),
      build: buildCubit,
      act: (c) => c.loadAppointments(),
      expect: () => [
        const AppointmentsState(
          status: AppointmentsStatus.loading,
        ),
        const AppointmentsState(
          status: AppointmentsStatus.loaded,
        ),
      ],
    );

    blocTest<AppointmentsCubit, AppointmentsState>(
      'loadAppointments error emits error',
      setUp: () => when(() => getAppointments())
          .thenThrow(Exception('network error')),
      build: buildCubit,
      act: (c) => c.loadAppointments(),
      expect: () => [
        const AppointmentsState(
          status: AppointmentsStatus.loading,
        ),
        isA<AppointmentsState>()
            .having(
              (s) => s.status,
              'status',
              AppointmentsStatus.error,
            )
            .having(
              (s) => s.error,
              'error',
              isNotNull,
            ),
      ],
    );
  });
}
