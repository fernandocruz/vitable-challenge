import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/atoms/app_loader.dart';
import 'package:health_copilot/core/design_system/tokens/app_icons.dart';
import 'package:health_copilot/core/design_system/tokens/app_spacing.dart';

class AsyncContent extends StatelessWidget {
  const AsyncContent({
    required this.isLoading,
    required this.contentBuilder,
    this.errorMessage,
    this.isEmpty = false,
    this.emptyMessage = 'No items available',
    this.emptyIcon = AppIcons.inbox,
    this.onRetry,
    super.key,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;
  final WidgetBuilder contentBuilder;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const AppLoader();

    if (errorMessage != null) {
      return _StateView(
        icon: AppIcons.warning,
        message: errorMessage!,
        action: onRetry != null
            ? TextButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              )
            : null,
      );
    }

    if (isEmpty) {
      return _StateView(
        icon: emptyIcon,
        message: emptyMessage,
      );
    }

    return contentBuilder(context);
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
