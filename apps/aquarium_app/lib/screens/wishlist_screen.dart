import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wishlist.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../widgets/empty_state.dart';
import '../widgets/mascot/mascot_widgets.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import '../widgets/app_bottom_sheet.dart';

const double _maxWishlistContentWidth = 720;

double _wishlistHorizontalInset(double availableWidth) {
  final boundedWithPadding = _maxWishlistContentWidth + (AppSpacing.md * 2);
  if (availableWidth <= boundedWithPadding) return AppSpacing.md;

  return (availableWidth - _maxWishlistContentWidth) / 2;
}

/// Screen to view and manage wishlist items for a category
class WishlistScreen extends ConsumerWidget {
  final WishlistCategory category;

  const WishlistScreen({super.key, required this.category});

  String get _title {
    switch (category) {
      case WishlistCategory.fish:
        return 'Fish Wishlist';
      case WishlistCategory.plant:
        return 'Plant Wishlist';
      case WishlistCategory.equipment:
        return 'Equipment Wishlist';
    }
  }

  Color get _accentColor {
    switch (category) {
      case WishlistCategory.fish:
        return DanioColors.coralAccent;
      case WishlistCategory.plant:
        return AppColors.success;
      case WishlistCategory.equipment:
        return DanioColors.equipmentGold;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenContext = context;
    final allItems = ref.watch(wishlistProvider);
    final items =
        allItems
            .where((item) => item.category == category && !item.purchased)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final purchasedItems = allItems
        .where((item) => item.category == category && item.purchased)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          if (purchasedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Purchased items',
              onPressed: () =>
                  _showPurchasedItems(context, ref, purchasedItems),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState.withMascot(
              icon: category == WishlistCategory.fish
                  ? Icons.set_meal
                  : category == WishlistCategory.plant
                  ? Icons.grass
                  : Icons.shopping_cart,
              title: 'Your wishlist is empty',
              message:
                  'Add ${category == WishlistCategory.fish
                      ? 'fish'
                      : category == WishlistCategory.plant
                      ? 'plants'
                      : 'equipment'} you want to get for your aquarium',
              mascotContext: MascotContext.encouragement,
              actionLabel: 'Add Item',
              onAction: () => _showAddDialog(screenContext, ref),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: _wishlistHorizontalInset(
                      constraints.maxWidth,
                    ),
                    vertical: AppSpacing.md,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _WishlistItemCard(
                      item: item,
                      accentColor: _accentColor,
                      onTap: () => _showEditDialog(context, ref, item),
                      onPurchased: () =>
                          _markPurchased(screenContext, ref, item),
                      onDelete: () => _deleteItem(screenContext, ref, item),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: _accentColor,
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);
    showAppBottomSheet(
      context: context,
      padding: EdgeInsets.zero,
      child: _AddEditItemSheet(
        category: category,
        accentColor: _accentColor,
        feedbackMessenger: messenger,
        successMessage: (item) => '${item.name} added.',
        onSave: (item) async {
          await ref.read(wishlistProvider.notifier).addItem(item);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, WishlistItem item) {
    final messenger = ScaffoldMessenger.of(context);
    showAppBottomSheet(
      context: context,
      padding: EdgeInsets.zero,
      child: _AddEditItemSheet(
        category: category,
        accentColor: _accentColor,
        existingItem: item,
        feedbackMessenger: messenger,
        successMessage: (updated) => '${updated.name} saved.',
        onSave: (updated) async {
          await ref.read(wishlistProvider.notifier).updateItem(updated);
        },
      ),
    );
  }

  Future<void> _markPurchased(
    BuildContext context,
    WidgetRef ref,
    WishlistItem item,
  ) async {
    final wishlist = ref.read(wishlistProvider.notifier);
    var markedPurchased = false;

    try {
      await wishlist.markPurchased(item.id);
      markedPurchased = true;

      // Add to budget if price is set
      if (item.estimatedPrice != null) {
        await ref
            .read(budgetProvider.notifier)
            .addPurchase(item.estimatedPrice! * item.quantity);
      }
    } catch (_) {
      var purchaseRemainsCommitted = false;
      if (markedPurchased) {
        try {
          await wishlist.updateItem(item);
        } catch (_) {
          purchaseRemainsCommitted = true;
        }
      }
      if (!context.mounted) return;
      if (purchaseRemainsCommitted) {
        AppFeedback.showWarning(
          context,
          '${item.name} was marked as purchased, but the budget could not be updated.',
        );
        return;
      }
      AppFeedback.showError(
        context,
        'Could not mark ${item.name} as purchased. Try again in a moment.',
      );
      return;
    }

    if (!context.mounted) return;
    AppFeedback.showSuccess(context, '${item.name} marked as purchased!');
  }

  void _deleteItem(BuildContext context, WidgetRef ref, WishlistItem item) {
    showAppDestructiveDialog(
      context: context,
      title: 'Remove From Wishlist?',
      message: 'Remove "${item.name}" from your wishlist?',
      destructiveLabel: 'Remove Item',
      cancelLabel: 'Keep',
      onConfirm: () async {
        final wishlist = ref.read(wishlistProvider.notifier);
        try {
          await wishlist.removeItem(item.id);
        } catch (_) {
          if (!context.mounted) return;
          AppFeedback.showError(
            context,
            'Could not remove ${item.name}. Try again in a moment.',
          );
          return;
        }
        if (!context.mounted) return;
        AppFeedback.show(
          context,
          '${item.name} removed',
          duration: const Duration(seconds: 5),
          actionLabel: 'Undo',
          onAction: () async {
            try {
              await wishlist.addItem(item);
            } catch (_) {
              if (!context.mounted) return;
              AppFeedback.showError(
                context,
                'Could not restore ${item.name}. Try again in a moment.',
              );
            }
          },
        );
      },
    );
  }

  void _showPurchasedItems(
    BuildContext context,
    WidgetRef ref,
    List<WishlistItem> items,
  ) {
    showAppBottomSheet(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: AppSpacing.sm2),
              Text('Purchased Items', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(Icons.check_circle, color: _accentColor),
                  title: Text(item.name),
                  subtitle: item.purchasedAt != null
                      ? Text('Purchased ${_formatDate(item.purchasedAt!)}')
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _WishlistItemCard extends StatelessWidget {
  final WishlistItem item;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback onPurchased;
  final VoidCallback onDelete;

  const _WishlistItemCard({
    required this.item,
    required this.accentColor,
    required this.onTap,
    required this.onPurchased,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm2),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mediumRadius,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withAlpha(38),
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Icon(_getCategoryIcon(), color: accentColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name, style: AppTypography.labelLarge),
                      if (item.species != null)
                        Text(
                          item.species!,
                          style: AppTypography.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                            color: context.textSecondary,
                          ),
                        ),
                      if (item.estimatedPrice != null || item.quantity > 1)
                        Row(
                          children: [
                            if (item.estimatedPrice != null)
                              Text(
                                '£${item.estimatedPrice!.toStringAsFixed(2)}',
                                style: AppTypography.bodySmall.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (item.estimatedPrice != null &&
                                item.quantity > 1)
                              Text(' × ', style: AppTypography.bodySmall),
                            if (item.quantity > 1)
                              Text(
                                '${item.quantity}',
                                style: AppTypography.bodySmall,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  color: AppColors.success,
                  tooltip: 'Mark as purchased',
                  onPressed: onPurchased,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: context.textHint,
                  tooltip: 'Remove from wishlist',
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (item.category) {
      case WishlistCategory.fish:
        return Icons.set_meal;
      case WishlistCategory.plant:
        return Icons.eco;
      case WishlistCategory.equipment:
        return Icons.build;
    }
  }
}

class _AddEditItemSheet extends StatefulWidget {
  final WishlistCategory category;
  final Color accentColor;
  final WishlistItem? existingItem;
  final ScaffoldMessengerState feedbackMessenger;
  final String Function(WishlistItem) successMessage;
  final Future<void> Function(WishlistItem) onSave;

  const _AddEditItemSheet({
    required this.category,
    required this.accentColor,
    this.existingItem,
    required this.feedbackMessenger,
    required this.successMessage,
    required this.onSave,
  });

  @override
  State<_AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends State<_AddEditItemSheet> {
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _priceController;
  late TextEditingController _notesController;
  late int _quantity;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _speciesController = TextEditingController(text: item?.species ?? '');
    _priceController = TextEditingController(
      text: item?.estimatedPrice?.toStringAsFixed(2) ?? '',
    );
    _notesController = TextEditingController(text: item?.notes ?? '');
    _quantity = item?.quantity ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: EdgeInsets.only(
        bottom: max(
          MediaQuery.of(context).viewInsets.bottom,
          MediaQuery.of(context).viewPadding.bottom,
        ),
      ),
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
            Row(
              children: [
                Icon(
                  _isEditing ? Icons.edit : Icons.add_circle,
                  color: widget.accentColor,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Text(
                  _isEditing ? 'Edit Item' : 'Add to Wishlist',
                  style: AppTypography.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Name field
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _getNameLabel(),
                hintText: _getNameHint(),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              inputFormatters: [LengthLimitingTextInputFormatter(500)],
            ),
            const SizedBox(height: AppSpacing.md),

            // Species field (for fish and plants)
            if (widget.category != WishlistCategory.equipment) ...[
              TextField(
                controller: _speciesController,
                decoration: const InputDecoration(
                  labelText: 'Scientific name (optional)',
                  hintText: 'e.g., Paracheirodon innesi',
                ),
                inputFormatters: [LengthLimitingTextInputFormatter(500)],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Price and quantity row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Est. price (£)',
                      prefixText: '£ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity', style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Mark as purchased',
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                        ),
                        Text('$_quantity', style: AppTypography.labelLarge),
                        IconButton(
                          tooltip: 'Delete item',
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any details to remember...',
              ),
              maxLines: 2,
              inputFormatters: [LengthLimitingTextInputFormatter(500)],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Save button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: _isEditing ? 'Save Changes' : 'Add to Wishlist',
                onPressed: _nameController.text.trim().isNotEmpty
                    ? _save
                    : null,
                variant: AppButtonVariant.primary,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNameLabel() {
    switch (widget.category) {
      case WishlistCategory.fish:
        return 'Fish name';
      case WishlistCategory.plant:
        return 'Plant name';
      case WishlistCategory.equipment:
        return 'Equipment name';
    }
  }

  String _getNameHint() {
    switch (widget.category) {
      case WishlistCategory.fish:
        return 'e.g., Neon Tetra';
      case WishlistCategory.plant:
        return 'e.g., Java Fern';
      case WishlistCategory.equipment:
        return 'e.g., Fluval 207 Filter';
    }
  }

  Future<void> _save() async {
    final item = WishlistItem(
      id: widget.existingItem?.id,
      category: widget.category,
      name: _nameController.text.trim(),
      species: _speciesController.text.trim().isEmpty
          ? null
          : _speciesController.text.trim(),
      estimatedPrice: double.tryParse(_priceController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      quantity: _quantity,
      createdAt: widget.existingItem?.createdAt,
    );
    final navigator = Navigator.of(context);
    try {
      await widget.onSave(item);
      if (!mounted || !navigator.mounted) return;
      await navigator.maybePop();
      if (!widget.feedbackMessenger.mounted) return;
      AppFeedback.showSuccessViaMessenger(
        widget.feedbackMessenger,
        widget.successMessage(item),
      );
    } catch (_) {
      if (!mounted) return;
      AppFeedback.showError(
        context,
        'Could not save that wishlist item. Try again in a moment.',
      );
    }
  }
}
