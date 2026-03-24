import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/design_system.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() =>
      _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.xs,
          horizontal: AppSpacing.lg,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusXl),
            topRight: Radius.circular(AppSpacing.radiusXl),
            bottomLeft:
                Radius.circular(AppSpacing.radiusSm),
            bottomRight:
                Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final delay = i * 0.2;
                final value =
                    ((_controller.value + delay) % 1.0 *
                                2 -
                            1)
                        .abs();
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  width: AppSpacing.sm,
                  height: AppSpacing.sm,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant
                        .withValues(
                      alpha: 0.3 + value * 0.7,
                    ),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
