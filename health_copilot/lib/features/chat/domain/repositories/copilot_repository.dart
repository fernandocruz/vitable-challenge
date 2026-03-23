import 'package:health_copilot/features/chat/domain/entities/conversation.dart';
import 'package:health_copilot/features/chat/domain/entities/message.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';

abstract class CopilotRepository {
  Future<Conversation> createConversation();

  Future<({Message message, Recommendation? recommendation})>
      sendMessage({
    required int conversationId,
    required String content,
  });

  Future<Conversation> getConversation(int id);
}
