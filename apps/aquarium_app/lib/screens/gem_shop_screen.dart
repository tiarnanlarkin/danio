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

/// Gem Shop colors - jewel/treasure theme (WCAG AA compliant)
class GemShopColors {
  static const background1 = Color(0xFF1A1A2E);  // Deep navy
  static const background2 = Color(0xFF16213E);  // Dark blue
  static const background3 = Color(0xFF0F1A2E);  // Darker blue
  static const gemPrimary = Color(0xFF5FD9CF);   // Turquoise (gem color) - Lightened for better contrast
  static const gemGlow = Color(0xFF95E1D3);      // Light turquoise
  static const goldAccent = Color(0xFFFFD700);   // Gold
  static const silverAccent = Color(0xFFC0C0C0); // Silver
  static const glassCard = Color(0x15FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);
  static const textPrimary = Color(0xFFF5F5F5);  // High contrast white
  static const textSecondary = Color(0xFFC5C5D5); // Improved contrast - lightened from B8B8C8
  static const powerUpColor = Color(0xFFFF7B7B);    // Red - Lightened slightly
  static const extrasColor = Color(0xFF5FD9CF);     // Turquoise - matches gemPrimary
  static const cosmeticsColor = Color(0xFFFFD700);  // Gold
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
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
          elevation: 0,
          title: const Text(
            '💎 Gem Shop',
            style: TextStyle(
              color: GemShopColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            // Gem balance display
            _GemBalanceChip(balance: gemBalance),
            const SizedBox(width: 16),
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
                icon: Icon(Icons.card_giftcard, semanticLabel: 'Extras category'),
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
                  Colors.blue,
                  Colors.pink,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePurchase(ShopItem item) async {
    // Show confirmation dialog
    final confirmed = await _showPurchaseDialog(item);
    if (!confirmed) return;

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
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: GemShopColors.glassBorder),
              ),
              title: Row(
                children: [
                  Text(item.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        color: GemShopColors.textPrimary,
                        fontSize: 20,
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
                    style: const TextStyle(
                      color: GemShopColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: GemShopColors.glassCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GemShopColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cost:',
                          style: TextStyle(
                            color: GemShopColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${item.gemCost}',
                              style: TextStyle(
                                color: canAfford
                                    ? GemShopColors.gemPrimary
                                    : GemShopColors.powerUpColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '💎',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your balance:',
                        style: TextStyle(
                          color: GemShopColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$gemBalance 💎',
                        style: const TextStyle(
                          color: GemShopColors.textPrimary,
                          fontSize: 14,
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
                          color: GemShopColors.powerUpColor.withOpacity(0.8),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: GemShopColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: canAfford ? () => Navigator.pop(ctx, true) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GemShopColors.gemPrimary,
                    disabledBackgroundColor: GemShopColors.textSecondary.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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

  const _ShopItemGrid({
    required this.category,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ShopCatalog.getByCategory(category);

    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'No items available',
        message: 'Check back later for new items in this category!',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ShopItemCard(
          item: item,
          onTap: () => onPurchase(item),
        );
      },
    );
  }
}

/// Individual shop item card
class _ShopItemCard extends ConsumerWidget {
  final ShopItem item;
  final VoidCallback onTap;

  const _ShopItemCard({
    required this.item,
    required this.onTap,
  });

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

    final semanticLabel = '${item.name}, ${item.gemCost} gems. ${item.description}'
        '${owned ? '. Already owned${item.isConsumable && quantity > 0 ? ', quantity $quantity' : ''}' : ''}';

    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: GemShopColors.glassCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: owned
                    ? categoryColor.withOpacity(0.5)
                    : GemShopColors.glassBorder,
                width: owned ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
                          color: GemShopColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Expanded(
                        child: Text(
                          item.description,
                          style: const TextStyle(
                            color: GemShopColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.gemCost}',
                              style: TextStyle(
                                color: categoryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
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
                        borderRadius: BorderRadius.circular(8),
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
                            const SizedBox(width: 4),
                            Text(
                              'x$quantity',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
          gradient: LinearGradient(
            colors: [
              GemShopColors.gemPrimary.withOpacity(0.3),
              GemShopColors.gemGlow.withOpacity(0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: GemShopColors.gemPrimary.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: GemShopColors.gemPrimary.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💎', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              '$balance',
              style: const TextStyle(
                color: GemShopColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
