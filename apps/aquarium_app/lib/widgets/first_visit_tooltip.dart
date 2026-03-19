/// Reusable first-visit tooltip overlay.
///
/// Shows a tooltip card that auto-dismisses after [autoDismissDuration] or
/// when tapped. Tracked via [SharedPreferences] using the given [prefsKey].
///
/// Designed to be placed inside an existing [Stack] (e.g. as a [Positioned]
/// child). Does NOT wrap a child widget — call [hasSeenTooltip] first and
/// only instantiate this widget when the tooltip has not yet been seen.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_profile_provider.dart';
import '../providers/reduced_motion_provider.dart';
import '../theme/app_theme.dart';

/// A tooltip that appears as a floating card with a subtle shadow.
class FirstVisitTooltip extends ConsumerStatefulWidget {
  /// Unique SharedPreferences key (e.g. `tooltip_seen_tank`).
  final String prefsKey;

  /// Tooltip text (1–2 sentences max).
  final String message;

  /// Optional leading emoji.
  final String? emoji;

  /// How long before the tooltip auto-dismisses.
  final Duration autoDismissDuration;

  /// Called when the tooltip is dismissed (either by tap or timeout).
  final VoidCallback? onDismissed;

  const FirstVisitTooltip({
    super.key,
    required this.prefsKey,
    required this.message,
    this.emoji,
    this.autoDismissDuration = const Duration(seconds: 4),
    this.onDismissed,
  });

  @override
  ConsumerState<FirstVisitTooltip> createState() => FirstVisitTooltipState();
}

class FirstVisitTooltipState extends ConsumerState<FirstVisitTooltip>
    with SingleTickerProviderStateMixin {
  Timer? _dismissTimer;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final disableMotion = ref.read(reducedMotionProvider).disableDecorativeAnimations;
    _controller = AnimationController(
      vsync: this,
      duration: disableMotion ? Duration.zero : const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
    _scheduleDismiss();
  }

  void _scheduleDismiss() {
    _dismissTimer = Timer(widget.autoDismissDuration, () {
      if (mounted) _dismiss();
    });
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    if (!mounted) return;
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (!mounted) return;
    await prefs.setBool(widget.prefsKey, true);
    if (!mounted) return;
    widget.onDismissed?.call();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: AppSpacing.md),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm2,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.mediumRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackAlpha15,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (widget.emoji != null) ...[
                  Text(
                    widget.emoji!,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Text(
                    widget.message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Check if a tooltip has been seen without building the widget.
Future<bool> hasSeenTooltip(String prefsKey, WidgetRef ref) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  return prefs.getBool(prefsKey) ?? false;
}
