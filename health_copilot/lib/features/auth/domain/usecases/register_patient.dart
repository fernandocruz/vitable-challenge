import 'package:health_copilot/features/auth/domain/entities/patient.dart';
import 'package:health_copilot/features/auth/domain/repositories/auth_repository.dart';

class RegisterPatient {
  RegisterPatient(this._repository);

  final AuthRepository _repository;

  Future<({Patient patient, String otp})> call({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
  }) =>
      _repository.registerPatient(
        name: name,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
}
