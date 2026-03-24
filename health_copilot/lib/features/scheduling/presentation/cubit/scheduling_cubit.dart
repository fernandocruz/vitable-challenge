import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:health_copilot/features/appointments/domain/usecases/create_appointment.dart';
import 'package:health_copilot/features/scheduling/domain/entities/doctor.dart';
import 'package:health_copilot/features/scheduling/domain/entities/time_slot.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_doctor_slots.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_doctors.dart';
import 'package:health_copilot/features/scheduling/domain/usecases/get_specialties.dart';

part 'scheduling_state.dart';

class SchedulingCubit extends Cubit<SchedulingState> {
  SchedulingCubit({
    required GetSpecialties getSpecialties,
    required GetDoctors getDoctors,
    required GetDoctorSlots getDoctorSlots,
    required CreateAppointment createAppointment,
  })  : _getSpecialties = getSpecialties,
        _getDoctors = getDoctors,
        _getDoctorSlots = getDoctorSlots,
        _createAppointment = createAppointment,
        super(const SchedulingState());

  final GetSpecialties _getSpecialties;
  final GetDoctors _getDoctors;
  final GetDoctorSlots _getDoctorSlots;
  final CreateAppointment _createAppointment;

  Future<void> loadDoctorsBySpecialty(
    String specialtyName,
  ) async {
    emit(state.copyWith(status: SchedulingStatus.loading));
    try {
      final specialties = await _getSpecialties();
      final specialty = specialties.firstWhere(
        (s) => s.name == specialtyName,
        orElse: () => specialties.first,
      );
      final doctors =
          await _getDoctors(specialtyId: specialty.id);
      emit(
        state.copyWith(
          status: SchedulingStatus.loaded,
          doctors: doctors,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SchedulingStatus.error,
          error: 'Failed to load doctors.',
        ),
      );
    }
  }

  Future<void> selectDoctor(Doctor doctor) async {
    emit(state.copyWith(status: SchedulingStatus.loading));
    try {
      final slots = await _getDoctorSlots(doctor.id);
      emit(
        state.copyWith(
          status: SchedulingStatus.loaded,
          selectedDoctor: doctor,
          slots: slots,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SchedulingStatus.error,
          error: 'Failed to load time slots.',
        ),
      );
    }
  }

  Future<Appointment?> bookAppointment({
    required int timeSlotId,
    required int? conversationId,
    required String symptomsSummary,
    required String urgencyLevel,
    int? patientId,
  }) async {
    if (state.selectedDoctor == null) return null;
    try {
      return await _createAppointment(
        conversationId: conversationId,
        doctorId: state.selectedDoctor!.id,
        timeSlotId: timeSlotId,
        symptomsSummary: symptomsSummary,
        urgencyLevel: urgencyLevel,
        patientId: patientId,
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SchedulingStatus.error,
          error: 'Failed to book appointment.',
        ),
      );
      return null;
    }
  }
}
