import 'package:health_copilot/features/appointments/data/models/appointment_model.dart';
import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';

extension AppointmentMapper on AppointmentModel {
  Appointment toEntity() => Appointment(
        id: id,
        patientName: patientName,
        doctorName: doctorName,
        specialtyName: specialtyName,
        startTime: startTime,
        symptomsSummary: symptomsSummary,
        urgencyLevel: urgencyLevel,
        status: status,
        createdAt: createdAt,
      );
}
