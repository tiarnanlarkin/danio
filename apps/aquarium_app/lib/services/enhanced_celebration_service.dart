/// Enhanced Celebration Service - Duolingo-style celebrations with sound & haptics
/// Provides comprehensive celebration system with animations, sounds, and haptic feedback
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:confetti/confetti.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/celebrations/confetti_overlay.dart';
import '../widgets/celebrations/level_up_overlay.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/reduced_motion_provider.dart';

/// Types of celebration sounds
enum CelebrationSound {
  /// Quick whoosh for small wins
  whoosh('whoosh.mp3', 800),
  
  /// Chime for achievements
  chime('chime.mp3', 1500),
  
  /// Fanfare for lesson completion
  fanfare('fanfare.mp3', 2500),
  
  /// Applause for streaks
  applause('applause.mp3', 3000),
  
  /// Fireworks for epic milestones
  fireworks('fireworks.mp3', 4000);
  
  const CelebrationSound(this.filename, this.durationMs);
  
  final String filename;
  final int durationMs;
  
  String get path => 'audio/celebrations/$filename';
}

/// Types of haptic feedback patterns
enum HapticPattern {
  /// Quick light tap
  light,
  
  /// Medium impact
  medium,
  
  /// Strong impact
  heavy,
  
  /// Success pattern (light-medium-light)
  success,
  
  /// Epic pattern (multiple impacts)
  epic,
}

/// Enhanced celebration state with sound and haptics
class EnhancedCelebrationState {
  final bool isActive;
  final String? title;
  final String? subtitle;
  final CelebrationLevel level;
  final ConfettiController? confettiController;
  final CelebrationSound? sound;
  final HapticPattern? haptic;
  final bool canShare;
  final String? shareText;
  
  const EnhancedCelebrationState({
    this.isActive = false,
    this.title,
    this.subtitle,
    this.level = CelebrationLevel.standard,
    this.confettiController,
    this.sound,
    this.haptic,
    this.canShare = false,
    this.shareText,
  });
  
  EnhancedCelebrationState copyWith({
    bool? isActive,
    String? title,
    String? subtitle,
    CelebrationLevel? level,
    ConfettiController? confettiController,
    CelebrationSound? sound,
    HapticPattern? haptic,
    bool? canShare,
    String? shareText,
  }) {
    return EnhancedCelebrationState(
      isActive: isActive ?? this.isActive,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      level: level ?? this.level,
      confettiController: confettiController ?? this.confettiController,
      sound: sound ?? this.sound,
      haptic: haptic ?? this.haptic,
      canShare: canShare ?? this.canShare,
      shareText: shareText ?? this.shareText,
    );
  }
}

/// Celebration levels matching Duolingo patterns
enum CelebrationLevel {
  /// Quick confetti burst (small XP gain)
  standard,
  
  /// Achievement unlocked - confetti + overlay + badge animation
  achievement,
  
  /// Level up - special effects + fireworks
  levelUp,
  
  /// Milestone - big celebration (7-day streak, 100 lessons, etc.)
  milestone,
  
  /// Epic - ultra celebration (365-day streak, platinum achievement)
  epic,
}

/// Provider for enhanced celebration state
final enhancedCelebrationProvider = 
    StateNotifierProvider<EnhancedCelebrationNotifier, EnhancedCelebrationState>(
  (ref) => EnhancedCelebrationNotifier(ref),
);

/// Notifier for managing enhanced celebrations with sound and haptics
class EnhancedCelebrationNotifier extends StateNotifier<EnhancedCelebrationState> {
  final Ref _ref;
  final AudioPlayer _audioPlayer = AudioPlayer();
  ConfettiController? _controller;
  
  EnhancedCelebrationNotifier(this._ref) : super(const EnhancedCelebrationState());
  
  /// Check if reduced motion is enabled
  bool get _isReducedMotion {
    try {
      final reducedMotion = _ref.read(reducedMotionProvider);
      return reducedMotion.isEnabled;
    } catch (_) {
      return false;
    }
  }
  
  /// Check if sound effects are enabled
  bool get _isSoundEnabled {
    // Sound effects are always enabled for celebrations
    // Could be expanded to check settings if needed
    return true;
  }
  
