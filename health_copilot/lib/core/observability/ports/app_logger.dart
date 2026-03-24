enum LogLevel { debug, info, warning, error }

abstract class AppLogger {
  void log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  });

  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) =>
      log(
        LogLevel.debug,
        message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
        context: context,
      );

  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) =>
      log(
        LogLevel.info,
        message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
        context: context,
      );

  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) =>
      log(
        LogLevel.warning,
        message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
        context: context,
      );

  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) =>
      log(
        LogLevel.error,
        message,
        tag: tag,
        error: error,
        stackTrace: stackTrace,
        context: context,
      );
}
