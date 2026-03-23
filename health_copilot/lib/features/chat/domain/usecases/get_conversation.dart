import 'package:health_copilot/features/chat/domain/entities/conversation.dart';
import 'package:health_copilot/features/chat/domain/repositories/copilot_repository.dart';

class GetConversation {
  GetConversation(this._repository);

  final CopilotRepository _repository;

  Future<Conversation> call(int id) =>
      _repository.getConversation(id);
}
