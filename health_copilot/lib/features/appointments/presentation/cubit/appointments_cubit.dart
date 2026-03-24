import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_copilot/features/appointments/domain/entities/appointment.dart';
import 'package:health_copilot/features/appointments/domain/usecases/get_appointments.dart';

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  AppointmentsCubit({
    required GetAppointments getAppointments,
  })  : _getAppointments = getAppointments,
        super(const AppointmentsState());

  final GetAppointments _getAppointments;

  Future<void> loadAppointments() async {
    emit(
      state.copyWith(status: AppointmentsStatus.loading),
    );
    try {
      final appointments = await _getAppointments();
      emit(
        state.copyWith(
          status: AppointmentsStatus.loaded,
          appointments: appointments,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AppointmentsStatus.error,
          error: 'Failed to load appointments.',
        ),
      );
    }
  }
}
