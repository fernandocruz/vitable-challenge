import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/core/observability/interceptors/observability_interceptor.dart';
import 'package:health_copilot/core/observability/ports/app_logger.dart';
import 'package:health_copilot/core/observability/ports/error_reporter.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogger extends Mock implements AppLogger {}

class _MockErrorReporter extends Mock
    implements ErrorReporter {}

class _MockHandler extends Mock
    implements RequestInterceptorHandler {}

class _MockErrorHandler extends Mock
    implements ErrorInterceptorHandler {}

class _MockResponseHandler extends Mock
    implements ResponseInterceptorHandler {}

void main() {
  late _MockLogger logger;
  late _MockErrorReporter errorReporter;
  late ObservabilityInterceptor interceptor;

  setUp(() {
    logger = _MockLogger();
    errorReporter = _MockErrorReporter();
    interceptor = ObservabilityInterceptor(
      logger: logger,
      errorReporter: errorReporter,
    );
  });

  group('ObservabilityInterceptor', () {
    test('onRequest logs HTTP method and path', () {
      final options = RequestOptions(path: '/api/test');
      final handler = _MockHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => logger.debug(
          any(that: contains('/api/test')),
          tag: 'HTTP',
        ),
      ).called(1);
      verify(() => handler.next(options)).called(1);
    });

    test('onRequest does not add context trail', () {
      final options = RequestOptions(path: '/api/test');
      final handler = _MockHandler();

      interceptor.onRequest(options, handler);

      verifyNever(
        () => errorReporter.addContext(
          any(),
          category: any(named: 'category'),
        ),
      );
    });

    test('onResponse logs and adds context trail', () {
      final options = RequestOptions(path: '/api/test');
      final response = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
      );
      final handler = _MockResponseHandler();

      interceptor.onResponse(response, handler);

      verify(
        () => logger.debug(
          any(that: contains('200')),
          tag: 'HTTP',
        ),
      ).called(1);
      verify(
        () => errorReporter.addContext(
          any(that: contains('200')),
          category: 'http',
        ),
      ).called(1);
    });

    test('onError logs, captures, and adds context', () {
      final options = RequestOptions(path: '/api/fail');
      final dioError = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: options,
          statusCode: 500,
        ),
      );
      final handler = _MockErrorHandler();

      interceptor.onError(dioError, handler);

      verify(
        () => logger.error(
          any(that: contains('500')),
          tag: 'HTTP',
          error: dioError,
          stackTrace: any(named: 'stackTrace'),
          context: any(named: 'context'),
        ),
      ).called(1);
      verify(
        () => errorReporter.captureException(
          dioError,
          stackTrace: any(named: 'stackTrace'),
          context: any(named: 'context'),
        ),
      ).called(1);
    });

    test('sanitizePath strips query parameters', () {
      final options = RequestOptions(
        path: '/api/users?token=secret&page=1',
      );
      final handler = _MockHandler();

      interceptor.onRequest(options, handler);

      verify(
        () => logger.debug(
          any(
            that: allOf(
              contains('/api/users'),
              isNot(contains('token')),
              isNot(contains('secret')),
            ),
          ),
          tag: 'HTTP',
        ),
      ).called(1);
    });
  });
}
