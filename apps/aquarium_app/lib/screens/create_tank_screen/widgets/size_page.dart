import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/accessibility_utils.dart';

/// Second page of tank creation — volume and dimensions.
class SizePage extends StatefulWidget {
  final double volumeLitres;
  final double? lengthCm;
  final double? widthCm;
  final double? heightCm;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double?> onLengthChanged;
  final ValueChanged<double?> onWidthChanged;
  final ValueChanged<double?> onHeightChanged;

  const SizePage({
    super.key,
    required this.volumeLitres,
    this.lengthCm,
    this.widthCm,
    this.heightCm,
    required this.onVolumeChanged,
    required this.onLengthChanged,
    required this.onWidthChanged,
    required this.onHeightChanged,
  });

  @override
  State<SizePage> createState() => _SizePageState();
}

class _SizePageState extends State<SizePage> {
  late TextEditingController _volumeController;
  bool _disposed = false;

  static String _formatVolume(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void initState() {
    super.initState();
    _volumeController = TextEditingController(
      text: widget.volumeLitres > 0 ? _formatVolume(widget.volumeLitres) : '',
    );
  }

  @override
  void didUpdateWidget(SizePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_disposed) return;
    try {
      final currentText = _volumeController.text;
      final newText = widget.volumeLitres > 0
          ? _formatVolume(widget.volumeLitres)
          : '';
      if (currentText != newText &&
          double.tryParse(currentText) != widget.volumeLitres) {
        _volumeController.text = newText;
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _volumeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text('Tank size', style: AppTypography.headlineMedium),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter the volume, or we can calculate it from dimensions.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Volume input
          FocusTraversalOrder(
            order: const NumericFocusOrder(1.0),
            child: Semantics(
              label: A11yLabels.textField('Volume in litres', required: true),
              textField: true,
              child: TextFormField(
                controller: _volumeController,
                decoration: const InputDecoration(
                  labelText: 'Volume (litres)',
                  hintText: 'e.g., 120',
                  suffixText: 'L',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                onChanged: (v) {
                  final value = double.tryParse(v);
                  if (value != null) widget.onVolumeChanged(value);
                },
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter a volume';
                  final n = double.tryParse(v);
                  if (n == null || n < 1) {
                    return 'Minimum tank volume is 1 litre';
                  }
                  if (n > 10000) return 'Maximum 10,000 litres';
                  return null;
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Semantics(
            header: true,
            child: Text(
              'Dimensions (optional)',
              style: AppTypography.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Useful for stocking recommendations.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(2.0),
                  child: Semantics(
                    label: A11yLabels.textField('Length in centimeters'),
                    textField: true,
                    child: TextFormField(
                      initialValue: widget.lengthCm?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Length',
                        suffixText: 'cm',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (v) =>
                          widget.onLengthChanged(double.tryParse(v)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(3.0),
                  child: Semantics(
                    label: A11yLabels.textField('Width in centimeters'),
                    textField: true,
                    child: TextFormField(
                      initialValue: widget.widthCm?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Width',
                        suffixText: 'cm',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (v) =>
                          widget.onWidthChanged(double.tryParse(v)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(4.0),
                  child: Semantics(
                    label: A11yLabels.textField('Height in centimeters'),
                    textField: true,
                    child: TextFormField(
                      initialValue: widget.heightCm?.toString() ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Height',
                        suffixText: 'cm',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                      ],
                      onChanged: (v) =>
                          widget.onHeightChanged(double.tryParse(v)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Quick size presets
          const SizedBox(height: AppSpacing.lg),
          Text('Quick presets', style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SizePreset(
                label: '20L',
                onTap: () => widget.onVolumeChanged(20),
              ),
              _SizePreset(
                label: '60L',
                onTap: () => widget.onVolumeChanged(60),
              ),
              _SizePreset(
                label: '120L',
                onTap: () => widget.onVolumeChanged(120),
              ),
              _SizePreset(
                label: '200L',
                onTap: () => widget.onVolumeChanged(200),
              ),
              _SizePreset(
                label: '300L',
                onTap: () => widget.onVolumeChanged(300),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SizePreset extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SizePreset({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: A11yLabels.button('Set volume to $label'),
      button: true,
      child: ActionChip(label: Text(label), onPressed: onTap),
    );
  }
}
