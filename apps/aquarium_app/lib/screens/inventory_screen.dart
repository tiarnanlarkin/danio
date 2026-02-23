import 'package:aquarium_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../models/shop_item.dart';
import '../data/shop_catalog.dart';
import '../providers/inventory_provider.dart';
import '../providers/hearts_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/core/app_states.dart';
import '../widgets/mascot/mascot_widgets.dart';

/// Inventory colors - warm treasure chest theme
/// Adapts slightly for dark mode to maintain readability
class InventoryColors {
  InventoryColors._();

  // Light/default theme colors
  static const background1 = Color(0xFF2D1B4E); // Deep purple
  static const background2 = Color(0xFF1F1337); // Darker purple
  static const background3 = Color(0xFF150D26); // Deepest purple
  static const goldAccent = Color(0xFFFFD700); // Gold
  static const consumableColor = Color(0xFF4CAF50); // Green for consumables
  static const activeColor = Color(0xFF2196F3); // Blue for active items
  static const activeColorAlpha20 = Color(0x332196F3); // 20%
  static const permanentColor = Color(0xFFE91E63); // Pink for permanent items
  static const glassCard = Color(0x15FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFB8B8D8);

  // Dark mode adjustments — lighter/desaturated gradients for readability
  static const background1Dark = Color(0xFF3A2660); // Lighter purple
  static const background2Dark = Color(0xFF2A1C48); // Lighter mid
  static const background3Dark = Color(0xFF1E1435); // Lighter base

  /// Returns gradient colors adapted to current brightness
  static List<Color> gradientColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? [background1Dark, background2Dark, background3Dark]
        : [background1, background2, background3];
  }
}

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

    final gradientColors = InventoryColors.gradientColors(context);

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
          title: const Text(
            '🎒 My Items',
            style: TextStyle(
              color: InventoryColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
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
            indicatorColor: InventoryColors.goldAccent,
            labelColor: InventoryColors.goldAccent,
            unselectedLabelColor: InventoryColors.textSecondary,
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
          loading: () => const Center(
            child: CircularProgressIndicator(color: InventoryColors.goldAccent),
          ),
          error: (e, _) => AppErrorState(
            title: 'Failed to load inventory',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(shopItem.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getUseSuccessMessage(shopItem),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to use item'),
          backgroundColor: Colors.red,
        ),
      );
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
        return 'Quiz retry ready! 🎯';
      case ShopItemType.lessonHelper:
        return 'Lesson helper activated! 💡';
      case ShopItemType.goalAdjust:
        return 'Goal protection active! 🛡️';
      default:
        return 'Item used successfully!';
    }
  }

  Future<bool> _showUseDialog(ShopItem shopItem, InventoryItem item) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? InventoryColors.background2Dark
                  : InventoryColors.background2,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.largeRadius,
                side: const BorderSide(color: InventoryColors.glassBorder),
              ),
              title: Row(
                children: [
                  Text(shopItem.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Use ${shopItem.name}?',
                      style: const TextStyle(
                        color: InventoryColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shopItem.description,
                    style: const TextStyle(
                      color: InventoryColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm2),
                    decoration: BoxDecoration(
                      color: InventoryColors.glassCard,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'You have:',
                          style: TextStyle(
                            color: InventoryColors.textSecondary,
                          ),
                        ),
                        Text(
                          'x${item.quantity}',
                          style: const TextStyle(
                            color: InventoryColors.goldAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: InventoryColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: InventoryColors.consumableColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mediumRadius,
                    ),
                  ),
                  child: const Text(
                    'Use Now',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      accentColor = InventoryColors.activeColor;
    } else if (shopItem.isConsumable) {
      accentColor = InventoryColors.consumableColor;
    } else {
      accentColor = InventoryColors.permanentColor;
    }

    return ClipRRect(
      borderRadius: AppRadius.largeRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: InventoryColors.glassCard,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(
              color: accentColor.withAlpha(128),
              width: 2,
            ),
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
                      style: const TextStyle(fontSize: 40),
                    ),
                    if (item.quantity > 1 || shopItem.isConsumable)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: AppRadius.smallRadius,
                        ),
                        child: Text(
                          'x${item.quantity}',
                          style: const TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 12,
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
                  style: const TextStyle(
                    color: InventoryColors.textPrimary,
                    fontSize: 14,
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
                          style: const TextStyle(
                            color: InventoryColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                // Use button
                if (showUseButton && item.quantity > 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => onUse?.call(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smallRadius,
                        ),
                      ),
                      child: const Text(
                        'USE',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Timer showing time until expiry
class _ExpiryTimer extends StatelessWidget {
  final DateTime expiresAt;

  const _ExpiryTimer({required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final remaining = expiresAt.difference(DateTime.now());
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: InventoryColors.activeColorAlpha20,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: InventoryColors.activeColor,
            size: AppIconSizes.xs,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            timeText,
            style: const TextStyle(
              color: InventoryColors.activeColor,
              fontSize: 12,
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

  const _HeartsChip({
    required this.currentHearts,
    required this.maxHearts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppOverlays.red20,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: AppOverlays.red50,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('❤️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '$currentHearts/$maxHearts',
            style: const TextStyle(
              color: InventoryColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
