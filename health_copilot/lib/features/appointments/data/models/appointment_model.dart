import 'package:equatable/equatable.dart';

class AppointmentModel extends Equatable {
  const AppointmentModel({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.specialtyName,
    required this.startTime,
    required this.symptomsSummary,
    required this.urgencyLevel,
    required this.status,
    required this.createdAt,
  });

  factory AppointmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppointmentModel(
      id: json['id'] as int,
      patientName:
          (json['patient_name'] as String?) ?? '',
      doctorName: json['doctor_name'] as String,
      specialtyName:
          json['specialty_name'] as String,
      startTime: DateTime.parse(
        json['start_time'] as String,
      ),
      symptomsSummary:
          json['symptoms_summary'] as String,
      urgencyLevel:
          json['urgency_level'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  final int id;
  final String patientName;
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
        patientName,
        doctorName,
        specialtyName,
        startTime,
        symptomsSummary,
        urgencyLevel,
        status,
        createdAt,
      ];
}
