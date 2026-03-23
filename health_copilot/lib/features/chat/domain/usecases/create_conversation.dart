import 'package:health_copilot/features/chat/domain/entities/conversation.dart';
import 'package:health_copilot/features/chat/domain/repositories/copilot_repository.dart';

class CreateConversation {
  CreateConversation(this._repository);

  final CopilotRepository _repository;

  Future<Conversation> call() => _repository.createConversation();
}
