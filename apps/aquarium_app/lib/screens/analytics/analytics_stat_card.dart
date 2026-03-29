import 'package:flutter/material.dart';

import '../../models/analytics.dart';
import '../../theme/app_theme.dart';

/// Single metric stat card for the analytics overview section.
class AnalyticsStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;
  final ProgressTrend? trend;

  const AnalyticsStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
    this.trend,
  });

  /// Darkens a decorative colour to meet WCAG AA (4.5:1) for text on light bg.
  static Color ensureTextContrast(Color color) {
    final luminance = color.computeLuminance();
    if (luminance > 0.18) {
      return Color.from(
        alpha: color.a,
        red: (color.r * 0.6).clamp(0, 1),
        green: (color.g * 0.6).clamp(0, 1),
        blue: (color.b * 0.6).clamp(0, 1),
      );
    }
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: AppIconSizes.md),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(178),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trend != null) Text(trend!.emoji),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: ensureTextContrast(color),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(178),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
