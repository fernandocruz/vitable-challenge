import 'package:health_copilot/features/scheduling/data/mappers/time_slot_mapper.dart';
import 'package:health_copilot/features/scheduling/data/models/doctor_model.dart';
import 'package:health_copilot/features/scheduling/domain/entities/doctor.dart';

extension DoctorMapper on DoctorModel {
  Doctor toEntity() => Doctor(
        id: id,
        name: name,
        specialtyName: specialtyName,
        bio: bio,
        availableSlots:
            availableSlots.map((s) => s.toEntity()).toList(),
      );
}
