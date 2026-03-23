import 'package:health_copilot/core/api/api_client.dart';
import 'package:health_copilot/features/scheduling/data/models/doctor_model.dart';
import 'package:health_copilot/features/scheduling/data/models/specialty_model.dart';
import 'package:health_copilot/features/scheduling/data/models/time_slot_model.dart';

class SchedulingRemoteDataSource {
  SchedulingRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<SpecialtyModel>> getSpecialties() async {
    final response = await _apiClient
        .get<List<dynamic>>('/scheduling/specialties/');
    return response.data!
        .map(
          (s) =>
              SpecialtyModel.fromJson(s as Map<String, dynamic>),
        )
        .toList();
  }

  Future<List<DoctorModel>> getDoctors({
    int? specialtyId,
  }) async {
    final params = <String, dynamic>{};
    if (specialtyId != null) {
      params['specialty'] = specialtyId;
    }
    final response = await _apiClient.get<List<dynamic>>(
      '/scheduling/doctors/',
      queryParameters: params,
    );
    return response.data!
        .map(
          (d) =>
              DoctorModel.fromJson(d as Map<String, dynamic>),
        )
        .toList();
  }

  Future<DoctorModel> getDoctor(int id) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>('/scheduling/doctors/$id/');
    return DoctorModel.fromJson(response.data!);
  }

  Future<List<TimeSlotModel>> getDoctorSlots(
    int doctorId,
  ) async {
    final response = await _apiClient.get<List<dynamic>>(
      '/scheduling/doctors/$doctorId/slots/',
    );
    return response.data!
        .map(
          (s) =>
              TimeSlotModel.fromJson(s as Map<String, dynamic>),
        )
        .toList();
  }
}
