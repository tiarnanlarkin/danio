import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/inventory_provider.dart';
import '../providers/achievement_provider.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import '../services/xp_animation_service.dart';
import '../utils/haptic_feedback.dart';
import '../theme/app_theme.dart';
import '../widgets/celebrations/water_change_celebration.dart';
import '../utils/app_feedback.dart';
import '../widgets/core/app_button.dart';

const _uuid = Uuid();

class AddLogScreen extends ConsumerStatefulWidget {
  final String tankId;
  final LogType initialType;
  final LogEntry? existingLog;

  const AddLogScreen({
    super.key,
    required this.tankId,
    this.initialType = LogType.waterTest,
    this.existingLog,
  });

  @override
  ConsumerState<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends ConsumerState<AddLogScreen> {
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  late LogType _type;
  bool _isSaving = false;
  bool _isPickingImages = false;
  bool _bulkEntryMode = false;

  // Photos
  final List<String> _photoPaths = [];

  // Water test values
  double? _temperature;
  double? _ph;
  double? _ammonia;
  double? _nitrite;
  double? _nitrate;
  double? _gh;
  double? _kh;
  double? _phosphate;

  // Water change
  int? _waterChangePercent;

  // General
  String _notes = '';
  DateTime _timestamp = DateTime.now();

  @override
  void initState() {
    super.initState();

    final existing = widget.existingLog;
    if (existing != null) {
      _type = existing.type;
      _timestamp = existing.timestamp;
      _notes = existing.notes ?? '';
      if (existing.photoUrls != null) {
        _photoPaths.addAll(existing.photoUrls!);
      }

      if (existing.type == LogType.waterTest && existing.waterTest != null) {
        final t = existing.waterTest!;
        _temperature = t.temperature;
        _ph = t.ph;
        _ammonia = t.ammonia;
        _nitrite = t.nitrite;
        _nitrate = t.nitrate;
        _gh = t.gh;
        _kh = t.kh;
        _phosphate = t.phosphate;
      }

      if (existing.type == LogType.waterChange) {
        _waterChangePercent = existing.waterChangePercent;
      }
    } else {
      _type = widget.initialType;
      // Pre-fill last values for new logs
      _loadLastValues();
    }
  }

  Future<void> _loadLastValues() async {
    try {
      final storage = ref.read(storageServiceProvider);
      final logs = await storage.getLogsForTank(widget.tankId);

      // Find the most recent water test
      final lastWaterTest = logs
          .where((l) => l.type == LogType.waterTest && l.waterTest != null)
          .fold<LogEntry?>(null, (prev, curr) {
            if (prev == null) return curr;
            return curr.timestamp.isAfter(prev.timestamp) ? curr : prev;
          });

      if (lastWaterTest != null && lastWaterTest.waterTest != null && mounted) {
        final t = lastWaterTest.waterTest!;
        setState(() {
          _temperature = t.temperature;
          _ph = t.ph;
          _ammonia = t.ammonia;
          _nitrite = t.nitrite;
          _nitrate = t.nitrate;
          _gh = t.gh;
          _kh = t.kh;
          _phosphate = t.phosphate;
        });
      }

      // Pre-fill last water change percentage
      if (_type == LogType.waterChange) {
        final lastWaterChange = logs
            .where(
              (l) =>
                  l.type == LogType.waterChange && l.waterChangePercent != null,
            )
            .fold<LogEntry?>(null, (prev, curr) {
              if (prev == null) return curr;
              return curr.timestamp.isAfter(prev.timestamp) ? curr : prev;
            });

        if (lastWaterChange != null &&
            lastWaterChange.waterChangePercent != null &&
            mounted) {
          setState(() {
            _waterChangePercent = lastWaterChange.waterChangePercent;
          });
        }
      }
    } catch (e) {
      // Silently fail - pre-fill is optional
      debugPrint('Could not pre-fill last values: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.existingLog != null ? 'Edit Log' : _getTitle()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AppButton(
              label: 'Save',
              onPressed: _isSaving ? null : _save,
              isLoading: _isSaving,
              size: AppButtonSize.small,
              variant: AppButtonVariant.primary,
            ),
          ),
        ],
      ),
      body: FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type selector
              _TypeSelector(
                selected: _type,
                onChanged: (type) => setState(() => _type = type),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Type-specific form
              if (_type == LogType.waterTest) _buildWaterTestForm(),
              if (_type == LogType.waterChange) _buildWaterChangeForm(),
              if (_type == LogType.observation) _buildObservationForm(),
              if (_type == LogType.medication) _buildMedicationForm(),

              const SizedBox(height: AppSpacing.lg),

            // Photos
            Text('Photos (optional)', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Attach up to 5 photos to this log.',
                    style: AppTypography.bodySmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: (_isSaving || _isPickingImages)
                      ? null
                      : _pickImages,
                  icon: _isPickingImages
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 18,
                        ),
                  label: const Text('Add'),
                ),
              ],
            ),
            if (_photoPaths.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _PhotoGrid(
                paths: _photoPaths,
                onRemove: (path) => setState(() => _photoPaths.remove(path)),
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // Timestamp
            Text('Date & Time', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _pickDateTime,
              borderRadius: AppRadius.mediumRadius,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm2),
                    Text(
                      '${_timestamp.day}/${_timestamp.month}/${_timestamp.year} at ${_timestamp.hour}:${_timestamp.minute.toString().padLeft(2, '0')}',
                      style: AppTypography.bodyLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          setState(() => _timestamp = DateTime.now()),
                      child: const Text('Now'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Notes (always shown)
            Text('Notes (optional)', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              initialValue: _notes,
              decoration: const InputDecoration(
                hintText: 'Any observations or notes...',
              ),
              maxLines: 3,
              onChanged: (v) => _notes = v,
            ),
          ],
        ),
        ),
      ),
          ),
    ),
    );
  }

  String _getTitle() {
    switch (_type) {
      case LogType.waterTest:
        return 'Log Water Test';
      case LogType.waterChange:
        return 'Log Water Change';
      case LogType.observation:
        return 'Add Observation';
      case LogType.medication:
        return 'Log Medication';
      default:
        return 'Add Log';
    }
  }

  Widget _buildWaterTestForm() {
    final hasPrefilledValues =
        _temperature != null ||
        _ph != null ||
        _ammonia != null ||
        _nitrite != null ||
        _nitrate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Water Parameters', style: AppTypography.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enter the values you tested. Leave blank if not tested.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Bulk entry toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _bulkEntryMode
                    ? AppOverlays.primary10
                    : AppColors.surfaceVariant,
                borderRadius: AppRadius.smallRadius,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.dashboard_outlined,
                    size: AppIconSizes.xs,
                    color: _bulkEntryMode
                        ? AppColors.primary
                        : context.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Quick',
                    style: AppTypography.bodySmall.copyWith(
                      color: _bulkEntryMode
                          ? AppColors.primary
                          : context.textSecondary,
                      fontWeight: _bulkEntryMode
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Switch(
                    value: _bulkEntryMode,
                    onChanged: (v) => setState(() => _bulkEntryMode = v),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ),
          ],
        ),

        // Pre-fill indicator
        if (hasPrefilledValues && widget.existingLog == null) ...[
          const SizedBox(height: AppSpacing.sm2),
          Container(
            padding: EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: AppOverlays.info10,
              borderRadius: AppRadius.smallRadius,
              border: Border.all(color: AppOverlays.accent20),
            ),
            child: Row(
              children: [
                Icon(Icons.history, size: AppIconSizes.xs, color: context.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Pre-filled with last test values',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _temperature = null;
                      _ph = null;
                      _ammonia = null;
                      _nitrite = null;
                      _nitrate = null;
                      _gh = null;
                      _kh = null;
                      _phosphate = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: context.textSecondary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),

        // Bulk entry mode - compact grid
        if (_bulkEntryMode) ...[
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppRadius.mediumRadius,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CompactParamField(
                        label: 'Temp',
                        unit: '°C',
                        value: _temperature,
                        onChanged: (v) => setState(() => _temperature = v),
                        idealRange: '24–27°C',
                        maxValue: 50,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CompactParamField(
                        label: 'pH',
                        value: _ph,
                        onChanged: (v) => setState(() => _ph = v),
                        decimal: true,
                        idealRange: '6.5–7.5',
                        maxValue: 14,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CompactParamField(
                        label: 'NH₃',
                        unit: 'ppm',
                        value: _ammonia,
                        onChanged: (v) => setState(() => _ammonia = v),
                        decimal: true,
                        warningThreshold: 0.25,
                        dangerThreshold: 0.5,
                        idealRange: '0 ppm',
                        maxValue: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                Row(
                  children: [
                    Expanded(
                      child: _CompactParamField(
                        label: 'NO₂',
                        unit: 'ppm',
                        value: _nitrite,
                        onChanged: (v) => setState(() => _nitrite = v),
                        decimal: true,
                        warningThreshold: 0.25,
                        dangerThreshold: 0.5,
                        idealRange: '0 ppm',
                        maxValue: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CompactParamField(
                        label: 'NO₃',
                        unit: 'ppm',
                        value: _nitrate,
                        onChanged: (v) => setState(() => _nitrate = v),
                        warningThreshold: 20,
                        dangerThreshold: 40,
                        idealRange: '<20 ppm',
                        maxValue: 500,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CompactParamField(
                        label: 'GH',
                        unit: 'dGH',
                        value: _gh,
                        onChanged: (v) => setState(() => _gh = v),
                        idealRange: '4–8 dGH',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm2),
                Row(
                  children: [
                    Expanded(
                      child: _CompactParamField(
                        label: 'KH',
                        unit: 'dKH',
                        value: _kh,
                        onChanged: (v) => setState(() => _kh = v),
                        idealRange: '3–8 dKH',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _CompactParamField(
                        label: 'PO₄',
                        unit: 'ppm',
                        value: _phosphate,
                        onChanged: (v) => setState(() => _phosphate = v),
                        decimal: true,
                      ),
                    ),
                    const Expanded(child: SizedBox()), // Spacer for alignment
                  ],
                ),
              ],
            ),
          ),
        ]
        // Standard entry mode - detailed form
        else ...[
          // Temperature & pH row
          Row(
            children: [
              Expanded(
                child: _ParameterField(
                  label: 'Temperature',
                  unit: '°C',
                  value: _temperature,
                  onChanged: (v) => setState(() => _temperature = v),
                  idealRange: 'Ideal: 24–27°C',
                  maxValue: 50,
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: _ParameterField(
                  label: 'pH',
                  value: _ph,
                  onChanged: (v) => setState(() => _ph = v),
                  decimal: true,
                  idealRange: 'Ideal: 6.5–7.5',
                  maxValue: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Nitrogen cycle
          Text('Nitrogen Cycle', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm2),
          Row(
            children: [
              Expanded(
                child: _ParameterField(
                  label: 'Ammonia (NH₃)',
                  unit: 'ppm',
                  value: _ammonia,
                  onChanged: (v) => setState(() => _ammonia = v),
                  warningThreshold: 0.25,
                  dangerThreshold: 0.5,
                  idealRange: 'Ideal: 0 ppm',
                  maxValue: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: _ParameterField(
                  label: 'Nitrite (NO₂)',
                  unit: 'ppm',
                  value: _nitrite,
                  onChanged: (v) => setState(() => _nitrite = v),
                  warningThreshold: 0.25,
                  dangerThreshold: 0.5,
                  idealRange: 'Ideal: 0 ppm',
                  maxValue: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          Row(
            children: [
              Expanded(
                child: _ParameterField(
                  label: 'Nitrate (NO₃)',
                  unit: 'ppm',
                  value: _nitrate,
                  onChanged: (v) => setState(() => _nitrate = v),
                  warningThreshold: 20,
                  dangerThreshold: 40,
                  idealRange: 'Ideal: <20 ppm',
                  maxValue: 500,
                ),
              ),
              const Expanded(child: SizedBox()), // Placeholder for alignment
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Hardness
          Text('Hardness', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm2),
          Row(
            children: [
              Expanded(
                child: _ParameterField(
                  label: 'GH',
                  unit: 'dGH',
                  value: _gh,
                  onChanged: (v) => setState(() => _gh = v),
                  idealRange: 'Ideal: 4–8 dGH',
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: _ParameterField(
                  label: 'KH',
                  unit: 'dKH',
                  value: _kh,
                  onChanged: (v) => setState(() => _kh = v),
                  idealRange: 'Ideal: 3–8 dKH',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // Other
          Text('Other', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.sm2),
          Row(
            children: [
              Expanded(
                child: _ParameterField(
                  label: 'Phosphate (PO₄)',
                  unit: 'ppm',
                  value: _phosphate,
                  onChanged: (v) => setState(() => _phosphate = v),
                  decimal: true,
                  idealRange: 'Ideal: 0–1 ppm',
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildWaterChangeForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Water Change', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.md),

        Text('How much water did you change?', style: AppTypography.bodyMedium),
        const SizedBox(height: AppSpacing.sm2),

        // Preset buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [10, 20, 25, 30, 40, 50].map((percent) {
            final isSelected = _waterChangePercent == percent;
            return ChoiceChip(
              label: Text('$percent%'),
              selected: isSelected,
              onSelected: (_) => setState(() => _waterChangePercent = percent),
              selectedColor: AppOverlays.secondary30,
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.md),

        // Custom input
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _waterChangePercent?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Custom %',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  final value = int.tryParse(v);
                  if (value != null && value > 0 && value <= 100) {
                    setState(() => _waterChangePercent = value);
                  }
                },
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final n = int.tryParse(v);
                    if (n == null || n < 1 || n > 100) return '1-100 only';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildObservationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Observation', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Record anything you notice - fish behavior, algae, plant growth, etc.',
          style: AppTypography.bodyMedium,
        ),
        // Notes field is shown below
      ],
    );
  }

  Widget _buildMedicationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medication', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Record what medication you added and dosage in the notes.',
          style: AppTypography.bodyMedium,
        ),
        // Notes field is shown below
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_timestamp),
      );
      if (time != null && mounted) {
        setState(() {
          _timestamp = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImages() async {
    if (_photoPaths.length >= 5) {
      AppFeedback.showWarning(context, 'Maximum 5 photos per log');
      return;
    }

    setState(() => _isPickingImages = true);

    try {
      final remaining = 5 - _photoPaths.length;
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (picked.isEmpty) return;

      final toAdd = picked.take(remaining);
      final savedPaths = <String>[];
      for (final file in toAdd) {
        savedPaths.add(await _persistPickedImage(file));
      }

      if (!mounted) return;
      setState(() => _photoPaths.addAll(savedPaths));

      if (picked.length > remaining && mounted) {
        AppFeedback.showInfo(context, 'Added $remaining photos (max 5)');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Couldn\'t add photos. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isPickingImages = false);
    }
  }

  Future<String> _persistPickedImage(XFile file) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'photos'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final ext = p.extension(file.path).isNotEmpty
        ? p.extension(file.path)
        : '.jpg';
    final filename = '${_uuid.v4()}$ext';
    final destPath = p.join(dir.path, filename);

    await File(file.path).copy(destPath);
    return destPath;
  }

  Future<void> _save() async {
    // Validate all form fields (range checks on water params)
    if (!(_formKey.currentState?.validate() ?? true)) return;

    // Validate based on type
    if (_type == LogType.waterChange && _waterChangePercent == null) {
      AppFeedback.showWarning(context, 'Please enter water change percentage');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = ref.read(storageServiceProvider);

      final existing = widget.existingLog;

      final log = LogEntry(
        id: existing?.id ?? _uuid.v4(),
        tankId: widget.tankId,
        type: _type,
        timestamp: _timestamp,
        waterTest: _type == LogType.waterTest
            ? WaterTestResults(
                temperature: _temperature,
                ph: _ph,
                ammonia: _ammonia,
                nitrite: _nitrite,
                nitrate: _nitrate,
                gh: _gh,
                kh: _kh,
                phosphate: _phosphate,
              )
            : null,
        waterChangePercent: _type == LogType.waterChange
            ? _waterChangePercent
            : null,
        notes: _notes.isNotEmpty ? _notes : null,
        photoUrls: _photoPaths.isNotEmpty
            ? List.unmodifiable(_photoPaths)
            : null,
        createdAt: existing?.createdAt ?? DateTime.now(),
      );

      await storage.saveLog(log);

      // Schedule water change reminder if this was a water change log
      if (log.type == LogType.waterChange) {
        try {
          final tank = await ref.read(tankProvider(widget.tankId).future);
          final notificationService = NotificationService();
          await notificationService.scheduleWaterChangeReminder(
            tankName: tank?.name ?? 'Your tank',
            daysSinceLastChange: 0, // Just did a water change
          );
        } catch (e) {
          debugPrint('Failed to schedule water change reminder: $e');
        }
      }

      // Invalidate logs providers
      ref.invalidate(logsProvider(widget.tankId));
      ref.invalidate(allLogsProvider(widget.tankId));

      // Engagement: count any log as "activity" (and award small XP).
      final xp = switch (log.type) {
        LogType.waterTest => XpRewards.waterTest,
        LogType.waterChange => XpRewards.waterChange,
        LogType.taskCompleted => XpRewards.taskComplete,
        LogType.observation => XpRewards.journalEntry,
        LogType.medication => XpRewards.journalEntry,
        LogType.feeding => XpRewards.journalEntry,
        LogType.livestockAdded => XpRewards.addLivestock,
        LogType.livestockRemoved => 0,
        LogType.equipmentMaintenance => XpRewards.taskComplete,
        LogType.other => XpRewards.journalEntry,
      };

      final isBoostActive = ref.read(xpBoostActiveProvider);
      final effectiveXp = isBoostActive ? xp * 2 : xp;
      await ref.read(userProfileProvider.notifier).recordActivity(
        xp: xp,
        xpBoostActive: isBoostActive,
      );

      // Show XP animation if XP was awarded
      if (effectiveXp > 0 && mounted) {
        AppHaptics.success();
        ref.showXpAnimation(effectiveXp);
      }

      // Check for achievements after logging activity
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        try {
          final achievementChecker = ref.read(achievementCheckerProvider);

          // Build stats for achievement checking
          final stats = AchievementStats(
            totalXp: profile.totalXp,
            currentStreak: profile.currentStreak,
            hasCompletedPlacementTest: profile.hasCompletedPlacementTest,
            lessonsCompleted: profile.completedLessons.length,
          );

          await achievementChecker.checkAllAchievements(stats: stats);
        } catch (e) {
          // Don't fail the log save if achievement check fails
          debugPrint('Achievement check failed: $e');
        }
      }

      if (mounted) {
        // Show water change celebration on root overlay (survives nav pop)
        if (log.type == LogType.waterChange) {
          final rootOverlay = Overlay.of(context, rootOverlay: true);
          late OverlayEntry celebrationEntry;
          celebrationEntry = OverlayEntry(
            builder: (ctx) => WaterChangeCelebration(
              onComplete: () => celebrationEntry.remove(),
            ),
          );
          rootOverlay.insert(celebrationEntry);
        }
        Navigator.pop(context);
        AppFeedback.showSuccess(context, '${log.typeName} logged! +$effectiveXp XP');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Hmm, couldn\'t save that. Check your connection and try again.',
          onRetry: _save,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _TypeSelector extends StatelessWidget {
  final LogType selected;
  final ValueChanged<LogType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _TypeChip(
            icon: Icons.science,
            label: 'Water Test',
            isSelected: selected == LogType.waterTest,
            onTap: () => onChanged(LogType.waterTest),
          ),
          const SizedBox(width: AppSpacing.sm),
          _TypeChip(
            icon: Icons.water_drop,
            label: 'Water Change',
            isSelected: selected == LogType.waterChange,
            onTap: () => onChanged(LogType.waterChange),
          ),
          const SizedBox(width: AppSpacing.sm),
          _TypeChip(
            icon: Icons.visibility,
            label: 'Observation',
            isSelected: selected == LogType.observation,
            onTap: () => onChanged(LogType.observation),
          ),
          const SizedBox(width: AppSpacing.sm),
          _TypeChip(
            icon: Icons.medication,
            label: 'Medication',
            isSelected: selected == LogType.medication,
            onTap: () => onChanged(LogType.medication),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.largeRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: AppRadius.largeRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : context.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : context.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParameterField extends StatelessWidget {
  final String label;
  final String? unit;
  final double? value;
  final ValueChanged<double?> onChanged;
  final bool decimal;
  final double? warningThreshold;
  final double? dangerThreshold;
  final String? idealRange;
  final double? maxValue;

  const _ParameterField({
    required this.label,
    this.unit,
    required this.value,
    required this.onChanged,
    this.decimal = false,
    this.warningThreshold,
    this.dangerThreshold,
    this.idealRange,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    Color? statusColor;
    if (value != null) {
      if (dangerThreshold != null && value! >= dangerThreshold!) {
        statusColor = AppColors.paramDanger;
      } else if (warningThreshold != null && value! >= warningThreshold!) {
        statusColor = AppColors.paramWarning;
      } else if (warningThreshold != null || dangerThreshold != null) {
        statusColor = AppColors.paramSafe;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            labelText: label,
            suffixText: unit,
            suffixIcon: statusColor != null
                ? Icon(Icons.circle, color: statusColor, size: 12)
                : null,
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
          onChanged: (v) => onChanged(double.tryParse(v)),
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              final n = double.tryParse(v);
              if (n == null) return 'Enter a valid number';
              if (n < 0) return 'Must be ≥ 0';
              if (maxValue != null && n > maxValue!) return 'Max: $maxValue ${unit ?? ''}';
            }
            return null;
          },
        ),
        if (idealRange != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              idealRange!,
              style: AppTypography.bodySmall.copyWith(
                color: context.textHint,
              ),
            ),
          ),
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<String> paths;
  final ValueChanged<String> onRemove;

  const _PhotoGrid({required this.paths, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: paths.map((path) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: AppRadius.mediumRadius,
              child: Image.file(
                File(path),
                width: 96,
                height: 96,
                fit: BoxFit.cover,
                cacheWidth: (96 * MediaQuery.of(context).devicePixelRatio)
                    .round(),
                cacheHeight: (96 * MediaQuery.of(context).devicePixelRatio)
                    .round(),
                errorBuilder: (_, __, ___) => Container(
                  width: 96,
                  height: 96,
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: () => onRemove(path),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppOverlays.black60,
                    borderRadius: AppRadius.pillRadius,
                  ),
                  child: const Icon(Icons.close, size: AppIconSizes.xs, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _CompactParamField extends StatelessWidget {
  final String label;
  final String? unit;
  final double? value;
  final ValueChanged<double?> onChanged;
  final bool decimal;
  final double? warningThreshold;
  final double? dangerThreshold;
  final String? idealRange;
  final double? maxValue;

  const _CompactParamField({
    required this.label,
    this.unit,
    required this.value,
    required this.onChanged,
    this.decimal = false,
    this.warningThreshold,
    this.dangerThreshold,
    this.idealRange,
    this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    Color? statusColor;
    if (value != null) {
      if (dangerThreshold != null && value! >= dangerThreshold!) {
        statusColor = AppColors.paramDanger;
      } else if (warningThreshold != null && value! >= warningThreshold!) {
        statusColor = AppColors.paramWarning;
      } else if (warningThreshold != null || dangerThreshold != null) {
        statusColor = AppColors.paramSafe;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (statusColor != null)
              Icon(Icons.circle, color: statusColor, size: 8),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            hintText: unit ?? '--',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            border: OutlineInputBorder(borderRadius: AppRadius.smallRadius),
          ),
          style: AppTypography.bodySmall.copyWith(),
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          onChanged: (v) => onChanged(double.tryParse(v)),
          validator: (v) {
            if (v != null && v.isNotEmpty) {
              final n = double.tryParse(v);
              if (n == null) return 'Invalid';
              if (n < 0) return '≥ 0';
              if (maxValue != null && n > maxValue!) return '≤ $maxValue';
            }
            return null;
          },
        ),
        if (idealRange != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Text(
              idealRange!,
              style: AppTypography.bodySmall.copyWith(
                color: context.textHint,
              ),
            ),
          ),
      ],
    );
  }
}
