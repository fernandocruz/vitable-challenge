import 'package:health_copilot/core/api/api_client.dart';
import 'package:health_copilot/features/appointments/data/models/appointment_model.dart';

class AppointmentRemoteDataSource {
  AppointmentRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<AppointmentModel> createAppointment({
    required int? conversationId,
    required int doctorId,
    required int timeSlotId,
    required String symptomsSummary,
    required String urgencyLevel,
    int? patientId,
  }) async {
    final response =
        await _apiClient.post<Map<String, dynamic>>(
      '/copilot/appointments/',
      data: {
        'patient': patientId,
        'conversation': conversationId,
        'doctor': doctorId,
        'time_slot': timeSlotId,
        'symptoms_summary': symptomsSummary,
        'urgency_level': urgencyLevel,
      },
    );
    return AppointmentModel.fromJson(response.data!);
  }

  Future<List<AppointmentModel>> getAppointments() async {
    final response = await _apiClient
        .get<List<dynamic>>('/copilot/appointments/');
    return response.data!
        .map(
          (a) => AppointmentModel.fromJson(
            a as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
