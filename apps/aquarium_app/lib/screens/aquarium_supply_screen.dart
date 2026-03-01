import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';

/// Model for an aquarium product/supply item.
class AquariumSupplyItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final double lowStockThreshold;
  final String unit; // e.g., "ml", "g", "tablets", "packs"
  final double? unitCost;
  final DateTime? lastPurchased;
  final String? notes;

  const AquariumSupplyItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.lowStockThreshold,
    required this.unit,
    this.unitCost,
    this.lastPurchased,
    this.notes,
  });

  bool get isLowStock => quantity <= lowStockThreshold;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'quantity': quantity,
        'lowStockThreshold': lowStockThreshold,
        'unit': unit,
        'unitCost': unitCost,
        'lastPurchased': lastPurchased?.toIso8601String(),
        'notes': notes,
      };

  factory AquariumSupplyItem.fromJson(Map<String, dynamic> json) =>
      AquariumSupplyItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String? ?? 'General',
        quantity: (json['quantity'] as num).toDouble(),
        lowStockThreshold: (json['lowStockThreshold'] as num).toDouble(),
        unit: json['unit'] as String? ?? 'units',
        unitCost: (json['unitCost'] as num?)?.toDouble(),
        lastPurchased: json['lastPurchased'] != null
            ? DateTime.parse(json['lastPurchased'] as String)
            : null,
        notes: json['notes'] as String?,
      );

  AquariumSupplyItem copyWith({
    String? id,
    String? name,
    String? category,
    double? quantity,
    double? lowStockThreshold,
    String? unit,
    double? unitCost,
    DateTime? lastPurchased,
    String? notes,
  }) =>
      AquariumSupplyItem(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        quantity: quantity ?? this.quantity,
        lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
        unit: unit ?? this.unit,
        unitCost: unitCost ?? this.unitCost,
        lastPurchased: lastPurchased ?? this.lastPurchased,
        notes: notes ?? this.notes,
      );
}

const _kPrefsKey = 'aquarium_supplies_v1';
const _kCurrencyKey = 'aquarium_supply_currency';

const _kCategories = [
  'Water Treatment',
  'Food',
  'Fertiliser',
  'Medication',
  'Test Kits',
  'CO2',
  'Equipment',
  'Substrate',
  'General',
];

/// Aquarium supply inventory screen - tracks product quantities, low-stock alerts,
/// and monthly expense summaries.
class AquariumSupplyScreen extends ConsumerStatefulWidget {
  const AquariumSupplyScreen({super.key});

  @override
  ConsumerState<AquariumSupplyScreen> createState() =>
      _AquariumSupplyScreenState();
}

