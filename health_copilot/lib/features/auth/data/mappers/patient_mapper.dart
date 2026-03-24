import 'package:health_copilot/features/auth/data/models/patient_model.dart';
import 'package:health_copilot/features/auth/domain/entities/patient.dart';

extension PatientMapper on PatientModel {
  Patient toEntity() => Patient(
        id: id,
        name: name,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        isVerified: isVerified,
      );
}
