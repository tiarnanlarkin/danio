import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final settings = ref.watch(settingsProvider);
    
    // If ambient lighting is disabled, just return the child
    if (!settings.ambientLightingEnabled) {
      return child;
    }
    
    final ambientState = ref.watch(ambientTimeProvider);
    final config = ambientState.config;
    final progress = ambientState.transitionProgress;
    
    // For day period with no overlay, skip the overlay widgets
    if (config.overlayOpacity == 0.0 && progress >= 1.0) {
      return child;
    }
    
    final effectiveOpacity = intensityOverride ?? config.overlayOpacity;
    
    // Apply easing to transition progress for smoother feel
    final easedProgress = Curves.easeInOut.transform(progress);
    
    return Stack(
      children: [
        // Main content
        child,
        
        // Color overlay with gradient (if configured)
        if (config.gradientStart != null && config.gradientEnd != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: easedProgress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        config.gradientStart!,
                        config.gradientEnd!,
                      ],
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
                duration: const Duration(milliseconds: 500),
                opacity: easedProgress,
                child: Container(
                  color: config.overlayColor.withOpacity(effectiveOpacity),
                ),
              ),
            ),
          ),
        
        // Vignette effect for mood
        if (showVignette && ambientState.currentPeriod != TimePeriod.day)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: easedProgress * 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                      ],
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

  const AmbientTankOverlay({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    if (!settings.ambientLightingEnabled) {
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
          1.05, 0.0, 0.0, 0.0, 10.0,
          0.0, 1.0, 0.0, 0.0, 5.0,
          0.0, 0.0, 0.95, 0.0, -5.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ]);
      
      case TimePeriod.day:
        // Identity matrix - no change
        return const ColorFilter.matrix(<double>[
          1.0, 0.0, 0.0, 0.0, 0.0,
          0.0, 1.0, 0.0, 0.0, 0.0,
          0.0, 0.0, 1.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ]);
      
      case TimePeriod.dusk:
        // Golden hour - warm orange/yellow tint
        return const ColorFilter.matrix(<double>[
          1.08, 0.0, 0.0, 0.0, 15.0,
          0.0, 1.02, 0.0, 0.0, 8.0,
          0.0, 0.0, 0.92, 0.0, -10.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ]);
      
      case TimePeriod.night:
        // Blue moonlight - reduce brightness, add blue tint
        return const ColorFilter.matrix(<double>[
          0.85, 0.0, 0.05, 0.0, -10.0,
          0.0, 0.88, 0.05, 0.0, -8.0,
          0.0, 0.0, 1.1, 0.0, 15.0,
          0.0, 0.0, 0.0, 1.0, 0.0,
        ]);
    }
  }
}

/// Small indicator showing current time period (for debugging/info)
class AmbientTimeIndicator extends ConsumerWidget {
  const AmbientTimeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    
    if (!settings.ambientLightingEnabled) {
      return const SizedBox.shrink();
    }
    
    final ambientState = ref.watch(ambientTimeProvider);
    final config = ambientState.config;
    
    final icon = _getIcon(ambientState.currentPeriod);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            config.name,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
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
