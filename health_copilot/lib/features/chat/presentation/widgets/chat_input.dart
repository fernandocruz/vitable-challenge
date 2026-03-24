import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/design_system.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    required this.onSend,
    this.enabled = true,
    super.key,
  });

  final ValueChanged<String> onSend;
  final bool enabled;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _controller = TextEditingController();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InputWithAction(
      controller: _controller,
      onAction: _handleSend,
      hintText: 'Describe your symptoms...',
      enabled: widget.enabled,
      onSubmitted: (_) => _handleSend(),
    );
  }
}
