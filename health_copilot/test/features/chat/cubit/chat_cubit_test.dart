import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_copilot/features/chat/domain/entities/conversation.dart';
import 'package:health_copilot/features/chat/domain/entities/message.dart';
import 'package:health_copilot/features/chat/domain/entities/recommendation.dart';
import 'package:health_copilot/features/chat/domain/usecases/create_conversation.dart';
import 'package:health_copilot/features/chat/domain/usecases/send_message.dart';
import 'package:health_copilot/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockCreateConversation extends Mock
    implements CreateConversation {}

class _MockSendMessage extends Mock
    implements SendMessage {}

void main() {
  late _MockCreateConversation createConversation;
  late _MockSendMessage sendMessage;

  const greeting = Message(
    id: 1,
    role: 'assistant',
    content: 'Hello!',
    createdAt: '2026-01-01',
  );
  const conversation = Conversation(
    id: 1,
    sessionId: 'abc',
    messages: [greeting],
    createdAt: '2026-01-01',
  );
  const aiResponse = Message(
    id: 2,
    role: 'assistant',
    content: 'How long?',
    createdAt: '2026-01-01',
  );
  const recommendation = Recommendation(
    specialty: 'Neurology',
    urgency: 'medium',
    summary: 'headaches',
  );

  setUp(() {
    createConversation = _MockCreateConversation();
    sendMessage = _MockSendMessage();
  });

  ChatCubit buildCubit() => ChatCubit(
        createConversation: createConversation,
        sendMessage: sendMessage,
      );

  group('ChatCubit', () {
    blocTest<ChatCubit, ChatState>(
      'startConversation emits loading then ready',
      setUp: () => when(() => createConversation())
          .thenAnswer((_) async => conversation),
      build: buildCubit,
      act: (cubit) => cubit.startConversation(),
      expect: () => [
        const ChatState(status: ChatStatus.loading),
        const ChatState(
          status: ChatStatus.ready,
          conversationId: 1,
          messages: [greeting],
        ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'startConversation emits error on failure',
      setUp: () => when(() => createConversation())
          .thenThrow(Exception('network')),
      build: buildCubit,
      act: (cubit) => cubit.startConversation(),
      expect: () => [
        const ChatState(status: ChatStatus.loading),
        isA<ChatState>()
            .having(
              (s) => s.status,
              'status',
              ChatStatus.error,
            )
            .having(
              (s) => s.error,
              'error',
              isNotNull,
            ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'sendMessage emits sending then ready with response',
      setUp: () {
        when(() => createConversation())
            .thenAnswer((_) async => conversation);
        when(
          () => sendMessage(
            conversationId: any(named: 'conversationId'),
            content: any(named: 'content'),
          ),
        ).thenAnswer(
          (_) async => (
            message: aiResponse,
            recommendation: null,
          ),
        );
      },
      build: buildCubit,
      seed: () => const ChatState(
        status: ChatStatus.ready,
        conversationId: 1,
        messages: [greeting],
      ),
      act: (cubit) => cubit.sendMessage('I have headaches'),
      expect: () => [
        isA<ChatState>()
            .having(
              (s) => s.status,
              'status',
              ChatStatus.sending,
            )
            .having(
              (s) => s.messages.length,
              'messages',
              2,
            ),
        isA<ChatState>()
            .having(
              (s) => s.status,
              'status',
              ChatStatus.ready,
            )
            .having(
              (s) => s.messages.last.role,
              'last role',
              'assistant',
            ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'sendMessage with recommendation sets hasRecommendation',
      setUp: () {
        when(
          () => sendMessage(
            conversationId: any(named: 'conversationId'),
            content: any(named: 'content'),
          ),
        ).thenAnswer(
          (_) async => (
            message: aiResponse,
            recommendation: recommendation,
          ),
        );
      },
      build: buildCubit,
      seed: () => const ChatState(
        status: ChatStatus.ready,
        conversationId: 1,
        messages: [greeting],
      ),
      act: (cubit) => cubit.sendMessage('test'),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.status, 'status', ChatStatus.sending),
        isA<ChatState>()
            .having(
              (s) => s.hasRecommendation,
              'hasRecommendation',
              true,
            )
            .having(
              (s) => s.recommendation?.specialty,
              'specialty',
              'Neurology',
            ),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'sendMessage error emits error state',
      setUp: () {
        when(
          () => sendMessage(
            conversationId: any(named: 'conversationId'),
            content: any(named: 'content'),
          ),
        ).thenThrow(Exception('fail'));
      },
      build: buildCubit,
      seed: () => const ChatState(
        status: ChatStatus.ready,
        conversationId: 1,
        messages: [greeting],
      ),
      act: (cubit) => cubit.sendMessage('test'),
      expect: () => [
        isA<ChatState>()
            .having((s) => s.status, 'status', ChatStatus.sending),
        isA<ChatState>()
            .having((s) => s.status, 'status', ChatStatus.error),
      ],
    );

    blocTest<ChatCubit, ChatState>(
      'sendMessage does nothing without conversationId',
      build: buildCubit,
      act: (cubit) => cubit.sendMessage('test'),
      expect: () => <ChatState>[],
    );
  });
}
