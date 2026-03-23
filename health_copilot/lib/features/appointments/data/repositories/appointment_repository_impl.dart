import 'package:health_copilot/features/appointments/data/datasource/appointment_remote_data_source.dart';
import 'package:health_copilot/features/appointments/data/mappers/appointment_mapper.dart';
import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:health_copilot/features/appointments/domain/repositories/appointment_repository.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  AppointmentRepositoryImpl({
    required AppointmentRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  final AppointmentRemoteDataSource _dataSource;

  @override
  Future<Appointment> createAppointment({
    required int? conversationId,
    required int doctorId,
    required int timeSlotId,
    required String symptomsSummary,
    required String urgencyLevel,
  }) async {
    final model = await _dataSource.createAppointment(
      conversationId: conversationId,
      doctorId: doctorId,
      timeSlotId: timeSlotId,
      symptomsSummary: symptomsSummary,
      urgencyLevel: urgencyLevel,
    );
    return model.toEntity();
  }

  @override
  Future<List<Appointment>> getAppointments() async {
    final models = await _dataSource.getAppointments();
    return models.map((m) => m.toEntity()).toList();
  }
}
