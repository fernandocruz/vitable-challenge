import 'package:equatable/equatable.dart';
import 'package:health_copilot/features/chat/data/models/message_model.dart';

class ConversationModel extends Equatable {
  const ConversationModel({
    required this.id,
    required this.sessionId,
    required this.messages,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final messagesList = (json['messages'] as List<dynamic>?)
            ?.map(
              (m) =>
                  MessageModel.fromJson(m as Map<String, dynamic>),
            )
            .toList() ??
        [];
    return ConversationModel(
      id: json['id'] as int,
      sessionId: json['session_id'] as String,
      messages: messagesList,
      createdAt: json['created_at'] as String,
    );
  }

  final int id;
  final String sessionId;
  final List<MessageModel> messages;
  final String createdAt;

  @override
  List<Object?> get props => [id, sessionId, messages, createdAt];
}
