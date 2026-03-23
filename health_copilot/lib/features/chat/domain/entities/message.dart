import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final String role;
  final String content;
  final String createdAt;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  @override
  List<Object?> get props => [id, role, content, createdAt];
}
