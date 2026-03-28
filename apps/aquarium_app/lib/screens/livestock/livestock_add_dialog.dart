import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/species_database.dart';
import '../../models/models.dart';
import '../../providers/storage_provider.dart';
import '../../providers/tank_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/xp_animation_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_feedback.dart';
import '../../utils/haptic_feedback.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_text_field.dart';
import 'package:danio/utils/logger.dart';

const _uuid = Uuid();

/// Bottom sheet for adding a new livestock entry or editing an existing one.
/// Pass [existing] to switch into edit mode.
class LivestockAddDialog extends ConsumerStatefulWidget {
  final String tankId;
  final Livestock? existing;

  const LivestockAddDialog({super.key, required this.tankId, this.existing});

  @override
  ConsumerState<LivestockAddDialog> createState() => _LivestockAddDialogState();
}

class _LivestockAddDialogState extends ConsumerState<LivestockAddDialog> {
  late TextEditingController _nameController;
  late TextEditingController _scientificController;
  late TextEditingController _countController;
  bool _isSaving = false;
  List<SpeciesInfo> _suggestions = [];
  SpeciesInfo? _selectedSpecies;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existing?.commonName ?? '',
    );
    _scientificController = TextEditingController(
      text: widget.existing?.scientificName ?? '',
    );
    _countController = TextEditingController(
      text: widget.existing?.count.toString() ?? '1',
    );

    _nameController.addListener(_onNameChanged);

    if (widget.existing != null) {
      _selectedSpecies = SpeciesDatabase.lookup(widget.existing!.commonName);
    }
  }

  void _onNameChanged() {
    final query = _nameController.text.trim();
    if (query.length >= 2) {
      setState(() {
        _suggestions = SpeciesDatabase.search(query).take(5).toList();
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _selectSpecies(SpeciesInfo species) {
    setState(() {
      _selectedSpecies = species;
      _nameController.text = species.commonName;
      _scientificController.text = species.scientificName;
      _suggestions = [];

      if (widget.existing == null && species.minSchoolSize > 1) {
        _countController.text = species.minSchoolSize.toString();
      }
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _scientificController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: max(
                MediaQuery.of(context).viewInsets.bottom,
                MediaQuery.of(context).viewPadding.bottom,
              ) +
              16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing != null ? 'Edit Livestock' : 'Add Livestock',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),

              // Name with autocomplete
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Common Name *',
                  hintText: 'e.g., Neon Tetra',
                  suffixIcon: _selectedSpecies != null
                      ? Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: AppIconSizes.sm,
                        )
                      : null,
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
              ),

              // Suggestions
              if (_suggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: context.surfaceVariant,
                    borderRadius: AppRadius.smallRadius,
                    border: Border.all(color: context.surfaceVariant),
                  ),
                  child: Column(
                    children: _suggestions
                        .map(
                          (species) => ListTile(
                            dense: true,
                            title: Text(species.commonName),
                            subtitle: Text(
                              '${species.scientificName} • ${species.temperament}',
                              style: AppTypography.bodySmall,
                            ),
                            trailing: Text(
                              species.careLevel,
                              style: AppTypography.bodySmall.copyWith(
                                color: _careLevelColor(species.careLevel),
                              ),
                            ),
                            onTap: () => _selectSpecies(species),
                          ),
                        )
                        .toList(),
                  ),
                ),

              // Species info tip
              if (_selectedSpecies != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAlpha05,
                    borderRadius: AppRadius.smallRadius,
                    border: Border.all(color: AppOverlays.primary20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: AppIconSizes.xs,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.xs2),
                          Text(
                            'Species Info',
                            style: AppTypography.labelLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs2),
                      Text(
                        '${_selectedSpecies!.temperament} • ${_selectedSpecies!.adultSizeCm.toStringAsFixed(0)}cm adult • ${_selectedSpecies!.careLevel}',
                        style: AppTypography.bodySmall,
                      ),
                      if (_selectedSpecies!.minSchoolSize > 1)
                        Text(
                          'Schooling fish — keep ${_selectedSpecies!.minSchoolSize}+ together',
                          style: AppTypography.bodySmall.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.sm2),
              TextFormField(
                controller: _scientificController,
                decoration: const InputDecoration(
                  labelText: 'Scientific Name (optional)',
                  hintText: 'e.g., Paracheirodon innesi',
                ),
              ),
              const SizedBox(height: AppSpacing.sm2),
              AppTextField(
                controller: _countController,
                label: 'Count *',
                hint: _selectedSpecies != null &&
                        _selectedSpecies!.minSchoolSize > 1
                    ? 'Recommended: ${_selectedSpecies!.minSchoolSize}+'
                    : 'How many?',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                onPressed: _isSaving ? null : _save,
                label: widget.existing != null ? 'Save' : 'Add',
                isLoading: _isSaving,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _careLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return context.textSecondary;
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final count = int.tryParse(_countController.text) ?? 0;

    if (name.isEmpty) {
      AppFeedback.showWarning(context, 'Please enter a name');
      return;
    }
    if (count <= 0) {
      AppFeedback.showWarning(context, 'Count must be at least 1');
      return;
    }
    if (count > 9999) {
      AppFeedback.showWarning(context, 'Count can\'t exceed 9,999');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = ref.read(storageServiceProvider);
      final now = DateTime.now();

      final livestock = Livestock(
        id: widget.existing?.id ?? _uuid.v4(),
        tankId: widget.tankId,
        commonName: name,
        scientificName: _scientificController.text.trim().isNotEmpty
            ? _scientificController.text.trim()
            : null,
        count: count,
        dateAdded: widget.existing?.dateAdded ?? now,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      await storage.saveLivestock(livestock);

      if (widget.existing == null) {
        await storage.saveLog(
          LogEntry(
            id: _uuid.v4(),
            tankId: widget.tankId,
            type: LogType.livestockAdded,
            timestamp: now,
            title: 'Added ${livestock.count}× ${livestock.commonName}',
            relatedLivestockId: livestock.id,
            createdAt: now,
          ),
        );

        ref.invalidate(logsProvider(widget.tankId));
        ref.invalidate(allLogsProvider(widget.tankId));

        await ref
            .read(userProfileProvider.notifier)
            .recordActivity(xp: XpRewards.addLivestock);

        if (mounted) {
          AppHaptics.success();
          ref.showXpAnimation(XpRewards.addLivestock);
        }
      }

      ref.invalidate(livestockProvider(widget.tankId));

      if (mounted) Navigator.maybePop(context);
    } catch (e) {
      logError('Error saving livestock: $e', tag: 'LivestockAddDialog');
      if (mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t save that. Check your connection and try again.',
          onRetry: _save,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
