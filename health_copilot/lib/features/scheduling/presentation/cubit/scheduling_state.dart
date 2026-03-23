part of 'scheduling_cubit.dart';

enum SchedulingStatus { initial, loading, loaded, error }

class SchedulingState extends Equatable {
  const SchedulingState({
    this.status = SchedulingStatus.initial,
    this.doctors = const [],
    this.selectedDoctor,
    this.slots = const [],
    this.error,
  });

  final SchedulingStatus status;
  final List<Doctor> doctors;
  final Doctor? selectedDoctor;
  final List<TimeSlot> slots;
  final String? error;

  SchedulingState copyWith({
    SchedulingStatus? status,
    List<Doctor>? doctors,
    Doctor? selectedDoctor,
    List<TimeSlot>? slots,
    String? error,
  }) {
    return SchedulingState(
      status: status ?? this.status,
      doctors: doctors ?? this.doctors,
      selectedDoctor: selectedDoctor ?? this.selectedDoctor,
      slots: slots ?? this.slots,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, doctors, selectedDoctor, slots, error];
}
