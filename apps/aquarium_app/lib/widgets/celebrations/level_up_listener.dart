/// Level Up Listener Widget
/// Automatically shows level-up celebrations when the user levels up
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_profile_provider.dart';
import 'level_up_overlay.dart';

/// Widget that listens for level-up events and shows celebrations
/// 
/// Wrap this around your main content to automatically show level-up
/// celebrations whenever the user gains enough XP to level up.
/// 
/// ```dart
/// LevelUpListener(
///   child: HomeScreen(),
/// )
/// ```
class LevelUpListener extends ConsumerStatefulWidget {
  final Widget child;
  
  /// Whether to show the celebration (can be disabled for certain screens)
  final bool enabled;

  const LevelUpListener({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  ConsumerState<LevelUpListener> createState() => _LevelUpListenerState();
}

class _LevelUpListenerState extends ConsumerState<LevelUpListener> {
  bool _isShowingCelebration = false;

  @override
  Widget build(BuildContext context) {
    // Listen to level up events
    ref.listen<LevelUpEvent?>(levelUpEventProvider, (previous, next) {
      if (next != null && widget.enabled && !_isShowingCelebration) {
        _showLevelUpCelebration(next);
      }
    });

    return widget.child;
  }

  Future<void> _showLevelUpCelebration(LevelUpEvent event) async {
    if (!mounted) return;
    
    _isShowingCelebration = true;
    
    // Show the level up overlay
    await LevelUpOverlay.show(
      context,
      newLevel: event.newLevel,
      levelTitle: event.levelTitle,
    );
    
    // Clear the event after showing
    if (mounted) {
      ref.read(levelUpEventProvider.notifier).clearEvent();
      _isShowingCelebration = false;
    }
  }
}

/// Extension to easily wrap screens with level up listener
extension LevelUpListenerExtension on Widget {
  /// Wrap this widget with a LevelUpListener
  Widget withLevelUpListener({bool enabled = true}) {
    return LevelUpListener(
      enabled: enabled,
      child: this,
    );
  }
}
