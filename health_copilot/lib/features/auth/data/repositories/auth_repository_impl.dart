import 'package:health_copilot/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:health_copilot/features/auth/data/mappers/patient_mapper.dart';
import 'package:health_copilot/features/auth/domain/entities/patient.dart';
import 'package:health_copilot/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required SharedPreferences prefs,
  })  : _dataSource = dataSource,
        _prefs = prefs;

  final AuthRemoteDataSource _dataSource;
  final SharedPreferences _prefs;

  static const _tokenKey = 'auth_token';

  @override
  Future<({Patient patient, String otp})>
      registerPatient({
    required String name,
    required String email,
    required String phone,
    required String dateOfBirth,
  }) async {
    final result = await _dataSource.registerPatient(
      name: name,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
    );
    return (
      patient: result.patient.toEntity(),
      otp: result.otp,
    );
  }

  @override
  Future<String> sendOtp({required String email}) =>
      _dataSource.sendOtp(email: email);

  @override
  Future<({String token, Patient patient})> verifyOtp({
    required String email,
    required String code,
  }) async {
    final result = await _dataSource.verifyOtp(
      email: email,
      code: code,
    );
    return (
      token: result.token,
      patient: result.patient.toEntity(),
    );
  }

  @override
  Future<Patient> getCurrentPatient() async {
    final model = await _dataSource.getCurrentPatient();
    return model.toEntity();
  }

  @override
  Future<void> saveToken(String token) =>
      _prefs.setString(_tokenKey, token);

  @override
  Future<String?> getStoredToken() async =>
      _prefs.getString(_tokenKey);

  @override
  Future<void> clearToken() => _prefs.remove(_tokenKey);
}
