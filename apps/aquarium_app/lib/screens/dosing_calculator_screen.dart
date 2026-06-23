import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/log_entry.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/core/app_card.dart';
import 'add_log_screen.dart';

const double _maxDosingReadableWidth = 720;

class DosingCalculatorScreen extends StatefulWidget {
  final String? tankId;
  final double? tankVolumeLitres;

  const DosingCalculatorScreen({super.key, this.tankId, this.tankVolumeLitres});

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

  String? get _validationMessage {
    final volumeText = _volumeController.text.trim();
    final doseText = _dosePerController.text.trim();
    final volume = _tankVolume;
    final dosePer = _dosePer;

    if (volumeText.isNotEmpty && (volume == null || volume <= 0)) {
      return 'Enter a tank volume greater than 0';
    }
    if (doseText.isNotEmpty && (dosePer == null || dosePer <= 0)) {
      return 'Enter a dose amount greater than 0';
    }
    return null;
  }

  double? get _totalDose {
    final volume = _tankVolume;
    final dosePer = _dosePer;
    if (volume == null || dosePer == null) return null;
    if (volume <= 0 || dosePer <= 0) return null;
    return (volume / _dosePerLitres) * dosePer;
  }

  bool get _canLogDose => widget.tankId != null && _totalDose != null;

  String get _doseSummary {
    final totalDose = _totalDose;
    final tankVolume = _tankVolume;
    final dosePer = _dosePer;
    if (totalDose == null || tankVolume == null || dosePer == null) {
      return '';
    }

    return 'Dosing calculation: ${totalDose.toStringAsFixed(2)} ml.\n'
        'Tank volume: ${tankVolume.toStringAsFixed(0)} L.\n'
        'Dose rate: ${dosePer.toStringAsFixed(1)} ml per ${_dosePerLitres.toStringAsFixed(0)} L.\n'
        'Check the product label before adding anything to the tank.';
  }

  void _logDosingNote() {
    final tankId = widget.tankId;
    if (tankId == null || _totalDose == null) return;

    NavigationThrottle.push(
      context,
      AddLogScreen(
        tankId: tankId,
        initialType: LogType.observation,
        initialNotes: _doseSummary,
      ),
      rootNavigator: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Dosing Calculator')),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _DosingReadableFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FB-S4: Medication safety warning banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(
                        color: const Color(0xFFFFCA28),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFF7B5800),
                          size: 22,
                          semanticLabel: 'Safety warning',
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Text(
                            'This calculator is for liquid aquarium products with label directions in ml per volume. Do not use for medications - always follow manufacturer instructions for medication dosing.',
                            style: TextStyle(
                              color: Color(0xFF7B5800),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tank volume
                  Text('Tank Volume', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _volumeController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., 120 litres',
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
                        width: 110,
                        child: DropdownButtonFormField<double>(
                          initialValue: _dosePerLitres,
                          decoration: const InputDecoration(
                            suffixText: 'L',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          items: [5, 10, 20, 25, 38, 40, 50, 100].map((v) {
                            return DropdownMenuItem(
                              value: v.toDouble(),
                              child: Text('$v'),
                            );
                          }).toList(),
                          onChanged: (v) =>
                              setState(() => _dosePerLitres = v ?? 10),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Result
                  if (_validationMessage != null) ...[
                    AppCard(
                      backgroundColor: AppOverlays.error10,
                      padding: AppCardPadding.spacious,
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: AppIconSizes.lg,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _validationMessage!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ] else if (_tankVolume == null || _totalDose == null) ...[
                    AppCard(
                      backgroundColor: AppOverlays.info10,
                      padding: AppCardPadding.spacious,
                      child: Column(
                        children: [
                          Icon(
                            Icons.science_outlined,
                            color: context.textHint,
                            size: AppIconSizes.lg,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Enter your tank volume above to calculate dose',
                            style: AppTypography.bodyMedium.copyWith(
                              color: context.textHint,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
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

                    if (_canLogDose) ...[
                      AppCard(
                        backgroundColor: AppOverlays.info10,
                        padding: AppCardPadding.standard,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.route_outlined,
                                  color: AppColors.info,
                                  size: AppIconSizes.sm,
                                ),
                                const SizedBox(width: AppSpacing.sm2),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Guided next step',
                                        style: AppTypography.labelLarge,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Save this dose as a tank journal note so you can see what was added later.',
                                        style: AppTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FilledButton.icon(
                              onPressed: _logDosingNote,
                              icon: const Icon(Icons.edit_note_rounded),
                              label: const Text('Log this dosing note'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Common liquid products
                    Text(
                      'Common Liquid Products',
                      style: AppTypography.headlineSmall,
                    ),
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
                      per: 38,
                      onTap: () => setState(() {
                        _dosePerController.text = '5';
                        _dosePerLitres = 38;
                      }),
                    ),
                    _ProductPreset(
                      name: 'Tropica Specialised',
                      dose: 6,
                      per: 50,
                      onTap: () => setState(() {
                        _dosePerController.text = '6';
                        _dosePerLitres = 50;
                      }),
                    ),
                    _ProductPreset(
                      name: 'Easy Green (Aquarium Co-Op)',
                      dose: 1,
                      per: 38,
                      onTap: () => setState(() {
                        _dosePerController.text = '1';
                        _dosePerLitres = 38;
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DosingReadableFrame extends StatelessWidget {
  final Widget child;

  const _DosingReadableFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxDosingReadableWidth),
        child: child,
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
