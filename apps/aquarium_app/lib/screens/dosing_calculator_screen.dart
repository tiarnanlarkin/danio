import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class DosingCalculatorScreen extends StatefulWidget {
  final double? tankVolumeLitres;

  const DosingCalculatorScreen({super.key, this.tankVolumeLitres});

  @override
  State<DosingCalculatorScreen> createState() => _DosingCalculatorScreenState();
}

class _DosingCalculatorScreenState extends State<DosingCalculatorScreen> {
  late TextEditingController _volumeController;
  late TextEditingController _dosePerController;
  double _dosePerLitres = 10; // Default: dose per 10L

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController(
      text: widget.tankVolumeLitres?.toStringAsFixed(0) ?? '',
    );
    _dosePerController = TextEditingController(text: '1');
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _dosePerController.dispose();
    super.dispose();
  }

  double? get _tankVolume => double.tryParse(_volumeController.text);
  double? get _dosePer => double.tryParse(_dosePerController.text);

  double? get _totalDose {
    final volume = _tankVolume;
    final dosePer = _dosePer;
    if (volume == null || dosePer == null) return null;
    return (volume / _dosePerLitres) * dosePer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dosing Calculator')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tank volume
            Text('Tank Volume', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _volumeController,
              decoration: const InputDecoration(
                hintText: 'Enter tank volume',
                suffixText: 'L',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Dose per X litres
            Text('Recommended Dose', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dosePerController,
                    decoration: const InputDecoration(
                      hintText: 'Amount',
                      suffixText: 'ml',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                const Text('per'),
                const SizedBox(width: AppSpacing.sm2),
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<double>(
                    value: _dosePerLitres,
                    decoration: const InputDecoration(
                      suffixText: 'L',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: [5, 10, 20, 25, 40, 50, 100].map((v) {
                      return DropdownMenuItem(
                        value: v.toDouble(),
                        child: Text('$v'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _dosePerLitres = v ?? 10),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Result
            if (_tankVolume != null && _totalDose != null) ...[
              AppCard(
                padding: AppCardPadding.spacious,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.science,
                          color: AppColors.primary,
                          size: 32,
                        ),
                        const SizedBox(width: AppSpacing.sm2),
                        Text(
                          '${_totalDose!.toStringAsFixed(2)} ml',
                          style: AppTypography.headlineLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Total dose for your tank',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    _ResultRow(
                      label: 'Tank volume',
                      value: '${_tankVolume!.toStringAsFixed(0)} L',
                    ),
                    _ResultRow(
                      label: 'Dose rate',
                      value:
                          '${_dosePer!.toStringAsFixed(1)} ml per ${_dosePerLitres.toStringAsFixed(0)} L',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Common products
              Text('Common Products', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm2),
              _ProductPreset(
                name: 'Seachem Prime',
                dose: 5,
                per: 200,
                onTap: () => setState(() {
                  _dosePerController.text = '5';
                  _dosePerLitres = 200;
                }),
              ),
              _ProductPreset(
                name: 'Seachem Stability',
                dose: 5,
                per: 40,
                onTap: () => setState(() {
                  _dosePerController.text = '5';
                  _dosePerLitres = 40;
                }),
              ),
              _ProductPreset(
                name: 'API Stress Coat',
                dose: 5,
                per: 40,
                onTap: () => setState(() {
                  _dosePerController.text = '5';
                  _dosePerLitres = 40;
                }),
              ),
              _ProductPreset(
                name: 'Tropica Specialised',
                dose: 1,
                per: 25,
                onTap: () => setState(() {
                  _dosePerController.text = '1';
                  _dosePerLitres = 25;
                }),
              ),
              _ProductPreset(
                name: 'Easy Green (Aquarium Co-Op)',
                dose: 1,
                per: 10,
                onTap: () => setState(() {
                  _dosePerController.text = '1';
                  _dosePerLitres = 10;
                }),
              ),
            ] else ...[
              AppCard(
                padding: AppCardPadding.spacious,
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: AppIconSizes.xl,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Enter values to calculate dose',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
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

class _ProductPreset extends StatelessWidget {
  final String name;
  final double dose;
  final double per;
  final VoidCallback onTap;

  const _ProductPreset({
    required this.name,
    required this.dose,
    required this.per,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: AppCardPadding.none,
        onTap: onTap,
        child: ListTile(
          title: Text(name),
          subtitle: Text(
            '${dose.toStringAsFixed(0)} ml per ${per.toStringAsFixed(0)} L',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: AppIconSizes.xs),
        ),
      ),
    );
  }
}
