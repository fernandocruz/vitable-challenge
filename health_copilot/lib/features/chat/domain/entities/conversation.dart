import 'package:equatable/equatable.dart';
import 'package:health_copilot/features/chat/domain/entities/message.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.sessionId,
    required this.messages,
    required this.createdAt,
  });

  final int id;
  final String sessionId;
  final List<Message> messages;
  final String createdAt;

  @override
  List<Object?> get props => [id, sessionId, messages, createdAt];
}
