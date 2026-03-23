import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:health_copilot/features/appointments/domain/repositories/appointment_repository.dart';

class GetAppointments {
  GetAppointments(this._repository);

  final AppointmentRepository _repository;

  Future<List<Appointment>> call() =>
      _repository.getAppointments();
}
