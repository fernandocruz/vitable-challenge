import 'package:health_copilot/features/chat/data/models/message_model.dart';
import 'package:health_copilot/features/chat/domain/entities/message.dart';

extension MessageMapper on MessageModel {
  Message toEntity() => Message(
        id: id,
        role: role,
        content: content,
        createdAt: createdAt,
      );
}
