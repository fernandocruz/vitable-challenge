import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/app/app.dart';
import 'package:health_copilot/core/di/injection_container.dart';
import 'package:health_copilot/core/observability/ports/app_logger.dart';

void main() {
  group('App', () {
    setUp(() {
      if (!sl.isRegistered<AppLogger>()) {
        initDependencies();
      }
    });

    tearDown(sl.reset);

    testWidgets('renders App widget', (tester) async {
      await tester.pumpWidget(const App());
      // Only verify initial render; don't pump again
      // to avoid triggering network calls from cubits.
      expect(find.byType(App), findsOneWidget);
    });
  });
}
