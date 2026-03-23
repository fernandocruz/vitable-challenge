import 'package:equatable/equatable.dart';

class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  final int id;
  final String role;
  final String content;
  final String createdAt;

  @override
  List<Object?> get props => [id, role, content, createdAt];
}
