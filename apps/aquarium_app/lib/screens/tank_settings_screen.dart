import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';

class TankSettingsScreen extends ConsumerStatefulWidget {
  final String tankId;

  const TankSettingsScreen({super.key, required this.tankId});

  @override
  ConsumerState<TankSettingsScreen> createState() => _TankSettingsScreenState();
}

class _TankSettingsScreenState extends ConsumerState<TankSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _isSaving = false;

  // Local editable state
  bool _initialized = false;
  late String _name;
  late TankType _type;
  late double _volumeLitres;
  double? _lengthCm;
  double? _widthCm;
  double? _heightCm;
  late DateTime _startDate;
  late String _waterType; // 'tropical' | 'coldwater'
  late String _notes;

  @override
  Widget build(BuildContext context) {
    final tankAsync = ref.watch(tankProvider(widget.tankId));

    return tankAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Tank Settings')),
        body: Center(child: Text('Error: $err')),
      ),
      data: (tank) {
        if (tank == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tank Settings')),
            body: const Center(child: Text('Tank not found')),
          );
        }

        if (!_initialized) {
          _name = tank.name;
          _type = tank.type;
          _volumeLitres = tank.volumeLitres;
          _lengthCm = tank.lengthCm;
          _widthCm = tank.widthCm;
          _heightCm = tank.heightCm;
          _startDate = tank.startDate;
          _notes = tank.notes ?? '';

          // Infer water type for freshwater.
          final tropical = WaterTargets.freshwaterTropical();
          final coldwater = WaterTargets.freshwaterColdwater();
          final isMoreLikeTropical = _closeTo(tank.targets.tempMax, tropical.tempMax) ||
              _closeTo(tank.targets.tempMin, tropical.tempMin);
          final isMoreLikeCold = _closeTo(tank.targets.tempMax, coldwater.tempMax) ||
              _closeTo(tank.targets.tempMin, coldwater.tempMin);
          _waterType = isMoreLikeCold && !isMoreLikeTropical ? 'coldwater' : 'tropical';

          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tank Settings'),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : () => _save(tank),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Basics', style: AppTypography.headlineSmall),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _name,
                  decoration: const InputDecoration(labelText: 'Tank name'),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (v) => _name = v,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Please enter a name';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TankType>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: TankType.freshwater, child: Text('Freshwater')),
                    DropdownMenuItem(value: TankType.marine, child: Text('Marine (coming soon)')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    // Keep MVP simple: prevent switching to marine for now.
                    if (v == TankType.marine) {
                      AppFeedback.showInfo(context, 'Marine is coming soon.');
                      return;
                    }
                    setState(() => _type = v);
                  },
                  decoration: const InputDecoration(labelText: 'Tank type'),
                ),

                const SizedBox(height: 24),
                Text('Size', style: AppTypography.headlineSmall),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _volumeLitres > 0 ? _volumeLitres.toString() : '',
                  decoration: const InputDecoration(labelText: 'Volume', suffixText: 'L'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  onChanged: (v) => _volumeLitres = double.tryParse(v) ?? 0,
                  validator: (v) {
                    final parsed = double.tryParse((v ?? '').trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid volume';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _lengthCm?.toString() ?? '',
                        decoration: const InputDecoration(labelText: 'Length', suffixText: 'cm'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                        onChanged: (v) => _lengthCm = double.tryParse(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _widthCm?.toString() ?? '',
                        decoration: const InputDecoration(labelText: 'Width', suffixText: 'cm'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                        onChanged: (v) => _widthCm = double.tryParse(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: _heightCm?.toString() ?? '',
                        decoration: const InputDecoration(labelText: 'Height', suffixText: 'cm'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                        onChanged: (v) => _heightCm = double.tryParse(v),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text('Water profile', style: AppTypography.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  'This sets target ranges used by Alerts and Charts.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 12),
                if (_type == TankType.freshwater)
                  Column(
                    children: [
                      RadioListTile<String>(
                        value: 'tropical',
                        groupValue: _waterType,
                        onChanged: (v) => setState(() => _waterType = v!),
                        title: const Text('Tropical'),
                        subtitle: const Text('24–28°C • most community fish'),
                      ),
                      RadioListTile<String>(
                        value: 'coldwater',
                        groupValue: _waterType,
                        onChanged: (v) => setState(() => _waterType = v!),
                        title: const Text('Coldwater'),
                        subtitle: const Text('15–22°C • goldfish etc.'),
                      ),
                    ],
                  )
                else
                  const Text('Marine targets not available yet.'),

                const SizedBox(height: 24),
                Text('Start date', style: AppTypography.headlineSmall),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Text(DateFormat('MMM d, yyyy').format(_startDate), style: AppTypography.bodyLarge),
                        const Spacer(),
                        const Icon(Icons.edit, color: AppColors.textHint, size: 18),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text('Notes', style: AppTypography.headlineSmall),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: _notes,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Anything you want to remember about this tank…',
                  ),
                  maxLines: 4,
                  onChanged: (v) => _notes = v,
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 12),
                Text('Danger zone', style: AppTypography.headlineSmall.copyWith(color: AppColors.error)),
                const SizedBox(height: 8),
                Text(
                  'Deleting a tank removes all livestock, equipment, logs, and tasks for it.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: _isSaving ? null : _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete tank'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _closeTo(double? a, double? b, {double epsilon = 0.6}) {
    if (a == null || b == null) return false;
    return (a - b).abs() <= epsilon;
  }

  WaterTargets _selectedTargets() {
    if (_type != TankType.freshwater) return const WaterTargets();
    return _waterType == 'coldwater'
        ? WaterTargets.freshwaterColdwater()
        : WaterTargets.freshwaterTropical();
  }

  Future<void> _save(Tank original) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final actions = ref.read(tankActionsProvider);
      final updated = original.copyWith(
        name: _name.trim(),
        type: _type,
        volumeLitres: _volumeLitres,
        lengthCm: _lengthCm,
        widthCm: _widthCm,
        heightCm: _heightCm,
        startDate: _startDate,
        targets: _selectedTargets(),
        notes: _notes.trim().isEmpty ? null : _notes.trim(),
      );

      await actions.updateTank(updated);
      if (mounted) {
        AppFeedback.showSuccess(context, 'Tank updated.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Failed to update tank. Please try again.',
          onRetry: () => _save(original),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tank?'),
        content: const Text('You\'ll have 5 seconds to undo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Soft delete the tank
    final actions = ref.read(tankActionsProvider);
    actions.softDeleteTank(
      widget.tankId,
      onUndoExpired: () {
        // Tank has been permanently deleted
      },
    );

    // Navigate back to home immediately
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      // Show SnackBar with Undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tank deleted'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              actions.undoDeleteTank(widget.tankId);
            },
          ),
        ),
      );
    }
  }
}
