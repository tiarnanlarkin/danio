import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// A dismissable seasonal tip card that shows relevant fishkeeping advice
/// based on the current month. Appears on the home screen.
class SeasonalTipCard extends StatefulWidget {
  const SeasonalTipCard({super.key});

  @override
  State<SeasonalTipCard> createState() => _SeasonalTipCardState();
}

class _SeasonalTipCardState extends State<SeasonalTipCard>
    with SingleTickerProviderStateMixin {
  bool _dismissed = false;
  bool _loaded = false;
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _checkDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _dismissKey;
    final wasDismissed = prefs.getBool(key) ?? false;
    if (mounted) {
      setState(() {
        _dismissed = wasDismissed;
        _loaded = true;
      });
      if (!wasDismissed) {
        _controller.forward();
      }
    }
  }

  String get _dismissKey {
    final now = DateTime.now();
    return 'seasonal_tip_dismissed_${now.year}_${now.month}';
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissKey, true);
    if (mounted) {
      setState(() => _dismissed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _dismissed) return const SizedBox.shrink();

    final tip = _getSeasonalTip();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tip.color.withAlpha(30),
                tip.color.withAlpha(15),
              ],
            ),
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: tip.color.withAlpha(60),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tip.emoji, style: Theme.of(context).textTheme.headlineMedium!),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: AppTypography.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      tip.message,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _dismiss,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _SeasonalTipData _getSeasonalTip() {
    final month = DateTime.now().month;

    // Northern hemisphere seasons
    if (month >= 3 && month <= 5) {
      // Spring
      return _SeasonalTipData(
        emoji: '\u{1F331}',
        title: 'Spring Tip',
        message:
            'Spring is ideal for breeding! Many species spawn as temperatures rise naturally.',
        color: AppColors.success,
      );
    } else if (month >= 6 && month <= 8) {
      // Summer
      return _SeasonalTipData(
        emoji: '\u2600\uFE0F',
        title: 'Summer Tip',
        message:
            'Watch your water temperature -- summer heat can stress fish. Consider a clip-on fan.',
        color: DanioColors.coralAccent,
      );
    } else if (month >= 9 && month <= 11) {
      // Autumn
      return _SeasonalTipData(
        emoji: '\u{1F342}',
        title: 'Autumn Tip',
        message:
            'Great time to start a new tank before winter. Your fish will be settled by the cold months.',
        color: AppColors.primary,
      );
    } else {
      // Winter
      return _SeasonalTipData(
        emoji: '\u2744\uFE0F',
        title: 'Winter Tip',
        message:
            'Check your heater is working well -- consistent temperature is crucial in cold months.',
        color: AppColors.info,
      );
    }
  }
}

class _SeasonalTipData {
  final String emoji;
  final String title;
  final String message;
  final Color color;

  const _SeasonalTipData({
    required this.emoji,
    required this.title,
    required this.message,
    required this.color,
  });
}
