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
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_text_field.dart';
import 'package:danio/utils/logger.dart';

const _uuid = Uuid();

class LivestockAddRollbackFailure {
  LivestockAddRollbackFailure({
    required this.phase,
    required this.error,
    required this.stackTrace,
  });

  final String phase;
  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => '$phase failed ($error)';
}

class LivestockAddCompensationException implements Exception {
  LivestockAddCompensationException({
    required this.initiatingError,
    required this.initiatingStackTrace,
    required List<LivestockAddRollbackFailure> rollbackFailures,
    required this.tankId,
    required this.livestockId,
    required this.logId,
  }) : rollbackFailures = List.unmodifiable(rollbackFailures);

  final Object initiatingError;
  final StackTrace initiatingStackTrace;
  final List<LivestockAddRollbackFailure> rollbackFailures;
  final String tankId;
  final String livestockId;
  final String logId;

  @override
  String toString() {
    return 'LivestockAddCompensationException: adding livestock $livestockId '
        'to tank $tankId failed ($initiatingError), and compensation was '
        'incomplete: ${rollbackFailures.join('; ')}. Livestock $livestockId '
        'and activity log $logId may be inconsistent.';
  }
}

/// Bottom sheet for adding a new livestock entry or editing an existing one.
/// Pass [existing] to switch into edit mode.
class LivestockAddDialog extends ConsumerStatefulWidget {
  final String tankId;
  final Livestock? existing;

  /// Optional pre-fill values populated from Fish ID results.
  final String? prefillCommonName;
  final String? prefillScientificName;

  const LivestockAddDialog({
    super.key,
    required this.tankId,
    this.existing,
    this.prefillCommonName,
    this.prefillScientificName,
  });

  @override
  ConsumerState<LivestockAddDialog> createState() => _LivestockAddDialogState();
}

