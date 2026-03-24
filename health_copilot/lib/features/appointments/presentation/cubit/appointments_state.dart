part of 'appointments_cubit.dart';

enum AppointmentsStatus { initial, loading, loaded, error }

class AppointmentsState extends Equatable {
  const AppointmentsState({
    this.status = AppointmentsStatus.initial,
    this.appointments = const [],
    this.error,
  });

  final AppointmentsStatus status;
  final List<Appointment> appointments;
  final String? error;

  AppointmentsState copyWith({
    AppointmentsStatus? status,
    List<Appointment>? appointments,
    String? error,
  }) {
    return AppointmentsState(
      status: status ?? this.status,
      appointments: appointments ?? this.appointments,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, appointments, error];
}
