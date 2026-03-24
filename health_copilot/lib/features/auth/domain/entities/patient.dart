import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.isVerified,
  });

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
