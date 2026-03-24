import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    this.hintText,
    this.enabled = true,
    this.onSubmitted,
    this.textInputAction,
    super.key,
  });

  final TextEditingController controller;
  final String? hintText;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }
}
