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

  /// Optional leading emoji. Kept for older callers; polished surfaces should
  /// prefer [icon].
  final String? emoji;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional leading icon color.
  final Color? iconColor;

  /// Optional leading icon background color.
  final Color? iconBackgroundColor;

  /// How long before the tooltip auto-dismisses.
  final Duration autoDismissDuration;

  /// Called when the tooltip is dismissed (either by tap or timeout).
  final VoidCallback? onDismissed;

  const FirstVisitTooltip({
    super.key,
    required this.prefsKey,
    required this.message,
    this.emoji,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
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
    final disableMotion = ref
        .read(reducedMotionProvider)
        .disableDecorativeAnimations;
    _controller = AnimationController(
      vsync: this,
      duration: disableMotion ? Duration.zero : AppDurations.long1,
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
    return Semantics(
      label: 'Dismiss tooltip',
      button: true,
      child: GestureDetector(
        onTap: _dismiss,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm2,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppRadius.lg2Radius,
                border: Border.all(color: AppColors.blackAlpha05),
                boxShadow: AppShadows.medium,
              ),
              child: Row(
                children: [
                  if (widget.icon != null || widget.emoji != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            widget.iconBackgroundColor ??
                            context.surfaceVariant,
                        borderRadius: AppRadius.sm4Radius,
                      ),
                      child: Center(
                        child: widget.icon != null
                            ? Icon(
                                widget.icon,
                                color: widget.iconColor ?? context.textPrimary,
                                size: 22,
                              )
                            : Text(
                                widget.emoji!,
                                style: const TextStyle(fontSize: 22, height: 1),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      widget.message,
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Semantics(
                    label: 'Close tooltip',
                    button: true,
                    child: GestureDetector(
                      onTap: _dismiss,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: context.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
