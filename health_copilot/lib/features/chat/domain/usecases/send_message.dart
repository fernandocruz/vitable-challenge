import 'package:health_copilot/features/chat/domain/entities/message.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';
import 'package:health_copilot/features/chat/domain/repositories/copilot_repository.dart';

class SendMessage {
  SendMessage(this._repository);

  final CopilotRepository _repository;

  Future<({Message message, Recommendation? recommendation})>
      call({
    required int conversationId,
    required String content,
  }) =>
          _repository.sendMessage(
            conversationId: conversationId,
            content: content,
          );
}
