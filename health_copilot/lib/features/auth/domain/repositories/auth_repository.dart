import 'package:health_copilot/features/auth/domain/entities/patient.dart';

abstract class AuthRepository {
  Future<({Patient patient, String otp})> registerPatient({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
  });

  Future<String> sendOtp({required String email});

  Future<({String token, Patient patient})> verifyOtp({
    required String email,
    required String code,
  });

  Future<Patient> getCurrentPatient();

  Future<void> saveToken(String token);
  Future<String?> getStoredToken();
  Future<void> clearToken();
}
