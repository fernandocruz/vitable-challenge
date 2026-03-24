import 'package:health_copilot/core/observability/ports/app_user.dart';

abstract class ErrorReporter {
  void captureException(
    Object exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
    String? message,
  });

  void recordFatalError(
    Object error,
    StackTrace stackTrace,
  );

  /// Adds contextual trail for debugging.
  /// Sentry: maps to breadcrumbs. Crashlytics: maps
  /// to FirebaseCrashlytics.log(). Vendors without
  /// this concept can no-op.
  void addContext(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  });

  void setUser(AppUser user);

  /// Flush pending reports. Call before app exit or
  /// during fatal error handling to ensure delivery.
  Future<void> flush();
}
