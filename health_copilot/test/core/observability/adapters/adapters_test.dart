import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/core/observability/observability.dart';

void main() {
  group('ConsoleLogger', () {
    late ConsoleLogger logger;

    setUp(() => logger = ConsoleLogger());

    test('logs at all levels without throwing', () {
      expect(
        () => logger.debug('debug message'),
        returnsNormally,
      );
      expect(
        () => logger.info('info message'),
        returnsNormally,
      );
      expect(
        () => logger.warning('warning message'),
        returnsNormally,
      );
      expect(
        () => logger.error('error message'),
        returnsNormally,
      );
    });

    test('handles null tag, context, and error', () {
      expect(
        () => logger.log(
          LogLevel.debug,
          'test',
        ),
        returnsNormally,
      );
    });

    test('handles empty message', () {
      expect(
        () => logger.debug(''),
        returnsNormally,
      );
    });

    test('handles context map', () {
      expect(
        () => logger.info(
          'with context',
          context: {'key': 'value'},
        ),
        returnsNormally,
      );
    });

    test('handles error and stackTrace params', () {
      expect(
        () => logger.debug(
          'parsing failed',
          error: Exception('parse error'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });

  group(
    'Contract: observability is optional '
    'with noop adapters',
    () {
      test('NoopErrorReporter methods are inert', () async {
        const reporter = NoopErrorReporter();
        const user = AppUser(id: 'test');

        expect(
          () => reporter.captureException(
            Exception('test'),
            stackTrace: StackTrace.current,
            context: {'key': 'val'},
            message: 'msg',
          ),
          returnsNormally,
        );
        expect(
          () => reporter.recordFatalError(
            Exception('fatal'),
            StackTrace.current,
          ),
          returnsNormally,
        );
        expect(
          () => reporter.addContext(
            'breadcrumb',
            category: 'test',
            data: {'k': 'v'},
          ),
          returnsNormally,
        );
        expect(
          () => reporter.setUser(user),
          returnsNormally,
        );
        await expectLater(
          reporter.flush(),
          completes,
        );
      });

      test('NoopEventTracker methods are inert', () {
        const tracker = NoopEventTracker();
        const user = AppUser(id: 'test');

        expect(
          () => tracker.trackEvent(
            'event',
            properties: {'key': 'val'},
          ),
          returnsNormally,
        );
        expect(
          () => tracker.trackScreenView('screen'),
          returnsNormally,
        );
        expect(
          () => tracker.setUserProperty('name', 'val'),
          returnsNormally,
        );
        expect(
          () => tracker.identify(user),
          returnsNormally,
        );
      });
    },
  );
}
