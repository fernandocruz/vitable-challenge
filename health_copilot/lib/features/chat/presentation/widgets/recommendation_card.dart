import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    required this.recommendation,
    required this.onFindDoctor,
    super.key,
  });

  final Recommendation recommendation;
  final VoidCallback onFindDoctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    AppIcons.medical,
                    color:
                        Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Recommendation',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: AppTypography.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              InfoRow(
                label: 'Specialty',
                value: recommendation.specialty,
                icon: AppIcons.hospital,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(AppIcons.warning, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  const Text('Urgency: '),
                  AppBadge(
                    label: recommendation.urgency
                        .toUpperCase(),
                    color: AppColors.urgencyColor(
                      recommendation.urgency,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Find a Doctor',
                onPressed: onFindDoctor,
                icon: AppIcons.search,
                isExpanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
