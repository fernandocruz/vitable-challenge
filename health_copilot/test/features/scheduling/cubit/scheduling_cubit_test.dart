import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:health_copilot/features/appointments/domain/usecases/create_appointment.dart';
import 'package:health_copilot/features/scheduling/domain/entities/doctor.dart';
import 'package:health_copilot/features/scheduling/domain/entities/specialty.dart';
import 'package:health_copilot/features/scheduling/domain/entities/time_slot.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_doctor_slots.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_doctors.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_specialties.dart';
import 'package:health_copilot/features/scheduling/presentation/cubit/scheduling_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetSpecialties extends Mock
    implements GetSpecialties {}

class _MockGetDoctors extends Mock implements GetDoctors {}

class _MockGetDoctorSlots extends Mock
    implements GetDoctorSlots {}

class _MockCreateAppointment extends Mock
    implements CreateAppointment {}

void main() {
  late _MockGetSpecialties getSpecialties;
  late _MockGetDoctors getDoctors;
  late _MockGetDoctorSlots getDoctorSlots;
  late _MockCreateAppointment createAppointment;

  const specialty = Specialty(
    id: 1,
    name: 'Neurology',
    description: 'Brain',
  );
  const doctor = Doctor(
    id: 1,
    name: 'Dr. Brain',
    specialtyName: 'Neurology',
    bio: 'Expert',
  );
  final slot = TimeSlot(
    id: 1,
    doctorId: 1,
    startTime: DateTime(2026, 4, 1, 9),
    isAvailable: true,
  );
  final appointment = Appointment(
    id: 1,
    patientName: 'John',
    doctorName: 'Dr. Brain',
    specialtyName: 'Neurology',
    startTime: DateTime(2026, 4, 1, 9),
    symptomsSummary: 'headaches',
    urgencyLevel: 'medium',
    status: 'confirmed',
    createdAt: '2026-01-01',
  );

  setUp(() {
    getSpecialties = _MockGetSpecialties();
    getDoctors = _MockGetDoctors();
    getDoctorSlots = _MockGetDoctorSlots();
    createAppointment = _MockCreateAppointment();
  });

  SchedulingCubit buildCubit() => SchedulingCubit(
        getSpecialties: getSpecialties,
        getDoctors: getDoctors,
        getDoctorSlots: getDoctorSlots,
        createAppointment: createAppointment,
      );

  group('SchedulingCubit', () {
    blocTest<SchedulingCubit, SchedulingState>(
      'loadDoctorsBySpecialty emits loaded with doctors',
      setUp: () {
        when(() => getSpecialties())
            .thenAnswer((_) async => [specialty]);
        when(() => getDoctors(specialtyId: 1))
            .thenAnswer((_) async => [doctor]);
      },
      build: buildCubit,
      act: (c) => c.loadDoctorsBySpecialty('Neurology'),
      expect: () => [
        const SchedulingState(
          status: SchedulingStatus.loading,
        ),
        const SchedulingState(
          status: SchedulingStatus.loaded,
          doctors: [doctor],
        ),
      ],
    );

    blocTest<SchedulingCubit, SchedulingState>(
      'loadDoctorsBySpecialty falls back to first specialty',
      setUp: () {
        when(() => getSpecialties())
            .thenAnswer((_) async => [specialty]);
        when(() => getDoctors(specialtyId: 1))
            .thenAnswer((_) async => [doctor]);
      },
      build: buildCubit,
      act: (c) => c.loadDoctorsBySpecialty('Unknown'),
      expect: () => [
        const SchedulingState(
          status: SchedulingStatus.loading,
        ),
        const SchedulingState(
          status: SchedulingStatus.loaded,
          doctors: [doctor],
        ),
      ],
    );

    blocTest<SchedulingCubit, SchedulingState>(
      'loadDoctorsBySpecialty error emits error',
      setUp: () => when(() => getSpecialties())
          .thenThrow(Exception('fail')),
      build: buildCubit,
      act: (c) => c.loadDoctorsBySpecialty('Neurology'),
      expect: () => [
        const SchedulingState(
          status: SchedulingStatus.loading,
        ),
        isA<SchedulingState>().having(
          (s) => s.status,
          'status',
          SchedulingStatus.error,
        ),
      ],
    );

    blocTest<SchedulingCubit, SchedulingState>(
      'selectDoctor emits loaded with slots',
      setUp: () => when(() => getDoctorSlots(1))
          .thenAnswer((_) async => [slot]),
      build: buildCubit,
      act: (c) => c.selectDoctor(doctor),
      expect: () => [
        const SchedulingState(
          status: SchedulingStatus.loading,
        ),
        SchedulingState(
          status: SchedulingStatus.loaded,
          selectedDoctor: doctor,
          slots: [slot],
        ),
      ],
    );

    blocTest<SchedulingCubit, SchedulingState>(
      'selectDoctor error emits error',
      setUp: () => when(() => getDoctorSlots(1))
          .thenThrow(Exception('fail')),
      build: buildCubit,
      act: (c) => c.selectDoctor(doctor),
      expect: () => [
        const SchedulingState(
          status: SchedulingStatus.loading,
        ),
        isA<SchedulingState>().having(
          (s) => s.status,
          'status',
          SchedulingStatus.error,
        ),
      ],
    );

    test('bookAppointment returns appointment', () async {
      when(
        () => createAppointment(
          conversationId: any(named: 'conversationId'),
          doctorId: any(named: 'doctorId'),
          timeSlotId: any(named: 'timeSlotId'),
          symptomsSummary:
              any(named: 'symptomsSummary'),
          urgencyLevel: any(named: 'urgencyLevel'),
          patientId: any(named: 'patientId'),
        ),
      ).thenAnswer((_) async => appointment);

      final cubit = buildCubit()
        ..emit(
          SchedulingState(
            status: SchedulingStatus.loaded,
            selectedDoctor: doctor,
            slots: [slot],
          ),
        );

      final result = await cubit.bookAppointment(
        timeSlotId: 1,
        conversationId: null,
        symptomsSummary: 'headaches',
        urgencyLevel: 'medium',
      );

      expect(result, isNotNull);
      expect(result!.doctorName, 'Dr. Brain');
    });

    test(
      'bookAppointment returns null without selected doctor',
      () async {
        final cubit = buildCubit();
        final result = await cubit.bookAppointment(
          timeSlotId: 1,
          conversationId: null,
          symptomsSummary: 'test',
          urgencyLevel: 'low',
        );
        expect(result, isNull);
      },
    );

    test(
      'bookAppointment returns null on error',
      () async {
        when(
          () => createAppointment(
            conversationId:
                any(named: 'conversationId'),
            doctorId: any(named: 'doctorId'),
            timeSlotId: any(named: 'timeSlotId'),
            symptomsSummary:
                any(named: 'symptomsSummary'),
            urgencyLevel: any(named: 'urgencyLevel'),
            patientId: any(named: 'patientId'),
          ),
        ).thenThrow(Exception('fail'));

        final cubit = buildCubit()
          ..emit(
            SchedulingState(
              status: SchedulingStatus.loaded,
              selectedDoctor: doctor,
              slots: [slot],
            ),
          );

        final result = await cubit.bookAppointment(
          timeSlotId: 1,
          conversationId: null,
          symptomsSummary: 'test',
          urgencyLevel: 'low',
        );
        expect(result, isNull);
      },
    );
  });
}
