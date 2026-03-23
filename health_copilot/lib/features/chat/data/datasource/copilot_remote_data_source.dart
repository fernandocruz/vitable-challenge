import 'package:health_copilot/core/api/api_client.dart';
import 'package:health_copilot/features/chat/data/models/conversation_model.dart';
import 'package:health_copilot/features/chat/data/models/message_model.dart';
import 'package:health_copilot/features/chat/data/models/recommendation_model.dart';

class CopilotRemoteDataSource {
  CopilotRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<ConversationModel> createConversation() async {
    final response = await _apiClient
        .post<Map<String, dynamic>>('/copilot/conversations/');
    return ConversationModel.fromJson(response.data!);
  }

  Future<
      ({
        MessageModel message,
        RecommendationModel? recommendation,
      })> sendMessage({
    required int conversationId,
    required String content,
  }) async {
    final response =
        await _apiClient.post<Map<String, dynamic>>(
      '/copilot/conversations/$conversationId/messages/',
      data: {'content': content},
    );
    final data = response.data!;
    final message = MessageModel.fromJson(
      data['message'] as Map<String, dynamic>,
    );
    final recJson =
        data['recommendation'] as Map<String, dynamic>?;
    final recommendation = recJson != null
        ? RecommendationModel.fromJson(recJson)
        : null;
    return (message: message, recommendation: recommendation);
  }

  Future<ConversationModel> getConversation(int id) async {
    final response = await _apiClient
        .get<Map<String, dynamic>>(
      '/copilot/conversations/$id/',
    );
    return ConversationModel.fromJson(response.data!);
  }
}
