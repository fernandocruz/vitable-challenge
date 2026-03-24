import 'package:health_copilot/core/api/api_client.dart';
import 'package:health_copilot/features/auth/data/models/patient_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<({PatientModel patient, String otp})>
      registerPatient({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
  }) async {
    final response =
        await _apiClient.post<Map<String, dynamic>>(
      '/copilot/patients/register/',
      data: {
        'name': name,
        'email': email,
        'phone': phone,
        'date_of_birth': dateOfBirth,
      },
    );
    final data = response.data!;
    return (
      patient: PatientModel.fromJson(
        data['patient'] as Map<String, dynamic>,
      ),
      otp: (data['otp'] ?? '') as String,
    );
  }

  Future<String> sendOtp({required String email}) async {
    final response =
        await _apiClient.post<Map<String, dynamic>>(
      '/copilot/patients/send-otp/',
      data: {'email': email},
    );
    return (response.data!['otp'] ?? '') as String;
  }

  Future<({String token, PatientModel patient})>
      verifyOtp({
    required String email,
    required String code,
  }) async {
    final response =
        await _apiClient.post<Map<String, dynamic>>(
      '/copilot/patients/verify-otp/',
      data: {'email': email, 'code': code},
    );
    final data = response.data!;
    return (
      token: data['token'] as String,
      patient: PatientModel.fromJson(
        data['patient'] as Map<String, dynamic>,
      ),
    );
  }

  Future<PatientModel> getCurrentPatient() async {
    final response = await _apiClient
        .get<Map<String, dynamic>>('/copilot/patients/me/');
    return PatientModel.fromJson(response.data!);
  }
}