  /// Play celebration sound
  Future<void> _playSound(CelebrationSound sound) async {
    if (!_isSoundEnabled) return;
    
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(sound.path), volume: 0.7);
    } catch (e) {
      // Gracefully fail if sound file is missing
      debugPrint('Failed to play celebration sound: $e');
    }
  }
  
  /// Trigger haptic feedback
  Future<void> _triggerHaptic(HapticPattern pattern) async {
    if (_isReducedMotion) return;
    
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (!hasVibrator) return;
      
      switch (pattern) {
        case HapticPattern.light:
          HapticFeedback.lightImpact();
          break;
        case HapticPattern.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticPattern.heavy:
          HapticFeedback.heavyImpact();
          break;
        case HapticPattern.success:
          // Light-medium-light pattern
          HapticFeedback.lightImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.lightImpact();
          break;
        case HapticPattern.epic:
          // Multiple impacts for epic celebrations
          for (int i = 0; i < 3; i++) {
            HapticFeedback.heavyImpact();
            await Future.delayed(const Duration(milliseconds: 150));
          }
          break;
      }
    } catch (e) {
      debugPrint('Failed to trigger haptic: $e');
    }
  }
  
  /// Trigger a standard confetti burst (small win)
  void confetti({Duration duration = const Duration(seconds: 2)}) {
    _disposeController();
    _controller = ConfettiController(duration: duration);
    
    state = EnhancedCelebrationState(
      isActive: true,
      level: CelebrationLevel.standard,
      confettiController: _controller,
      sound: CelebrationSound.whoosh,
      haptic: HapticPattern.light,
    );
    
    _playSound(CelebrationSound.whoosh);
    _triggerHaptic(HapticPattern.light);
    _controller!.play();
    
    _autoDismiss(duration + const Duration(milliseconds: 500));
  }
  
  /// Trigger lesson completion celebration
  void lessonComplete({
    required int xpEarned,
    required bool isPerfect,
    String? lessonTitle,
  }) {
    _disposeController();
    _controller = ConfettiController(duration: const Duration(seconds: 3));
    
    final sound = isPerfect ? CelebrationSound.fanfare : CelebrationSound.chime;
    final haptic = isPerfect ? HapticPattern.success : HapticPattern.medium;
    
    state = EnhancedCelebrationState(
      isActive: true,
      title: isPerfect ? 'Perfect! 💯' : 'Lesson Complete! 🎉',
      subtitle: lessonTitle != null 
          ? '$lessonTitle • +$xpEarned XP'
          : '+$xpEarned XP',
      level: isPerfect ? CelebrationLevel.achievement : CelebrationLevel.standard,
      confettiController: _controller,
      sound: sound,
      haptic: haptic,
      canShare: isPerfect,
      shareText: isPerfect 
          ? 'Just got a perfect score on "$lessonTitle" in Danio! 🐠💯'
          : null,
    );
    
    _playSound(sound);
    _triggerHaptic(haptic);
    _controller!.play();
    
    _autoDismiss(const Duration(seconds: 4));
  }
  
  /// Trigger streak celebration (Duolingo-style)
  void streakMilestone({
    required int streakDays,
    bool isNewRecord = false,
  }) {
    _disposeController();
    
    // Different celebration levels based on streak length
    final level = _getStreakCelebrationLevel(streakDays);
    final duration = _getStreakDuration(level);
    
    _controller = ConfettiController(duration: duration);
    
    final emoji = _getStreakEmoji(streakDays);
    final sound = level == CelebrationLevel.epic 
        ? CelebrationSound.fireworks 
        : CelebrationSound.applause;
    final haptic = level == CelebrationLevel.epic 
        ? HapticPattern.epic 
        : HapticPattern.success;
    
    state = EnhancedCelebrationState(
      isActive: true,
      title: '$streakDays Day Streak! $emoji',
      subtitle: isNewRecord 
          ? 'New personal record! Keep it up!' 
          : 'Amazing consistency! 🔥',
      level: level,
      confettiController: _controller,
      sound: sound,
      haptic: haptic,
      canShare: streakDays >= 7,
      shareText: 'I just hit a $streakDays-day learning streak in Danio! 🔥🐠',
    );
    
    _playSound(sound);
    _triggerHaptic(haptic);
    _controller!.play();
    
    _autoDismiss(Duration(milliseconds: duration.inMilliseconds + 1000));
  }
  
  /// Trigger achievement unlock celebration
  void achievementUnlocked({
    required String achievementName,
    required String achievementIcon,
    required String description,
    bool isRare = false,
  }) {
    _disposeController();
    _controller = ConfettiController(
      duration: Duration(seconds: isRare ? 4 : 3),
    );
    
    final level = isRare ? CelebrationLevel.milestone : CelebrationLevel.achievement;
    final sound = isRare ? CelebrationSound.fireworks : CelebrationSound.chime;
    final haptic = isRare ? HapticPattern.epic : HapticPattern.success;
    
    state = EnhancedCelebrationState(
      isActive: true,
      title: '$achievementIcon $achievementName',
      subtitle: description,
      level: level,
      confettiController: _controller,
      sound: sound,
      haptic: haptic,
      canShare: true,
      shareText: 'Just unlocked "$achievementName" in Danio! $achievementIcon',
    );
    
    _playSound(sound);
    _triggerHaptic(haptic);
    _controller!.play();
    
    _autoDismiss(Duration(seconds: isRare ? 5 : 4));
  }
  
  /// Trigger level up celebration
  void levelUp({
    required int newLevel,
    String? levelTitle,
    BuildContext? context,
  }) {
    if (context != null) {
      // Use enhanced overlay if context is available
      showLevelUpOverlay(context, newLevel, levelTitle: levelTitle);
    } else {
      // Fallback to basic celebration
      _disposeController();
      _controller = ConfettiController(duration: const Duration(seconds: 4));
      
      state = EnhancedCelebrationState(
        isActive: true,
        title: 'Level $newLevel! 🎊',
        subtitle: levelTitle ?? 'You\'re making great progress!',
        level: CelebrationLevel.levelUp,
        confettiController: _controller,
        sound: CelebrationSound.fireworks,
        haptic: HapticPattern.epic,
        canShare: newLevel % 5 == 0, // Share every 5 levels
        shareText: 'Just reached Level $newLevel in Danio! 🐠🎊',
      );
      
      _playSound(CelebrationSound.fireworks);
      _triggerHaptic(HapticPattern.epic);
      _controller!.play();
      
      _autoDismiss(const Duration(seconds: 5));
    }
  }
  
  /// Show enhanced level up overlay with full-screen animation
  void showLevelUpOverlay(BuildContext context, int level, {String? levelTitle}) {
    dismiss();
    
    // Play sound and haptic before showing overlay
    _playSound(CelebrationSound.fireworks);
    _triggerHaptic(HapticPattern.epic);
    
    LevelUpOverlay.show(
      context,
      newLevel: level,
      levelTitle: levelTitle,
    );
  }
  
  /// Share celebration to social media
  Future<void> shareAchievement() async {
    if (!state.canShare || state.shareText == null) return;
    
    try {
      await Share.share(
        state.shareText!,
        subject: 'Danio Achievement',
      );
    } catch (e) {
      debugPrint('Failed to share achievement: $e');
    }
  }
  
  /// Get celebration level based on streak length
  CelebrationLevel _getStreakCelebrationLevel(int days) {
    if (days >= 365) return CelebrationLevel.epic;
    if (days >= 100) return CelebrationLevel.milestone;
    if (days >= 30) return CelebrationLevel.milestone;
    if (days >= 7) return CelebrationLevel.achievement;
    return CelebrationLevel.standard;
  }
  
  /// Get duration based on celebration level
  Duration _getStreakDuration(CelebrationLevel level) {
    return switch (level) {
      CelebrationLevel.epic => const Duration(seconds: 5),
      CelebrationLevel.milestone => const Duration(seconds: 4),
      CelebrationLevel.achievement => const Duration(seconds: 3),
      _ => const Duration(seconds: 2),
    };
  }
  
  /// Get emoji based on streak length (Duolingo-style)
  String _getStreakEmoji(int days) {
    if (days >= 365) return '👑'; // Year
    if (days >= 100) return '🏆'; // Century
    if (days >= 30) return '💪'; // Month
    if (days >= 7) return '🔥'; // Week
    return '⭐'; // Default
  }
  
  /// Auto-dismiss after delay
  void _autoDismiss(Duration delay) {
    Future.delayed(delay, () {
      if (mounted) {
        dismiss();
      }
    });
  }
  
  /// Dismiss active celebration
  void dismiss() {
    _disposeController();
    state = const EnhancedCelebrationState();
  }
  
  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }
  
  @override
  void dispose() {
    _disposeController();
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Extension for easy access to enhanced celebration service
extension EnhancedCelebrationExtension on WidgetRef {
  /// Trigger lesson completion celebration
  void celebrateLessonComplete({
    required int xpEarned,
    required bool isPerfect,
    String? lessonTitle,
  }) => read(enhancedCelebrationProvider.notifier).lessonComplete(
    xpEarned: xpEarned,
    isPerfect: isPerfect,
    lessonTitle: lessonTitle,
  );
  
  /// Trigger streak milestone celebration
  void celebrateStreak({
    required int streakDays,
    bool isNewRecord = false,
  }) => read(enhancedCelebrationProvider.notifier).streakMilestone(
    streakDays: streakDays,
    isNewRecord: isNewRecord,
  );
  
  /// Trigger achievement unlock celebration
  void celebrateAchievement({
    required String name,
    required String icon,
    required String description,
    bool isRare = false,
  }) => read(enhancedCelebrationProvider.notifier).achievementUnlocked(
    achievementName: name,
    achievementIcon: icon,
    description: description,
    isRare: isRare,
  );
  
  /// Trigger level up celebration
  void celebrateLevelUp({
    required int newLevel,
    String? levelTitle,
    BuildContext? context,
  }) => read(enhancedCelebrationProvider.notifier).levelUp(
    newLevel: newLevel,
    levelTitle: levelTitle,
    context: context,
  );
  
  /// Share current celebration
  Future<void> shareCelebration() => 
      read(enhancedCelebrationProvider.notifier).shareAchievement();
}
