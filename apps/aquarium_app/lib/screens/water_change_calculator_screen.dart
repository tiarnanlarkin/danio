import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class WaterChangeCalculatorScreen extends StatefulWidget {
  const WaterChangeCalculatorScreen({super.key});

  @override
  State<WaterChangeCalculatorScreen> createState() =>
      _WaterChangeCalculatorScreenState();
}

class _WaterChangeCalculatorScreenState
    extends State<WaterChangeCalculatorScreen> {
  final _tankVolumeController = TextEditingController(text: '100');
  final _currentNitrateController = TextEditingController(text: '40');
  final _targetNitrateController = TextEditingController(text: '20');
  final _tapNitrateController = TextEditingController(text: '5');

  double? _changePercent;
  double? _changeVolume;
  String? _recommendation;

  @override
  void dispose() {
    _tankVolumeController.dispose();
    _currentNitrateController.dispose();
    _targetNitrateController.dispose();
    _tapNitrateController.dispose();
    super.dispose();
  }

  void _calculate() {
    final tankVolume = double.tryParse(_tankVolumeController.text);
    final currentNitrate = double.tryParse(_currentNitrateController.text);
    final targetNitrate = double.tryParse(_targetNitrateController.text);
    final tapNitrate = double.tryParse(_tapNitrateController.text) ?? 0;

    if (tankVolume == null || currentNitrate == null || targetNitrate == null) {
      setState(() {
        _changePercent = null;
        _changeVolume = null;
        _recommendation = 'Please fill in all fields';
      });
      return;
    }

    if (currentNitrate <= targetNitrate) {
      setState(() {
        _changePercent = 0;
        _changeVolume = 0;
        _recommendation =
            'Your nitrates are already at or below target! No water change needed.';
      });
      return;
    }

    if (tapNitrate >= targetNitrate) {
      setState(() {
        _changePercent = null;
        _changeVolume = null;
        _recommendation =
            'Your tap water nitrate (${tapNitrate.toStringAsFixed(0)} ppm) is higher than your target. '
            'Consider using RO water or a nitrate-removing filter.';
      });
      return;
    }

    // Formula: changePercent = (current - target) / (current - tap)
    final changePercent =
        ((currentNitrate - targetNitrate) / (currentNitrate - tapNitrate)) *
        100;
    final changeVolume = tankVolume * (changePercent / 100);

    String recommendation;
    if (changePercent > 50) {
      recommendation =
          'This requires a large water change (${changePercent.toStringAsFixed(0)}%). '
          'Consider splitting into 2-3 smaller changes over a few days to reduce stress.';
    } else if (changePercent > 30) {
      recommendation =
          'A ${changePercent.toStringAsFixed(0)}% water change should do the trick. '
          'Make sure new water is temperature-matched and dechlorinated.';
    } else {
      recommendation =
          'A modest ${changePercent.toStringAsFixed(0)}% change will bring nitrates to target. '
          'This is a routine maintenance level.';
    }

    setState(() {
      _changePercent = changePercent;
      _changeVolume = changeVolume;
      _recommendation = recommendation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Change Calculator')),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.standard,
            child: Row(
              children: [
                Icon(Icons.calculate, size: AppIconSizes.lg, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Calculate exactly how much water to change to reach your target nitrate level.',
                    style: AppTypography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Tank Info', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),

          TextField(
            controller: _tankVolumeController,
            decoration: const InputDecoration(
              labelText: 'Tank Volume',
              suffixText: 'litres',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _calculate(),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Nitrate Levels', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),

          TextField(
            controller: _currentNitrateController,
            decoration: const InputDecoration(
              labelText: 'Current Nitrate',
              suffixText: 'ppm',
              border: OutlineInputBorder(),
              helperText: 'What your test kit shows now',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _calculate(),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _targetNitrateController,
            decoration: const InputDecoration(
              labelText: 'Target Nitrate',
              suffixText: 'ppm',
              border: OutlineInputBorder(),
              helperText: 'Usually 10-20 ppm for most tanks',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _calculate(),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _tapNitrateController,
            decoration: const InputDecoration(
              labelText: 'Tap Water Nitrate',
              suffixText: 'ppm',
              border: OutlineInputBorder(),
              helperText: 'Test your tap water! Often 0-10 ppm',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => _calculate(),
          ),

          const SizedBox(height: AppSpacing.lg),

          if (_changePercent != null && _changeVolume != null) ...[
            AppCard(
              backgroundColor: AppOverlays.success10,
              padding: AppCardPadding.spacious,
              child: Column(
                children: [
                  Text(
                    'Water Change Needed',
                    style: AppTypography.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${_changePercent!.toStringAsFixed(0)}%',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text('of tank', style: AppTypography.bodySmall),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.textHint,
                      ),
                      Column(
                        children: [
                          Text(
                            '${_changeVolume!.toStringAsFixed(0)}L',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text('to remove', style: AppTypography.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (_recommendation != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: AppCardPadding.standard,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb, color: AppColors.warning, size: AppIconSizes.sm),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _recommendation!,
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          Text('Quick Reference', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RefRow(label: 'Ideal nitrate', value: '< 20 ppm'),
                _RefRow(label: 'Acceptable', value: '20-40 ppm'),
                _RefRow(label: 'High (act soon)', value: '40-80 ppm'),
                _RefRow(label: 'Dangerous', value: '> 80 ppm'),
                const Divider(height: 24),
                Text(
                  'Tip: Regular 20-25% weekly water changes usually keep nitrates in check without needing to calculate.',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text('Multi-Change Strategy', style: AppTypography.headlineSmall),
          const SizedBox(height: 12),

          AppCard(
            padding: AppCardPadding.standard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For very high nitrates (>60 ppm), don\'t do one massive change. Instead:',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 12),
                _StepRow(num: 1, text: 'Day 1: 30% water change'),
                _StepRow(num: 2, text: 'Day 3: 25% water change'),
                _StepRow(num: 3, text: 'Day 5: 20% water change'),
                _StepRow(num: 4, text: 'Test and repeat if needed'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This gradual approach prevents osmotic shock to fish.',
                  style: AppTypography.bodySmall.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class _RefRow extends StatelessWidget {
  final String label;
  final String value;

  const _RefRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int num;
  final String text;

  const _StepRow({required this.num, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$num',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }
}
