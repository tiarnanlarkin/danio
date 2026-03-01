import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui';
import '../models/shop_item.dart';
import '../models/purchase_result.dart';
import '../providers/gems_provider.dart';
import '../services/shop_service.dart';
import '../data/shop_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'inventory_screen.dart';
import '../widgets/mascot/mascot_widgets.dart';

/// Gem Shop colors - jewel/treasure theme (WCAG AA compliant)
class GemShopColors {
  static const background1 = Color(0xFF1A1A2E); // Deep navy
  static const background2 = Color(0xFF16213E); // Dark blue
  static const background3 = Color(0xFF0F1A2E); // Darker blue
  static const gemPrimary = Color(
    0xFF5FD9CF,
  ); // Turquoise (gem color) - Lightened for better contrast
  static const gemGlow = Color(0xFF95E1D3); // Light turquoise
  static const goldAccent = Color(0xFFFFD700); // Gold
  static const silverAccent = Color(0xFFC0C0C0); // Silver
  static const glassCard = Color(0x15FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);
  static const textPrimary = Color(0xFFF5F5F5); // High contrast white
  static const textSecondary = Color(
    0xFFCDBFAE,
  ); // Warm beige for brand consistency
  static const powerUpColor = Color(0xFFFF7B7B); // Red - Lightened slightly
  static const extrasColor = Color(
    0xFF5FD9CF,
  ); // Turquoise - matches gemPrimary
  static const cosmeticsColor = Color(0xFFFFD700); // Gold
  
  // Pre-computed overlays for performance
  static const gemPrimary20 = Color(0x335FD9CF);  // 20%
  static const gemPrimary30 = Color(0x4D5FD9CF);  // 30%
  static const gemPrimary50 = Color(0x805FD9CF);  // 50%
  static const gemGlow20 = Color(0x3395E1D3);     // 20%
  static const powerUpColor80 = Color(0xCCFF7B7B); // 80%
  static const textSecondary30 = Color(0x4DC5C5D5); // 30%
}

/// Main Gem Shop Screen
class GemShopScreen extends ConsumerStatefulWidget {
  const GemShopScreen({super.key});

  @override
  ConsumerState<GemShopScreen> createState() => _GemShopScreenState();
}

