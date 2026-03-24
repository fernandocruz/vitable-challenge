import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/tokens/app_spacing.dart';
import 'package:health_copilot/core/design_system/tokens/app_typography.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
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
    return Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text('$label: '),
        Text(
          value,
          style: const TextStyle(
            fontWeight: AppTypography.bold,
          ),
        ),
      ],
    );
  }
}
