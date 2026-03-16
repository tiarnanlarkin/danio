import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onViewAll;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(title, style: AppTypography.headlineSmall),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
          const Spacer(),
          if (onViewAll != null)
            TextButton(onPressed: onViewAll, child: const Text('View All')),
        ],
      ),
    );
  }
}
