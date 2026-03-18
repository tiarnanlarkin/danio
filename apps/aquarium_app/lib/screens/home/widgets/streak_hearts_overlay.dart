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
        padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 4),
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
                    child: Icon(Icons.close, size: 14, color: Colors.white70),
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
  bool _heartsDismissed = false;

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
        if (prev != next) {
          setState(() => _streakDismissed = false);
        }
      },
    );

    final topPad = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPad + 8,
      left: 16,
      right: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (streak > 0 && !_streakDismissed)
            DismissibleBanner(
              color: DanioColors.amberGold.withAlpha(230),
              text: '\u{1F525} $streak day streak!',
              textStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onDismiss: () => setState(() => _streakDismissed = true),
            ),

          const WcStreakBanner(),

          if (lowHearts && hearts.currentHearts >= 0 && !_heartsDismissed) ...[
            const SizedBox(height: AppSpacing.xs),
            DismissibleBanner(
              color: AppColors.warning.withAlpha(210),
              text: hearts.currentHearts == 0
                  ? '\u{1F494} No hearts left - wait for refill!'
                  : '\u{26A0}\u{FE0F} You\'re on your last heart - be careful!',
              textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              onDismiss: () => setState(() => _heartsDismissed = true),
            ),
          ],
        ],
      ),
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
        return Padding(
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
        );
      },
    );
  }
}
