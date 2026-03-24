import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/core/di/injection_container.dart';
import 'package:health_copilot/features/appointments/presentation/cubit/appointments_cubit.dart';
import 'package:health_copilot/features/appointments/presentation/widgets/appointment_card.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppointmentsCubit(
        getAppointments: sl(),
      )..loadAppointments(),
      child: const _AppointmentsView(),
    );
  }
}

class _AppointmentsView extends StatelessWidget {
  const _AppointmentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
      ),
      body:
          BlocBuilder<AppointmentsCubit, AppointmentsState>(
        builder: (context, state) {
          return AsyncContent(
            isLoading: state.status ==
                AppointmentsStatus.loading,
            errorMessage:
                state.status == AppointmentsStatus.error
                    ? state.error
                    : null,
            isEmpty: state.status ==
                    AppointmentsStatus.loaded &&
                state.appointments.isEmpty,
            emptyMessage:
                'No appointments yet.\n'
                'Start a chat to book your first visit!',
            emptyIcon: AppIcons.calendar,
            onRetry: () => context
                .read<AppointmentsCubit>()
                .loadAppointments(),
            contentBuilder: (_) => ListView.builder(
              padding:
                  const EdgeInsets.all(AppSpacing.lg),
              itemCount: state.appointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(
                  appointment:
                      state.appointments[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
