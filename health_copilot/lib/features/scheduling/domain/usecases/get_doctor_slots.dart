import 'package:health_copilot/features/scheduling/domain/entities/time_slot.dart';
import 'package:health_copilot/features/scheduling/domain/repositories/scheduling_repository.dart';

class GetDoctorSlots {
  GetDoctorSlots(this._repository);

  final SchedulingRepository _repository;

  Future<List<TimeSlot>> call(int doctorId) =>
      _repository.getDoctorSlots(doctorId);
}
