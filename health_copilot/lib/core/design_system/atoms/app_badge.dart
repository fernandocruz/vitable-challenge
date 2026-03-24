import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/tokens/app_spacing.dart';
import 'package:health_copilot/core/design_system/tokens/app_typography.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    required this.color,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius:
            BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: AppTypography.bold,
          fontSize: AppTypography.badgeFontSize,
        ),
      ),
    );
  }
}
