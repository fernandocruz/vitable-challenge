import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_copilot/core/di/injection_container.dart';
import 'package:health_copilot/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:health_copilot/features/chat/presentation/widgets/chat_input.dart';
import 'package:health_copilot/features/chat/presentation/widgets/message_bubble.dart';
import 'package:health_copilot/features/chat/presentation/widgets/recommendation_card.dart';
import 'package:health_copilot/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:health_copilot/features/scheduling/presentation/view/doctor_list_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatCubit(
        createConversation: sl(),
        sendMessage: sl(),
      )..startConversation(),
      child: const _ChatView(),
    );
  }
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.health_and_safety_rounded),
            SizedBox(width: 8),
            Text('Health Copilot'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<ChatCubit>().resetConversation(),
            tooltip: 'New conversation',
          ),
        ],
      ),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state.status == ChatStatus.error &&
              state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ChatStatus.initial ||
              state.status == ChatStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              Expanded(child: _MessageList(state: state)),
              if (state.hasRecommendation)
                RecommendationCard(
                  recommendation: state.recommendation!,
                  onFindDoctor: () =>
                      _navigateToScheduling(context, state),
                )
              else
                ChatInput(
                  onSend: (text) =>
                      context.read<ChatCubit>().sendMessage(text),
                  enabled: state.status != ChatStatus.sending,
                ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToScheduling(
    BuildContext context,
    ChatState state,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorListPage(
          specialtyName: state.recommendation!.specialty,
          conversationId: state.conversationId,
          recommendation: state.recommendation!,
        ),
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.state});

  final ChatState state;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.messages.length +
          (state.status == ChatStatus.sending ? 1 : 0),
      itemBuilder: (context, index) {
        if (state.status == ChatStatus.sending && index == 0) {
          return const TypingIndicator();
        }
        final msgIndex = state.status == ChatStatus.sending
            ? state.messages.length - index
            : state.messages.length - 1 - index;
        return MessageBubble(message: state.messages[msgIndex]);
      },
    );
  }
}
