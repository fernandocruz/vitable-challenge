import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/core/observability/observability.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogger extends Mock implements AppLogger {}

class _MockErrorReporter extends Mock
    implements ErrorReporter {}

class _TestCubit extends Cubit<int> {
  _TestCubit() : super(0);
  void increment() => emit(state + 1);
}

void main() {
  late _MockLogger logger;
  late _MockErrorReporter errorReporter;
  late ObservabilityBlocObserver observer;

  setUp(() {
    logger = _MockLogger();
    errorReporter = _MockErrorReporter();
    observer = ObservabilityBlocObserver(
      logger: logger,
      errorReporter: errorReporter,
    );
    Bloc.observer = observer;
  });

  group('ObservabilityBlocObserver', () {
    test('onChange logs state change with Bloc tag', () {
      final cubit = _TestCubit()
        ..increment();

      verify(
        () => logger.debug(
          any(that: contains('_TestCubit')),
          tag: 'Bloc',
        ),
      ).called(1);

      cubit.close();
    });

    test('onError logs and captures exception', () {
      final cubit = _TestCubit();
      final error = Exception('test error');
      final stackTrace = StackTrace.current;

      observer.onError(cubit, error, stackTrace);

      verify(
        () => logger.error(
          any(that: contains('_TestCubit')),
          tag: 'Bloc',
          error: error,
          stackTrace: stackTrace,
        ),
      ).called(1);

      verify(
        () => errorReporter.captureException(
          error,
          stackTrace: stackTrace,
          message: any(
            named: 'message',
            that: contains('_TestCubit'),
          ),
        ),
      ).called(1);

      cubit.close();
    });
  });
}
