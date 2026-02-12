import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Time periods for ambient lighting
enum TimePeriod {
  dawn,   // 6:00 - 9:00
  day,    // 9:00 - 17:00
  dusk,   // 17:00 - 20:00
  night,  // 20:00 - 6:00
}

/// Ambient lighting configuration for each time period
class AmbientConfig {
  final Color overlayColor;
  final double overlayOpacity;
  final Color? gradientStart;
  final Color? gradientEnd;
  final String name;
  final String description;

  const AmbientConfig({
    required this.overlayColor,
    required this.overlayOpacity,
    this.gradientStart,
    this.gradientEnd,
    required this.name,
    required this.description,
  });

  /// Dawn: Warm orange tint, gradual brighten
  static const dawn = AmbientConfig(
    overlayColor: Color(0xFFFF9800),
    overlayOpacity: 0.08,
    gradientStart: Color(0x0AFF6F00),
    gradientEnd: Color(0x05FFCC80),
    name: 'Dawn',
    description: 'Soft morning light',
  );

  /// Day: Full bright, natural colors (minimal/no overlay)
  static const day = AmbientConfig(
    overlayColor: Colors.transparent,
    overlayOpacity: 0.0,
    name: 'Day',
    description: 'Natural daylight',
  );

  /// Dusk: Warm golden hour tint
  static const dusk = AmbientConfig(
    overlayColor: Color(0xFFFF8F00),
    overlayOpacity: 0.10,
    gradientStart: Color(0x0CFF6F00),
    gradientEnd: Color(0x08FFD54F),
    name: 'Dusk',
    description: 'Golden hour warmth',
  );

  /// Night: Blue moonlight, dimmed
  static const night = AmbientConfig(
    overlayColor: Color(0xFF1A237E),
    overlayOpacity: 0.15,
    gradientStart: Color(0x12000051),
    gradientEnd: Color(0x0A1A237E),
    name: 'Night',
    description: 'Cozy moonlight',
  );

  static AmbientConfig fromPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.dawn:
        return dawn;
      case TimePeriod.day:
        return day;
      case TimePeriod.dusk:
        return dusk;
      case TimePeriod.night:
        return night;
    }
  }
}

/// State for ambient time service
class AmbientTimeState {
  final TimePeriod currentPeriod;
  final AmbientConfig config;
  final double transitionProgress; // 0.0 to 1.0 for smooth transitions
  final DateTime lastUpdate;

  const AmbientTimeState({
    required this.currentPeriod,
    required this.config,
    this.transitionProgress = 1.0,
    required this.lastUpdate,
  });

  AmbientTimeState copyWith({
    TimePeriod? currentPeriod,
    AmbientConfig? config,
    double? transitionProgress,
    DateTime? lastUpdate,
  }) {
    return AmbientTimeState(
      currentPeriod: currentPeriod ?? this.currentPeriod,
      config: config ?? this.config,
      transitionProgress: transitionProgress ?? this.transitionProgress,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// Notifier for ambient time state
class AmbientTimeNotifier extends StateNotifier<AmbientTimeState> {
  Timer? _updateTimer;
  Timer? _transitionTimer;
  TimePeriod? _previousPeriod;

  AmbientTimeNotifier()
      : super(AmbientTimeState(
          currentPeriod: _getCurrentPeriod(),
          config: AmbientConfig.fromPeriod(_getCurrentPeriod()),
          lastUpdate: DateTime.now(),
        )) {
    _startPeriodicUpdate();
  }

  /// Get the current time period based on hour
  static TimePeriod _getCurrentPeriod() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 9) {
      return TimePeriod.dawn;
    } else if (hour >= 9 && hour < 17) {
      return TimePeriod.day;
    } else if (hour >= 17 && hour < 20) {
      return TimePeriod.dusk;
    } else {
      return TimePeriod.night;
    }
  }

  /// Start periodic updates to check for time period changes
  void _startPeriodicUpdate() {
    // Check every minute for time period changes
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkAndUpdatePeriod();
    });
  }

  /// Check if time period has changed and trigger transition
  void _checkAndUpdatePeriod() {
    final newPeriod = _getCurrentPeriod();
    
    if (newPeriod != state.currentPeriod) {
      _previousPeriod = state.currentPeriod;
      _startTransition(newPeriod);
    }
  }

  /// Start a smooth transition to a new time period
  void _startTransition(TimePeriod newPeriod) {
    _transitionTimer?.cancel();
    
    const transitionDuration = Duration(seconds: 3);
    const steps = 30; // 30 steps over 3 seconds = ~10fps for transitions
    final stepDuration = Duration(
      milliseconds: transitionDuration.inMilliseconds ~/ steps,
    );
    
    int currentStep = 0;
    
    _transitionTimer = Timer.periodic(stepDuration, (timer) {
      currentStep++;
      final progress = currentStep / steps;
      
      if (progress >= 1.0) {
        timer.cancel();
        state = AmbientTimeState(
          currentPeriod: newPeriod,
          config: AmbientConfig.fromPeriod(newPeriod),
          transitionProgress: 1.0,
          lastUpdate: DateTime.now(),
        );
        _previousPeriod = null;
      } else {
        state = state.copyWith(
          currentPeriod: newPeriod,
          config: AmbientConfig.fromPeriod(newPeriod),
          transitionProgress: progress,
          lastUpdate: DateTime.now(),
        );
      }
    });
  }

  /// Force update to current time (useful for testing or app resume)
  void forceUpdate() {
    final newPeriod = _getCurrentPeriod();
    state = AmbientTimeState(
      currentPeriod: newPeriod,
      config: AmbientConfig.fromPeriod(newPeriod),
      transitionProgress: 1.0,
      lastUpdate: DateTime.now(),
    );
  }

  /// Get interpolated config for smooth transitions
  AmbientConfig? get previousConfig {
    return _previousPeriod != null 
        ? AmbientConfig.fromPeriod(_previousPeriod!) 
        : null;
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _transitionTimer?.cancel();
    super.dispose();
  }
}

/// Provider for ambient time state
final ambientTimeProvider = StateNotifierProvider<AmbientTimeNotifier, AmbientTimeState>((ref) {
  return AmbientTimeNotifier();
});

/// Convenience provider for just the current config
final ambientConfigProvider = Provider<AmbientConfig>((ref) {
  return ref.watch(ambientTimeProvider).config;
});

/// Convenience provider for current time period
final currentTimePeriodProvider = Provider<TimePeriod>((ref) {
  return ref.watch(ambientTimeProvider).currentPeriod;
});
