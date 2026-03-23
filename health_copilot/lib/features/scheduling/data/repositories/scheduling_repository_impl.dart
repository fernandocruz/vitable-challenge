import 'package:health_copilot/features/scheduling/data/datasource/scheduling_remote_data_source.dart';
import 'package:health_copilot/features/scheduling/data/mappers/doctor_mapper.dart';
import 'package:health_copilot/features/scheduling/data/mappers/specialty_mapper.dart';
import 'package:health_copilot/features/scheduling/data/mappers/time_slot_mapper.dart';
import 'package:health_copilot/features/scheduling/domain/entities/doctor.dart';
import 'package:health_copilot/features/scheduling/domain/entities/specialty.dart';
import 'package:health_copilot/features/scheduling/domain/entities/time_slot.dart';
import 'package:health_copilot/features/scheduling/domain/repositories/scheduling_repository.dart';

class SchedulingRepositoryImpl implements SchedulingRepository {
  SchedulingRepositoryImpl({
    required SchedulingRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  final SchedulingRemoteDataSource _dataSource;

  @override
  Future<List<Specialty>> getSpecialties() async {
    final models = await _dataSource.getSpecialties();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Doctor>> getDoctors({int? specialtyId}) async {
    final models =
        await _dataSource.getDoctors(specialtyId: specialtyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Doctor> getDoctor(int id) async {
    final model = await _dataSource.getDoctor(id);
    return model.toEntity();
  }

  @override
  Future<List<TimeSlot>> getDoctorSlots(int doctorId) async {
    final models = await _dataSource.getDoctorSlots(doctorId);
    return models.map((m) => m.toEntity()).toList();
  }
}
