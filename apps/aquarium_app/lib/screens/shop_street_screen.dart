import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../models/wishlist.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../utils/app_constants.dart';
import 'gem_shop_screen.dart';
import 'wishlist_screen.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/app_bottom_sheet.dart';

/// Shop Street colors - fresh outdoor market theme
/// Adapts slightly for dark mode to maintain readability
class ShopColors {
  ShopColors._();

  static const background1 = Color(0xFF4A7C59); // Forest green
  static const background2 = Color(0xFF3D6B4A); // Darker green
  static const background3 = Color(0xFF2F5A3B); // Deep green
  static const accent = Color(0xFFD97706); // Sunny yellow
  static const accentLight = Color(0xFFFFF0DC); // Light yellow
  static const wood = Color(0xFF8B7355); // Market stall wood
  static const awning = Color(0xFFE74C3C); // Red awning
  static const glassCard = Color(0x20FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFCDBFAE); // Warm secondary text

  // Pre-computed alpha variants for performance
  static const accentAlpha20 = Color(0x33D97706); // 20% opacity
  static const textSecondaryAlpha50 = Color(0x80CDBFAE); // 50% opacity
  static const textSecondaryAlpha70 = Color(0xB3CDBFAE); // 70% opacity

  // Dark mode adjustments - slightly lighter/desaturated greens
  static const background1Dark = Color(0xFF5A8E6A); // Lighter forest green
  static const background2Dark = Color(0xFF4D7D5C); // Lighter mid green
  static const background3Dark = Color(0xFF3F6C4D); // Lighter base green

  /// Returns gradient colors adapted to current brightness
  static List<Color> gradientColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? [background1Dark, background2Dark, background3Dark]
        : [background1, background2, background3];
  }
}

/// Shop Street Room - Wishlist & Shopping
class ShopStreetScreen extends ConsumerWidget {
  const ShopStreetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fishCount = ref.watch(fishWishlistProvider.select((list) => list.length));
    final plantCount = ref.watch(plantWishlistProvider.select((list) => list.length));
    final equipmentCount = ref.watch(equipmentWishlistProvider.select((list) => list.length));
    final budget = ref.watch(budgetProvider);
    final shops = ref.watch(localShopsProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: ShopColors.gradientColors(context),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              // AppBar with back button
              SliverAppBar(
                title: const Text('🏪 Shop Street'),
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textPrimaryDark,
                elevation: 0,
                pinned: true,
              ),

              // Header
              SliverToBoxAdapter(child: _ShopHeader()),

              // Shop sections
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _ShopSection(
                      title: '🐟 Fish Wishlist',
                      subtitle: 'Species you want to keep',
                      icon: Icons.favorite,
                      color: DanioColors.coralAccent,
                      itemCount: fishCount,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const WishlistScreen(category: WishlistCategory.fish),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm2),
                    _ShopSection(
                      title: '🌿 Plant Wishlist',
                      subtitle: 'Plants to add to your tank',
                      icon: Icons.eco,
                      color: DanioColors.wishlistAmber,
                      itemCount: plantCount,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const WishlistScreen(category: WishlistCategory.plant),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm2),
                    _ShopSection(
                      title: '🛠️ Equipment Wishlist',
                      subtitle: 'Gear upgrades planned',
                      icon: Icons.build,
                      color: DanioColors.wishlistAmber,
                      itemCount: equipmentCount,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const WishlistScreen(
                          category: WishlistCategory.equipment,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm2),
                    _ShopSection(
                      title: '💎 Gem Shop',
                      subtitle: 'Spend gems on rewards & cosmetics',
                      icon: Icons.diamond,
                      color: AppColors.accentAlt,
                      itemCount: 0,
                      onTap: () => NavigationThrottle.push(
                        context,
                        const GemShopScreen(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BudgetCard(
                      budget: budget,
                      onEdit: () => _showBudgetDialog(context, ref, budget),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _LocalShopsCard(
                      shops: shops,
                      onAddShop: () => _showAddShopDialog(context, ref),
                      onEditShop: (shop) =>
                          _showEditShopDialog(context, ref, shop),
                      onDeleteShop: (shop) => _deleteShop(context, ref, shop),
                    ),
                  ]),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: kScrollEndPadding),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    ShopBudget budget,
  ) {
    final controller = TextEditingController(
      text: budget.monthlyBudget.toStringAsFixed(0),
    );

    showAppDialog(
      context: context,
      title: 'Set Monthly Budget',
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Budget amount',
          prefixText: '£ ',
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        ],
      ),
      actions: [
        AppButton(
          label: 'Cancel',
          onPressed: () => Navigator.maybePop(context),
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: 'Save',
          onPressed: () {
            final amount = double.tryParse(controller.text) ?? 100;
            ref.read(budgetProvider.notifier).setMonthlyBudget(amount);
            Navigator.maybePop(context);
          },
          variant: AppButtonVariant.primary,
          isFullWidth: true,
        ),
      ],
    ).whenComplete(() => controller.dispose());
  }

