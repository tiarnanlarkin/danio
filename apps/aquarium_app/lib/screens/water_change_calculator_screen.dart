import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class WaterChangeCalculatorScreen extends StatefulWidget {
  final double? tankVolumeLitres;

  const WaterChangeCalculatorScreen({super.key, this.tankVolumeLitres});

  @override
  State<WaterChangeCalculatorScreen> createState() => _WaterChangeCalculatorScreenState();
}

class _WaterChangeCalculatorScreenState extends State<WaterChangeCalculatorScreen> {
  late TextEditingController _volumeController;
  double _percentage = 25;

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController(
      text: widget.tankVolumeLitres?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _volumeController.dispose();
    super.dispose();
  }

  double? get _tankVolume => double.tryParse(_volumeController.text);

  double? get _waterToChange {
    final volume = _tankVolume;
    if (volume == null) return null;
    return volume * (_percentage / 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Change Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tank volume input
            Text('Tank Volume', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            TextFormField(
              controller: _volumeController,
              decoration: const InputDecoration(
                hintText: 'Enter tank volume',
                suffixText: 'L',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 24),

            // Percentage slider
            Text('Water Change Percentage', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _percentage,
                    min: 5,
                    max: 90,
                    divisions: 17,
                    label: '${_percentage.toStringAsFixed(0)}%',
                    onChanged: (value) => setState(() => _percentage = value),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${_percentage.toStringAsFixed(0)}%',
                    style: AppTypography.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),

            // Quick presets
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [10, 20, 25, 30, 50].map((p) {
                return ChoiceChip(
                  label: Text('$p%'),
                  selected: _percentage == p,
                  onSelected: (_) => setState(() => _percentage = p.toDouble()),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Result card
            if (_tankVolume != null && _waterToChange != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop, color: AppColors.secondary, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            '${_waterToChange!.toStringAsFixed(1)} L',
                            style: AppTypography.headlineLarge.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Water to remove/replace',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _ResultRow(
                        label: 'Tank volume',
                        value: '${_tankVolume!.toStringAsFixed(0)} L',
                      ),
                      _ResultRow(
                        label: 'Change percentage',
                        value: '${_percentage.toStringAsFixed(0)}%',
                      ),
                      _ResultRow(
                        label: 'Remaining water',
                        value: '${(_tankVolume! - _waterToChange!).toStringAsFixed(1)} L',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tips
              Card(
                color: AppColors.info.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppColors.info, size: 20),
                          const SizedBox(width: 8),
                          Text('Tips', style: AppTypography.labelLarge.copyWith(color: AppColors.info)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _TipItem(text: 'Match temperature of new water to tank (±2°C)'),
                      _TipItem(text: 'Use dechlorinator for tap water'),
                      _TipItem(text: '10-25% weekly is typical for most tanks'),
                      _TipItem(text: 'Larger changes (50%+) for emergencies only'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.calculate_outlined, size: 48, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        Text(
                          'Enter your tank volume to calculate',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTypography.bodySmall),
          Expanded(child: Text(text, style: AppTypography.bodySmall)),
        ],
      ),
    );
  }
}