class _AquariumSupplyScreenState extends ConsumerState<AquariumSupplyScreen>
    with SingleTickerProviderStateMixin {
  List<AquariumSupplyItem> _items = [];
  bool _loading = true;
  String _currency = '£';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    final currency = prefs.getString(_kCurrencyKey) ?? '£';
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      setState(() {
        _items = list
            .map((e) => AquariumSupplyItem.fromJson(e as Map<String, dynamic>))
            .toList();
        _currency = currency;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kPrefsKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
    await prefs.setString(_kCurrencyKey, _currency);
  }

  // ── Stats ──────────────────────────────────────────────────────────────────

  List<AquariumSupplyItem> get _lowStockItems =>
      _items.where((i) => i.isLowStock).toList();

  double get _monthlyEstimate {
    final now = DateTime.now();
    return _items
        .where((i) =>
            i.lastPurchased != null &&
            i.lastPurchased!.month == now.month &&
            i.lastPurchased!.year == now.year &&
            i.unitCost != null)
        .fold(0, (sum, i) => sum + (i.unitCost ?? 0));
  }

  // ── Add / Edit / Delete ────────────────────────────────────────────────────

  void _openAddEdit([AquariumSupplyItem? existing]) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _SupplyItemSheet(
        currency: _currency,
        existing: existing,
        onSave: (item) {
          setState(() {
            if (existing == null) {
              _items.insert(0, item);
            } else {
              final idx = _items.indexWhere((i) => i.id == item.id);
              if (idx >= 0) _items[idx] = item;
            }
          });
          _save();
        },
      ),
    );
  }

  void _delete(AquariumSupplyItem item) {
    final idx = _items.indexOf(item);
    setState(() => _items.remove(item));
    _save();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: ${item.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => _items.insert(idx, item));
            _save();
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _confirmDelete(AquariumSupplyItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove "${item.name}" from inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _delete(item);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Supplies & Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Currency',
            onPressed: _showCurrencyDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Badge(
                isLabelVisible: _lowStockItems.isNotEmpty,
                label: Text('${_lowStockItems.length}'),
                child: const Icon(Icons.inventory_2_outlined),
              ),
              text: 'Inventory',
            ),
            const Tab(icon: Icon(Icons.bar_chart), text: 'Summary'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInventoryTab(),
                _buildSummaryTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEdit(),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    ),
    );
  }

  Widget _buildInventoryTab() {
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text('Your supply shelf is empty!',
                style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add products like fertilisers, test kits,\nand treatments to track stock levels.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => _openAddEdit(),
              icon: const Icon(Icons.add),
              label: const Text('Add First Product'),
            ),
          ],
        ),
      );
    }

    // Group: low stock first, then alphabetical by category
    final lowStock = _items.where((i) => i.isLowStock).toList();
    final normal = _items.where((i) => !i.isLowStock).toList();

    final allItems = <_SupplyListItem>[];
    if (lowStock.isNotEmpty) {
      allItems.add(_SupplyListItem.header('⚠️ Low Stock', AppColors.warning));
      allItems.addAll(lowStock.map(_SupplyListItem.item));
      allItems.add(_SupplyListItem.spacer());
    }
    if (normal.isNotEmpty) {
      allItems.add(_SupplyListItem.header('In Stock', AppColors.success));
      allItems.addAll(normal.map(_SupplyListItem.item));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        if (item.isHeader) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: item.headerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(item.headerTitle!, style: AppTypography.labelLarge),
              ],
            ),
          );
        }
        if (item.isSpacer) return const SizedBox(height: AppSpacing.md);

        final supply = item.supply!;
        return _SupplyCard(
          item: supply,
          currency: _currency,
          onTap: () => _openAddEdit(supply),
          onDelete: () => _confirmDelete(supply),
        );
      },
    );
  }

  Widget _buildSummaryTab() {
    if (_items.isEmpty) {
      return const Center(child: Text('Add products to see a summary.'));
    }

    final byCategory = <String, List<AquariumSupplyItem>>{};
    for (final item in _items) {
      byCategory.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Monthly estimate card
        Card(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm2),
                  decoration: BoxDecoration(
                    color: AppOverlays.primary10,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Icon(Icons.calendar_month, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Month', style: AppTypography.bodySmall),
                    Text(
                      '$_currency${_monthlyEstimate.toStringAsFixed(2)}',
                      style: AppTypography.headlineMedium,
                    ),
                    Text(
                      'Based on items purchased this month',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Low stock summary
        if (_lowStockItems.isNotEmpty) ...[
          Text('Low Stock Alert', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warningAlpha10,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: AppColors.warningAlpha30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _lowStockItems
                  .map((i) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 16, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    '${i.name}: ${i.quantity} ${i.unit} left')),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // By category
        Text('By Category', style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.sm),
        ...byCategory.entries.map((entry) {
          final totalItems = entry.value.length;
          final lowStockCount = entry.value.where((i) => i.isLowStock).length;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppOverlays.primary10,
                child: Icon(Icons.category_outlined, color: AppColors.primary),
              ),
              title: Text(entry.key),
              subtitle: Text('$totalItems item${totalItems == 1 ? '' : 's'}'),
              trailing: lowStockCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warningAlpha10,
                        borderRadius: AppRadius.pillRadius,
                      ),
                      child: Text(
                        '$lowStockCount low',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.warning),
                      ),
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: _currency);
        return AlertDialog(
          title: const Text('Currency Symbol'),
          content: TextField(
            controller: controller,
            maxLength: 3,
            decoration: const InputDecoration(hintText: '£, \$, €...'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isNotEmpty) {
                  setState(() => _currency = val);
                  _save();
                }
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// ── Helper list item wrapper ───────────────────────────────────────────────

class _SupplyListItem {
  final bool isHeader;
  final bool isSpacer;
  final String? headerTitle;
  final Color? headerColor;
  final AquariumSupplyItem? supply;

  const _SupplyListItem._({
    this.isHeader = false,
    this.isSpacer = false,
    this.headerTitle,
    this.headerColor,
    this.supply,
  });

  factory _SupplyListItem.header(String title, Color color) =>
      _SupplyListItem._(isHeader: true, headerTitle: title, headerColor: color);

  factory _SupplyListItem.item(AquariumSupplyItem s) =>
      _SupplyListItem._(supply: s);

  factory _SupplyListItem.spacer() => const _SupplyListItem._(isSpacer: true);
}

// ── Supply card ────────────────────────────────────────────────────────────

class _SupplyCard extends StatelessWidget {
  final AquariumSupplyItem item;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SupplyCard({
    required this.item,
    required this.currency,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: item.isLowStock ? AppColors.warningAlpha05 : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              item.isLowStock ? AppColors.warningAlpha10 : AppOverlays.primary10,
          child: Icon(
            item.isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2,
            color: item.isLowStock ? AppColors.warning : AppColors.primary,
          ),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.quantity} ${item.unit} - threshold: ${item.lowStockThreshold} ${item.unit}',
              style: AppTypography.bodySmall,
            ),
            if (item.lastPurchased != null)
              Text(
                'Last purchased: ${DateFormat('MMM d, yyyy').format(item.lastPurchased!)}',
                style: AppTypography.bodySmall,
              ),
            if (item.unitCost != null)
              Text(
                'Cost: $currency${item.unitCost!.toStringAsFixed(2)}',
                style: AppTypography.bodySmall,
              ),
          ],
        ),
        isThreeLine: item.lastPurchased != null,
        trailing: PopupMenuButton(
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (v) {
            if (v == 'edit') onTap();
            if (v == 'delete') onDelete();
          },
        ),
        onTap: onTap,
      ),
    );
  }
}

// ── Add / Edit sheet ───────────────────────────────────────────────────────

class _SupplyItemSheet extends StatefulWidget {
  final String currency;
  final AquariumSupplyItem? existing;
  final void Function(AquariumSupplyItem) onSave;

  const _SupplyItemSheet({
    required this.currency,
    this.existing,
    required this.onSave,
  });

  @override
  State<_SupplyItemSheet> createState() => _SupplyItemSheetState();
}

class _SupplyItemSheetState extends State<_SupplyItemSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _quantityCtrl;
  late TextEditingController _thresholdCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _costCtrl;
  late TextEditingController _notesCtrl;
  late String _category;
  DateTime? _lastPurchased;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _quantityCtrl = TextEditingController(
        text: e?.quantity.toString() ?? '');
    _thresholdCtrl = TextEditingController(
        text: e?.lowStockThreshold.toString() ?? '');
    _unitCtrl = TextEditingController(text: e?.unit ?? 'units');
    _costCtrl = TextEditingController(
        text: e?.unitCost?.toStringAsFixed(2) ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _category = e?.category ?? 'General';
    _lastPurchased = e?.lastPurchased;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    _thresholdCtrl.dispose();
    _unitCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null ? 'Add Product' : 'Edit Product',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'e.g., Seachem Flourish',
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 12),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _kCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Quantity *'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    textCapitalization: TextCapitalization.none,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _thresholdCtrl,
              decoration: InputDecoration(
                labelText: 'Low-stock alert threshold *',
                hintText: 'Alert when below this quantity',
                suffixText: _unitCtrl.text,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _costCtrl,
              decoration: InputDecoration(
                labelText: 'Cost per purchase (optional)',
                prefixText: widget.currency,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
            ),
            const SizedBox(height: 12),

            // Last purchased date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _lastPurchased ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _lastPurchased = date);
              },
              borderRadius: AppRadius.mediumRadius,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Text(
                      _lastPurchased != null
                          ? 'Last purchased: ${DateFormat('MMM d, yyyy').format(_lastPurchased!)}'
                          : 'Set last purchased date (optional)',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g., Amazon subscribe & save',
              ),
              maxLines: 2,
            ),

            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final quantity = double.tryParse(_quantityCtrl.text.trim());
    final threshold = double.tryParse(_thresholdCtrl.text.trim());

    if (name.isEmpty) {
      AppFeedback.showWarning(context, 'Please enter a product name');
      return;
    }
    if (quantity == null) {
      AppFeedback.showWarning(context, 'Please enter a valid quantity');
      return;
    }
    if (threshold == null) {
      AppFeedback.showWarning(context, 'Please enter a valid low-stock threshold');
      return;
    }

    setState(() => _isSaving = true);

    final item = AquariumSupplyItem(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: _category,
      quantity: quantity,
      lowStockThreshold: threshold,
      unit: _unitCtrl.text.trim().isNotEmpty ? _unitCtrl.text.trim() : 'units',
      unitCost: double.tryParse(_costCtrl.text.trim()),
      lastPurchased: _lastPurchased,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    widget.onSave(item);
    if (mounted) Navigator.pop(context);
  }
}