  void _showAddShopDialog(BuildContext context, WidgetRef ref) {
    _showShopDialog(context, ref, null);
  }

  void _showEditShopDialog(
    BuildContext context,
    WidgetRef ref,
    LocalShop shop,
  ) {
    _showShopDialog(context, ref, shop);
  }

  void _showShopDialog(
    BuildContext context,
    WidgetRef ref,
    LocalShop? existingShop,
  ) {
    final nameController = TextEditingController(
      text: existingShop?.name ?? '',
    );
    final addressController = TextEditingController(
      text: existingShop?.address ?? '',
    );
    final distanceController = TextEditingController(
      text: existingShop?.distanceMiles?.toStringAsFixed(1) ?? '',
    );
    final notesController = TextEditingController(
      text: existingShop?.notes ?? '',
    );

    showAppBottomSheet<void>(
      context: context,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                existingShop == null ? 'Add Local Shop' : 'Edit Shop',
                style: AppTypography.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Shop name',
                  hintText: 'e.g., Aquatic World',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: distanceController,
                decoration: const InputDecoration(
                  labelText: 'Distance (miles)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                onPressed: nameController.text.trim().isNotEmpty
                    ? () {
                        final shop = LocalShop(
                          id: existingShop?.id,
                          name: nameController.text.trim(),
                          address: addressController.text.trim().isEmpty
                              ? null
                              : addressController.text.trim(),
                          distanceMiles: double.tryParse(
                            distanceController.text,
                          ),
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        );

                        if (existingShop == null) {
                          ref.read(localShopsProvider.notifier).addShop(shop);
                        } else {
                          ref
                              .read(localShopsProvider.notifier)
                              .updateShop(shop);
                        }
                        Navigator.maybePop(context);
                      }
                    : null,
                label: existingShop == null ? 'Add Shop' : 'Save Changes',
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      nameController.dispose();
      addressController.dispose();
      distanceController.dispose();
      notesController.dispose();
    });
  }

