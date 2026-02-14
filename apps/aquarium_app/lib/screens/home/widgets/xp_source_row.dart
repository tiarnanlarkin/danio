import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class XpSourceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int xp;

  const XpSourceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Text(
              '+$xp XP',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
