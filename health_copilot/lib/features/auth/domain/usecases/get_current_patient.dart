import 'package:health_copilot/features/auth/domain/entities/patient.dart';
import 'package:health_copilot/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentPatient {
  GetCurrentPatient(this._repository);

  final AuthRepository _repository;

  Future<Patient> call() => _repository.getCurrentPatient();
}
