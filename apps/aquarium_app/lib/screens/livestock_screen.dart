import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../data/species_database.dart';
import '../models/models.dart';
import '../providers/inventory_provider.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/compatibility_service.dart';
import '../services/xp_animation_service.dart';
import '../utils/haptic_feedback.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/skeleton_placeholders.dart';
import '../widgets/core/app_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/core/app_states.dart';
import '../widgets/mascot/mascot_widgets.dart';
import 'livestock_detail_screen.dart';

const _uuid = Uuid();

class LivestockScreen extends ConsumerStatefulWidget {
  final String tankId;

  const LivestockScreen({super.key, required this.tankId});

  @override
  ConsumerState<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends ConsumerState<LivestockScreen> {
  bool _isSelectMode = false;
  final Set<String> _selectedLivestockIds = {};

  void _toggleSelectMode() {
    setState(() {
      _isSelectMode = !_isSelectMode;
      if (!_isSelectMode) {
        _selectedLivestockIds.clear();
      }
    });
  }

  void _toggleLivestockSelection(String livestockId) {
    setState(() {
      if (_selectedLivestockIds.contains(livestockId)) {
        _selectedLivestockIds.remove(livestockId);
      } else {
        _selectedLivestockIds.add(livestockId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final livestockAsync = ref.watch(livestockProvider(widget.tankId));
    final tankAsync = ref.watch(tankProvider(widget.tankId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectMode ? 'Select Livestock' : 'Livestock'),
        actions: [
          if (_isSelectMode)
            TextButton(
              onPressed: _toggleSelectMode,
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            )
          else
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'add') _showAddDialog(context, ref);
                if (value == 'bulk') _showBulkAddDialog(context, ref);
                if (value == 'select') _toggleSelectMode();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'add', child: Text('Add livestock')),
                PopupMenuItem(value: 'bulk', child: Text('Bulk add')),
                PopupMenuItem(value: 'select', child: Text('Select multiple')),
              ],
            ),
        ],
      ),
      body: livestockAsync.when(
        loading: () => _buildSkeletonList(),
        error: (err, _) => AppErrorState(
          title: 'Couldn\'t load your livestock',
          message: 'Check your connection and give it another go',
          onRetry: () => ref.invalidate(livestockProvider(widget.tankId)),
        ),
        data: (livestock) {
          if (livestock.isEmpty) {
            return EmptyState.withMascot(
              icon: Icons.set_meal,
              title: 'Your tank awaits its first residents! 🐠',
              message:
                  "Add your fish, shrimp, or snails -- we'll help you keep them happy and healthy",
              mascotContext: MascotContext.noLivestock,
              actionLabel: 'Add Livestock',
              onAction: () => _showAddDialog(context, ref),
              tips: const [
                'Research compatibility before adding fish',
                'Start with hardy species if you\'re new',
                'Consider schooling fish for active tanks',
                'Track population to avoid overcrowding',
              ],
            );
          }

          final totalCount = livestock.fold<int>(0, (sum, l) => sum + l.count);
          final tank = tankAsync.asData?.value;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(livestockProvider(widget.tankId));
              await Future.delayed(AppDurations.long2);
            },
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                  slivers: [
                    // Header padding
                    const SliverPadding(
                      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                      sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                    ),
                    
                    // Summary card (when not in select mode)
                    if (!_isSelectMode)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        sliver: SliverToBoxAdapter(
                          child: AppCard(
                            padding: AppCardPadding.standard,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.set_meal,
                                      color: AppColors.primary,
                                      size: 32,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$totalCount total',
                                          style: AppTypography.headlineMedium,
                                        ),
                                        Text(
                                          '${livestock.length} species',
                                          style: AppTypography.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    FilledButton.icon(
                                      onPressed: () => _quickFeed(context, ref),
                                      icon: const Icon(Icons.restaurant, size: 18),
                                      label: const Text('Feed'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.sm,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Last fed info
                                _LastFedInfo(tankId: widget.tankId),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (!_isSelectMode)
                      const SliverPadding(
                        padding: EdgeInsets.only(top: AppSpacing.md),
                        sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),

                    // Selection info banner (when in select mode)
                    if (_isSelectMode)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        sliver: SliverToBoxAdapter(
                          child: AppCard(
                            backgroundColor: AppOverlays.primary10,
                            padding: AppCardPadding.standard,
                            child: Row(
                              children: [
                                Icon(Icons.checklist, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text(
                                  '${_selectedLivestockIds.length} selected',
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                if (_selectedLivestockIds.length < livestock.length)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedLivestockIds.addAll(
                                          livestock.map((l) => l.id),
                                        );
                                      });
                                    },
                                    child: const Text('Select All'),
                                  )
                                else
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedLivestockIds.clear();
                                      });
                                    },
                                    child: const Text('Clear'),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (_isSelectMode)
                      const SliverPadding(
                        padding: EdgeInsets.only(top: AppSpacing.md),
                        sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),

                    // Livestock list with lazy loading (SliverList.builder)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      sliver: SliverList.builder(
                        itemCount: livestock.length,
                        itemBuilder: (context, index) {
                          final l = livestock[index];
                          final reduceMotion = MediaQuery.of(context).disableAnimations;
                          
                          return _LivestockCard(
                            livestock: l,
                            tank: tank,
                            allLivestock: livestock,
                            isSelectMode: _isSelectMode,
                            isSelected: _selectedLivestockIds.contains(l.id),
                            onTap: _isSelectMode
                                ? () => _toggleLivestockSelection(l.id)
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LivestockDetailScreen(
                                        tankId: widget.tankId,
                                        livestock: l,
                                      ),
                                    ),
                                  ),
                            onEdit: () => _showEditDialog(context, ref, l),
                            onDelete: () => _confirmDelete(context, ref, l),
                          )
                              .animate(autoPlay: !reduceMotion)
                              .fadeIn(
                                duration: reduceMotion ? 0.ms : 300.ms,
                                delay: reduceMotion ? 0.ms : (index * 50).ms,
                              )
                              .slideY(
                                begin: reduceMotion ? 0 : 0.2,
                                end: 0,
                                duration: reduceMotion ? 0.ms : 300.ms,
                                delay: reduceMotion ? 0.ms : (index * 50).ms,
                              );
                        },
                      ),
                    ),
                    
                    // Bottom padding
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: 16),
                      sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                    ),
                  ],
                ),
              ),

              // Bulk action buttons
              if (_isSelectMode && _selectedLivestockIds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppOverlays.black10,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _bulkMoveLivestock(context, ref, livestock),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.move_down, size: AppIconSizes.sm),
                          label: const Text('Move to Tank'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _bulkDelete(context, ref, livestock),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.delete_outline, size: AppIconSizes.sm),
                          label: const Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            ),
          );
        },
      ),
      floatingActionButton: _isSelectMode
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddDialog(context, ref),
              tooltip: 'Add livestock',
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<void> _bulkMoveLivestock(
    BuildContext context,
    WidgetRef ref,
    List<Livestock> allLivestock,
  ) async {
    final tanksAsync = await ref.read(tanksProvider.future);
    if (!context.mounted) return;
    
    final availableTanks = tanksAsync
        .where((t) => t.id != widget.tankId)
        .toList();

    if (availableTanks.isEmpty) {
      if (context.mounted) {
        AppFeedback.showError(context, 'No other tanks available to move to');
      }
      return;
    }

    final selectedTank = await showDialog<Tank>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Move to Tank'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableTanks
              .map(
                (tank) => ListTile(
                  title: Text(tank.name),
                  subtitle: Text('${tank.volumeLitres.toStringAsFixed(0)}L'),
                  onTap: () => Navigator.pop(ctx, tank),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (selectedTank == null || !context.mounted) return;

    try {
      final actions = ref.read(tankActionsProvider);
      await actions.bulkMoveLivestock(
        _selectedLivestockIds.toList(),
        widget.tankId,
        selectedTank.id,
      );

      if (context.mounted) {
        setState(() {
          _isSelectMode = false;
          _selectedLivestockIds.clear();
        });
        AppFeedback.showSuccess(
          context,
          'Moved ${_selectedLivestockIds.length} livestock to ${selectedTank.name}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t move that right now. Try again!',
        );
      }
    }
  }

  Future<void> _bulkDelete(
    BuildContext context,
    WidgetRef ref,
    List<Livestock> allLivestock,
  ) async {
    final selectedLivestock = allLivestock
        .where((l) => _selectedLivestockIds.contains(l.id))
        .toList();

    final livestockNames = selectedLivestock
        .map((l) => '${l.count}× ${l.commonName}')
        .join(', ');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remove ${_selectedLivestockIds.length} livestock?'),
        content: Text('Livestock to remove:\n\n$livestockNames'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final actions = ref.read(tankActionsProvider);
      for (final id in _selectedLivestockIds) {
        actions.softDeleteLivestock(id, widget.tankId);
      }

      if (context.mounted) {
        setState(() {
          _isSelectMode = false;
          _selectedLivestockIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedLivestock.length} livestock removed'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Undo All',
              onPressed: () {
                for (final id in _selectedLivestockIds) {
                  actions.undoDeleteLivestock(id, widget.tankId);
                }
                AppFeedback.showSuccess(context, 'Livestock restored');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t remove that. Give it another go.',
        );
      }
    }
  }

  Future<void> _quickFeed(BuildContext context, WidgetRef ref) async {
    const uuid = Uuid();
    final storage = ref.read(storageServiceProvider);
    final now = DateTime.now();

    await storage.saveLog(
      LogEntry(
        id: uuid.v4(),
        tankId: widget.tankId,
        type: LogType.feeding,
        timestamp: now,
        title: 'Fed fish',
        createdAt: now,
      ),
    );

    ref.invalidate(logsProvider(widget.tankId));

    // Award XP for feeding
    final isBoostActive = ref.read(xpBoostActiveProvider);
    await ref.read(userProfileProvider.notifier).recordActivity(
      xp: XpRewards.journalEntry,
      xpBoostActive: isBoostActive,
    );
    final effectiveXp = isBoostActive ? XpRewards.journalEntry * 2 : XpRewards.journalEntry;
    if (context.mounted) {
      AppHaptics.success();
      ref.showXpAnimation(effectiveXp);
      AppFeedback.showSuccess(context, 'Feeding logged! \u{1F41F}');
    }
  }

  Widget _buildSkeletonList() {
    final placeholders = SkeletonPlaceholders.livestockList;
    return Skeletonizer(
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: placeholders.length + 2, // +2 for summary card and spacing
        itemBuilder: (context, index) {
          if (index == 0) {
            // Skeleton summary card
            return AppCard(
              padding: AppCardPadding.standard,
              child: Row(
                children: [
                  Icon(Icons.set_meal, color: AppColors.primary, size: AppIconSizes.lg),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('50 total', style: AppTypography.headlineMedium),
                      Text('5 species', style: AppTypography.bodyMedium),
                    ],
                  ),
                ],
              ),
            );
          } else if (index == 1) {
            return const SizedBox(height: AppSpacing.md);
          } else {
            // Skeleton livestock cards
            final livestock = placeholders[index - 2];
            return _LivestockCard(
              livestock: livestock,
              tank: null,
              allLivestock: placeholders,
              onTap: () {},
              onEdit: () {},
              onDelete: () {},
            );
          }
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddLivestockSheet(tankId: widget.tankId, ref: ref),
    );
  }

  void _showBulkAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BulkAddLivestockSheet(tankId: widget.tankId, ref: ref),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Livestock livestock,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddLivestockSheet(
        tankId: widget.tankId,
        ref: ref,
        existing: livestock,
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Livestock livestock,
  ) async {
    final actions = ref.read(tankActionsProvider);
    final storage = ref.read(storageServiceProvider);
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();

    // Soft delete the livestock (marks for deletion, starts 5s timer)
    actions.softDeleteLivestock(
      livestock.id,
      widget.tankId,
      onUndoExpired: () async {
        // Called after 5 seconds if user doesn't undo - log the removal
        try {
          await storage.saveLog(
            LogEntry(
              id: _uuid.v4(),
              tankId: widget.tankId,
              type: LogType.livestockRemoved,
              timestamp: now,
              title: 'Removed ${livestock.count}× ${livestock.commonName}',
              relatedLivestockId: livestock.id,
              createdAt: now,
            ),
          );
          ref.invalidate(logsProvider(widget.tankId));
          ref.invalidate(allLogsProvider(widget.tankId));
        } catch (_) {
          // Silently fail log creation
        }
      },
    );

    // Show SnackBar with undo action (5 seconds)
    messenger.showSnackBar(
      SnackBar(
        content: Text('${livestock.count}× ${livestock.commonName} removed'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Restore the livestock
            actions.undoDeleteLivestock(livestock.id, widget.tankId);
            if (context.mounted) {
              AppFeedback.showSuccess(
                context,
                '${livestock.commonName} restored',
              );
            }
          },
        ),
      ),
    );
  }
}

