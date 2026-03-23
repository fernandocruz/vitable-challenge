import 'package:health_copilot/features/scheduling/data/models/time_slot_model.dart';
import 'package:health_copilot/features/scheduling/domain/entities/time_slot.dart';

extension TimeSlotMapper on TimeSlotModel {
  TimeSlot toEntity() => TimeSlot(
        id: id,
        doctorId: doctorId,
        startTime: startTime,
        isAvailable: isAvailable,
      );
}
