import 'package:health_copilot/core/observability/ports/app_user.dart';
import 'package:health_copilot/core/observability/ports/event_tracker.dart';

class NoopEventTracker implements EventTracker {
  const NoopEventTracker();

  @override
  void trackEvent(
    String name, {
    Map<String, dynamic>? properties,
  }) {}

  @override
  void trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  }) {}

  @override
  void setUserProperty(String name, Object value) {}

  @override
  void identify(AppUser user) {}
}
