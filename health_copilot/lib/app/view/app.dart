import 'package:flutter/material.dart';
import 'package:health_copilot/core/theme/app_theme.dart';
import 'package:health_copilot/features/chat/presentation/view/chat_page.dart';
import 'package:health_copilot/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      localizationsDelegates:
          AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ChatPage(),
    );
  }
}
