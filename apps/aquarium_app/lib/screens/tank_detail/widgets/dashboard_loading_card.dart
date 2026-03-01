import 'package:flutter/material.dart';
import '../../../widgets/core/bubble_loader.dart';
import '../../../theme/app_theme.dart';

class DashboardLoadingCard extends StatelessWidget {
  final String title;

  const DashboardLoadingCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Text(title, style: AppTypography.headlineSmall),
            const Spacer(),
            const BubbleLoader.small(),
          ],
        ),
      ),
    );
  }
}
