import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {
  const Recommendation({
    required this.specialty,
    required this.urgency,
    required this.summary,
  });

  final String specialty;
  final String urgency;
  final String summary;

  @override
  List<Object?> get props => [specialty, urgency, summary];
}
