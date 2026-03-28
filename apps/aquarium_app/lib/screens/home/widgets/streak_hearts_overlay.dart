import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/hearts_provider.dart';
import '../../../providers/tank_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../services/tank_health_service.dart';
import '../../../theme/app_theme.dart';

/// A banner with a dismiss × button on the right.
class DismissibleBanner extends StatelessWidget {
  final Color color;
  final String text;
  final TextStyle textStyle;
  final VoidCallback onDismiss;

  const DismissibleBanner({
    super.key,
    required this.color,
    required this.text,
    required this.textStyle,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.only(left: AppSpacing.sm3, top: AppSpacing.xs, bottom: AppSpacing.xs, right: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.mediumRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(text, style: textStyle)),
            Semantics(
              label: 'Dismiss banner',
              button: true,
              child: GestureDetector(
                onTap: onDismiss,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Icon(Icons.close, size: 14, color: AppColors.whiteAlpha70),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standalone widget for the streak / hearts overlay.
/// Positioned top-left. Each banner is individually dismissable via × button.
/// Dismissed state resets when the streak value changes (new milestone).
class StreakHeartsOverlay extends ConsumerStatefulWidget {
  const StreakHeartsOverlay({super.key});

  @override
  ConsumerState<StreakHeartsOverlay> createState() =>
      StreakHeartsOverlayState();
}

class StreakHeartsOverlayState extends ConsumerState<StreakHeartsOverlay> {
  bool _streakDismissed = false;
  int _lastStreakMilestone = 0;
  bool _heartsDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadDismissedState();
  }

  Future<void> _loadDismissedState() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final dismissedAt = prefs.getInt('streak_banner_dismissed_at') ?? 0;
    final current = ref.read(userProfileProvider).value?.currentStreak ?? 0;
    if (dismissedAt > 0 && dismissedAt >= current) {
      if (mounted) setState(() => _streakDismissed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = ref.watch(
      userProfileProvider.select((p) => p.value?.currentStreak ?? 0),
    );
    final hearts = ref.watch(heartsStateProvider);
    final lowHearts = hearts.currentHearts <= 1;

    ref.listen<int>(
      userProfileProvider.select((p) => p.value?.currentStreak ?? 0),
      (prev, next) {
        // Only reset dismiss state on streak increase (new milestone),
        // not on every recalculation or decrease.
        if (prev != null && next > prev && next > _lastStreakMilestone) {
          setState(() {
            _streakDismissed = false;
            _lastStreakMilestone = next;
          });
        }
      },
    );

    final topPad = MediaQuery.of(context).padding.top;

    // Fix 1: Show only ONE banner at a time (priority: streak > WC streak > low hearts).
    // This prevents multiple banners stacking and covering interactive controls.
    Widget? activeBanner;

    if (streak > 0 && !_streakDismissed) {
      activeBanner = Semantics(
        liveRegion: true,
        label: 'Learning streak: $streak days',
        child: DismissibleBanner(
          color: DanioColors.amberGold.withAlpha(230),
          text: '\u{1F525} $streak-day streak!',
          textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          onDismiss: () {
            setState(() => _streakDismissed = true);
            ref.read(sharedPreferencesProvider.future).then(
              (p) => p.setInt('streak_banner_dismissed_at', streak),
            );
          },
        ),
      );
    } else if (lowHearts && hearts.currentHearts >= 0 && !_heartsDismissed) {
      activeBanner = Semantics(
        liveRegion: true,
        label: hearts.currentHearts == 0
            ? 'No energy remaining, refilling over time'
            : 'Low energy — last charge',
        child: DismissibleBanner(
          color: const Color(0xD0FFA000),
          text: hearts.currentHearts == 0
              ? '\u{26A1} Energy out — bonus XP paused while refilling'
              : '\u{26A1} Low energy — almost out of bonus XP',
          textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          onDismiss: () => setState(() => _heartsDismissed = true),
        ),
      );
    }

    if (activeBanner == null) {
      // If no streak/hearts banner, show the WC streak banner alone
      return Positioned(
        top: topPad + 8,
        left: 16,
        right: 80,
        child: Semantics(liveRegion: true, child: const WcStreakBanner()),
      );
    }

    return Positioned(
      top: topPad + 8,
      left: 16,
      right: 80,
      child: activeBanner,
    );
  }
}

/// Extracted water-change streak banner with its own dismissal state.
class WcStreakBanner extends ConsumerStatefulWidget {
  const WcStreakBanner({super.key});

  @override
  ConsumerState<WcStreakBanner> createState() => WcStreakBannerState();
}

class WcStreakBannerState extends ConsumerState<WcStreakBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final tanks = ref.watch(tanksProvider).value ?? [];
    if (tanks.isEmpty) return const SizedBox.shrink();

    final logsAsync = ref.watch(allLogsProvider(tanks.first.id));

    ref.listen(allLogsProvider(tanks.first.id), (prev, next) {
      final prevStreak = prev?.whenOrNull(
        data: (logs) => TankHealthService.calculateWaterChangeStreak(logs),
      );
      final nextStreak = next.whenOrNull(
        data: (logs) => TankHealthService.calculateWaterChangeStreak(logs),
      );
      if (prevStreak != null &&
          nextStreak != null &&
          prevStreak != nextStreak) {
        setState(() => _dismissed = false);
      }
    });

    return logsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (logs) {
        final wcStreak = TankHealthService.calculateWaterChangeStreak(logs);
        if (wcStreak == 0 || _dismissed) return const SizedBox.shrink();
        return Semantics(
          liveRegion: true,
          label:
              'Water change streak: $wcStreak week${wcStreak == 1 ? "" : "s"}',
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: DismissibleBanner(
              color: DanioColors.tealWater.withAlpha(230),
              text:
                  '\u{1F4A7} Water change streak: $wcStreak week${wcStreak == 1 ? "" : "s"}',
              textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onDismiss: () => setState(() => _dismissed = true),
            ),
          ),
        );
      },
    );
  }
}
