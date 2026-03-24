import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/tokens/app_colors.dart';
import 'package:health_copilot/core/design_system/tokens/app_icons.dart';
import 'package:health_copilot/core/design_system/tokens/app_spacing.dart';

class InputWithAction extends StatelessWidget {
  const InputWithAction({
    required this.controller,
    required this.onAction,
    this.hintText,
    this.enabled = true,
    this.actionIcon = AppIcons.send,
    this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onAction;
  final String? hintText;
  final bool enabled;
  final IconData actionIcon;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                textInputAction: TextInputAction.send,
                onSubmitted: onSubmitted,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppSpacing.radiusPill),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton.filled(
              onPressed: enabled ? onAction : null,
              icon: Icon(actionIcon),
            ),
          ],
        ),
      ),
    );
  }
}
