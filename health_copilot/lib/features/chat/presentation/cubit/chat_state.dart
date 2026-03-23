part of 'chat_cubit.dart';

enum ChatStatus { initial, loading, ready, sending, error }

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.conversationId,
    this.messages = const [],
    this.recommendation,
    this.error,
  });

  final ChatStatus status;
  final int? conversationId;
  final List<Message> messages;
  final Recommendation? recommendation;
  final String? error;

  bool get hasRecommendation => recommendation != null;

  ChatState copyWith({
    ChatStatus? status,
    int? conversationId,
    List<Message>? messages,
    Recommendation? recommendation,
    String? error,
  }) {
    return ChatState(
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      messages: messages ?? this.messages,
      recommendation: recommendation ?? this.recommendation,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props =>
      [status, conversationId, messages, recommendation, error];
}
