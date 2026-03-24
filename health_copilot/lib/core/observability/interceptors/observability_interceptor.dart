import 'package:dio/dio.dart';
import 'package:health_copilot/core/observability/ports/app_logger.dart';
import 'package:health_copilot/core/observability/ports/error_reporter.dart';

class ObservabilityInterceptor extends Interceptor {
  const ObservabilityInterceptor({
    required AppLogger logger,
    required ErrorReporter errorReporter,
  })  : _logger = logger,
        _errorReporter = errorReporter;

  final AppLogger _logger;
  final ErrorReporter _errorReporter;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    _logger.debug(
      'HTTP ${options.method} '
      '${_sanitizePath(options.path)}',
      tag: 'HTTP',
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final path = _sanitizePath(
      response.requestOptions.path,
    );
    _logger.debug(
      'HTTP ${response.statusCode} $path',
      tag: 'HTTP',
    );
    _errorReporter.addContext(
      'HTTP ${response.statusCode} $path',
      category: 'http',
    );
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    final path = _sanitizePath(
      err.requestOptions.path,
    );
    _logger.error(
      'HTTP error ${err.response?.statusCode} $path',
      tag: 'HTTP',
      error: err,
      stackTrace: err.stackTrace,
      context: {
        'method': err.requestOptions.method,
        'path': path,
        'type': err.type.name,
      },
    );
    _errorReporter
      ..captureException(
        err,
        stackTrace: err.stackTrace,
        context: {
          'method': err.requestOptions.method,
          'path': path,
          'statusCode':
              err.response?.statusCode?.toString() ??
                  'null',
        },
      )
      ..addContext(
        'HTTP error '
        '${err.response?.statusCode} $path',
        category: 'http',
      );
    handler.next(err);
  }

  /// Strips query parameters from paths to avoid
  /// logging tokens or PII.
  static String _sanitizePath(String path) {
    final queryIndex = path.indexOf('?');
    if (queryIndex == -1) return path;
    return path.substring(0, queryIndex);
  }
}