class _LivestockAddDialogState extends ConsumerState<LivestockAddDialog> {
  late TextEditingController _nameController;
  late TextEditingController _scientificController;
  late TextEditingController _countController;
  bool _isSaving = false;
  bool _persistenceUncertain = false;
  List<SpeciesInfo> _suggestions = [];
  SpeciesInfo? _selectedSpecies;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existing?.commonName ?? widget.prefillCommonName ?? '',
    );
    _scientificController = TextEditingController(
      text:
          widget.existing?.scientificName ?? widget.prefillScientificName ?? '',
    );
    _countController = TextEditingController(
      text: widget.existing?.count.toString() ?? '1',
    );

    _nameController.addListener(_onNameChanged);

    if (widget.existing != null) {
      _selectedSpecies = SpeciesDatabase.lookup(widget.existing!.commonName);
    } else if (widget.prefillCommonName != null) {
      // Try to match the pre-filled name against our local species DB.
      _selectedSpecies = SpeciesDatabase.lookup(widget.prefillCommonName!);
      if (_selectedSpecies != null && _selectedSpecies!.minSchoolSize > 1) {
        _countController.text = _selectedSpecies!.minSchoolSize.toString();
      }
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
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom:
              max(
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
                          (species) => Material(
                            type: MaterialType.transparency,
                            child: ListTile(
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
                          Text('Species Info', style: AppTypography.labelLarge),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs2),
                      Text(
                        '${_selectedSpecies!.temperament} • ${_selectedSpecies!.adultSizeCm.toStringAsFixed(0)}cm adult • ${_selectedSpecies!.careLevel}',
                        style: AppTypography.bodySmall,
                      ),
                      if (_selectedSpecies!.minSchoolSize > 1)
                        Text(
                          'Schooling fish - keep ${_selectedSpecies!.minSchoolSize}+ together',
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
                hint:
                    _selectedSpecies != null &&
                        _selectedSpecies!.minSchoolSize > 1
                    ? 'Recommended: ${_selectedSpecies!.minSchoolSize}+'
                    : 'How many?',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                onPressed: _isSaving || _persistenceUncertain ? null : _save,
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
    if (!mounted || _isSaving || _persistenceUncertain) return;

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

    final saveTankId = widget.tankId;
    final container = ProviderScope.containerOf(context, listen: false);
    setState(() => _isSaving = true);

    try {
      final storage = container.read(storageServiceProvider);
      final now = DateTime.now();

      final tank = await storage.getTank(saveTankId);
      if (tank == null) {
        throw StateError('Cannot save livestock for missing tank $saveTankId');
      }

      if (widget.existing != null) {
        final currentLivestock = await storage.getLivestockForTank(saveTankId);
        final stillExists = currentLivestock.any(
          (entry) => entry.id == widget.existing!.id,
        );
        if (!stillExists) {
          throw StateError(
            'Cannot update missing livestock ${widget.existing!.id}.',
          );
        }
      }

      final livestock = Livestock(
        id: widget.existing?.id ?? _uuid.v4(),
        tankId: saveTankId,
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

      var progressUpdated = true;

      if (widget.existing == null) {
        final log = LogEntry(
          id: _uuid.v4(),
          tankId: saveTankId,
          type: LogType.livestockAdded,
          timestamp: now,
          title: 'Added ${livestock.count}x ${livestock.commonName}',
          relatedLivestockId: livestock.id,
          createdAt: now,
        );
        try {
          await storage.saveLog(log);
        } catch (error, stackTrace) {
          final rollbackFailures = <LivestockAddRollbackFailure>[];
          try {
            await storage.deleteLog(log.id);
          } catch (rollbackError, rollbackStack) {
            rollbackFailures.add(
              LivestockAddRollbackFailure(
                phase: 'activity log deletion',
                error: rollbackError,
                stackTrace: rollbackStack,
              ),
            );
            logError(
              'LivestockAddDialog: activity log rollback failed: '
              '$rollbackError',
              stackTrace: rollbackStack,
              tag: 'LivestockAddDialog',
            );
          }
          try {
            await storage.deleteLivestock(livestock.id);
          } catch (rollbackError, rollbackStack) {
            rollbackFailures.add(
              LivestockAddRollbackFailure(
                phase: 'livestock deletion',
                error: rollbackError,
                stackTrace: rollbackStack,
              ),
            );
            logError(
              'LivestockAddDialog: livestock rollback failed: '
              '$rollbackError',
              stackTrace: rollbackStack,
              tag: 'LivestockAddDialog',
            );
          }
          if (rollbackFailures.isNotEmpty) {
            Error.throwWithStackTrace(
              LivestockAddCompensationException(
                initiatingError: error,
                initiatingStackTrace: stackTrace,
                rollbackFailures: rollbackFailures,
                tankId: saveTankId,
                livestockId: livestock.id,
                logId: log.id,
              ),
              stackTrace,
            );
          }
          Error.throwWithStackTrace(error, stackTrace);
        }

        container.invalidate(logsProvider(saveTankId));
        container.invalidate(allLogsProvider(saveTankId));

        try {
          await container
              .read(userProfileProvider.notifier)
              .recordActivity(xp: XpRewards.addLivestock);
        } catch (e, st) {
          progressUpdated = false;
          logError(
            'LivestockAddDialog: profile activity update failed after livestock save: $e',
            stackTrace: st,
            tag: 'LivestockAddDialog',
          );
          container.invalidate(userProfileProvider);
        }

        if (progressUpdated && mounted) {
          ref.showXpAnimation(XpRewards.addLivestock);
        }
      }

      container.invalidate(livestockProvider(saveTankId));

      if (mounted) {
        if (widget.existing != null) {
          AppFeedback.showSuccess(
            context,
            '${livestock.count}x ${livestock.commonName} saved.',
          );
        } else if (progressUpdated) {
          AppFeedback.showSuccess(
            context,
            '${livestock.count}x ${livestock.commonName} added.',
          );
        } else {
          AppFeedback.showWarning(
            context,
            '${livestock.count}x ${livestock.commonName} added, but progress couldn\'t update.',
          );
        }
      }
      if (mounted) Navigator.maybePop(context);
    } catch (e, st) {
      final persistenceUncertain = e is LivestockAddCompensationException;
      logError(
        'LivestockAddDialog: livestock save failed: $e',
        stackTrace: st,
        tag: 'LivestockAddDialog',
      );
      if (persistenceUncertain && mounted) {
        setState(() => _persistenceUncertain = true);
      }
      if (persistenceUncertain) {
        await _reloadLivestockAddAuthority(container, saveTankId);
      } else {
        container.invalidate(livestockProvider(saveTankId));
        container.invalidate(logsProvider(saveTankId));
        container.invalidate(allLogsProvider(saveTankId));
      }
      if (mounted) {
        if (persistenceUncertain) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.clearSnackBars();
          messenger.removeCurrentSnackBar();
          AppFeedback.showWarning(
            context,
            '${count}x $name may already be saved, and its activity history '
            'may be incomplete. Close this form and check your livestock '
            'before trying again.',
          );
        } else {
          AppFeedback.showError(
            context,
            'Couldn\'t save that. Check your connection and try again.',
            onRetry: _save,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _reloadLivestockAddAuthority(
    ProviderContainer container,
    String tankId,
  ) async {
    container.invalidate(tankProvider(tankId));
    container.invalidate(livestockProvider(tankId));
    container.invalidate(logsProvider(tankId));
    container.invalidate(allLogsProvider(tankId));

    try {
      await Future.wait<Object?>([
        container.read(tankProvider(tankId).future),
        container.read(livestockProvider(tankId).future),
        container.read(logsProvider(tankId).future),
        container.read(allLogsProvider(tankId).future),
      ]);
    } catch (e, st) {
      logError(
        'LivestockAddDialog: authoritative add reload failed for tank '
        '$tankId: $e',
        stackTrace: st,
        tag: 'LivestockAddDialog',
      );
    }
  }
}
