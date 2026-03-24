import 'package:bloc/bloc.dart';
import 'package:health_copilot/core/observability/ports/app_logger.dart';
import 'package:health_copilot/core/observability/ports/error_reporter.dart';

class ObservabilityBlocObserver extends BlocObserver {
  const ObservabilityBlocObserver({
    required AppLogger logger,
    required ErrorReporter errorReporter,
  })  : _logger = logger,
        _errorReporter = errorReporter;

  final AppLogger _logger;
  final ErrorReporter _errorReporter;

  @override
  void onChange(
    BlocBase<dynamic> bloc,
    Change<dynamic> change,
  ) {
    super.onChange(bloc, change);
    _logger.debug(
      'State change: ${bloc.runtimeType}',
      tag: 'Bloc',
    );
  }

  @override
  void onError(
    BlocBase<dynamic> bloc,
    Object error,
    StackTrace stackTrace,
  ) {
    _logger.error(
      'Bloc error: ${bloc.runtimeType}',
      tag: 'Bloc',
      error: error,
      stackTrace: stackTrace,
    );
    _errorReporter.captureException(
      error,
      stackTrace: stackTrace,
      message: 'Bloc error in ${bloc.runtimeType}',
    );
    super.onError(bloc, error, stackTrace);
  }
}
