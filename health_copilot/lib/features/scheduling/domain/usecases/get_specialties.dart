import 'package:health_copilot/features/scheduling/domain/entities/specialty.dart';
import 'package:health_copilot/features/scheduling/domain/repositories/scheduling_repository.dart';

class GetSpecialties {
  GetSpecialties(this._repository);

  final SchedulingRepository _repository;

  Future<List<Specialty>> call() => _repository.getSpecialties();
}
