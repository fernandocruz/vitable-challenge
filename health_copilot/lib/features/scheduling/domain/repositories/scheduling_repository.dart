import 'package:health_copilot/features/scheduling/domain/entities/doctor.dart';
import 'package:health_copilot/features/scheduling/domain/entities/specialty.dart';
import 'package:health_copilot/features/scheduling/domain/entities/time_slot.dart';

abstract class SchedulingRepository {
  Future<List<Specialty>> getSpecialties();
  Future<List<Doctor>> getDoctors({int? specialtyId});
  Future<Doctor> getDoctor(int id);
  Future<List<TimeSlot>> getDoctorSlots(int doctorId);
}
