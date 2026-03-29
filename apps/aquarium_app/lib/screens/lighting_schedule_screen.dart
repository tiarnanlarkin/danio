import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class LightingScheduleScreen extends StatefulWidget {
  const LightingScheduleScreen({super.key});

  @override
  State<LightingScheduleScreen> createState() => _LightingScheduleScreenState();
}

class _LightingScheduleScreenState extends State<LightingScheduleScreen> {
  bool _hasPlants = true;
  bool _hasCO2 = false;
  bool _hasAlgaeIssues = false;
  String _lightIntensity = 'Medium';

  TimeOfDay _lightsOn = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _lightsOff = const TimeOfDay(hour: 20, minute: 0);
  bool _useSiesta = false;
  TimeOfDay _siestaStart = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _siestaEnd = const TimeOfDay(hour: 16, minute: 0);

  int get _totalLightHours {
    final onMinutes = _lightsOn.hour * 60 + _lightsOn.minute;
    final offMinutes = _lightsOff.hour * 60 + _lightsOff.minute;
    var totalMinutes = offMinutes - onMinutes;
    if (totalMinutes < 0) totalMinutes += 24 * 60;

    if (_useSiesta) {
      final siestaStartMin = _siestaStart.hour * 60 + _siestaStart.minute;
      final siestaEndMin = _siestaEnd.hour * 60 + _siestaEnd.minute;
      totalMinutes -= (siestaEndMin - siestaStartMin);
    }

    return (totalMinutes / 60).round();
  }

  String get _recommendation {
    if (_hasAlgaeIssues) {
      return 'With algae issues, consider reducing to 6 hours until it clears up. '
          'A siesta period can also help starve algae while still supporting plants.';
    }

    if (_hasCO2 && _hasPlants) {
      if (_totalLightHours > 10) {
        return 'With CO2, you can run lights longer. ${_totalLightHours}h is reasonable, '
            'but monitor for algae. Turn CO2 on 1 hour before lights.';
      } else if (_totalLightHours >= 6) {
        return 'Good balance! ${_totalLightHours}h with CO2 should support healthy plant growth. '
            'CO2 should come on 1 hour before lights and off 1 hour before lights off.';
      } else {
        return 'You could increase light duration slightly with CO2. '
            'Consider 8-10 hours for optimal plant growth.';
      }
    }

    if (_hasPlants && !_hasCO2) {
      if (_totalLightHours > 8) {
        return 'Without CO2, ${_totalLightHours}h may cause algae. '
            'Consider reducing to 6-8 hours or adding a siesta period.';
      } else if (_totalLightHours >= 6) {
        return 'Good range for a low-tech planted tank. '
            'If you see algae, reduce by an hour or two.';
      } else {
        return 'This may be insufficient for plants. Try 6-8 hours for low-tech tanks.';
      }
    }

    // Fish only
    if (_totalLightHours > 10) {
      return 'Fish-only tanks don\'t need much light. Consider reducing to 8-10 hours.';
    }
    return 'Looks good for a fish-only setup!';
  }

