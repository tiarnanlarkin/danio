import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

/// Interactive Nitrogen Cycle Assistant - guides beginners through tank cycling.
///
/// Shows the three phases of the nitrogen cycle with real data from water tests,
/// educational tooltips, and celebrates when the tank is fully cycled.
/// This addresses the #1 beginner pain point in fishkeeping.
class CyclingAssistantScreen extends ConsumerWidget {
  final String tankId;

  const CyclingAssistantScreen({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tankAsync = ref.watch(tankProvider(tankId));
    final logsAsync = ref.watch(allLogsProvider(tankId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nitrogen Cycle Assistant'),
      ),
      body: tankAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tank) {
          if (tank == null) {
            return const Center(child: Text('Tank not found'));
          }
          return logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (logs) => _CyclingAssistantBody(tank: tank, logs: logs),
          );
        },
      ),
    );
  }
}

class _CyclingAssistantBody extends StatelessWidget {
  final Tank tank;
  final List<LogEntry> logs;

  const _CyclingAssistantBody({required this.tank, required this.logs});

  @override
  Widget build(BuildContext context) {
    final waterTests = logs
        .where((l) => l.type == LogType.waterTest && l.waterTest != null)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final phase = _determinePhase(waterTests);
    final tankAgeDays = DateTime.now().difference(tank.startDate).inDays;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Phase indicator
        _PhaseHeader(phase: phase, tankAgeDays: tankAgeDays)
            .animate()
            .fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.lg),

        // Visual cycle diagram
        _CycleDiagram(
          phase: phase,
          waterTests: waterTests,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

        const SizedBox(height: AppSpacing.lg),

        // Parameter chart - ammonia, nitrite, nitrate over time
        if (waterTests.length >= 2)
          _ParameterTimeline(waterTests: waterTests)
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),

        if (waterTests.length >= 2) const SizedBox(height: AppSpacing.lg),

        // Educational content for current phase
        _PhaseEducation(phase: phase)
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms),

        const SizedBox(height: AppSpacing.lg),

        // Action items
        _ActionItems(phase: phase, waterTests: waterTests)
            .animate()
            .fadeIn(delay: 500.ms, duration: 400.ms),

        // Celebration for cycled tanks
        if (phase == _CyclePhase.cycled)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: _CycledCelebration()
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          ),

        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  _CyclePhase _determinePhase(List<LogEntry> waterTests) {
    if (waterTests.isEmpty) return _CyclePhase.notStarted;

    final latest = waterTests.last.waterTest!;
    final ammonia = latest.ammonia ?? 0;
    final nitrite = latest.nitrite ?? 0;
    final nitrate = latest.nitrate;

    // Cycled: both ammonia and nitrite near zero, nitrate present
    if (ammonia < 0.25 && nitrite < 0.25 && nitrate != null && nitrate > 5) {
      return _CyclePhase.cycled;
    }

    // Phase 3: Ammonia dropping, nitrite dropping, nitrate rising
    if (ammonia < 0.5 && nitrite < 1.0 && nitrate != null && nitrate > 0) {
      return _CyclePhase.phase3;
    }

    // Phase 2: Nitrite spike - ammonia dropping, nitrite rising
    if (nitrite > 0.25) {
      return _CyclePhase.phase2;
    }

    // Phase 1: Ammonia spike
    if (ammonia > 0) {
      return _CyclePhase.phase1;
    }

    return _CyclePhase.notStarted;
  }
}

enum _CyclePhase { notStarted, phase1, phase2, phase3, cycled }

class _PhaseHeader extends StatelessWidget {
  final _CyclePhase phase;
  final int tankAgeDays;

  const _PhaseHeader({required this.phase, required this.tankAgeDays});

