import 'dart:developer' as developer;

import 'package:health_copilot/core/observability/ports/app_logger.dart';

class ConsoleLogger extends AppLogger {
  ConsoleLogger();

  @override
  void log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final buffer = StringBuffer('[${level.name}] $message');
    if (context != null && context.isNotEmpty) {
      buffer.write(
        ' | ${_formatContext(context)}',
      );
    }
    developer.log(
      buffer.toString(),
      name: tag ?? 'App',
      level: _levelToInt(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static int _levelToInt(LogLevel level) => switch (level) {
        LogLevel.debug => 0,
        LogLevel.info => 500,
        LogLevel.warning => 900,
        LogLevel.error => 1000,
      };

  static String _formatContext(Map<String, dynamic> ctx) =>
      ctx.entries
          .map((e) => '${e.key}=${e.value}')
          .join(', ');
}
