import 'package:equatable/equatable.dart';

class Specialty extends Equatable {
  const Specialty({
    required this.id,
    required this.name,
    required this.description,
  });

  final int id;
  final String name;
  final String description;

  @override
  List<Object?> get props => [id, name, description];
}