  void _deleteShop(BuildContext context, WidgetRef ref, LocalShop shop) {
    showAppDestructiveDialog(
      context: context,
      title: 'Remove Shop?',
      message: 'Remove "${shop.name}" from your saved shops?',
      destructiveLabel: 'Remove Shop',
      cancelLabel: 'Keep',
      onConfirm: () => ref.read(localShopsProvider.notifier).removeShop(shop.id),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm2),
            decoration: BoxDecoration(
              color: AppColors.whiteAlpha12,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.whiteAlpha20),
            ),
            child: const Icon(
              Icons.storefront,
              color: AppColors.primaryLight,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Builder(
                builder: (context) => Text(
                  '🏪 Shop Street',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Builder(
                builder: (context) => Text(
                  'Wishlists & shopping',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShopSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int itemCount;
  final VoidCallback onTap;

  const _ShopSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.itemCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.largeRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.largeRadius,
        splashColor: color.withAlpha(30),
        highlightColor: color.withAlpha(15),
        child: ClipRRect(
          borderRadius: AppRadius.largeRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg2),
              decoration: BoxDecoration(
                color: AppColors.whiteAlpha12,
                borderRadius: AppRadius.largeRadius,
                border: Border.all(color: AppColors.whiteAlpha20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm2),
                    decoration: BoxDecoration(
                      color: Color(
                        (color.toARGB32() & 0x00FFFFFF) | 0x33000000,
                      ), // 20% opacity
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm2,
                      vertical: AppSpacing.xs2,
                    ),
                    decoration: BoxDecoration(
                      color: itemCount > 0
                          ? AppColors.primaryLightAlpha20
                          : AppColors.whiteAlpha12,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: Text(
                      '$itemCount',
                      style: TextStyle(
                        color: itemCount > 0
                            ? AppColors.primaryLight
                            : AppColors.textSecondaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondaryDark,
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

class _BudgetCard extends StatelessWidget {
  final ShopBudget budget;
  final VoidCallback onEdit;

  const _BudgetCard({required this.budget, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.largeRadius,
      child: InkWell(
        onTap: onEdit,
        borderRadius: AppRadius.largeRadius,
        splashColor: AppColors.primaryLight.withAlpha(30),
        highlightColor: AppColors.primaryLight.withAlpha(15),
        child: ClipRRect(
          borderRadius: AppRadius.largeRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg2),
              decoration: BoxDecoration(
                color: AppColors.whiteAlpha12,
                borderRadius: AppRadius.largeRadius,
                border: Border.all(color: AppColors.whiteAlpha20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: AppSpacing.sm2),
                      Builder(
                        builder: (context) => Text(
                          'Monthly Budget',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.edit,
                        color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '£${budget.spentThisMonth.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: AppColors.primaryLight,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Builder(
                            builder: (context) => Text(
                              'spent this month',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondaryDark),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '£${budget.remaining.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Builder(
                            builder: (context) => Text(
                              'remaining',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondaryDark),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ClipRRect(
                    borderRadius: AppRadius.xsRadius,
                    child: LinearProgressIndicator(
                      value: budget.percentUsed,
                      // P2-005: background3 is opaque deep-green which made the
                      // empty track look "nearly full". Use a transparent white
                      // track so only the accent fill is visible.
                      backgroundColor: AppColors.whiteAlpha20,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        budget.percentUsed > 0.9
                            ? AppColors.error
                            : AppColors.primaryLight,
                      ),
                      minHeight: 8,
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

class _LocalShopsCard extends StatelessWidget {
  final List<LocalShop> shops;
  final VoidCallback onAddShop;
  final Function(LocalShop) onEditShop;
  final Function(LocalShop) onDeleteShop;

  const _LocalShopsCard({
    required this.shops,
    required this.onAddShop,
    required this.onEditShop,
    required this.onDeleteShop,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.largeRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg2),
          decoration: BoxDecoration(
            color: AppColors.whiteAlpha12,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: AppColors.whiteAlpha20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: DanioColors.coralAccent),
                  const SizedBox(width: AppSpacing.sm2),
                  Builder(
                    builder: (context) => Text(
                      'Local Fish Shops',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (shops.isEmpty)
                CompactEmptyState(
                  icon: Icons.storefront,
                  message: 'No shops added yet',
                  actionLabel: 'Add a shop',
                  onAction: onAddShop,
                )
              else
                ...shops.map(
                  (shop) => _ShopTile(
                    shop: shop,
                    onTap: () => onEditShop(shop),
                    onDelete: () => onDeleteShop(shop),
                  ),
                ),
              if (shops.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm2),
              Center(
                child: AppButton(
                  label: 'Add a shop',
                  onPressed: onAddShop,
                  leadingIcon: Icons.add,
                  variant: AppButtonVariant.text,
                ),
              ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopTile extends StatelessWidget {
  final LocalShop shop;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ShopTile({
    required this.shop,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mediumRadius,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ShopColors.background3,
                borderRadius: AppRadius.smallRadius,
              ),
              child: const Icon(
                Icons.store,
                color: AppColors.textSecondaryDark,
                size: AppIconSizes.sm,
              ),
            ),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (shop.distanceMiles != null)
                    Text(
                      '${shop.distanceMiles!.toStringAsFixed(1)} miles',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                ],
              ),
            ),
            if (shop.rating != null)
              Text(
                '⭐ ${shop.rating!.toStringAsFixed(1)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.primaryLight),
              ),
            IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
