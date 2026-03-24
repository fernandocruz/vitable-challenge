import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/features/appointments/presentation/view/confirmation_page.dart';
import 'package:health_copilot/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:health_copilot/features/auth/presentation/view/patient_info_page.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';
import 'package:health_copilot/features/scheduling/domain/entities/doctor.dart';
import 'package:health_copilot/features/scheduling/domain/entities/time_slot.dart';
import 'package:health_copilot/features/scheduling/presentation/cubit/scheduling_cubit.dart';
import 'package:intl/intl.dart';

class SlotPickerPage extends StatelessWidget {
  const SlotPickerPage({
    required this.doctor,
    required this.conversationId,
    required this.recommendation,
    super.key,
  });

  final Doctor doctor;
  final int? conversationId;
  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book with ${doctor.name}'),
      ),
      body: BlocBuilder<SchedulingCubit, SchedulingState>(
        builder: (context, state) {
          return AsyncContent(
            isLoading:
                state.status == SchedulingStatus.loading,
            isEmpty: state.status ==
                    SchedulingStatus.loaded &&
                state.slots.isEmpty,
            emptyMessage: 'No available slots',
            emptyIcon: AppIcons.calendar,
            contentBuilder: (_) {
              final grouped = <String, List<TimeSlot>>{};
              for (final slot in state.slots) {
                final dateKey = DateFormat('EEEE, MMM d')
                    .format(slot.startTime);
                grouped
                    .putIfAbsent(dateKey, () => [])
                    .add(slot);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(
                  AppSpacing.lg,
                ),
                itemCount: grouped.length,
                itemBuilder: (context, index) {
                  final dateKey =
                      grouped.keys.elementAt(index);
                  final slots = grouped[dateKey]!;

                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          dateKey,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    AppTypography.bold,
                              ),
                        ),
                      ),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: slots.map((slot) {
                          return _SlotChip(
                            slot: slot,
                            onTap: () => _bookSlot(
                              context,
                              slot,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(
                        height: AppSpacing.lg,
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _bookSlot(
    BuildContext context,
    TimeSlot slot,
  ) async {
    final authCubit = context.read<AuthCubit>();

    if (!authCubit.state.isAuthenticated) {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: authCubit,
            child: PatientInfoPage(
              onVerified: () {
                // Pop back to slot picker after auth
                Navigator.of(context)
                  ..pop() // OTP page
                  ..pop(); // Patient info page
              },
            ),
          ),
        ),
      );
      // After returning, check if now authenticated
      if (!authCubit.state.isAuthenticated) return;
      if (!context.mounted) return;
    }

    final cubit = context.read<SchedulingCubit>();
    final appointment = await cubit.bookAppointment(
      timeSlotId: slot.id,
      conversationId: conversationId,
      symptomsSummary: recommendation.summary,
      urgencyLevel: recommendation.urgency,
      patientId: authCubit.state.patient!.id,
    );

    if (appointment != null && context.mounted) {
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) =>
              ConfirmationPage(appointment: appointment),
        ),
        (route) => route.isFirst,
      );
    }
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.slot,
    required this.onTap,
  });

  final TimeSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final time =
        DateFormat('h:mm a').format(slot.startTime);

    return ActionChip(
      label: Text(time),
      avatar: Icon(
        AppIcons.time,
        size: 18,
        color: colorScheme.primary,
      ),
      onPressed: onTap,
    );
  }
}
