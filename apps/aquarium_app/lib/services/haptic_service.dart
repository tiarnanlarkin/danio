import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../providers/reduced_motion_provider.dart';

/// Service for managing haptic feedback
/// Provides contextual vibration when enabled in settings
class HapticService {
  HapticService(this._ref);
  
  final Ref _ref;
  
  /// Light impact - for button presses, list item selection
  Future<void> light() async {
    if (!_isEnabled()) return;
    await HapticFeedback.lightImpact();
  }
  
  /// Medium impact - for confirmations, important selections
  Future<void> medium() async {
    if (!_isEnabled()) return;
    await HapticFeedback.mediumImpact();
  }
  
  /// Heavy impact - for critical actions, errors
  Future<void> heavy() async {
    if (!_isEnabled()) return;
    await HapticFeedback.heavyImpact();
  }
  
  /// Selection click - for picker scrolling, dragging
  Future<void> selection() async {
    if (!_isEnabled()) return;
    await HapticFeedback.selectionClick();
  }
  
  /// Success feedback - for achievements, completions
  /// Uses medium impact as Flutter doesn't have success pattern
  Future<void> success() async {
    if (!_isEnabled()) return;
    await HapticFeedback.mediumImpact();
  }
  
  /// Error feedback - for validation errors, failures
  /// Uses heavy impact + vibration pattern
  Future<void> error() async {
    if (!_isEnabled()) return;
    await HapticFeedback.heavyImpact();
    // Could add custom pattern via platform channel
  }
  
  /// Check if haptic feedback is enabled
  bool _isEnabled() {
    final settings = _ref.read(settingsProvider);
    final reducedMotion = _ref.read(reducedMotionProvider);
    
    // Enable haptic when:
    // 1. User has haptic enabled in settings
    // 2. OR reduced motion is enabled (haptic compensates for disabled animations)
    return settings.hapticFeedbackEnabled || reducedMotion.isEnabled;
  }
}

/// Provider for haptic service
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService(ref);
});

/// Extension for easy haptic access in widgets
extension HapticExtension on WidgetRef {
  HapticService get haptic => read(hapticServiceProvider);
}
