import 'package:equatable/equatable.dart';

class SpecialtyModel extends Equatable {
  const SpecialtyModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SpecialtyModel.fromJson(Map<String, dynamic> json) {
    return SpecialtyModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  final int id;
  final String name;
  final String description;

  @override
  List<Object?> get props => [id, name, description];
}
