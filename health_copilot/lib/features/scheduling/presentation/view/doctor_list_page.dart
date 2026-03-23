import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/di/injection_container.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';
import 'package:health_copilot/features/scheduling/domain/entities/doctor.dart';
import 'package:health_copilot/features/scheduling/presentation/cubit/scheduling_cubit.dart';
import 'package:health_copilot/features/scheduling/presentation/view/slot_picker_page.dart';

class DoctorListPage extends StatelessWidget {
  const DoctorListPage({
    required this.specialtyName,
    required this.conversationId,
    required this.recommendation,
    super.key,
  });

  final String specialtyName;
  final int? conversationId;
  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SchedulingCubit(
        getSpecialties: sl(),
        getDoctors: sl(),
        getDoctorSlots: sl(),
        createAppointment: sl(),
      )..loadDoctorsBySpecialty(specialtyName),
      child: _DoctorListView(
        conversationId: conversationId,
        recommendation: recommendation,
      ),
    );
  }
}

class _DoctorListView extends StatelessWidget {
  const _DoctorListView({
    required this.conversationId,
    required this.recommendation,
  });

  final int? conversationId;
  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${recommendation.specialty} Doctors'),
      ),
      body: BlocBuilder<SchedulingCubit, SchedulingState>(
        builder: (context, state) {
          if (state.status == SchedulingStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state.status == SchedulingStatus.error) {
            return Center(
              child: Text(state.error ?? 'An error occurred'),
            );
          }
          if (state.doctors.isEmpty) {
            return const Center(
              child: Text('No doctors available'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.doctors.length,
            itemBuilder: (context, index) {
              final doctor = state.doctors[index];
              return _DoctorCard(
                doctor: doctor,
                onTap: () => _selectDoctor(context, doctor),
              );
            },
          );
        },
      ),
    );
  }

  void _selectDoctor(BuildContext context, Doctor doctor) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<SchedulingCubit>()
            ..selectDoctor(doctor),
          child: SlotPickerPage(
            doctor: doctor,
            conversationId: conversationId,
            recommendation: recommendation,
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({
    required this.doctor,
    required this.onTap,
  });

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.person_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.bio,
                      style:
                          Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