  @override
  Widget build(BuildContext context) {
      final items = <Widget>[
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  size: AppIconSizes.lg,
                  color: context.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Text(
                    'Proper lighting duration prevents algae while keeping plants and fish healthy.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Tank Setup', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm2),

          AppCard(
            padding: AppCardPadding.none,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Live Plants'),
                  subtitle: const Text('Do you have live aquarium plants?'),
                  value: _hasPlants,
                  onChanged: (v) => setState(() => _hasPlants = v),
                ),
                SwitchListTile(
                  title: const Text('CO2 Injection'),
                  subtitle: const Text('Are you dosing CO2?'),
                  value: _hasCO2,
                  onChanged: (v) => setState(() => _hasCO2 = v),
                ),
                SwitchListTile(
                  title: const Text('Algae Issues'),
                  subtitle: const Text('Currently fighting algae?'),
                  value: _hasAlgaeIssues,
                  onChanged: (v) => setState(() => _hasAlgaeIssues = v),
                ),
                ListTile(
                  title: const Text('Light Intensity'),
                  trailing: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Low', label: Text('Low')),
                      ButtonSegment(value: 'Medium', label: Text('Med')),
                      ButtonSegment(value: 'High', label: Text('High')),
                    ],
                    selected: {_lightIntensity},
                    onSelectionChanged: (v) =>
                        setState(() => _lightIntensity = v.first),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Schedule', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm2),

          AppCard(
            padding: AppCardPadding.none,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.wb_sunny, color: AppColors.warning),
                  title: const Text('Lights On'),
                  trailing: Text(
                    _formatTime(_lightsOn),
                    style: AppTypography.labelLarge,
                  ),
                  onTap: () => _pickTime(true),
                ),
                ListTile(
                  leading: Icon(Icons.nights_stay, color: AppColors.primary),
                  title: const Text('Lights Off'),
                  trailing: Text(
                    _formatTime(_lightsOff),
                    style: AppTypography.labelLarge,
                  ),
                  onTap: () => _pickTime(false),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Siesta Period'),
                  subtitle: const Text('Mid-day break to reduce algae'),
                  value: _useSiesta,
                  onChanged: (v) => setState(() => _useSiesta = v),
                ),
                if (_useSiesta) ...[
                  ListTile(
                    leading: const SizedBox(width: AppSpacing.lg),
                    title: const Text('Siesta Start'),
                    trailing: Text(
                      _formatTime(_siestaStart),
                      style: AppTypography.bodyMedium,
                    ),
                    onTap: () => _pickSiestaTime(true),
                  ),
                  ListTile(
                    leading: const SizedBox(width: AppSpacing.lg),
                    title: const Text('Siesta End'),
                    trailing: Text(
                      _formatTime(_siestaEnd),
                      style: AppTypography.bodyMedium,
                    ),
                    onTap: () => _pickSiestaTime(false),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Visual timeline
          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Total Light: ', style: AppTypography.labelLarge),
                    Text(
                      '$_totalLightHours hours',
                      style: AppTypography.headlineSmall.copyWith(
                        color: _totalLightHours > 10
                            ? AppColors.warning
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                _TimelineBar(
                  lightsOn: _lightsOn,
                  lightsOff: _lightsOff,
                  useSiesta: _useSiesta,
                  siestaStart: _siestaStart,
                  siestaEnd: _siestaEnd,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Recommendation
          AppCard(
            backgroundColor: _hasAlgaeIssues
                ? AppOverlays.warning10
                : AppOverlays.success10,
            padding: AppCardPadding.standard,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _hasAlgaeIssues ? Icons.warning : Icons.check_circle,
                  color: _hasAlgaeIssues
                      ? AppColors.warning
                      : AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recommendation', style: AppTypography.labelLarge),
                      const SizedBox(height: AppSpacing.xs),
                      Text(_recommendation, style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Quick Guide', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm2),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              children: const [
                _GuideRow(setup: 'Fish only', hours: '6-10 hours'),
                _GuideRow(setup: 'Low-tech planted', hours: '6-8 hours'),
                _GuideRow(setup: 'High-tech + CO2', hours: '8-10 hours'),
                _GuideRow(setup: 'Fighting algae', hours: '4-6 hours'),
              ],
            ),
          ),

          if (_hasCO2) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              backgroundColor: AppOverlays.info10,
              padding: AppCardPadding.standard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CO2 Timing', style: AppTypography.labelLarge),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    // FB-B1 fix: clamp/modulo hour to valid 0-23 range to prevent TimeOfDay(hour: -1) crash when lights-on is 00:xx
                    '• CO2 ON: ${_formatTime(TimeOfDay(hour: (_lightsOn.hour - 1 + 24) % 24, minute: _lightsOn.minute))} (1hr before lights)',
                    style: AppTypography.bodyMedium,
                  ),
                  Text(
                    // FB-B1 fix: same guard for lights-off hour
                    '• CO2 OFF: ${_formatTime(TimeOfDay(hour: (_lightsOff.hour - 1 + 24) % 24, minute: _lightsOff.minute))} (1hr before lights off)',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This gives CO2 time to dissolve before photosynthesis peaks.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),
      ];

    return Scaffold(
      appBar: AppBar(title: const Text('Lighting Schedule')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemBuilder: (context, index) => items[index],
        itemCount: items.length,
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _pickTime(bool isOn) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isOn ? _lightsOn : _lightsOff,
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        if (isOn) {
          _lightsOn = picked;
        } else {
          _lightsOff = picked;
        }
      });
    }
  }

  Future<void> _pickSiestaTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _siestaStart : _siestaEnd,
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        if (isStart) {
          _siestaStart = picked;
        } else {
          _siestaEnd = picked;
        }
      });
    }
  }
}

class _TimelineBar extends StatelessWidget {
  final TimeOfDay lightsOn;
  final TimeOfDay lightsOff;
  final bool useSiesta;
  final TimeOfDay siestaStart;
  final TimeOfDay siestaEnd;

  const _TimelineBar({
    required this.lightsOn,
    required this.lightsOff,
    required this.useSiesta,
    required this.siestaStart,
    required this.siestaEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 32,
          decoration: BoxDecoration(
            borderRadius: AppRadius.smallRadius,
            color: context.surfaceVariant,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final onPos =
                  (lightsOn.hour * 60 + lightsOn.minute) / (24 * 60) * width;
              final offPos =
                  (lightsOff.hour * 60 + lightsOff.minute) / (24 * 60) * width;

              return Stack(
                children: [
                  // Light period
                  Positioned(
                    left: onPos,
                    width: offPos - onPos,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.warningAlpha60,
                        borderRadius: AppRadius.smallRadius,
                      ),
                    ),
                  ),
                  // Siesta
                  if (useSiesta)
                    Positioned(
                      left:
                          (siestaStart.hour * 60 + siestaStart.minute) /
                          (24 * 60) *
                          width,
                      width:
                          ((siestaEnd.hour * 60 + siestaEnd.minute) -
                              (siestaStart.hour * 60 + siestaStart.minute)) /
                          (24 * 60) *
                          width,
                      top: 0,
                      bottom: 0,
                      child: Container(color: context.surfaceVariant),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('12AM', style: AppTypography.bodySmall),
            Text('6AM', style: AppTypography.bodySmall),
            Text('12PM', style: AppTypography.bodySmall),
            Text('6PM', style: AppTypography.bodySmall),
            Text('12AM', style: AppTypography.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _GuideRow extends StatelessWidget {
  final String setup;
  final String hours;

  const _GuideRow({required this.setup, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(setup, style: AppTypography.bodyMedium)),
          Text(hours, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}

