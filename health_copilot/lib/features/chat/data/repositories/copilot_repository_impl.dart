import 'package:health_copilot/features/chat/data/datasource/copilot_remote_data_source.dart';
import 'package:health_copilot/features/chat/data/mappers/conversation_mapper.dart';
import 'package:health_copilot/features/chat/data/mappers/message_mapper.dart';
import 'package:health_copilot/features/chat/data/mappers/recommendation_mapper.dart';
import 'package:health_copilot/features/chat/domain/entities/conversation.dart';
import 'package:health_copilot/features/chat/domain/entities/message.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';
import 'package:health_copilot/features/chat/domain/repositories/copilot_repository.dart';

class CopilotRepositoryImpl implements CopilotRepository {
  CopilotRepositoryImpl({
    required CopilotRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  final CopilotRemoteDataSource _dataSource;

  @override
  Future<Conversation> createConversation() async {
    final model = await _dataSource.createConversation();
    return model.toEntity();
  }

  @override
  Future<({Message message, Recommendation? recommendation})>
      sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final result = await _dataSource.sendMessage(
      conversationId: conversationId,
      content: content,
    );
    return (
      message: result.message.toEntity(),
      recommendation: result.recommendation?.toEntity(),
    );
  }

  @override
  Future<Conversation> getConversation(int id) async {
    final model = await _dataSource.getConversation(id);
    return model.toEntity();
  }
}
