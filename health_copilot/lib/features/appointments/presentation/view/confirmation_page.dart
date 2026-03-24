import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:intl/intl.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({
    required this.appointment,
    super.key,
  });

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat('EEEE, MMMM d, yyyy')
        .format(appointment.startTime);
    final timeStr =
        DateFormat('h:mm a').format(appointment.startTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Confirmed'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.successBackground,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  AppIcons.checkCircle,
                  size: 56,
                  color: AppColors.successForeground,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'Appointment Booked!',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: AppTypography.bold,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your visit has been confirmed',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              InfoCard(
                rows: [
                  DetailRow(
                    icon: AppIcons.person,
                    label: 'Doctor',
                    value: appointment.doctorName,
                  ),
                  DetailRow(
                    icon: AppIcons.hospital,
                    label: 'Specialty',
                    value: appointment.specialtyName,
                  ),
                  DetailRow(
                    icon: AppIcons.calendar,
                    label: 'Date',
                    value: dateStr,
                  ),
                  DetailRow(
                    icon: AppIcons.time,
                    label: 'Time',
                    value: timeStr,
                  ),
                  DetailRow(
                    icon: AppIcons.warning,
                    label: 'Urgency',
                    value: appointment.urgencyLevel
                        .toUpperCase(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            AppIcons.description,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(
                            width: AppSpacing.sm,
                          ),
                          Text(
                            'Symptoms Summary',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight:
                                      AppTypography.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: AppSpacing.sm,
                      ),
                      Text(
                        appointment.symptomsSummary,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: 'Back to Home',
                isExpanded: true,
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
