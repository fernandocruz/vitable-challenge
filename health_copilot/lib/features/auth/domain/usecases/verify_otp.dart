import 'package:health_copilot/features/auth/domain/entities/patient.dart';
import 'package:health_copilot/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtp {
  VerifyOtp(this._repository);

  final AuthRepository _repository;

  Future<({String token, Patient patient})> call({
    required String email,
    required String code,
  }) =>
      _repository.verifyOtp(email: email, code: code);
}
