import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/tokens/app_spacing.dart';
import 'package:health_copilot/core/design_system/tokens/app_typography.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(
                    fontWeight: AppTypography.medium,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
