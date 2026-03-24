import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:health_copilot/core/di/injection_container.dart';
import 'package:health_copilot/core/observability/observability.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function() builder,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Raw fallback for errors before DI is ready
  FlutterError.onError = (details) {
    developer.log(
      details.exceptionAsString(),
      stackTrace: details.stack,
    );
  };

  await initDependencies();

  final logger = sl<AppLogger>();
  final errorReporter = sl<ErrorReporter>();

  // Replace with observability-aware handlers
  FlutterError.onError = (details) {
    logger.error(
      details.exceptionAsString(),
      tag: 'Flutter',
      stackTrace: details.stack,
    );
    errorReporter
      ..recordFatalError(
        details.exception,
        details.stack ?? StackTrace.current,
      )
      ..flush(); // Best-effort, not awaited
  };

  // Catch uncaught async errors from detached zones.
  // Returns true = handled, don't propagate to engine.
  // For dev, consider false to surface errors loudly.
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error(
      'Uncaught async error',
      tag: 'Platform',
      error: error,
      stackTrace: stack,
    );
    errorReporter
      ..recordFatalError(error, stack)
      ..flush(); // Best-effort, not awaited
    return true;
  };

  Bloc.observer = ObservabilityBlocObserver(
    logger: logger,
    errorReporter: errorReporter,
  );

  runApp(await builder());
}