class _LivestockCard extends StatelessWidget {
  final Livestock livestock;
  final Tank? tank;
  final List<Livestock> allLivestock;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LivestockCard({
    required this.livestock,
    this.tank,
    required this.allLivestock,
    this.isSelectMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Check for species info and compatibility
    final species =
        SpeciesDatabase.lookup(livestock.commonName) ??
        (livestock.scientificName != null
            ? SpeciesDatabase.lookup(livestock.scientificName!)
            : null);

    List<CompatibilityIssue> issues = [];
    if (tank != null) {
      issues = CompatibilityService.checkLivestockCompatibility(
        livestock: livestock,
        tank: tank!,
        existingLivestock: allLivestock,
      );
    }

    final hasIssues = issues.isNotEmpty;
    final level = hasIssues ? CompatibilityService.overallLevel(issues) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected
          ? AppColors.primaryAlpha15
          : (level == CompatibilityLevel.incompatible
                ? AppColors.errorAlpha05
                : (level == CompatibilityLevel.warning
                      ? AppColors.warningAlpha05
                      : null)),
      child: ListTile(
        leading: isSelectMode
            ? Checkbox(value: isSelected, onChanged: (_) => onTap())
            : Stack(
                children: [
                  Hero(
                    tag: 'livestock-${livestock.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: CircleAvatar(
                        backgroundColor: AppOverlays.primary10,
                        child: const Icon(Icons.set_meal, color: AppColors.primary),
                      ),
                    ),
                  ),
                  if (hasIssues)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: level == CompatibilityLevel.incompatible
                              ? AppColors.error
                              : AppColors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          level == CompatibilityLevel.incompatible
                              ? Icons.error
                              : Icons.warning,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
        title: Text(livestock.commonName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (livestock.scientificName != null || species != null)
              Text(
                livestock.scientificName ?? species?.scientificName ?? '',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            Row(
              children: [
                Text('×${livestock.count}', style: AppTypography.bodySmall),
                if (species != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '• ${species.temperament}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ],
            ),
            // Health status chip
            if (livestock.healthStatus != HealthStatus.healthy)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _HealthChip(status: livestock.healthStatus),
              ),
            if (hasIssues && !isSelectMode)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${issues.length} compatibility ${issues.length == 1 ? 'note' : 'notes'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: level == CompatibilityLevel.incompatible
                        ? AppColors.error
                        : AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
        trailing: isSelectMode
            ? null
            : PopupMenuButton(
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('View Details'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Remove')),
                ],
                onSelected: (value) {
                  if (value == 'view') onTap();
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
              ),
        onTap: onTap,
      ),
    );
  }
}

class _AddLivestockSheet extends StatefulWidget {
  final String tankId;
  final WidgetRef ref;
  final Livestock? existing;

  const _AddLivestockSheet({
    required this.tankId,
    required this.ref,
    this.existing,
  });

  @override
  State<_AddLivestockSheet> createState() => _AddLivestockSheetState();
}

class _AddLivestockSheetState extends State<_AddLivestockSheet> {
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

    // Check if existing livestock matches a known species
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

      // Auto-set count to min school size if adding new
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(color: AppColors.surfaceVariant),
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
                        const SizedBox(width: 6),
                        Text('Species Info', style: AppTypography.labelLarge),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selectedSpecies!.temperament} • ${_selectedSpecies!.adultSizeCm.toStringAsFixed(0)}cm adult • ${_selectedSpecies!.careLevel}',
                      style: AppTypography.bodySmall,
                    ),
                    if (_selectedSpecies!.minSchoolSize > 1)
                      Text(
                        'Schooling fish -- keep ${_selectedSpecies!.minSchoolSize}+ together',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            TextFormField(
              controller: _scientificController,
              decoration: const InputDecoration(
                labelText: 'Scientific Name (optional)',
                hintText: 'e.g., Paracheirodon innesi',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countController,
              decoration: InputDecoration(
                labelText: 'Count *',
                hintText:
                    _selectedSpecies != null &&
                        _selectedSpecies!.minSchoolSize > 1
                    ? 'Recommended: ${_selectedSpecies!.minSchoolSize}+'
                    : 'How many?',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.existing != null ? 'Save' : 'Add'),
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
        return AppColors.textSecondary;
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

    setState(() => _isSaving = true);

    try {
      final storage = widget.ref.read(storageServiceProvider);
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

      // If this is a brand new livestock entry, also create a log entry + XP.
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

        widget.ref.invalidate(logsProvider(widget.tankId));
        widget.ref.invalidate(allLogsProvider(widget.tankId));

        await widget.ref
            .read(userProfileProvider.notifier)
            .recordActivity(xp: XpRewards.addLivestock);
        
        // Show XP animation + haptic feedback
        if (mounted) {
          AppHaptics.success();
          widget.ref.showXpAnimation(XpRewards.addLivestock);
        }
      }

      widget.ref.invalidate(livestockProvider(widget.tankId));

      if (mounted) Navigator.pop(context);
    } catch (e) {
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

class _BulkAddLivestockSheet extends StatefulWidget {
  final String tankId;
  final WidgetRef ref;

  const _BulkAddLivestockSheet({required this.tankId, required this.ref});

  @override
  State<_BulkAddLivestockSheet> createState() => _BulkAddLivestockSheetState();
}

class _BulkAddLivestockSheetState extends State<_BulkAddLivestockSheet> {
  final _controller = TextEditingController();
  bool _isSaving = false;
  List<_BulkLivestockItem> _items = const [];
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuildPreview);
    _rebuildPreview();
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuildPreview);
    _controller.dispose();
    super.dispose();
  }

  void _rebuildPreview() {
    final parsed = _parseItems(_controller.text);
    setState(() {
      _items = parsed.items;
      _parseError = parsed.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bulk add livestock', style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'One per line. Formats supported: "Neon Tetra, 10", "10 Neon Tetra", "Neon Tetra x10".',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'List',
                hintText: 'Neon Tetra, 12\nCorydoras x6\n2 Mystery Snail',
                errorText: _parseError,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            if (_items.isNotEmpty) ...[
              Text(
                'Preview (${_items.length})',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._items.map(
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(i.name, style: AppTypography.bodyMedium),
                      ),
                      const SizedBox(width: 12),
                      Text('×${i.count}', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.playlist_add),
              label: Text(
                _isSaving
                    ? 'Adding...'
                    : 'Add ${_items.isEmpty ? '' : '(${_items.length}) '}livestock',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      AppFeedback.showWarning(context, 'Add at least one line to continue');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = widget.ref.read(storageServiceProvider);
      final now = DateTime.now();

      for (final item in _items) {
        final livestock = Livestock(
          id: _uuid.v4(),
          tankId: widget.tankId,
          commonName: item.name,
          scientificName: null,
          count: item.count,
          dateAdded: now,
          createdAt: now,
          updatedAt: now,
        );

        await storage.saveLivestock(livestock);
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
      }

      widget.ref.invalidate(livestockProvider(widget.tankId));
      widget.ref.invalidate(logsProvider(widget.tankId));
      widget.ref.invalidate(allLogsProvider(widget.tankId));

      final totalXp = _items.length * XpRewards.addLivestock;
      await widget.ref
          .read(userProfileProvider.notifier)
          .recordActivity(xp: totalXp);

      // Show XP animation
      if (mounted && totalXp > 0) {
        widget.ref.showXpAnimation(totalXp);
      }

      if (mounted) {
        Navigator.pop(context);
        AppFeedback.showSuccess(
          context,
          'Added ${_items.length} livestock entries',
        );
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t add that right now. Try again!',
          onRetry: _save,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  _ParseResult _parseItems(String raw) {
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final items = <_BulkLivestockItem>[];

    for (final line in lines) {
      final item = _parseLine(line);
      if (item == null) {
        return _ParseResult(items: items, error: 'Could not parse: "$line"');
      }
      items.add(item);
    }

    return _ParseResult(items: items);
  }

  _BulkLivestockItem? _parseLine(String line) {
    // 1) comma format: Name, 10
    if (line.contains(',')) {
      final parts = line.split(',');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final count = int.tryParse(parts.sublist(1).join(',').trim());
        if (name.isNotEmpty && count != null && count > 0) {
          return _BulkLivestockItem(name: name, count: count);
        }
      }
    }

    // 2) Name x10 / Name ×10 / Name x 10
    final mult = RegExp(r'^(.*?)(?:\s*[x×]\s*)(\d+)$', caseSensitive: false);
    final multMatch = mult.firstMatch(line);
    if (multMatch != null) {
      final name = (multMatch.group(1) ?? '').trim();
      final count = int.tryParse(multMatch.group(2) ?? '');
      if (name.isNotEmpty && count != null && count > 0) {
        return _BulkLivestockItem(name: name, count: count);
      }
    }

    // 3) 10 Name
    final leading = RegExp(r'^(\d+)\s+(.*)$');
    final leadingMatch = leading.firstMatch(line);
    if (leadingMatch != null) {
      final count = int.tryParse(leadingMatch.group(1) ?? '');
      final name = (leadingMatch.group(2) ?? '').trim();
      if (name.isNotEmpty && count != null && count > 0) {
        return _BulkLivestockItem(name: name, count: count);
      }
    }

    // 4) fallback: just a name = count 1
    if (line.isNotEmpty) {
      return _BulkLivestockItem(name: line, count: 1);
    }

    return null;
  }
}

class _BulkLivestockItem {
  final String name;
  final int count;

  const _BulkLivestockItem({required this.name, required this.count});
}

class _ParseResult {
  final List<_BulkLivestockItem> items;
  final String? error;

  const _ParseResult({required this.items, this.error});
}



/// Health status chip widget
class _HealthChip extends StatelessWidget {
  final HealthStatus status;
  const _HealthChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, emoji) = switch (status) {
      HealthStatus.healthy => ('Healthy', Colors.green, '\u{1F7E2}'),
      HealthStatus.sick => ('Sick', Colors.orange, '\u{1F7E1}'),
      HealthStatus.quarantine => ('Quarantine', Colors.red, '\u{1F534}'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: AppRadius.md2Radius,
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows "Last fed: X hours ago" based on most recent feeding log
class _LastFedInfo extends ConsumerWidget {
  final String tankId;
  const _LastFedInfo({required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsProvider(tankId));
    return logsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
      data: (logs) {
        final lastFeeding = logs
            .where((l) => l.type == LogType.feeding)
            .toList();
        if (lastFeeding.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              'No feedings logged yet',
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          );
        }
        final last = lastFeeding.first; // logs are sorted newest first
        final diff = DateTime.now().difference(last.timestamp);
        String timeAgo;
        if (diff.inMinutes < 60) {
          timeAgo = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          timeAgo = '${diff.inHours}h ago';
        } else {
          timeAgo = '${diff.inDays}d ago';
        }
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Row(
            children: [
              Icon(Icons.restaurant, size: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text(
                'Last fed: $timeAgo',
                style: AppTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
