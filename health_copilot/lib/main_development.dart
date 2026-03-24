import 'package:health_copilot/app/app.dart';
import 'package:health_copilot/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
