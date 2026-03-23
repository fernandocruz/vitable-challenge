import 'package:equatable/equatable.dart';
import 'package:health_copilot/features/scheduling/domain/entities/time_slot.dart';

class Doctor extends Equatable {
  const Doctor({
    required this.id,
    required this.name,
    required this.specialtyName,
    required this.bio,
    this.availableSlots = const [],
  });

  final int id;
  final String name;
  final String specialtyName;
  final String bio;
  final List<TimeSlot> availableSlots;

  @override
  List<Object?> get props =>
      [id, name, specialtyName, bio, availableSlots];
}
