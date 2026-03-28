import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/storage_provider.dart';
import '../../providers/tank_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/xp_animation_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_feedback.dart';
import '../../utils/haptic_feedback.dart';
import '../../utils/navigation_throttle.dart';
import '../../utils/skeleton_placeholders.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_card.dart';
import '../../widgets/core/app_states.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/mascot/mascot_widgets.dart';
import '../livestock_detail_screen.dart';
import 'livestock_add_dialog.dart';
import 'livestock_bulk_add_dialog.dart';
import 'livestock_card.dart';
import 'livestock_last_fed.dart';
import '../../utils/logger.dart';

const _uuid = Uuid();

/// Main livestock list screen for a tank.
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
            AppButton(
              label: 'Cancel',
              onPressed: _toggleSelectMode,
              variant: AppButtonVariant.text,
              size: AppButtonSize.small,
            )
          else
            PopupMenuButton<String>(
              tooltip: 'Livestock actions',
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
            color: AppColors.primary,
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
                        padding: EdgeInsets.only(
                          top: AppSpacing.md,
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                        ),
                        sliver:
                            SliverToBoxAdapter(child: SizedBox.shrink()),
                      ),

                      // Summary card (when not in select mode)
                      if (!_isSelectMode)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '$totalCount total',
                                            style:
                                                AppTypography.headlineMedium,
                                          ),
                                          Text(
                                            '${livestock.length} species',
                                            style: AppTypography.bodyMedium,
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      FilledButton.icon(
                                        onPressed: () =>
                                            _quickFeed(context, ref),
                                        icon: const Icon(
                                          Icons.restaurant,
                                          size: 18,
                                        ),
                                        label: const Text('Feed'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding:
                                              const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.md,
                                            vertical: AppSpacing.sm,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Last fed info
                                  LivestockLastFedInfo(
                                    tankId: widget.tankId,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (!_isSelectMode)
                        const SliverPadding(
                          padding: EdgeInsets.only(top: AppSpacing.md),
                          sliver:
                              SliverToBoxAdapter(child: SizedBox.shrink()),
                        ),

                      // Selection info banner (when in select mode)
                      if (_isSelectMode)
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: AppCard(
                              backgroundColor: AppOverlays.primary10,
                              padding: AppCardPadding.standard,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.checklist,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.sm2),
                                  Text(
                                    '${_selectedLivestockIds.length} selected',
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_selectedLivestockIds.length <
                                      livestock.length)
                                    AppButton(
                                      label: 'Select All',
                                      onPressed: () {
                                        setState(() {
                                          _selectedLivestockIds.addAll(
                                            livestock.map((l) => l.id),
                                          );
                                        });
                                      },
                                      variant: AppButtonVariant.text,
                                      size: AppButtonSize.small,
                                    )
                                  else
                                    AppButton(
                                      label: 'Clear',
                                      onPressed: () {
                                        setState(() {
                                          _selectedLivestockIds.clear();
                                        });
                                      },
                                      variant: AppButtonVariant.text,
                                      size: AppButtonSize.small,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_isSelectMode)
                        const SliverPadding(
                          padding: EdgeInsets.only(top: AppSpacing.md),
                          sliver:
                              SliverToBoxAdapter(child: SizedBox.shrink()),
                        ),

                      // Livestock list with lazy loading (SliverList.builder)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        sliver: SliverList.builder(
                          itemCount: livestock.length,
                          itemBuilder: (context, index) {
                            final l = livestock[index];
                            final reduceMotion = MediaQuery.of(
                              context,
                            ).disableAnimations;

                            final card = LivestockCard(
                              key: ValueKey(l.id),
                              livestock: l,
                              tank: tank,
                              allLivestock: livestock,
                              isSelectMode: _isSelectMode,
                              isSelected: _selectedLivestockIds.contains(
                                l.id,
                              ),
                              onTap: _isSelectMode
                                  ? () => _toggleLivestockSelection(l.id)
                                  : () => NavigationThrottle.push(
                                      context,
                                      LivestockDetailScreen(
                                        tankId: widget.tankId,
                                        livestock: l,
                                      ),
                                    ),
                              onEdit: () =>
                                  _showEditDialog(context, ref, l),
                              onDelete: () =>
                                  _confirmDelete(context, ref, l),
                            );
                            if (reduceMotion) return card;
                            return card
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: (index * 50).ms,
                                )
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: (index * 50).ms,
                                );
                          },
                        ),
                      ),

                      // Bottom padding
                      const SliverPadding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        sliver:
                            SliverToBoxAdapter(child: SizedBox.shrink()),
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
                          child: AppButton(
                            onPressed: () => _bulkMoveLivestock(
                              context,
                              ref,
                              livestock,
                            ),
                            label: 'Move to Tank',
                            leadingIcon: Icons.move_down,
                            isFullWidth: true,
                            size: AppButtonSize.large,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm2),
                        Expanded(
                          child: AppButton(
                            onPressed: () =>
                                _bulkDelete(context, ref, livestock),
                            variant: AppButtonVariant.destructive,
                            label: 'Delete',
                            leadingIcon: Icons.delete_outline,
                            isFullWidth: true,
                            size: AppButtonSize.large,
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
                  subtitle:
                      Text('${tank.volumeLitres.toStringAsFixed(0)}L'),
                  onTap: () {
                    if (Navigator.canPop(ctx)) Navigator.pop(ctx, tank);
                  },
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
        title: Text('Remove ${_selectedLivestockIds.length} Livestock?'),
        content: Text('Livestock to remove:\n\n$livestockNames'),
        actions: [
          AppButton(
            label: 'Keep',
            onPressed: () {
              if (Navigator.canPop(ctx)) Navigator.pop(ctx, false);
            },
            variant: AppButtonVariant.text,
          ),
          AppButton(
            label: 'Remove Livestock',
            onPressed: () {
              if (Navigator.canPop(ctx)) Navigator.pop(ctx, true);
            },
            variant: AppButtonVariant.destructive,
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final actions = ref.read(tankActionsProvider);
      final deletedIds = List<String>.from(_selectedLivestockIds);
      for (final id in deletedIds) {
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
            duration: kSnackbarDuration,
            action: SnackBarAction(
              label: 'Undo All',
              onPressed: () {
                for (final id in deletedIds) {
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

    try {
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

      final isBoostActive = ref.read(xpBoostActiveProvider);
      await ref
          .read(userProfileProvider.notifier)
          .recordActivity(
            xp: XpRewards.journalEntry,
            xpBoostActive: isBoostActive,
          );
      final effectiveXp = isBoostActive
          ? XpRewards.journalEntry * 2
          : XpRewards.journalEntry;
      if (context.mounted) {
        AppHaptics.success();
        ref.showXpAnimation(effectiveXp);
        AppFeedback.showSuccess(context, 'Feeding logged! \u{1F41F}');
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t log that feeding. Give it another go!',
        );
      }
    }
  }

  Widget _buildSkeletonList() {
    final placeholders = SkeletonPlaceholders.livestockList;
    return IgnorePointer(
      child: Skeletonizer(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: placeholders.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return AppCard(
                padding: AppCardPadding.standard,
                child: Row(
                  children: [
                    Icon(
                      Icons.set_meal,
                      color: AppColors.primary,
                      size: AppIconSizes.lg,
                    ),
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
              final livestock = placeholders[index - 2];
              return LivestockCard(
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
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => LivestockAddDialog(tankId: widget.tankId),
    );
  }

  void _showBulkAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => LivestockBulkAddDialog(tankId: widget.tankId),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    Livestock livestock,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) =>
          LivestockAddDialog(tankId: widget.tankId, existing: livestock),
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

    actions.softDeleteLivestock(
      livestock.id,
      widget.tankId,
      onUndoExpired: () async {
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
        } catch (e) {
          logError(
            'Failed to create livestock-removal log: $e',
            tag: 'LivestockScreen',
          );
        }
      },
    );

    messenger.showSnackBar(
      SnackBar(
        content:
            Text('${livestock.count}× ${livestock.commonName} removed'),
        duration: kSnackbarDuration,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
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
