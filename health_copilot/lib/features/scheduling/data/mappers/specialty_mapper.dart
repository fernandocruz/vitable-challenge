import 'package:health_copilot/features/scheduling/data/models/specialty_model.dart';
import 'package:health_copilot/features/scheduling/domain/entities/specialty.dart';

extension SpecialtyMapper on SpecialtyModel {
  Specialty toEntity() => Specialty(
        id: id,
        name: name,
        description: description,
      );
}