  @override
  Widget build(BuildContext context) {
    final String title;
    final String subtitle;
    final Color color;
    final String emoji;
    switch (phase) {
      case _CyclePhase.notStarted:
        title = 'Ready to Start Cycling';
        subtitle = 'Add an ammonia source to begin';
        color = AppColors.textHint;
        emoji = '\u{23F3}';
      case _CyclePhase.phase1:
        title = 'Phase 1: Ammonia Spike';
        subtitle = 'Day $tankAgeDays - bacteria are colonising';
        color = AppColors.warning;
        emoji = '\u{1F9EA}';
      case _CyclePhase.phase2:
        title = 'Phase 2: Nitrite Spike';
        subtitle = 'Day $tankAgeDays - ammonia converters active!';
        color = AppColors.paramWarning;
        emoji = '\u{2697}\u{FE0F}';
      case _CyclePhase.phase3:
        title = 'Phase 3: Almost There!';
        subtitle = 'Day $tankAgeDays - nitrite dropping, nearly cycled';
        color = AppColors.info;
        emoji = '\u{1F4C8}';
      case _CyclePhase.cycled:
        title = 'Tank is Cycled!';
        subtitle = 'Safe to add fish gradually';
        color = AppColors.success;
        emoji = '\u{1F389}';
    }

    return AppCard(
      border: Border.all(color: color, width: 2),
      backgroundColor: color.withAlpha(20),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CycleDiagram extends StatelessWidget {
  final _CyclePhase phase;
  final List<LogEntry> waterTests;

  const _CycleDiagram({required this.phase, required this.waterTests});

  @override
  Widget build(BuildContext context) {
    final int phaseIndex;
    switch (phase) {
      case _CyclePhase.notStarted:
        phaseIndex = 0;
      case _CyclePhase.phase1:
        phaseIndex = 1;
      case _CyclePhase.phase2:
        phaseIndex = 2;
      case _CyclePhase.phase3:
        phaseIndex = 3;
      case _CyclePhase.cycled:
        phaseIndex = 4;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Cycling Progress',
            style: AppTypography.labelLarge,
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress bar with phase markers
          _buildProgressBar(context, phaseIndex),

          const SizedBox(height: AppSpacing.md),

          // Latest readings
          if (waterTests.isNotEmpty) _buildLatestReadings(waterTests.last),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, int phaseIndex) {
    final phases = ['Start', 'NH3 \u{2191}', 'NO2 \u{2191}', 'Clearing', 'Cycled!'];
    final progress = phaseIndex / 4.0;

    return Column(
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: AppRadius.xsRadius,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(
              phaseIndex == 4 ? AppColors.success : AppColors.primary,
            ),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Phase labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final isActive = i <= phaseIndex;
            final isCurrent = i == phaseIndex;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? (isCurrent ? AppColors.primary : AppColors.success)
                          : AppColors.surfaceVariant,
                      border: isCurrent
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phases[i],
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLatestReadings(LogEntry latest) {
    final wt = latest.waterTest!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm2),
      decoration: BoxDecoration(
        color: AppOverlays.surfaceVariant50,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        children: [
          _ParamChip(
            label: 'NH3',
            value: wt.ammonia?.toStringAsFixed(2) ?? '--',
            isGood: (wt.ammonia ?? 0) < 0.25,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ParamChip(
            label: 'NO2',
            value: wt.nitrite?.toStringAsFixed(2) ?? '--',
            isGood: (wt.nitrite ?? 0) < 0.25,
          ),
          const SizedBox(width: AppSpacing.sm),
          _ParamChip(
            label: 'NO3',
            value: wt.nitrate?.toStringAsFixed(1) ?? '--',
            isGood: (wt.nitrate ?? 0) > 0,
          ),
        ],
      ),
    );
  }
}

class _ParamChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isGood;

  const _ParamChip({
    required this.label,
    required this.value,
    required this.isGood,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isGood ? AppColors.success.withAlpha(26) : AppColors.warning.withAlpha(26),
          borderRadius: AppRadius.xsRadius,
          border: Border.all(
            color: isGood ? AppColors.success.withAlpha(51) : AppColors.warning.withAlpha(51),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                color: isGood ? AppColors.success : AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple mini-chart showing parameter trends over time
class _ParameterTimeline extends StatelessWidget {
  final List<LogEntry> waterTests;

  const _ParameterTimeline({required this.waterTests});

  @override
  Widget build(BuildContext context) {
    // Take last 10 tests
    final recent = waterTests.length > 10
        ? waterTests.sublist(waterTests.length - 10)
        : waterTests;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Parameter Trends', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Last ${recent.length} water tests',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: _MiniChartPainter(
                tests: recent,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: AppColors.error, label: 'NH3'),
              const SizedBox(width: AppSpacing.md),
              _LegendItem(color: AppColors.warning, label: 'NO2'),
              const SizedBox(width: AppSpacing.md),
              _LegendItem(color: AppColors.success, label: 'NO3'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  final List<LogEntry> tests;

  _MiniChartPainter({required this.tests});

  @override
  void paint(Canvas canvas, Size size) {
    if (tests.length < 2) return;

    // Collect data
    final ammonia = tests.map((t) => t.waterTest?.ammonia ?? 0.0).toList();
    final nitrite = tests.map((t) => t.waterTest?.nitrite ?? 0.0).toList();
    final nitrate = tests.map((t) => (t.waterTest?.nitrate ?? 0.0) / 10).toList(); // Scale down

    final maxVal = [
      ...ammonia,
      ...nitrite,
      ...nitrate,
    ].fold<double>(0.1, (a, b) => a > b ? a : b);

    void drawLine(List<double> data, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      for (var i = 0; i < data.length; i++) {
        final x = i / (data.length - 1) * size.width;
        final y = size.height - (data[i] / maxVal) * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }

    drawLine(ammonia, AppColors.error);
    drawLine(nitrite, AppColors.warning);
    drawLine(nitrate, AppColors.success);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PhaseEducation extends StatelessWidget {
  final _CyclePhase phase;

  const _PhaseEducation({required this.phase});

  @override
  Widget build(BuildContext context) {
    final String title;
    final String content;
    final IconData icon;
    switch (phase) {
      case _CyclePhase.notStarted:
        title = 'How the Nitrogen Cycle Works';
        content = 'Fish produce ammonia (NH3) from waste and breathing. '
            'In nature, bacteria convert this toxic ammonia into less harmful substances. '
            'Your filter needs to grow these bacteria - that is what "cycling" means.\n\n'
            'To start: add fish food or pure ammonia to feed the bacteria.';
        icon = Icons.school;
      case _CyclePhase.phase1:
        title = 'What is Happening Now';
        content = 'Ammonia is building up in your tank. This is normal and expected!\n\n'
            'Nitrosomonas bacteria are starting to colonise your filter media. '
            'These bacteria eat ammonia and convert it to nitrite (NO2).\n\n'
            'DO NOT add fish during this phase - ammonia is toxic to them.';
        icon = Icons.science;
      case _CyclePhase.phase2:
        title = 'Progress: Nitrite Phase';
        content = 'Your ammonia-eating bacteria are working! Ammonia should be dropping '
            'while nitrite rises.\n\n'
            'Now Nitrospira bacteria are growing - these convert nitrite to '
            'the much less harmful nitrate (NO3).\n\n'
            'Still DO NOT add fish - nitrite is also toxic.';
        icon = Icons.autorenew;
      case _CyclePhase.phase3:
        title = 'Nearly There!';
        content = 'Both ammonia and nitrite are dropping towards zero. '
            'Nitrate is rising, which means your biological filter is working!\n\n'
            'Keep testing every 1-2 days. When ammonia AND nitrite are both '
            'at 0 ppm for 3+ consecutive tests, your tank is cycled.';
        icon = Icons.trending_up;
      case _CyclePhase.cycled:
        title = 'Your Tank is Cycled!';
        content = 'Congratulations! Your biological filter can now process:\n'
            'Ammonia (NH3) \u{2192} Nitrite (NO2) \u{2192} Nitrate (NO3)\n\n'
            'You can now add fish - but go slowly! Add 2-3 small fish at a time '
            'and wait 1-2 weeks between additions to let the bacteria adjust.\n\n'
            'Regular water changes will keep nitrate levels manageable.';
        icon = Icons.celebration;
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: AppIconSizes.sm),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          Text(content, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}

class _ActionItems extends StatelessWidget {
  final _CyclePhase phase;
  final List<LogEntry> waterTests;

  const _ActionItems({required this.phase, required this.waterTests});

  @override
  Widget build(BuildContext context) {
    final List<_ActionItem> actions;
    switch (phase) {
      case _CyclePhase.notStarted:
        actions = [
          _ActionItem(
            icon: Icons.science,
            text: 'Add ammonia source (fish food or pure ammonia)',
            done: false,
          ),
          _ActionItem(
            icon: Icons.schedule,
            text: 'Set a reminder to test water every 2-3 days',
            done: false,
          ),
          _ActionItem(
            icon: Icons.thermostat,
            text: 'Ensure heater is set to 26-28C (speeds up cycling)',
            done: false,
          ),
        ];
      case _CyclePhase.phase1:
        actions = [
          _ActionItem(
            icon: Icons.water_drop,
            text: 'Test ammonia every 2-3 days',
            done: waterTests.isNotEmpty,
          ),
          _ActionItem(
            icon: Icons.do_not_disturb,
            text: 'DO NOT add fish yet',
            done: true,
          ),
          _ActionItem(
            icon: Icons.filter_alt,
            text: 'Keep the filter running 24/7',
            done: true,
          ),
        ];
      case _CyclePhase.phase2:
        actions = [
          _ActionItem(
            icon: Icons.water_drop,
            text: 'Test ammonia AND nitrite every 2 days',
            done: waterTests.length >= 3,
          ),
          _ActionItem(
            icon: Icons.do_not_disturb,
            text: 'Still no fish - nitrite is also toxic',
            done: true,
          ),
          _ActionItem(
            icon: Icons.update,
            text: 'Be patient - this phase takes 1-3 weeks',
            done: false,
          ),
        ];
      case _CyclePhase.phase3:
        actions = [
          _ActionItem(
            icon: Icons.water_drop,
            text: 'Test every 1-2 days to confirm both hit zero',
            done: false,
          ),
          _ActionItem(
            icon: Icons.checklist,
            text: 'Plan your first fish (research compatibility!)',
            done: false,
          ),
          _ActionItem(
            icon: Icons.water,
            text: 'Do a 25% water change to lower nitrate before adding fish',
            done: false,
          ),
        ];
      case _CyclePhase.cycled:
        actions = [
          _ActionItem(
            icon: Icons.set_meal,
            text: 'Add 2-3 small fish to start',
            done: false,
          ),
          _ActionItem(
            icon: Icons.schedule,
            text: 'Wait 1-2 weeks before adding more',
            done: false,
          ),
          _ActionItem(
            icon: Icons.water_drop,
            text: 'Continue weekly water tests',
            done: false,
          ),
        ];
    }

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist, color: AppColors.primary, size: AppIconSizes.sm),
              const SizedBox(width: AppSpacing.sm),
              Text('What To Do Now', style: AppTypography.labelLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          ...actions.map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      a.done ? Icons.check_circle : Icons.circle_outlined,
                      color: a.done ? AppColors.success : AppColors.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        a.text,
                        style: AppTypography.bodyMedium.copyWith(
                          decoration:
                              a.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String text;
  final bool done;

  const _ActionItem({
    required this.icon,
    required this.text,
    required this.done,
  });
}

class _CycledCelebration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.success.withAlpha(30),
            AppColors.primary.withAlpha(30),
          ],
        ),
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            '\u{1F389}\u{1F420}\u{1F389}',
            style: TextStyle(fontSize: 48),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Congratulations!',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your tank has completed the nitrogen cycle.\n'
            'You are ready for fish!',
            style: AppTypography.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
