import 'package:equatable/equatable.dart';

class PatientModel extends Equatable {
  const PatientModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.isVerified,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      dateOfBirth: DateTime.parse(
        json['date_of_birth'] as String,
      ),
      isVerified: json['is_verified'] as bool,
    );
  }

  final int id;
  final String name;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final bool isVerified;

  @override
  List<Object?> get props =>
      [id, name, email, phone, dateOfBirth, isVerified];
}
