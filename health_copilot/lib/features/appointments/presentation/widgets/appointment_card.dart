import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    required this.appointment,
    super.key,
  });

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat('MMM d, yyyy')
        .format(appointment.startTime);
    final timeStr =
        DateFormat('h:mm a').format(appointment.startTime);

    return Card(
      margin:
          const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppAvatar(radius: 22),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  AppTypography.bold,
                            ),
                      ),
                      Text(
                        appointment.specialtyName,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              color: colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                AppBadge(
                  label: appointment.urgencyLevel
                      .toUpperCase(),
                  color: AppColors.urgencyColor(
                    appointment.urgencyLevel,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.xxl),
            Row(
              children: [
                Icon(
                  AppIcons.calendar,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(dateStr),
                const SizedBox(width: AppSpacing.lg),
                Icon(
                  AppIcons.time,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(timeStr),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
