import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../services/ambient_time_service.dart';

/// Ambient lighting overlay that changes based on time of day.
///
/// Applies subtle color overlays to create atmosphere:
/// - Dawn (6-9): Warm orange tint, soft morning light
/// - Day (9-17): Natural colors, no overlay
/// - Dusk (17-20): Golden hour warmth
/// - Night (20-6): Blue moonlight, cozy feel
///
/// Uses [IgnorePointer] to ensure it doesn't block interactions.
class AmbientLightingOverlay extends ConsumerWidget {
  /// The child widget to apply the overlay to
  final Widget child;

  /// Whether to show a subtle vignette effect
  final bool showVignette;

  /// Override intensity (0.0 to 1.0). Null uses default from config.
  final double? intensityOverride;

  const AmbientLightingOverlay({
    super.key,
    required this.child,
    this.showVignette = true,
    this.intensityOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambientEnabled = ref.watch(
      settingsProvider.select((s) => s.ambientLightingEnabled),
    );

    // If ambient lighting is disabled, just return the child
    if (!ambientEnabled) {
      return child;
    }

    final ambientState = ref.watch(ambientTimeProvider);
    final config = ambientState.config;

    // For day period with no overlay, skip the overlay widgets
    if (config.overlayOpacity == 0.0) {
      return child;
    }

    final effectiveOpacity = intensityOverride ?? config.overlayOpacity;

    // StackFit.expand ensures the Stack fills its parent's constraints
    // rather than shrinking to fit the room background image's intrinsic
    // size. The room background uses cacheWidth: 1024 which can produce
    // an image narrower than the screen, and a loose-fit Stack would then
    // leave the right edge of the screen showing the Scaffold background
    // through as a vertical strip (QA fix 2026-04).
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main content — wrapped in Positioned.fill so it covers the full
        // expanded Stack rather than relying on its intrinsic size.
        Positioned.fill(child: child),

        // Color overlay with gradient (if configured).
        // AnimatedOpacity handles the smooth visual transition when
        // the time period changes — no rapid Riverpod state updates needed.
        if (config.gradientStart != null && config.gradientEnd != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: AppDurations.long2,
                opacity: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [config.gradientStart!, config.gradientEnd!],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Main color tint overlay
        if (effectiveOpacity > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: AppDurations.long2,
                opacity: 1.0,
                child: Container(
                  color: config.overlayColor.withAlpha(
                    (effectiveOpacity * 255).round(),
                  ),
                ),
              ),
            ),
          ),

        // Vignette effect for mood
        if (showVignette && ambientState.currentPeriod != TimePeriod.day)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: AppDurations.long2,
                opacity: 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [Colors.transparent, AppOverlays.black15],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A simpler ambient overlay that only applies to tank/aquarium views.
/// More subtle effect specifically designed for the aquarium rendering.
class AmbientTankOverlay extends ConsumerWidget {
  final Widget child;

  const AmbientTankOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambientEnabled = ref.watch(
      settingsProvider.select((s) => s.ambientLightingEnabled),
    );

    if (!ambientEnabled) {
      return child;
    }

    final ambientState = ref.watch(ambientTimeProvider);
    final config = ambientState.config;

    // For day, use ColorFiltered with identity matrix (no change)
    if (config.overlayOpacity == 0.0) {
      return child;
    }

    // Apply subtle color filter based on time period
    return ColorFiltered(
      colorFilter: _buildColorFilter(ambientState.currentPeriod, config),
      child: child,
    );
  }

  ColorFilter _buildColorFilter(TimePeriod period, AmbientConfig config) {
    switch (period) {
      case TimePeriod.dawn:
        // Warm orange tint - slightly increase red/orange
        return const ColorFilter.matrix(<double>[
          1.05,
          0.0,
          0.0,
          0.0,
          10.0,
          0.0,
          1.0,
          0.0,
          0.0,
          5.0,
          0.0,
          0.0,
          0.95,
          0.0,
          -5.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ]);

      case TimePeriod.day:
        // Identity matrix - no change
        return const ColorFilter.matrix(<double>[
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ]);

      case TimePeriod.dusk:
        // Golden hour - warm orange/yellow tint
        return const ColorFilter.matrix(<double>[
          1.08,
          0.0,
          0.0,
          0.0,
          15.0,
          0.0,
          1.02,
          0.0,
          0.0,
          8.0,
          0.0,
          0.0,
          0.92,
          0.0,
          -10.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ]);

      case TimePeriod.night:
        // Blue moonlight - reduce brightness, add blue tint
        return const ColorFilter.matrix(<double>[
          0.85,
          0.0,
          0.05,
          0.0,
          -10.0,
          0.0,
          0.88,
          0.05,
          0.0,
          -8.0,
          0.0,
          0.0,
          1.1,
          0.0,
          15.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
        ]);
    }
  }
}

/// Small indicator showing current time period (for debugging/info)
class AmbientTimeIndicator extends ConsumerWidget {
  const AmbientTimeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ambientEnabled = ref.watch(
      settingsProvider.select((s) => s.ambientLightingEnabled),
    );

    if (!ambientEnabled) {
      return const SizedBox.shrink();
    }

    final ambientState = ref.watch(ambientTimeProvider);
    final config = ambientState.config;

    final icon = _getIcon(ambientState.currentPeriod);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppOverlays.black30,
        borderRadius: AppRadius.md2Radius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.whiteAlpha70),
          const SizedBox(width: AppSpacing.xs),
          Text(
            config.name,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: AppColors.whiteAlpha70),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(TimePeriod period) {
    switch (period) {
      case TimePeriod.dawn:
        return Icons.wb_twilight;
      case TimePeriod.day:
        return Icons.wb_sunny;
      case TimePeriod.dusk:
        return Icons.nights_stay;
      case TimePeriod.night:
        return Icons.dark_mode;
    }
  }
}
