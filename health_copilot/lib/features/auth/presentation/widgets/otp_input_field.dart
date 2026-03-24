import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_copilot/core/design_system/design_system.dart';

class OtpInputField extends StatelessWidget {
  const OtpInputField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 6,
      style: Theme.of(context).textTheme.headlineMedium,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        hintText: '000000',
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppSpacing.radiusLg,
          ),
        ),
      ),
    );
  }
}
