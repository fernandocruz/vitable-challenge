import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:health_copilot/features/chat/domain/entities/message.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';
import 'package:health_copilot/features/chat/domain/usecases/create_conversation.dart';
import 'package:health_copilot/features/chat/domain/usecases/send_message.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required CreateConversation createConversation,
    required SendMessage sendMessage,
  })  : _createConversation = createConversation,
        _sendMessage = sendMessage,
        super(const ChatState());

  final CreateConversation _createConversation;
  final SendMessage _sendMessage;

  Future<void> startConversation() async {
    emit(state.copyWith(status: ChatStatus.loading));
    try {
      final conversation = await _createConversation();
      emit(
        state.copyWith(
          status: ChatStatus.ready,
          conversationId: conversation.id,
          messages: conversation.messages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error:
              'Failed to start conversation. Is the server running?',
        ),
      );
    }
  }

  Future<void> sendMessage(String content) async {
    if (state.conversationId == null) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      role: 'user',
      content: content,
      createdAt: DateTime.now().toIso8601String(),
    );

    emit(
      state.copyWith(
        status: ChatStatus.sending,
        messages: [...state.messages, userMessage],
      ),
    );

    try {
      final result = await _sendMessage(
        conversationId: state.conversationId!,
        content: content,
      );

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          messages: [...state.messages, result.message],
          recommendation: result.recommendation,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          error: 'Failed to send message. Please try again.',
        ),
      );
    }
  }

  void resetConversation() {
    emit(const ChatState());
    startConversation();
  }
}
