import 'package:flutter/material.dart';
import 'package:health_copilot/core/design_system/molecules/detail_row.dart';
import 'package:health_copilot/core/design_system/tokens/app_spacing.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    required this.rows,
    this.padding,
    super.key,
  });

  final List<DetailRow> rows;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ??
            const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            for (int i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1)
                const Divider(height: AppSpacing.xxl),
            ],
          ],
        ),
      ),
    );
  }
}
