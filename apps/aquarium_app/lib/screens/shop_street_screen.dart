import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../models/wishlist.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import 'gem_shop_screen.dart';
import 'wishlist_screen.dart';

/// Shop Street colors - fresh outdoor market theme
/// Adapts slightly for dark mode to maintain readability
class ShopColors {
  ShopColors._();

  static const background1 = Color(0xFF4A7C59); // Forest green
  static const background2 = Color(0xFF3D6B4A); // Darker green
  static const background3 = Color(0xFF2F5A3B); // Deep green
  static const accent = Color(0xFFF0C040); // Sunny yellow
  static const accentLight = Color(0xFFFFF3C4); // Light yellow
  static const wood = Color(0xFF8B7355); // Market stall wood
  static const awning = Color(0xFFE74C3C); // Red awning
  static const glassCard = Color(0x20FFFFFF);
  static const glassBorder = Color(0x30FFFFFF);
  static const textPrimary = Color(0xFFF5F5F5);
  static const textSecondary = Color(0xFFCDBFAE); // Warm secondary text

  // Pre-computed alpha variants for performance
  static const accentAlpha20 = Color(0x33F0C040); // 20% opacity
  static const textSecondaryAlpha50 = Color(0x80B8D4B8); // 50% opacity
  static const textSecondaryAlpha70 = Color(0xB3B8D4B8); // 70% opacity

  // Dark mode adjustments — slightly lighter/desaturated greens
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
    final fishCount = ref.watch(fishWishlistProvider).length;
    final plantCount = ref.watch(plantWishlistProvider).length;
    final equipmentCount = ref.watch(equipmentWishlistProvider).length;
    final budget = ref.watch(budgetProvider);
    final shops = ref.watch(localShopsProvider);

    return Container(
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
                    color: Colors.pink.shade300,
                    itemCount: fishCount,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WishlistScreen(
                          category: WishlistCategory.fish,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ShopSection(
                    title: '🌿 Plant Wishlist',
                    subtitle: 'Plants to add to your tank',
                    icon: Icons.eco,
                    color: Colors.green.shade400,
                    itemCount: plantCount,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WishlistScreen(
                          category: WishlistCategory.plant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ShopSection(
                    title: '🛠️ Equipment Wishlist',
                    subtitle: 'Gear upgrades planned',
                    icon: Icons.build,
                    color: Colors.blue.shade400,
                    itemCount: equipmentCount,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WishlistScreen(
                          category: WishlistCategory.equipment,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ShopSection(
                    title: '💎 Gem Shop',
                    subtitle: 'Spend gems on rewards & cosmetics',
                    icon: Icons.diamond,
                    color: Colors.purple.shade300,
                    itemCount: 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GemShopScreen(),
                      ),
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
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 100;
              ref.read(budgetProvider.notifier).setMonthlyBudget(amount);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(AppSpacing.md),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.largeRadius,
        ),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                          Navigator.pop(ctx);
                        }
                      : null,
                  child: Text(
                    existingShop == null ? 'Add Shop' : 'Save Changes',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteShop(BuildContext context, WidgetRef ref, LocalShop shop) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shop?'),
        content: Text('Remove "${shop.name}" from your list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(localShopsProvider.notifier).removeShop(shop.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
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
              color: ShopColors.glassCard,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: ShopColors.glassBorder),
            ),
            child: const Icon(
              Icons.storefront,
              color: ShopColors.accent,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '🏪 Shop Street',
                style: TextStyle(
                  color: ShopColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Wishlists & shopping',
                style: TextStyle(color: ShopColors.textSecondary, fontSize: 14),
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
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.largeRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg2),
            decoration: BoxDecoration(
              color: ShopColors.glassCard,
              borderRadius: AppRadius.largeRadius,
              border: Border.all(color: ShopColors.glassBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm2),
                  decoration: BoxDecoration(
                    color: Color((color.value & 0x00FFFFFF) | 0x33000000), // 20% opacity
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
                        style: const TextStyle(
                          color: ShopColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: ShopColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: itemCount > 0
                        ? ShopColors.accentAlpha20
                        : ShopColors.glassCard,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Text(
                    '$itemCount',
                    style: TextStyle(
                      color: itemCount > 0
                          ? ShopColors.accent
                          : ShopColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.chevron_right,
                  color: ShopColors.textSecondary,
                ),
              ],
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
    return GestureDetector(
      onTap: onEdit,
      child: ClipRRect(
        borderRadius: AppRadius.largeRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg2),
            decoration: BoxDecoration(
              color: ShopColors.glassCard,
              borderRadius: AppRadius.largeRadius,
              border: Border.all(color: ShopColors.glassBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: ShopColors.accent,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Monthly Budget',
                      style: TextStyle(
                        color: ShopColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.edit,
                      color: ShopColors.textSecondaryAlpha50,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '£${budget.spentThisMonth.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: ShopColors.accent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'spent this month',
                          style: TextStyle(
                            color: ShopColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '£${budget.remaining.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: ShopColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Text(
                          'remaining',
                          style: TextStyle(
                            color: ShopColors.textSecondary,
                            fontSize: 13,
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
                    backgroundColor: ShopColors.background3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budget.percentUsed > 0.9 ? Colors.red : ShopColors.accent,
                    ),
                    minHeight: 8,
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
            color: ShopColors.glassCard,
            borderRadius: AppRadius.largeRadius,
            border: Border.all(color: ShopColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.location_on, color: ShopColors.awning),
                  SizedBox(width: 12),
                  Text(
                    'Local Fish Shops',
                    style: TextStyle(
                      color: ShopColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (shops.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      'No shops added yet',
                      style: TextStyle(
                        color: ShopColors.textSecondaryAlpha70,
                      ),
                    ),
                  ),
                )
              else
                ...shops.map(
                  (shop) => _ShopTile(
                    shop: shop,
                    onTap: () => onEditShop(shop),
                    onDelete: () => onDeleteShop(shop),
                  ),
                ),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: onAddShop,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add a shop'),
                  style: TextButton.styleFrom(
                    foregroundColor: ShopColors.accent,
                  ),
                ),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 8),
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
                color: ShopColors.textSecondary,
                size: AppIconSizes.sm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop.name,
                    style: const TextStyle(
                      color: ShopColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (shop.distanceMiles != null)
                    Text(
                      '${shop.distanceMiles!.toStringAsFixed(1)} miles',
                      style: const TextStyle(
                        color: ShopColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (shop.rating != null)
              Text(
                '⭐ ${shop.rating!.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: ShopColors.accentLight,
                  fontSize: 13,
                ),
              ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: ShopColors.textSecondaryAlpha50,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
