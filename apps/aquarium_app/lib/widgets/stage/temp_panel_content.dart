import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/log_entry.dart';
import '../../providers/tank_provider.dart';
import '../../screens/add_log_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';

// ── Colour constants ──────────────────────────────────────────────────────────
const _kTeal = Color(0xFF3BBFB0);
const _kTealDark = Color(0xFF2D7A94);
const _kTealLight = Color(0xFF9ED8EC);
const _kAmberGold = Color(0xFFD97706);
const _kCharcoal = Color(0xFF2D3436);
const _kCream = Color(0xFFFFF8F0);
const _kGreen = Color(0xFF1E8449);
const _kAmberWarn = Color(0xFFC99524);
const _kRedWarn = Color(0xFFC0392B);

// ── Panel content ─────────────────────────────────────────────────────────────

/// Rich, fully-packed temperature panel for the Swiss Army stage system.
/// Keeps all existing Riverpod provider wiring.
class TempPanelContent extends ConsumerStatefulWidget {
  final String tankId;
  final RoomTheme theme;

  const TempPanelContent({
    super.key,
    required this.tankId,
    required this.theme,
  });

  @override
  ConsumerState<TempPanelContent> createState() => _TempPanelContentState();
}

class _TempPanelContentState extends ConsumerState<TempPanelContent>
    with TickerProviderStateMixin {
  late final AnimationController _fillAnim;

  static const double _defaultOptimalMin = 24.0;
  static const double _defaultOptimalMax = 26.0;
  static const double _gaugeMin = 18.0;
  static const double _gaugeMax = 30.0;

  @override
  void initState() {
    super.initState();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    _fillAnim = AnimationController(
      vsync: this,
      duration: disableMotion ? Duration.zero : const Duration(milliseconds: 1100),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fillAnim.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _fillAnim.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatTimestamp(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  _TempStatus _status(double temp, double optMin, double optMax) {
    if (temp >= optMin && temp <= optMax) return _TempStatus.perfect;
    if (temp > optMax) {
      return (temp - optMax) > 2.0 ? _TempStatus.tooHot : _TempStatus.warm;
    }
    return (optMin - temp) > 2.0 ? _TempStatus.tooCold : _TempStatus.cool;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final latestTestAsync = ref.watch(latestWaterTestProvider(widget.tankId));
    final latestEntryAsync = ref.watch(
      latestWaterTestEntryProvider(widget.tankId),
    );
    final streakAsync = ref.watch(testStreakProvider(widget.tankId));
    final logsAsync = ref.watch(logsProvider(widget.tankId));
    final heaterAsync = ref.watch(tankHeaterProvider(widget.tankId));

    final temp = latestTestAsync.value?.temperature;
    final lastEntry = latestEntryAsync.value;
    final streak = streakAsync.value ?? 0;

    // Pull optimal range from heater settings if available
    final heater = heaterAsync.value;
    final optimalMin =
        (heater?.settings?['optimalMin'] as num?)?.toDouble() ??
        _defaultOptimalMin;
    final optimalMax =
        (heater?.settings?['optimalMax'] as num?)?.toDouble() ??
        _defaultOptimalMax;

    final status = temp != null ? _status(temp, optimalMin, optimalMax) : null;

    // Build 7-day sparkline data from recent logs
    final recentLogs = logsAsync.value ?? [];
    final sparkData = _buildSparkData(recentLogs);

    // Stats from spark data
    final double? minTemp = sparkData.isNotEmpty
        ? sparkData.reduce(math.min)
        : null;
    final double? maxTemp = sparkData.isNotEmpty
        ? sparkData.reduce(math.max)
        : null;
    final double? avgTemp = sparkData.isNotEmpty
        ? sparkData.reduce((a, b) => a + b) / sparkData.length
        : null;

    return Container(
      color: _kCream,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────
            _Header(streak: streak),
            const SizedBox(height: 14),

            // ── Hero: Thermometer + big readout ──────────────────────────
            _HeroSection(
              temp: temp,
              fillAnim: _fillAnim,
              gaugeMin: _gaugeMin,
              gaugeMax: _gaugeMax,
              optimalMin: optimalMin,
              optimalMax: optimalMax,
              status: status,
              lastEntry: lastEntry,
              formatTimestamp: _formatTimestamp,
            ),
            const SizedBox(height: 14),

            // ── Divider ──────────────────────────────────────────────────
            Container(height: 1, color: _kTeal.withAlpha(40)),
            const SizedBox(height: 14),

            // ── 7-Day Trend section ──────────────────────────────────────
            _TrendSection(
              sparkData: sparkData,
              minTemp: minTemp,
              maxTemp: maxTemp,
              avgTemp: avgTemp,
            ),
            const SizedBox(height: 14),

            // ── Log Temperature button ───────────────────────────────────
            _LogButton(tankId: widget.tankId),
          ],
        ),
      ),
    );
  }

  /// Extract the last 7 days of temperature readings (one per day, latest).
  List<double> _buildSparkData(List<LogEntry> logs) {
    final now = DateTime.now();
    final result = <double>[];
    for (var i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day - i);
      final dayLogs = logs.where((l) {
        if (l.type != LogType.waterTest) return false;
        final t = l.waterTest?.temperature;
        if (t == null) return false;
        final ld = DateTime(
          l.timestamp.year,
          l.timestamp.month,
          l.timestamp.day,
        );
        return ld == day;
      }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      if (dayLogs.isNotEmpty) {
        result.add(dayLogs.first.waterTest!.temperature!);
      }
    }
    return result;
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int streak;

  const _Header({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3BBFB0), Color(0xFF2D7A94)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _kTeal.withAlpha(80),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(
            Icons.thermostat_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'Temperature',
          style: AppTypography.titleMedium.copyWith(
            color: _kCharcoal,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (streak > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kAmberGold.withAlpha(30),
              borderRadius: AppRadius.pillRadius,
              border: Border.all(color: _kAmberGold.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  '$streak-day streak',
                  style: AppTypography.labelSmall.copyWith(
                    color: _kAmberGold,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Hero Section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final double? temp;
  final AnimationController fillAnim;
  final double gaugeMin;
  final double gaugeMax;
  final double optimalMin;
  final double optimalMax;
  final _TempStatus? status;
  final LogEntry? lastEntry;
  final String Function(DateTime) formatTimestamp;

  const _HeroSection({
    required this.temp,
    required this.fillAnim,
    required this.gaugeMin,
    required this.gaugeMax,
    required this.optimalMin,
    required this.optimalMax,
    required this.status,
    required this.lastEntry,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed thermometer dimensions — nice and large
    const thermW = 56.0;
    const thermH = 300.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Large thermometer ────────────────────────────────────────────
        SizedBox(
          width: thermW,
          height: thermH,
          child: AnimatedBuilder(
            animation: fillAnim,
            builder: (context, _) {
              final fillFraction = temp != null
                  ? ((temp! - gaugeMin) / (gaugeMax - gaugeMin)).clamp(0.0, 1.0)
                  : 0.0;
              final animatedFill =
                  Curves.easeOutCubic.transform(fillAnim.value) * fillFraction;
              return CustomPaint(
                painter: _ThermometerPainter(
                  fillFraction: animatedFill,
                  optimalMin: optimalMin,
                  optimalMax: optimalMax,
                  gaugeMin: gaugeMin,
                  gaugeMax: gaugeMax,
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        // ── Scale labels on the LEFT of gauge ───────────────────────────
        SizedBox(
          width: 28,
          height: thermH,
          child: _ScaleLabels(gaugeMin: gaugeMin, gaugeMax: gaugeMax),
        ),

        const SizedBox(width: 12),

        // ── Right column: big temp + badge + info ────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big temp display with fish emoji
              Text(
                temp != null ? '🐟 ${temp!.toStringAsFixed(1)}°C' : '🐟 --°C',
                style: AppTypography.headlineLarge.copyWith(
                  color: temp != null ? _kCharcoal : _kCharcoal.withAlpha(100),
                  fontWeight: FontWeight.w800,
                  fontSize: 42,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                temp != null
                    ? 'current temperature'
                    : 'no data yet',
                style: AppTypography.labelSmall.copyWith(
                  color: _kCharcoal.withAlpha(110),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 14),

              // Status badge
              if (status != null) _StatusBadge(status: status!),

              const SizedBox(height: 14),

              // Optimal range indicator
              _OptimalRangeRow(min: optimalMin, max: optimalMax),
              const SizedBox(height: 12),

              // Fish decorations — stacked at different heights
              const _FishDecorations(),
              const SizedBox(height: 12),

              // Last logged timestamp
              if (lastEntry != null)
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: _kCharcoal.withAlpha(100),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last logged: ${formatTimestamp(lastEntry!.timestamp)}',
                      style: AppTypography.labelSmall.copyWith(
                        color: _kCharcoal.withAlpha(120),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Scale Labels ──────────────────────────────────────────────────────────────

class _ScaleLabels extends StatelessWidget {
  final double gaugeMin;
  final double gaugeMax;

  const _ScaleLabels({required this.gaugeMin, required this.gaugeMax});

  @override
  Widget build(BuildContext context) {
    // Labels every 2 degrees from gaugeMax down to gaugeMin
    final labels = <double>[];
    for (var t = gaugeMax; t >= gaugeMin; t -= 2) {
      labels.add(t);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        // These match the painter geometry:
        const bulbRadius = 20.0;
        const tubeTopPad = 16.0;
        final bulbCy = h - bulbRadius - 4;
        final tubeBotY = bulbCy - bulbRadius - 2;
        const tubeTopY = tubeTopPad;
        final usableH = tubeBotY - tubeTopY;

        return Stack(
          children: List.generate(labels.length, (i) {
            final t = labels[i];
            final frac = (t - gaugeMin) / (gaugeMax - gaugeMin);
            final y = tubeTopY + usableH * (1.0 - frac) - 7;
            final isMajor = t % 4 == 0;
            return Positioned(
              top: y,
              right: 0,
              child: Text(
                '${t.toInt()}°',
                style: AppTypography.labelSmall.copyWith(
                  color: isMajor
                      ? _kCharcoal.withAlpha(180)
                      : _kCharcoal.withAlpha(110),
                  fontSize: isMajor ? 10 : 9,
                  fontWeight: isMajor ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ── Optimal Range Row ─────────────────────────────────────────────────────────

class _OptimalRangeRow extends StatelessWidget {
  final double min;
  final double max;

  const _OptimalRangeRow({required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _kGreen.withAlpha(20),
        borderRadius: AppRadius.pillRadius,
        border: Border.all(color: _kGreen.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _kGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Optimal ${min.toInt()}–${max.toInt()}°C',
            style: AppTypography.labelSmall.copyWith(
              color: _kGreen,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fish Decorations ──────────────────────────────────────────────────────────

class _FishDecorations extends StatelessWidget {
  const _FishDecorations();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FishChip(label: '🐟', opacity: 1.0),
        const SizedBox(width: 6),
        _FishChip(label: '🐠', opacity: 0.85),
        const SizedBox(width: 6),
        _FishChip(label: '🐡', opacity: 0.7),
      ],
    );
  }
}

class _FishChip extends StatelessWidget {
  final String label;
  final double opacity;

  const _FishChip({required this.label, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _kTeal.withAlpha(25),
          shape: BoxShape.circle,
          border: Border.all(color: _kTeal.withAlpha(60)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final _TempStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bgColor, label, icon) = switch (status) {
      _TempStatus.perfect => (_kGreen, 'Perfect!', '🐟'),
      _TempStatus.warm => (_kAmberWarn, 'A little warm', '☀️'),
      _TempStatus.cool => (_kAmberWarn, 'A little cool', '❄️'),
      _TempStatus.tooHot => (_kRedWarn, 'Too hot!', '🔥'),
      _TempStatus.tooCold => (_kRedWarn, 'Too cold!', '🥶'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.largeRadius,
        boxShadow: [
          BoxShadow(
            color: bgColor.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Trend Section ─────────────────────────────────────────────────────────────

class _TrendSection extends StatelessWidget {
  final List<double> sparkData;
  final double? minTemp;
  final double? maxTemp;
  final double? avgTemp;

  const _TrendSection({
    required this.sparkData,
    required this.minTemp,
    required this.maxTemp,
    required this.avgTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Icon(Icons.show_chart_rounded, size: 16, color: _kTealDark),
            const SizedBox(width: 6),
            Text(
              '7-Day Trend',
              style: AppTypography.titleMedium.copyWith(
                color: _kCharcoal,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Sparkline chart
        Container(
          decoration: BoxDecoration(
            color: AppColors.whiteAlpha80,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: _kTeal.withAlpha(50)),
            boxShadow: [
              BoxShadow(
                color: _kTeal.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chart area
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: SizedBox(
                  height: 72,
                  child: sparkData.length >= 2
                      ? CustomPaint(
                          size: const Size(double.infinity, 72),
                          painter: _SparklinePainter(data: sparkData),
                        )
                      : Center(
                          child: Text(
                            'No data yet — log some readings!',
                            style: AppTypography.labelSmall.copyWith(
                              color: _kCharcoal.withAlpha(100),
                              fontSize: 11,
                            ),
                          ),
                        ),
                ),
              ),

              // Day labels under chart
              if (sparkData.length >= 2)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: _DayLabels(count: sparkData.length),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Stats row
        if (minTemp != null && maxTemp != null && avgTemp != null)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                _StatCell(
                  label: 'Min',
                  value: '${minTemp!.toStringAsFixed(1)}°',
                  color: _kTealDark,
                ),
                _StatDivider(),
                _StatCell(
                  label: 'Avg',
                  value: '${avgTemp!.toStringAsFixed(1)}°',
                  color: _kTeal,
                ),
                _StatDivider(),
                _StatCell(
                  label: 'Max',
                  value: '${maxTemp!.toStringAsFixed(1)}°',
                  color: _kAmberWarn,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineLarge.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: _kCharcoal.withAlpha(120),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      color: _kCharcoal.withAlpha(30),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Day Labels ────────────────────────────────────────────────────────────────

class _DayLabels extends StatelessWidget {
  final int count;

  const _DayLabels({required this.count});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(count, (i) {
      final d = now.subtract(Duration(days: count - 1 - i));
      if (i == count - 1) return 'Today';
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[(d.weekday - 1) % 7];
    });
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (d) => Text(
              d,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 9,
                color: _kCharcoal.withAlpha(100),
                fontWeight: d == 'Today' ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Log Button ────────────────────────────────────────────────────────────────

class _LogButton extends StatelessWidget {
  final String tankId;

  const _LogButton({required this.tankId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddLogScreen(
                tankId: tankId,
                initialType: LogType.waterTest,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          'Log Temperature',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kAmberGold,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.md2Radius,
          ),
        ),
      ),
    );
  }
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum _TempStatus { perfect, warm, cool, tooHot, tooCold }

// ── ThermometerPainter ────────────────────────────────────────────────────────

/// Large thermometer CustomPainter:
/// - Thick tube (40dp wide, full height)
/// - Teal liquid with gradient fill
/// - Green optimal zone overlay labelled "Optimal"
/// - Tick marks every 2° on the right side of tube
/// - Bulb at bottom with highlight
class _ThermometerPainter extends CustomPainter {
  final double fillFraction; // 0.0 – 1.0
  final double optimalMin;
  final double optimalMax;
  final double gaugeMin;
  final double gaugeMax;

  const _ThermometerPainter({
    required this.fillFraction,
    required this.optimalMin,
    required this.optimalMax,
    required this.gaugeMin,
    required this.gaugeMax,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Geometry ─────────────────────────────────────────────────────────
    const bulbRadius = 20.0;
    const tubeHalfW = 13.0; // 26dp wide tube
    const tubeTopRadius = 13.0;
    const tubeTopPad = 16.0;
    final cx = w / 2;
    final bulbCy = h - bulbRadius - 4;
    final tubeBotY = bulbCy - bulbRadius - 2;
    const tubeTopY = tubeTopPad;
    final tubeUsable = tubeBotY - tubeTopY;

    // ── Background fill (light grey tube) ────────────────────────────────
    final bgPaint = Paint()
      ..color = _kCharcoal.withAlpha(15)
      ..style = PaintingStyle.fill;

    final tubeRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        cx - tubeHalfW,
        tubeTopY,
        tubeHalfW * 2,
        tubeBotY - tubeTopY,
      ),
      topLeft: const Radius.circular(tubeTopRadius),
      topRight: const Radius.circular(tubeTopRadius),
    );
    canvas.drawRRect(tubeRect, bgPaint);
    canvas.drawCircle(Offset(cx, bulbCy), bulbRadius, bgPaint);

    // ── Optimal zone overlay ──────────────────────────────────────────────
    final zoneMinFrac = (optimalMin - gaugeMin) / (gaugeMax - gaugeMin);
    final zoneMaxFrac = (optimalMax - gaugeMin) / (gaugeMax - gaugeMin);
    final zoneTop = tubeBotY - zoneMaxFrac * tubeUsable;
    final zoneBot = tubeBotY - zoneMinFrac * tubeUsable;

    final zonePaint = Paint()
      ..color = _kGreen.withAlpha(55)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTRB(cx - tubeHalfW + 2, zoneTop, cx + tubeHalfW - 2, zoneBot),
      ),
      zonePaint,
    );

    // "Optimal" label inside zone
    final optTP = TextPainter(
      text: TextSpan(
        text: 'OPT',
        style: TextStyle(
          color: _kGreen.withAlpha(220),
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: tubeHalfW * 2 - 4);
    optTP.paint(
      canvas,
      Offset(cx - optTP.width / 2, (zoneTop + zoneBot) / 2 - optTP.height / 2),
    );

    // ── Liquid fill (teal gradient) ───────────────────────────────────────
    final fillH = tubeUsable * fillFraction;
    final fillTopY = tubeBotY - fillH;

    if (fillH > 0) {
      final liquidShader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_kTealLight, _kTealDark],
          ).createShader(
            Rect.fromLTRB(
              cx - tubeHalfW + 2,
              fillTopY,
              cx + tubeHalfW - 2,
              tubeBotY,
            ),
          );
      final fillPaint = Paint()
        ..shader = liquidShader
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTRB(
            cx - tubeHalfW + 2,
            fillTopY,
            cx + tubeHalfW - 2,
            tubeBotY,
          ),
          topLeft: Radius.circular(fillH > 10 ? 8 : 0),
          topRight: Radius.circular(fillH > 10 ? 8 : 0),
        ),
        fillPaint,
      );
    }

    // ── Bulb fill ─────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, bulbCy),
      bulbRadius - 2,
      Paint()
        ..color = fillFraction > 0 ? _kTealDark : _kCharcoal.withAlpha(30)
        ..style = PaintingStyle.fill,
    );
    // Bulb shine
    canvas.drawCircle(
      Offset(cx - bulbRadius * 0.28, bulbCy - bulbRadius * 0.28),
      bulbRadius * 0.2,
      Paint()
        ..color = AppColors.whiteAlpha50
        ..style = PaintingStyle.fill,
    );

    // ── Tube outline stroke ───────────────────────────────────────────────
    final strokePaint = Paint()
      ..color = _kCharcoal.withAlpha(45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(tubeRect, strokePaint);
    canvas.drawCircle(Offset(cx, bulbCy), bulbRadius, strokePaint);

    // ── Tick marks (right side of tube) ──────────────────────────────────
    for (var t = gaugeMin; t <= gaugeMax; t += 2) {
      final frac = (t - gaugeMin) / (gaugeMax - gaugeMin);
      final ty = tubeBotY - frac * tubeUsable;
      final isMajor = (t.toInt() % 4 == 0);
      final tickLen = isMajor ? 6.0 : 4.0;
      final tickPaint = Paint()
        ..color = _kCharcoal.withAlpha(isMajor ? 90 : 55)
        ..strokeWidth = isMajor ? 1.5 : 1.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(cx + tubeHalfW - 1, ty),
        Offset(cx + tubeHalfW + tickLen, ty),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ThermometerPainter old) =>
      old.fillFraction != fillFraction ||
      old.optimalMin != optimalMin ||
      old.optimalMax != optimalMax;
}

// ── SparklinePainter ──────────────────────────────────────────────────────────

class _SparklinePainter extends CustomPainter {
  final List<double> data;

  const _SparklinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final minV = data.reduce(math.min);
    final maxV = data.reduce(math.max);
    final range = (maxV - minV).abs();
    final safeRange = range < 0.5 ? 1.0 : range;
    const vPad = 6.0;

    double xOf(int i) => size.width * i / (data.length - 1);
    double yOf(double v) {
      final norm = (v - minV) / safeRange;
      return size.height - vPad - norm * (size.height - vPad * 2);
    }

    // Filled area
    final fillPath = Path()..moveTo(xOf(0), size.height);
    for (var i = 0; i < data.length; i++) {
      final x0 = i == 0 ? xOf(0) : xOf(i - 1);
      final y0 = i == 0 ? yOf(data[0]) : yOf(data[i - 1]);
      final x1 = xOf(i);
      final y1 = yOf(data[i]);
      if (i == 0) {
        fillPath.lineTo(x1, y1);
      } else {
        final cpx = (x0 + x1) / 2;
        fillPath.cubicTo(cpx, y0, cpx, y1, x1, y1);
      }
    }
    fillPath.lineTo(xOf(data.length - 1), size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kTeal.withAlpha(100), _kTeal.withAlpha(8)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill,
    );

    // Line
    final linePath = Path()..moveTo(xOf(0), yOf(data[0]));
    for (var i = 1; i < data.length; i++) {
      final x0 = xOf(i - 1);
      final y0 = yOf(data[i - 1]);
      final x1 = xOf(i);
      final y1 = yOf(data[i]);
      final cpx = (x0 + x1) / 2;
      linePath.cubicTo(cpx, y0, cpx, y1, x1, y1);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = _kTeal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dot markers
    for (var i = 0; i < data.length; i++) {
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        4.0,
        Paint()..color = _kTealDark,
      );
      canvas.drawCircle(
        Offset(xOf(i), yOf(data[i])),
        2.2,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.data != data;
}
