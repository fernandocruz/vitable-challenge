import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required FlutterSecureStorage secureStorage,
  }) : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'auth_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token =
        await _secureStorage.read(key: _tokenKey);
    if (token != null) {
      options.headers['Authorization'] = 'Token $token';
    }
    handler.next(options);
  }
}
