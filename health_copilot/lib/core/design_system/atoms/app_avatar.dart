import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/tokens/app_icons.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    this.icon = AppIcons.person,
    this.radius = 28,
    super.key,
  });

  final IconData icon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Icon(
        icon,
        color: colorScheme.onPrimaryContainer,
        size: radius,
      ),
    );
  }
}
