import 'package:health_copilot/features/chat/data/mappers/message_mapper.dart';
import 'package:health_copilot/features/chat/data/models/conversation_model.dart';
import 'package:health_copilot/features/chat/domain/entities/conversation.dart';

extension ConversationMapper on ConversationModel {
  Conversation toEntity() => Conversation(
        id: id,
        sessionId: sessionId,
        messages: messages.map((m) => m.toEntity()).toList(),
        createdAt: createdAt,
      );
}
