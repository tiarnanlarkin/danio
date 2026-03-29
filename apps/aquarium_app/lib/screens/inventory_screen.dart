import 'dart:async';

import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// dart:ui import removed — BackdropFilter replaced with solid overlay (perf: T-D-270)
import '../models/shop_item.dart';
import '../data/shop_catalog.dart';
import '../providers/inventory_provider.dart';
import '../providers/hearts_provider.dart';
import '../widgets/core/bubble_loader.dart';
import '../widgets/empty_state.dart';
import '../widgets/core/app_states.dart';
import '../widgets/mascot/mascot_widgets.dart';
import '../widgets/danio_snack_bar.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';

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

    final gradientColors = (Theme.of(context).brightness == Brightness.dark
        ? [DanioColors.inventoryBackground1Dark, DanioColors.inventoryBackground2Dark, DanioColors.inventoryBackground3Dark]
        : [DanioColors.inventoryBackground1, DanioColors.inventoryBackground2, DanioColors.inventoryBackground3]);

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
            '🎒 My Items',
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
              if (shopItem == null) continue;

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
                _InventoryGrid(
                  items: permanentItems,
                  emptyTitle: 'No Permanent Items',
                  emptyMessage: 'Buy badges and themes from the shop!',
                  showUseButton: false,
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
    final success = await inventoryNotifier.useItem(item.itemId);

    if (!mounted) return;

    if (success) {
      DanioSnackBar.success(context, _getUseSuccessMessage(shopItem));
    } else {
      DanioSnackBar.error(context, 'Couldn\'t use that item — try again.');
    }
  }

  String _getUseSuccessMessage(ShopItem item) {
    switch (item.type) {
      case ShopItemType.heartsRefill:
        return 'Hearts refilled to full! ❤️';
      case ShopItemType.streakFreeze:
        return 'Streak freeze activated! 🧊';
      case ShopItemType.xpBoost:
        return '2x XP active for 1 hour! ⚡';
      case ShopItemType.quizSecondChance:
      case ShopItemType.lessonHelper:
        return 'Item used!';
      case ShopItemType.goalAdjust:
        return 'Goal protection active! 🛡️';
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
      return EmptyState.withMascot(
        icon: Icons.inventory_2_outlined,
        title: emptyTitle,
        message: emptyMessage,
        mascotContext: MascotContext.encouragement,
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
                  // Header row with emoji and quantity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shopItem.emoji,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium!.copyWith(),
                      ),
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
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
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textSecondaryDark),
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
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
          Text('❤️', style: Theme.of(context).textTheme.titleMedium!),
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
