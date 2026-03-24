import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/di/injection_container.dart';
import 'package:health_copilot/core/theme/app_theme.dart';
import 'package:health_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:health_copilot/features/chat/presentation/view/chat_page.dart';
import 'package:health_copilot/l10n/l10n.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>()..checkAuthStatus(),
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates:
            AppLocalizations.localizationsDelegates,
        supportedLocales:
            AppLocalizations.supportedLocales,
        home: const ChatPage(),
      ),
    );
  }
}
