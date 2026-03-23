import 'package:equatable/equatable.dart';

class TimeSlotModel extends Equatable {
  const TimeSlotModel({
    required this.id,
    required this.doctorId,
    required this.startTime,
    required this.isAvailable,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'] as int,
      doctorId: json['doctor'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      isAvailable: json['is_available'] as bool,
    );
  }

  final int id;
  final int doctorId;
  final DateTime startTime;
  final bool isAvailable;

  @override
  List<Object?> get props => [id, doctorId, startTime, isAvailable];
}
