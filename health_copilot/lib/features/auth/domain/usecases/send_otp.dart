import 'package:health_copilot/features/auth/domain/repositories/auth_repository.dart';

class SendOtp {
  SendOtp(this._repository);

  final AuthRepository _repository;

  Future<String> call({required String email}) =>
      _repository.sendOtp(email: email);
}
