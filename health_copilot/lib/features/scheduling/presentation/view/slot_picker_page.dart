import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/features/appointments/presentation/view/confirmation_page.dart';
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
          if (state.status == SchedulingStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.slots.isEmpty) {
            return const Center(
              child: Text('No available slots'),
            );
          }

          final grouped = <String, List<TimeSlot>>{};
          for (final slot in state.slots) {
            final dateKey =
                DateFormat('EEEE, MMM d').format(slot.startTime);
            grouped.putIfAbsent(dateKey, () => []).add(slot);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final dateKey = grouped.keys.elementAt(index);
              final slots = grouped[dateKey]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      dateKey,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: slots.map((slot) {
                      return _SlotChip(
                        slot: slot,
                        onTap: () => _bookSlot(context, slot),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
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
    final cubit = context.read<SchedulingCubit>();
    final appointment = await cubit.bookAppointment(
      timeSlotId: slot.id,
      conversationId: conversationId,
      symptomsSummary: recommendation.summary,
      urgencyLevel: recommendation.urgency,
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
  const _SlotChip({required this.slot, required this.onTap});

  final TimeSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final time = DateFormat('h:mm a').format(slot.startTime);

    return ActionChip(
      label: Text(time),
      avatar: Icon(
        Icons.access_time_rounded,
        size: 18,
        color: colorScheme.primary,
      ),
      onPressed: onTap,
    );
  }
}
