import 'dart:io';

import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({
    String? baseUrl,
    List<Interceptor>? interceptors,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? _defaultBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  // SECURITY: Development only. Production MUST use
  // HTTPS with certificate pinning. Configure the
  // production URL via flavor-specific config.
  static String get _defaultBaseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://localhost:8000/api';
  }

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.get(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
  }) =>
      _dio.post(path, data: data);
}
