import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Appointment> createAppointment({
    required int? conversationId,
    required int doctorId,
    required int timeSlotId,
    required String symptomsSummary,
    required String urgencyLevel,
    int? patientId,
  });

  Future<List<Appointment>> getAppointments();
}
