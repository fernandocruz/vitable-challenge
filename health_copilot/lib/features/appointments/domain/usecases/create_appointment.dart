import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:health_copilot/features/appointments/domain/repositories/appointment_repository.dart';

class CreateAppointment {
  CreateAppointment(this._repository);

  final AppointmentRepository _repository;

  Future<Appointment> call({
    required int? conversationId,
    required int doctorId,
    required int timeSlotId,
    required String symptomsSummary,
    required String urgencyLevel,
  }) =>
      _repository.createAppointment(
        conversationId: conversationId,
        doctorId: doctorId,
        timeSlotId: timeSlotId,
        symptomsSummary: symptomsSummary,
        urgencyLevel: urgencyLevel,
      );
}
