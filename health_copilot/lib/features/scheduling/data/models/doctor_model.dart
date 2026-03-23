import 'package:equatable/equatable.dart';
import 'package:health_copilot/features/scheduling/data/models/time_slot_model.dart';

class DoctorModel extends Equatable {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialtyName,
    required this.bio,
    this.availableSlots = const [],
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    final slots = (json['available_slots'] as List<dynamic>?)
            ?.map(
              (s) =>
                  TimeSlotModel.fromJson(s as Map<String, dynamic>),
            )
            .toList() ??
        [];
    return DoctorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      specialtyName:
          (json['specialty_name'] as String?) ??
              ((json['specialty']
                      as Map<String, dynamic>?)?['name']
                  as String?) ??
              '',
      bio: (json['bio'] ?? '') as String,
      availableSlots: slots,
    );
  }

  final int id;
  final String name;
  final String specialtyName;
  final String bio;
  final List<TimeSlotModel> availableSlots;

  @override
  List<Object?> get props =>
      [id, name, specialtyName, bio, availableSlots];
}
