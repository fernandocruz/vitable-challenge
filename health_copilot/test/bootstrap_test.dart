import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/core/api/api_client.dart';
import 'package:health_copilot/core/di/injection_container.dart';
import 'package:health_copilot/core/observability/observability.dart';

void main() {
  group('DI wiring', () {
    setUp(() {
      if (sl.isRegistered<AppLogger>()) {
        sl.reset();
      }
      initDependencies();
    });

    tearDown(sl.reset);

    test('registers AppLogger as ConsoleLogger', () {
      expect(sl.isRegistered<AppLogger>(), isTrue);
      expect(sl<AppLogger>(), isA<ConsoleLogger>());
    });

    test('registers ErrorReporter as NoopErrorReporter',
        () {
      expect(
        sl.isRegistered<ErrorReporter>(),
        isTrue,
      );
      expect(
        sl<ErrorReporter>(),
        isA<NoopErrorReporter>(),
      );
    });

    test('registers EventTracker as NoopEventTracker',
        () {
      expect(
        sl.isRegistered<EventTracker>(),
        isTrue,
      );
      expect(
        sl<EventTracker>(),
        isA<NoopEventTracker>(),
      );
    });

    test(
      'observability registered before core — '
      'ApiClient resolves without error',
      () {
        expect(sl.isRegistered<ApiClient>(), isTrue);
        expect(sl<ApiClient>(), isA<ApiClient>());
      },
    );
  });
}
