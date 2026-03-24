import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/atoms/app_avatar.dart';
import 'package:health_copilot/core/design_system/tokens/app_icons.dart';
import 'package:health_copilot/core/design_system/tokens/app_spacing.dart';
import 'package:health_copilot/core/design_system/tokens/app_typography.dart';

class ListTileCard extends StatelessWidget {
  const ListTileCard({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              leading ?? const AppAvatar(),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: AppTypography.bold,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(
                        height: AppSpacing.xs,
                      ),
                      Text(
                        subtitle!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    AppIcons.chevronRight,
                    color: colorScheme.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
