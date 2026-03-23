import 'package:health_copilot/features/scheduling/domain/entities/doctor.dart';
import 'package:health_copilot/features/scheduling/domain/repositories/scheduling_repository.dart';

class GetDoctors {
  GetDoctors(this._repository);

  final SchedulingRepository _repository;

  Future<List<Doctor>> call({int? specialtyId}) =>
      _repository.getDoctors(specialtyId: specialtyId);
}
