import 'dart:async';

import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// dart:ui import removed - BackdropFilter replaced with solid overlay (perf: T-D-270)
import '../models/shop_item.dart';
import '../data/shop_catalog.dart';
import '../providers/inventory_provider.dart';
import '../providers/hearts_provider.dart';
import '../providers/room_theme_provider.dart';
import '../providers/room_theme_unlock_provider.dart';
import '../providers/tank_decoration_provider.dart';
import '../services/room_theme_unlock_service.dart';
import '../services/tank_decoration_unlock_service.dart';
import '../models/tank_decoration.dart';
import '../theme/danio_surface_visuals.dart';
import '../theme/room_themes.dart';
import '../widgets/core/bubble_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/core/app_states.dart';
import '../widgets/danio_snack_bar.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import '../utils/logger.dart';

/// Main Inventory Screen - View and USE owned items
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(inventoryProvider.notifier).cleanupExpiredItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryProvider);
    final heartsState = ref.watch(heartsStateProvider);
    final roomVibeStates = ref.watch(roomThemeUnlockStatesProvider);
    final currentRoomTheme = ref.watch(roomThemeProvider);
    final decorationStates = ref.watch(tankDecorationUnlockStatesProvider);
    final equippedDecoration = ref.watch(equippedTankDecorationProvider);

    final gradientColors = (Theme.of(context).brightness == Brightness.dark
        ? [
            DanioColors.inventoryBackground1Dark,
            DanioColors.inventoryBackground2Dark,
            DanioColors.inventoryBackground3Dark,
          ]
        : [
            DanioColors.inventoryBackground1,
            DanioColors.inventoryBackground2,
            DanioColors.inventoryBackground3,
          ]);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: AppElevation.level0,
          title: Text(
            'My Items',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Hearts display
            _HeartsChip(
              currentHearts: heartsState.currentHearts,
              maxHearts: heartsState.maxHearts,
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: DanioColors.topaz,
            labelColor: DanioColors.topaz,
            unselectedLabelColor: AppColors.textSecondaryDark,
            tabs: const [
              Tab(
                icon: Icon(Icons.flash_on, semanticLabel: 'Consumables'),
                text: 'Consumables',
              ),
              Tab(
                icon: Icon(Icons.auto_awesome, semanticLabel: 'Active'),
                text: 'Active',
              ),
              Tab(
                icon: Icon(Icons.star, semanticLabel: 'Permanent'),
                text: 'Permanent',
              ),
            ],
          ),
        ),
        body: inventoryAsync.when(
          loading: () => const Center(child: BubbleLoader()),
          error: (e, _) => AppErrorState(
            title: 'Couldn\'t load your inventory',
            message: 'Please check your connection and try again.',
            onRetry: () => ref.invalidate(inventoryProvider),
          ),
          data: (inventory) {
            // Separate items by type
            final consumables = <InventoryItem>[];
            final activeItems = <InventoryItem>[];
            final permanentItems = <InventoryItem>[];

            for (final item in inventory) {
              final shopItem = ShopCatalog.getById(item.itemId);
              if (shopItem == null || !shopItem.isAvailable) continue;

              if (item.isActive && !item.isExpired) {
                activeItems.add(item);
              } else if (shopItem.isConsumable) {
                consumables.add(item);
              } else {
                permanentItems.add(item);
              }
            }

            return TabBarView(
              controller: _tabController,
              children: [
                _InventoryGrid(
                  items: consumables,
                  emptyTitle: 'No Consumables',
                  emptyMessage: 'Visit the Gem Shop to buy power-ups!',
                  showUseButton: true,
                  onUse: _handleUseItem,
                ),
                _InventoryGrid(
                  items: activeItems,
                  emptyTitle: 'No Active Effects',
                  emptyMessage: 'Use a consumable to activate an effect!',
                  showUseButton: false,
                  showTimer: true,
                ),
                _PermanentInventoryView(
                  items: permanentItems,
                  roomVibeStates: roomVibeStates,
                  currentRoomTheme: currentRoomTheme,
                  onApplyRoomVibe: _handleApplyRoomVibe,
                  decorationStates: decorationStates,
                  equippedDecoration: equippedDecoration,
                  onEquipDecoration: _handleEquipDecoration,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleUseItem(InventoryItem item) async {
    final shopItem = ShopCatalog.getById(item.itemId);
    if (shopItem == null) return;

    // Show confirmation dialog
    final confirmed = await _showUseDialog(shopItem, item);
    if (!confirmed) return;

    // Use the item
    final inventoryNotifier = ref.read(inventoryProvider.notifier);
    final bool success;
    try {
      success = await inventoryNotifier.useItem(item.itemId);
    } catch (e, st) {
      logError(
        'InventoryScreen: failed to use inventory item ${item.itemId}: $e',
        stackTrace: st,
        tag: 'InventoryScreen',
      );
      if (!mounted) return;
      DanioSnackBar.error(context, 'Couldn\'t use that item. Try again.');
      return;
    }

    if (!mounted) return;

    if (success) {
      DanioSnackBar.success(context, _getUseSuccessMessage(shopItem));
    } else {
      DanioSnackBar.error(context, 'Couldn\'t use that item. Try again.');
    }
  }

  Future<void> _handleApplyRoomVibe(RoomThemeType type) async {
    final unlockState = ref.read(roomThemeUnlockStatesProvider)[type];
    if (unlockState != null && !unlockState.isUnlocked) {
      if (!mounted) return;
      DanioSnackBar.info(context, unlockState.requirementLabel);
      return;
    }

    await ref.read(roomThemeProvider.notifier).setTheme(type);
    if (!mounted) return;

    final theme = RoomTheme.fromType(type);
    DanioSnackBar.success(context, '${theme.name} applied to your tank.');
  }

  Future<void> _handleEquipDecoration(TankDecorationType type) async {
    final unlockState = ref.read(tankDecorationUnlockStatesProvider)[type];
    if (unlockState != null && !unlockState.isUnlocked) {
      if (!mounted) return;
      DanioSnackBar.info(context, unlockState.requirementLabel);
      return;
    }

    final current = ref.read(equippedTankDecorationProvider);
    final next = current == type ? null : type;
    final equipped = await ref
        .read(equippedTankDecorationProvider.notifier)
        .equipDecoration(next);
    if (!mounted) return;

    if (!equipped) {
      DanioSnackBar.error(
        context,
        'Couldn\'t update that decoration. Try again.',
      );
      return;
    }

    final definition = TankDecorationDefinition.fromType(type);
    final message = next == null
        ? '${definition.name} returned to storage.'
        : '${definition.name} placed in your tank.';
    DanioSnackBar.success(context, message);
  }

  String _getUseSuccessMessage(ShopItem item) {
    switch (item.type) {
      case ShopItemType.heartsRefill:
        return 'Energy refilled to full!';
      case ShopItemType.streakFreeze:
        return 'Streak freeze activated!';
      case ShopItemType.xpBoost:
        return '2x XP active for 1 hour!';
      case ShopItemType.quizSecondChance:
      case ShopItemType.lessonHelper:
        return 'Item used!';
      case ShopItemType.goalAdjust:
        return 'Goal protection active!';
      default:
        return 'Item used successfully!';
    }
  }

  Future<bool> _showUseDialog(ShopItem shopItem, InventoryItem item) async {
    return await showAppConfirmDialog(
          context: context,
          title: 'Use ${shopItem.name}?',
          message: shopItem.description,
          confirmLabel: 'Use Now',
          cancelLabel: 'Cancel',
        ) ??
        false;
  }
}

class _PermanentInventoryView extends StatelessWidget {
  final List<InventoryItem> items;
  final Map<RoomThemeType, RoomThemeUnlockState> roomVibeStates;
  final RoomThemeType currentRoomTheme;
  final ValueChanged<RoomThemeType> onApplyRoomVibe;
  final Map<TankDecorationType, TankDecorationUnlockState> decorationStates;
  final TankDecorationType? equippedDecoration;
  final ValueChanged<TankDecorationType> onEquipDecoration;

  const _PermanentInventoryView({
    required this.items,
    required this.roomVibeStates,
    required this.currentRoomTheme,
    required this.onApplyRoomVibe,
    required this.decorationStates,
    required this.equippedDecoration,
    required this.onEquipDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final roomVibes = RoomThemeType.values
        .map((type) {
          return roomVibeStates[type] ??
              RoomThemeUnlockState(
                type: type,
                isUnlocked: true,
                requirementLabel: 'Unlocked from the start.',
              );
        })
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _SectionHeader(
          title: 'Room vibes',
          subtitle: 'Earn tank looks from lessons, streaks, and milestones.',
        ),
        const SizedBox(height: AppSpacing.sm2),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final unlockState in roomVibes) ...[
                _RoomVibeCard(
                  unlockState: unlockState,
                  isCurrent: unlockState.type == currentRoomTheme,
                  onApply: onApplyRoomVibe,
                ),
                const SizedBox(width: AppSpacing.sm2),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader(
          title: 'Tank decorations',
          subtitle: 'Place earned keepsakes into your aquarium scene.',
        ),
        const SizedBox(height: AppSpacing.sm2),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final definition in TankDecorationDefinition.all) ...[
                _TankDecorationCard(
                  unlockState:
                      decorationStates[definition.type] ??
                      TankDecorationUnlockState(
                        definition: definition,
                        isUnlocked: true,
                        requirementLabel: 'Unlocked from the start.',
                      ),
                  isEquipped: definition.type == equippedDecoration,
                  onEquip: onEquipDecoration,
                ),
                const SizedBox(width: AppSpacing.sm2),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionHeader(
          title: 'Permanent items',
          subtitle: 'Badges and other earned keepsakes stay here.',
        ),
        const SizedBox(height: AppSpacing.sm2),
        if (items.isEmpty)
          const _PermanentItemsEmptyNote()
        else
          Wrap(
            spacing: AppSpacing.sm2,
            runSpacing: AppSpacing.sm2,
            children: [
              for (final item in items)
                SizedBox(
                  width: 180,
                  height: 210,
                  child: _InventoryItemCard(item: item),
                ),
            ],
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomVibeCard extends StatelessWidget {
  final RoomThemeUnlockState unlockState;
  final bool isCurrent;
  final ValueChanged<RoomThemeType> onApply;

  const _RoomVibeCard({
    required this.unlockState,
    required this.isCurrent,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = RoomTheme.fromType(unlockState.type);
    final isUnlocked = unlockState.isUnlocked;

    return Semantics(
      label: isUnlocked
          ? '${theme.name} room vibe, unlocked'
          : '${theme.name} room vibe, locked. ${unlockState.requirementLabel}',
      button: isUnlocked,
      child: Container(
        key: ValueKey('room-vibe-card-${unlockState.type.name}'),
        width: 206,
        height: 188,
        padding: const EdgeInsets.all(AppSpacing.sm2),
        decoration: BoxDecoration(
          color: AppColors.whiteAlpha15,
          borderRadius: AppRadius.largeRadius,
          border: Border.all(
            color: isCurrent
                ? DanioColors.topaz.withAlpha(220)
                : AppColors.whiteAlpha35,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _RoomVibeSwatch(theme: theme),
                const Spacer(),
                Icon(
                  isUnlocked
                      ? (isCurrent
                            ? Icons.check_circle_rounded
                            : Icons.palette_outlined)
                      : Icons.lock_outline_rounded,
                  color: isUnlocked
                      ? DanioColors.topaz
                      : AppColors.textSecondaryDark,
                  size: AppIconSizes.md,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),
            Text(
              theme.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: Text(
                isUnlocked ? theme.description : unlockState.requirementLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FilledButton.icon(
              key: ValueKey(
                isUnlocked
                    ? 'apply-room-vibe-${unlockState.type.name}'
                    : 'locked-room-vibe-${unlockState.type.name}',
              ),
              onPressed: isUnlocked && !isCurrent
                  ? () => onApply(unlockState.type)
                  : null,
              icon: Icon(
                isCurrent ? Icons.check_rounded : Icons.palette_outlined,
                size: 16,
              ),
              label: Text(
                isCurrent ? 'Applied' : (isUnlocked ? 'Apply' : 'Locked'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TankDecorationCard extends StatelessWidget {
  final TankDecorationUnlockState unlockState;
  final bool isEquipped;
  final ValueChanged<TankDecorationType> onEquip;

  const _TankDecorationCard({
    required this.unlockState,
    required this.isEquipped,
    required this.onEquip,
  });

  @override
  Widget build(BuildContext context) {
    final definition = unlockState.definition;
    final isUnlocked = unlockState.isUnlocked;

    return Semantics(
      label: isUnlocked
          ? '${definition.name} tank decoration, unlocked'
          : '${definition.name} tank decoration, locked. ${unlockState.requirementLabel}',
      button: isUnlocked,
      child: Container(
        key: ValueKey('tank-decoration-card-${definition.type.name}'),
        width: 206,
        height: 188,
        padding: const EdgeInsets.all(AppSpacing.sm2),
        decoration: BoxDecoration(
          color: AppColors.whiteAlpha15,
          borderRadius: AppRadius.largeRadius,
          border: Border.all(
            color: isEquipped
                ? DanioColors.topaz.withAlpha(220)
                : AppColors.whiteAlpha35,
            width: isEquipped ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _DecorationIcon(type: definition.type),
                const Spacer(),
                Icon(
                  isUnlocked
                      ? (isEquipped
                            ? Icons.check_circle_rounded
                            : Icons.spa_outlined)
                      : Icons.lock_outline_rounded,
                  color: isUnlocked
                      ? DanioColors.topaz
                      : AppColors.textSecondaryDark,
                  size: AppIconSizes.md,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),
            Text(
              definition.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xs),
            Expanded(
              child: Text(
                isUnlocked
                    ? definition.description
                    : unlockState.requirementLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondaryDark,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            FilledButton.icon(
              key: ValueKey(
                isUnlocked
                    ? (isEquipped
                          ? 'equipped-tank-decoration-${definition.type.name}'
                          : 'equip-tank-decoration-${definition.type.name}')
                    : 'locked-tank-decoration-${definition.type.name}',
              ),
              onPressed: isUnlocked ? () => onEquip(definition.type) : null,
              icon: Icon(
                isEquipped ? Icons.check_rounded : Icons.add_rounded,
                size: 16,
              ),
              label: Text(
                isEquipped ? 'Placed' : (isUnlocked ? 'Place' : 'Locked'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorationIcon extends StatelessWidget {
  final TankDecorationType type;

  const _DecorationIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = switch (type) {
      TankDecorationType.riverStones => (
        const Color(0xFF8A8173),
        const Color(0xFFD5CCBC),
      ),
      TankDecorationType.driftwoodArch => (
        const Color(0xFF7A5738),
        const Color(0xFF5D8C55),
      ),
      TankDecorationType.mossyHide => (
        const Color(0xFF5F665C),
        const Color(0xFF4C9860),
      ),
      TankDecorationType.ceramicShelter => (
        const Color(0xFFB78368),
        const Color(0xFFE0B078),
      ),
    };

    return Container(
      width: 42,
      height: 32,
      decoration: BoxDecoration(
        color: colors.$1.withAlpha(210),
        borderRadius: AppRadius.smallRadius,
        border: Border.all(color: AppOverlays.black12, width: 0.5),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: colors.$2.withAlpha(220),
            borderRadius: AppRadius.xsRadius,
          ),
        ),
      ),
    );
  }
}

class _RoomVibeSwatch extends StatelessWidget {
  final RoomTheme theme;

  const _RoomVibeSwatch({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SmallColorDot(color: theme.background1),
        _SmallColorDot(color: theme.waterMid),
        _SmallColorDot(color: theme.plantPrimary),
        _SmallColorDot(color: theme.fish1),
      ],
    );
  }
}

class _SmallColorDot extends StatelessWidget {
  final Color color;

  const _SmallColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppOverlays.black12, width: 0.5),
      ),
    );
  }
}

class _PermanentItemsEmptyNote extends StatelessWidget {
  const _PermanentItemsEmptyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.whiteAlpha10,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.whiteAlpha25),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_outlined,
            color: DanioColors.topaz,
            size: AppIconSizes.md,
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Text(
              'Permanent badges and special keepsakes will appear as you earn or buy them.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid of inventory items
class _InventoryGrid extends StatelessWidget {
  final List<InventoryItem> items;
  final String emptyTitle;
  final String emptyMessage;
  final bool showUseButton;
  final bool showTimer;
  final Function(InventoryItem)? onUse;

  const _InventoryGrid({
    required this.items,
    required this.emptyTitle,
    required this.emptyMessage,
    this.showUseButton = false,
    this.showTimer = false,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _InventoryItemCard(
          item: item,
          showUseButton: showUseButton,
          showTimer: showTimer,
          onUse: onUse,
        );
      },
    );
  }
}

/// Individual inventory item card
class _InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final bool showUseButton;
  final bool showTimer;
  final Function(InventoryItem)? onUse;

  const _InventoryItemCard({
    required this.item,
    this.showUseButton = false,
    this.showTimer = false,
    this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final shopItem = ShopCatalog.getById(item.itemId);
    if (shopItem == null) {
      return const SizedBox.shrink();
    }

    final Color accentColor;
    if (item.isActive && !item.isExpired) {
      accentColor = DanioColors.inventoryActive;
    } else if (shopItem.isConsumable) {
      accentColor = DanioColors.inventoryConsumable;
    } else {
      accentColor = DanioColors.inventoryPermanent;
    }

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteAlpha15,
          borderRadius: AppRadius.largeRadius,
          border: Border.all(color: accentColor.withAlpha(128), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with item icon and quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InventoryItemIcon(item: shopItem, color: accentColor),
                  if (item.quantity > 1 || shopItem.isConsumable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: AppRadius.smallRadius,
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Name
              Text(
                shopItem.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              // Description or timer
              Expanded(
                child: showTimer && item.expiresAt != null
                    ? _ExpiryTimer(expiresAt: item.expiresAt!)
                    : Text(
                        shopItem.description,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              // Use button
              if (showUseButton && item.quantity > 0)
                AppButton(
                  label: 'USE',
                  onPressed: () => onUse?.call(item),
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                  size: AppButtonSize.small,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryItemIcon extends StatelessWidget {
  final ShopItem item;
  final Color color;

  const _InventoryItemIcon({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    final visual = danioShopItemVisual(item);

    return Semantics(
      label: '${item.name} icon',
      image: true,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withAlpha(34),
          borderRadius: AppRadius.mediumRadius,
          border: Border.all(color: color.withAlpha(90)),
        ),
        child: Icon(visual.icon, color: visual.color, size: 23),
      ),
    );
  }
}

/// Timer showing time until expiry
class _ExpiryTimer extends StatefulWidget {
  final DateTime expiresAt;

  const _ExpiryTimer({required this.expiresAt});

  @override
  State<_ExpiryTimer> createState() => _ExpiryTimerState();
}

class _ExpiryTimerState extends State<_ExpiryTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.expiresAt.difference(DateTime.now());
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    String timeText;
    if (remaining.isNegative) {
      timeText = 'Expired';
    } else if (hours > 0) {
      timeText = '${hours}h ${minutes}m left';
    } else {
      timeText = '${minutes}m left';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.infoAlpha20,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: DanioColors.inventoryActive,
            size: AppIconSizes.xs,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            timeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hearts display chip
class _HeartsChip extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;

  const _HeartsChip({required this.currentHearts, required this.maxHearts});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: AppOverlays.red20,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.red50, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite,
            color: AppColors.error,
            size: AppIconSizes.sm,
          ),
          const SizedBox(width: AppSpacing.xs2),
          Text(
            '$currentHearts/$maxHearts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