class _GemShopScreenState extends ConsumerState<GemShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ConfettiController _confettiController;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gemBalance = ref.watch(gemBalanceProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            GemShopColors.background1,
            GemShopColors.background2,
            GemShopColors.background3,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: AppElevation.level0,
          title: Text(
            '💎 Gem Shop',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: GemShopColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Inventory button
            IconButton(
              icon: const Icon(Icons.inventory_2, color: GemShopColors.goldAccent),
              tooltip: 'My Inventory',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryScreen()),
              ),
            ),
            // Gem balance display
            _GemBalanceChip(balance: gemBalance),
            const SizedBox(width: AppSpacing.md),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: GemShopColors.gemPrimary,
            labelColor: GemShopColors.gemPrimary,
            unselectedLabelColor: GemShopColors.textSecondary,
            tabs: const [
              Tab(
                icon: Icon(Icons.flash_on, semanticLabel: 'Power-ups category'),
                text: 'Power-ups',
              ),
              Tab(
                icon: Icon(
                  Icons.card_giftcard,
                  semanticLabel: 'Extras category',
                ),
                text: 'Extras',
              ),
              Tab(
                icon: Icon(Icons.palette, semanticLabel: 'Cosmetics category'),
                text: 'Cosmetics',
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [
                _ShopItemGrid(
                  category: ShopItemCategory.powerUps,
                  onPurchase: _handlePurchase,
                ),
                _ShopItemGrid(
                  category: ShopItemCategory.extras,
                  onPurchase: _handlePurchase,
                ),
                _ShopItemGrid(
                  category: ShopItemCategory.cosmetics,
                  onPurchase: _handlePurchase,
                ),
              ],
            ),
            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.2,
                shouldLoop: false,
                colors: const [
                  GemShopColors.gemPrimary,
                  GemShopColors.goldAccent,
                  GemShopColors.powerUpColor,
                  Colors.green,
                  AppColors.primary,
                  DanioColors.coralAccent,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePurchase(ShopItem item) async {
    if (_isPurchasing) return;

    // Show confirmation dialog
    final confirmed = await _showPurchaseDialog(item);
    if (!confirmed) return;

    setState(() => _isPurchasing = true);

    try {
      // Attempt purchase
      final shopService = ref.read(shopServiceProvider);
      final result = await shopService.purchaseItem(item);

      if (!mounted) return;

      if (result.success) {
        // Trigger confetti animation
        _confettiController.play();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Purchased ${item.name}!',
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
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Purchase failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle provider errors (atomic transaction failures)
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _handlePurchase(item),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<bool> _showPurchaseDialog(ShopItem item) async {
    final gemBalance = ref.read(gemBalanceProvider);
    final canAfford = gemBalance >= item.gemCost;

    return await showDialog<bool>(
          context: context,
          builder: (ctx) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: GemShopColors.background2,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.largeRadius,
                side: const BorderSide(color: GemShopColors.glassBorder),
              ),
              title: Row(
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: GemShopColors.textPrimary,
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
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: GemShopColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: GemShopColors.glassCard,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(color: GemShopColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cost:',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: GemShopColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${item.gemCost}',
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: canAfford
                                    ? GemShopColors.gemPrimary
                                    : GemShopColors.powerUpColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Text('💎', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your balance:',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: GemShopColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$gemBalance 💎',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: GemShopColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (!canAfford)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        'Not enough gems! Complete lessons to earn more.',
                        style: TextStyle(
                          color: GemShopColors.powerUpColor80,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isPurchasing
                      ? null
                      : () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: GemShopColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: (canAfford && !_isPurchasing)
                      ? () => Navigator.pop(ctx, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GemShopColors.gemPrimary,
                    disabledBackgroundColor: GemShopColors.textSecondary30,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mediumRadius,
                    ),
                  ),
                  child: _isPurchasing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              GemShopColors.background1,
                            ),
                          ),
                        )
                      : const Text(
                          'Purchase',
                          style: TextStyle(
                            color: GemShopColors.background1,
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

/// Grid of shop items for a category
class _ShopItemGrid extends ConsumerWidget {
  final ShopItemCategory category;
  final Function(ShopItem) onPurchase;

  const _ShopItemGrid({required this.category, required this.onPurchase});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ShopCatalog.getByCategory(category);

    if (items.isEmpty) {
      return EmptyState.withMascot(
        icon: Icons.shopping_bag_outlined,
        title: 'No items available',
        message: 'Check back later for new items in this category!',
        mascotContext: MascotContext.encouragement,
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ShopItemCard(item: item, onTap: () => onPurchase(item));
      },
    );
  }
}

/// Individual shop item card
class _ShopItemCard extends ConsumerWidget {
  final ShopItem item;
  final VoidCallback onTap;

  const _ShopItemCard({required this.item, required this.onTap});

  Color _getCategoryColor() {
    switch (item.category) {
      case ShopItemCategory.powerUps:
        return GemShopColors.powerUpColor;
      case ShopItemCategory.extras:
        return GemShopColors.extrasColor;
      case ShopItemCategory.cosmetics:
        return GemShopColors.cosmeticsColor;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(ownsItemProvider(item.id));
    final quantity = ref.watch(itemQuantityProvider(item.id));
    final categoryColor = _getCategoryColor();

    final semanticLabel =
        '${item.name}, ${item.gemCost} gems. ${item.description}'
        '${owned ? '. Already owned${item.isConsumable && quantity > 0 ? ', quantity $quantity' : ''}' : ''}';

    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: AppRadius.largeRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: GemShopColors.glassCard,
                borderRadius: AppRadius.largeRadius,
                border: Border.all(
                  color: owned
                      ? categoryColor.withAlpha(128)
                      : GemShopColors.glassBorder,
                  width: owned ? 2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  // Content
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji icon
                        Center(
                          child: Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Name
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: GemShopColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Description
                        Expanded(
                          child: Text(
                            item.description,
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: GemShopColors.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withAlpha(51),
                            borderRadius: AppRadius.mediumRadius,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${item.gemCost}',
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const Text('💎', style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Owned indicator
                  if (owned)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: AppRadius.smallRadius,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Colors.white,
                            ),
                            if (item.isConsumable && quantity > 0) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'x$quantity',
                                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Gem balance display chip
class _GemBalanceChip extends StatelessWidget {
  final int balance;

  const _GemBalanceChip({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Gem balance: $balance gems',
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              GemShopColors.gemPrimary30,
              GemShopColors.gemGlow20,
            ],
          ),
          borderRadius: AppRadius.largeRadius,
          border: Border.all(
            color: GemShopColors.gemPrimary50,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: GemShopColors.gemPrimary30,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💎', style: TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$balance',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: GemShopColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
