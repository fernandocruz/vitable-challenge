import 'package:health_copilot/core/observability/ports/app_user.dart';

abstract class EventTracker {
  void trackEvent(
    String name, {
    Map<String, dynamic>? properties,
  });

  void trackScreenView(
    String screenName, {
    Map<String, dynamic>? properties,
  });

  void setUserProperty(String name, Object value);

  void identify(AppUser user);
}
