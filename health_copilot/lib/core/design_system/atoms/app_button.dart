import 'package:flutter/material.dart';

enum AppButtonStyle { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AppButtonStyle.primary,
    this.isExpanded = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonStyle style;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget button;
    switch (style) {
      case AppButtonStyle.primary:
        button = icon != null
            ? ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              )
            : ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(label),
              );
      case AppButtonStyle.secondary:
        button = icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              )
            : OutlinedButton(
                onPressed: onPressed,
                child: Text(label),
              );
      case AppButtonStyle.text:
        button = icon != null
            ? TextButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
              )
            : TextButton(
                onPressed: onPressed,
                child: Text(label),
              );
    }

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
}
