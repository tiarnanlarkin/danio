import 'package:flutter/material.dart';
import '../../painters/water_vial_painter.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';

/// Content for the right (water quality) Swiss Army panel.
class WaterPanelContent extends StatefulWidget {
  final double? ph;
  final double? ammonia;
  final double? nitrate;
  final double? nitrite;
  final RoomTheme theme;
  final VoidCallback? onTestKitTap;

  const WaterPanelContent({
    super.key,
    this.ph,
    this.ammonia,
    this.nitrate,
    this.nitrite,
    required this.theme,
    this.onTestKitTap,
  });

  @override
  State<WaterPanelContent> createState() => _WaterPanelContentState();
}

class _WaterPanelContentState extends State<WaterPanelContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _vialAnim;

  @override
  void initState() {
    super.initState();
    _vialAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _vialAnim.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _vialAnim.dispose();
    super.dispose();
  }

  Color _statusColor(String param, double? value) {
    if (value == null) return const Color(0xFF9E9E9E);
    switch (param) {
      case 'pH':
        if (value >= 6.5 && value <= 7.8) return const Color(0xFF4CAF50);
        if (value >= 6.0 && value <= 8.2) return const Color(0xFFFFA726);
        return const Color(0xFFEF5350);
      case 'NH₃':
        if (value <= 0.25) return const Color(0xFF4CAF50);
        if (value <= 0.5) return const Color(0xFFFFA726);
        return const Color(0xFFEF5350);
      case 'NO₃':
        if (value <= 20) return const Color(0xFF4CAF50);
        if (value <= 40) return const Color(0xFFFFA726);
        return const Color(0xFFEF5350);
      case 'NO₂':
        if (value <= 0) return const Color(0xFF4CAF50);
        if (value <= 0.25) return const Color(0xFFFFA726);
        return const Color(0xFFEF5350);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.water_drop, color: widget.theme.textSecondary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Water Quality',
                style: AppTypography.titleMedium.copyWith(
                  color: widget.theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Vials
          AnimatedBuilder(
            animation: _vialAnim,
            builder: (context, _) {
              return SizedBox(
                width: double.infinity,
                height: 200,
                child: CustomPaint(
                  painter: WaterVialPainter(
                    phValue: widget.ph,
                    ammoniaValue: widget.ammonia,
                    nitrateValue: widget.nitrate,
                    nitriteValue: widget.nitrite,
                    animationValue: Curves.easeOutCubic.transform(
                      _vialAnim.value,
                    ),
                  ),
                ),
              );
            },
          ),

          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _VialLabel('pH', widget.ph, _statusColor('pH', widget.ph), widget.theme),
              _VialLabel('NH₃', widget.ammonia, _statusColor('NH₃', widget.ammonia), widget.theme),
              _VialLabel('NO₃', widget.nitrate, _statusColor('NO₃', widget.nitrate), widget.theme),
              _VialLabel('NO₂', widget.nitrite, _statusColor('NO₂', widget.nitrite), widget.theme),
            ],
          ),

          const Spacer(),

          // Last tested + CTA
          Text(
            'Tap Log Test to update values',
            style: AppTypography.bodySmall.copyWith(
              color: widget.theme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (widget.onTestKitTap != null)
            ElevatedButton.icon(
              onPressed: widget.onTestKitTap,
              icon: const Icon(Icons.science, size: 18),
              label: const Text('Log Test'),
            ),
        ],
      ),
    );
  }
}

class _VialLabel extends StatelessWidget {
  final String label;
  final double? value;
  final Color statusColor;
  final RoomTheme theme;

  const _VialLabel(this.label, this.value, this.statusColor, this.theme);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: statusColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value?.toStringAsFixed(value! < 10 ? 1 : 0) ?? '--',
          style: AppTypography.labelLarge.copyWith(
            color: theme.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }
}
