import 'package:equatable/equatable.dart';

class RecommendationModel extends Equatable {
  const RecommendationModel({
    required this.specialty,
    required this.urgency,
    required this.summary,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      specialty: json['specialty'] as String,
      urgency: json['urgency'] as String,
      summary: json['summary'] as String,
    );
  }

  final String specialty;
  final String urgency;
  final String summary;

  @override
  List<Object?> get props => [specialty, urgency, summary];
}
