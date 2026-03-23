import 'package:health_copilot/features/chat/data/models/recommendation_model.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';

extension RecommendationMapper on RecommendationModel {
  Recommendation toEntity() => Recommendation(
        specialty: specialty,
        urgency: urgency,
        summary: summary,
      );
}
