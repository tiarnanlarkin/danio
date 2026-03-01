import 'package:flutter/material.dart';
import '../../painters/temp_gauge_painter.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';

/// Content for the left (temperature) Swiss Army panel.
class TempPanelContent extends StatefulWidget {
  final double? temperature;
  final RoomTheme theme;
  final VoidCallback? onStatsTap;

  const TempPanelContent({
    super.key,
    this.temperature,
    required this.theme,
    this.onStatsTap,
  });

  @override
  State<TempPanelContent> createState() => _TempPanelContentState();
}

class _TempPanelContentState extends State<TempPanelContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gaugeAnim;

  @override
  void initState() {
    super.initState();
    _gaugeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Start the gauge animation after a brief delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _gaugeAnim.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _gaugeAnim.dispose();
    super.dispose();
  }

  Color _getTempColor(double temp) {
    if (temp < 22) return widget.theme.gaugeColor1;
    if (temp < 26) return widget.theme.gaugeColor2;
    if (temp < 28) return widget.theme.gaugeColor3;
    return widget.theme.buttonFeed;
  }

  @override
  Widget build(BuildContext context) {
    final temp = widget.temperature ?? 25.0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.thermostat, color: _getTempColor(temp), size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Temperature',
                style: AppTypography.titleMedium.copyWith(
                  color: widget.theme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Gauge
          AnimatedBuilder(
            animation: _gaugeAnim,
            builder: (context, _) {
              return SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(240, 240),
                      painter: TempGaugePainter(
                        temperature: temp,
                        animationValue: Curves.easeOutBack.transform(
                          _gaugeAnim.value,
                        ),
                        coldColor: widget.theme.gaugeColor1,
                        warmColor: widget.theme.gaugeColor2,
                        hotColor: widget.theme.gaugeColor3,
                        dangerColor: widget.theme.buttonFeed,
                        textColor: widget.theme.textPrimary,
                        secondaryTextColor: widget.theme.textSecondary,
                      ),
                    ),
                    // Centre label
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${temp.toStringAsFixed(1)}°C',
                          style: AppTypography.headlineMedium.copyWith(
                            color: widget.theme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _statusLabel(temp),
                          style: AppTypography.labelSmall.copyWith(
                            color: _getTempColor(temp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Ideal range bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm2,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: widget.theme.glassCard,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: widget.theme.glassBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: widget.theme.gaugeColor2, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Ideal: 24–26°C for tropical',
                  style: AppTypography.bodySmall.copyWith(
                    color: widget.theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom CTA
          if (widget.onStatsTap != null)
            TextButton.icon(
              onPressed: widget.onStatsTap,
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('View Full Stats'),
            ),
        ],
      ),
    );
  }

  String _statusLabel(double t) {
    if (t < 22) return 'Too cold';
    if (t < 24) return 'A bit cool';
    if (t <= 26) return 'Ideal';
    if (t <= 28) return 'A bit warm';
    return 'Too hot';
  }
}
