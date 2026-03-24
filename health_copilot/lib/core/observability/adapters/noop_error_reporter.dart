import 'package:health_copilot/core/observability/ports/app_user.dart';
import 'package:health_copilot/core/observability/ports/error_reporter.dart';

class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  @override
  void captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? message,
  }) {}

  @override
  void recordFatalError(
    Object error,
    StackTrace stackTrace,
  ) {}

  @override
  void addContext(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {}

  @override
  void setUser(AppUser user) {}

  @override
  Future<void> flush() async {}
}
