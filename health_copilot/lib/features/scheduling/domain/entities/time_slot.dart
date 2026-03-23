import 'package:equatable/equatable.dart';

class TimeSlot extends Equatable {
  const TimeSlot({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.isAvailable,
  });

  final int id;
  final int doctorId;
  final DateTime startTime;
  final bool isAvailable;

  @override
  List<Object?> get props => [id, doctorId, startTime, isAvailable];
}
