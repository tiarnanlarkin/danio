import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui';
import '../models/shop_item.dart';
import '../providers/gems_provider.dart';
import '../services/shop_service.dart';
import '../providers/inventory_provider.dart'; // ownsItemProvider
import '../data/shop_catalog.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'inventory_screen.dart';
import '../widgets/mascot/mascot_widgets.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/danio_snack_bar.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import '../utils/logger.dart';

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
            DanioColors.gemShopBackground1,
            DanioColors.gemShopBackground2,
            DanioColors.gemShopBackground3,
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
              color: AppColors.textPrimaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Inventory button
            IconButton(
              icon: const Icon(
                Icons.inventory_2,
                color: AppAchievementColors.gold,
              ),
              tooltip: 'My Inventory',
              onPressed: () =>
                  NavigationThrottle.push(context, const InventoryScreen()),
            ),
            // Gem balance display
            _GemBalanceChip(balance: gemBalance),
            const SizedBox(width: AppSpacing.md),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: DanioColors.gemPrimary,
            labelColor: DanioColors.gemPrimary,
            unselectedLabelColor: AppColors.textSecondaryDark,
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
                  DanioColors.gemPrimary,
                  AppAchievementColors.gold,
                  DanioColors.gemPowerUp,
                  AppColors.success,
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
    if (!confirmed || !mounted) return;

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
        DanioSnackBar.success(context, 'Purchased ${item.name}!');
      } else {
        // Show error message
        DanioSnackBar.error(
          context,
          result.errorMessage ?? 'Couldn\'t complete this purchase. Give it another go!',
        );
      }
    } catch (e, st) {
      logError('GemShopScreen: purchase failed: $e', stackTrace: st, tag: 'GemShopScreen');
      // Handle provider errors (atomic transaction failures)
      if (!mounted) return;

      DanioSnackBar.error(
        context,
        'Oops! We hit a snag. Give it another go!',
        onRetry: () => _handlePurchase(item),
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

    return await showAppDialog<bool>(
          context: context,
          title: '${item.emoji} ${item.name}',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description),
              const SizedBox(height: AppSpacing.lg2),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.whiteAlpha08,
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(color: AppColors.whiteAlpha20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cost:', style: AppTypography.bodyMedium),
                    Text(
                      '${item.gemCost} 💎',
                      style: AppTypography.titleMedium.copyWith(
                        color: canAfford
                            ? DanioColors.gemPrimary
                            : DanioColors.gemPowerUp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Your balance:', style: AppTypography.bodyMedium),
                  Text('$gemBalance 💎', style: AppTypography.bodyMedium),
                ],
              ),
              if (!canAfford)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Not enough gems! Complete lessons to earn more.',
                    style: AppTypography.bodySmall.copyWith(
                      // Use fully opaque powerUpColor for WCAG AA contrast on dark background
                      color: DanioColors.gemPowerUp,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            AppButton(
              label: 'Cancel',
              onPressed: _isPurchasing
                  ? null
                  : () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context, false);
                      }
                    },
              variant: AppButtonVariant.text,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppButton(
              label: 'Purchase',
              onPressed: (canAfford && !_isPurchasing)
                  ? () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context, true);
                      }
                    }
                  : null,
              isLoading: _isPurchasing,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
          ],
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
        title: 'Nothing in stock right now 🛍️',
        message: 'Check back soon — new goodies are on the way!',
        mascotContext: MascotContext.encouragement,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
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
        return DanioColors.gemPowerUp;
      case ShopItemCategory.extras:
        return DanioColors.gemPrimary;
      case ShopItemCategory.cosmetics:
        return AppAchievementColors.gold;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(ownsItemProvider(item.id));
    final quantity = ref.watch(itemQuantityProvider(item.id));
    final gemBalance = ref.watch(gemBalanceProvider);
    final canAfford = gemBalance >= item.gemCost;
    final categoryColor = _getCategoryColor();

    final semanticLabel =
        '${item.name}, ${item.gemCost} gems. ${item.description}'
        '${owned ? '. Already owned${item.isConsumable && quantity > 0 ? ', quantity $quantity' : ''}' : ''}';

    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: true,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.largeRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.largeRadius,
          splashColor: categoryColor.withAlpha(30),
          highlightColor: categoryColor.withAlpha(15),
          child: RepaintBoundary(
            child: ClipRRect(
              borderRadius: AppRadius.largeRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteAlpha08,
                  borderRadius: AppRadius.largeRadius,
                  border: Border.all(
                    color: owned
                        ? categoryColor.withAlpha(128)
                        : AppColors.whiteAlpha20,
                    width: owned ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Emoji icon
                          Center(
                            child: Text(
                              item.emoji,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium!.copyWith(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm2),
                          // Name
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: AppColors.textPrimaryDark,
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
                              style: Theme.of(context).textTheme.labelSmall!
                                  .copyWith(color: AppColors.textSecondaryDark),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          // Price
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm2,
                              vertical: AppSpacing.xs2,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: categoryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  '💎',
                                  style: Theme.of(context).textTheme.bodyLarge!,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dim overlay for items the user cannot afford
                    // P2-008: previously used Positioned.fill with a centered
                    // lock icon which covered the description text. Now we
                    // use a light dim + a small corner badge so text stays
                    // readable.
                    if (!owned && !canAfford) ...[
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.blackAlpha25,
                            borderRadius: AppRadius.largeRadius,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.xs2),
                          decoration: BoxDecoration(
                            color: AppColors.blackAlpha60,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: AppColors.whiteAlpha70,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                    // Owned indicator
                    if (owned)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
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
                                color: AppColors.onPrimary,
                              ),
                              if (item.isConsumable && quantity > 0) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'x$quantity',
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        color: AppColors.onPrimary,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [DanioColors.gemPrimary30, DanioColors.gemGlow20],
          ),
          borderRadius: AppRadius.largeRadius,
          border: Border.all(color: DanioColors.gemPrimary50, width: 2),
          boxShadow: const [
            BoxShadow(
              color: DanioColors.gemPrimary30,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('💎', style: Theme.of(context).textTheme.titleLarge!),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '$balance',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: AppColors.textPrimaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
