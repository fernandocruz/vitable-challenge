import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialtyName,
    required this.startTime,
    required this.symptomsSummary,
    required this.urgencyLevel,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String doctorName;
  final String specialtyName;
  final DateTime startTime;
  final String symptomsSummary;
  final String urgencyLevel;
  final String status;
  final String createdAt;

  @override
  List<Object?> get props => [
        id,
        doctorName,
        specialtyName,
        startTime,
        symptomsSummary,
        urgencyLevel,
        status,
        createdAt,
      ];
}
