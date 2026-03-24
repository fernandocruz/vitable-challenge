import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
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
        title:
            Text('${recommendation.specialty} Doctors'),
      ),
      body: BlocBuilder<SchedulingCubit, SchedulingState>(
        builder: (context, state) {
          return AsyncContent(
            isLoading:
                state.status == SchedulingStatus.loading,
            errorMessage:
                state.status == SchedulingStatus.error
                    ? state.error
                    : null,
            isEmpty: state.status ==
                    SchedulingStatus.loaded &&
                state.doctors.isEmpty,
            emptyMessage: 'No doctors available',
            emptyIcon: AppIcons.person,
            contentBuilder: (_) => ListView.builder(
              padding:
                  const EdgeInsets.all(AppSpacing.lg),
              itemCount: state.doctors.length,
              itemBuilder: (context, index) {
                final doctor = state.doctors[index];
                return ListTileCard(
                  title: doctor.name,
                  subtitle: doctor.bio,
                  onTap: () =>
                      _selectDoctor(context, doctor),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _selectDoctor(
    BuildContext context,
    Doctor doctor,
  ) {
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
