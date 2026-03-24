import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/design_system.dart';
import 'package:health_copilot/features/chat/domain/entities/message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment:
          isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.lg,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 14,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft:
                const Radius.circular(AppSpacing.radiusXl),
            topRight:
                const Radius.circular(AppSpacing.radiusXl),
            bottomLeft: Radius.circular(
              isUser ? AppSpacing.radiusXl : AppSpacing.radiusSm,
            ),
            bottomRight: Radius.circular(
              isUser ? AppSpacing.radiusSm : AppSpacing.radiusXl,
            ),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser
                ? colorScheme.onPrimary
                : colorScheme.onSurface,
            fontSize: AppTypography.messageFontSize,
          ),
        ),
      ),
    );
  }
}
