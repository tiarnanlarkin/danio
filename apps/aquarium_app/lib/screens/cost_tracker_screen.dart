import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';
import '../utils/logger.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import '../widgets/danio_snack_bar.dart';

const _fallbackCurrencySymbol = '\u00A3';
const double _maxCostTrackerReadableWidth = 720;
const _defaultCurrencyOptions = <String>[
  _fallbackCurrencySymbol,
  r'$',
  '\u20AC',
  '\u00A5',
  r'A$',
  r'C$',
];

List<String> _currencyOptions(String activeCurrency) {
  final options = <String>[];
  final active = activeCurrency.trim();
  if (active.isNotEmpty) {
    options.add(active);
  }

  for (final option in _defaultCurrencyOptions) {
    if (!options.contains(option)) {
      options.add(option);
    }
  }

  return options;
}

/// Returns the currency symbol for the current device locale.
/// Falls back to GBP if the locale cannot be determined.
String _localeCurrencySymbol() {
  try {
    final locale = Platform.localeName; // e.g. "en_GB", "en_US"
    final format = NumberFormat.simpleCurrency(locale: locale);
    return format.currencySymbol;
  } catch (e) {
    appLog(
      'CostTrackerScreen: locale currency lookup failed, using GBP fallback: $e',
      tag: 'CostTrackerScreen',
    );
    return _fallbackCurrencySymbol;
  }
}

class CostTrackerScreen extends ConsumerStatefulWidget {
  const CostTrackerScreen({super.key});

  @override
  ConsumerState<CostTrackerScreen> createState() => _CostTrackerScreenState();
}

class _CostTrackerScreenState extends ConsumerState<CostTrackerScreen> {
  List<_Expense> _expenses = [];
  String _currency = _localeCurrencySymbol();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final json = prefs.getString('cost_tracker_expenses');
    final currency =
        prefs.getString('cost_tracker_currency') ?? _localeCurrencySymbol();

    if (!mounted) return;
    if (json != null) {
      final list = jsonDecode(json) as List;
      setState(() {
        _expenses = list.map((e) => _Expense.fromJson(e)).toList();
        _currency = currency;
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final json = jsonEncode(_expenses.map((e) => e.toJson()).toList());
    await prefs.setString('cost_tracker_expenses', json);
    await prefs.setString('cost_tracker_currency', _currency);
  }

  Future<bool> _saveExpensesWithRollback({
    required List<_Expense> rollbackExpenses,
    required String errorMessage,
    required String logMessage,
  }) async {
    try {
      await _saveExpenses();
      return true;
    } catch (error, stackTrace) {
      logError(
        '$logMessage: $error',
        stackTrace: stackTrace,
        tag: 'CostTrackerScreen',
      );
      if (!mounted) return false;
      setState(() => _expenses = List<_Expense>.from(rollbackExpenses));
      AppFeedback.showError(context, errorMessage);
      return false;
    }
  }

  void _addExpense() {
    showAppDragSheet(
      context: context,
      builder: (ctx) => _AddExpenseSheet(
        currency: _currency,
        onSave: (expense) async {
          setState(() {
            _expenses.insert(0, expense);
          });
          await _saveExpenses();
          if (!mounted) return;
          AppFeedback.showSuccess(context, '${expense.description} added.');
        },
      ),
    );
  }

  Future<void> _deleteExpense(int index) async {
    final expense = _expenses[index];
    final previousExpenses = List<_Expense>.from(_expenses);
    setState(() {
      _expenses.removeAt(index);
    });
    final saved = await _saveExpensesWithRollback(
      rollbackExpenses: previousExpenses,
      errorMessage: "Couldn't delete that expense. Try again in a moment.",
      logMessage: 'Failed to persist deleted expense',
    );
    if (!saved || !mounted) return;

    DanioSnackBar.show(
      context,
      'Deleted: ${expense.description}',
      actionLabel: 'Undo',
      onAction: () async {
        final previousExpenses = List<_Expense>.from(_expenses);
        final restoreIndex = index > _expenses.length
            ? _expenses.length
            : index;
        setState(() {
          _expenses.insert(restoreIndex, expense);
        });
        await _saveExpensesWithRollback(
          rollbackExpenses: previousExpenses,
          errorMessage: "Couldn't restore that expense. Try again in a moment.",
          logMessage: 'Failed to persist restored expense',
        );
      },
    );
  }

  double get _totalSpent => _expenses.fold(0, (sum, e) => sum + e.amount);

  double get _thisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get _thisYear {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year)
        .fold(0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cost Tracker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Cost tracker settings',
              onPressed: _showSettings,
            ),
          ],
        ),
        body: _expenses.isEmpty
            ? _CostTrackerReadableFrame(child: _EmptyState(onAdd: _addExpense))
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: _buildItemCount(),
                itemBuilder: (context, index) {
                  return _CostTrackerReadableFrame(
                    child: _buildListItem(index),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addExpense,
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
        ),
      ),
    );
  }

  int _buildItemCount() {
    final sortedCategories = _byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int count = 0;
    count += 3; // Summary cards row, spacing, all-time card
    count += 1; // Spacing after summary

    if (_byCategory.isNotEmpty) {
      count += 2; // "By Category" header + spacing
      count += sortedCategories.length; // Category bars
      count += 1; // Spacing after categories
    }

    count += 2; // "Recent Expenses" header + spacing
    count += _expenses.length; // Expense tiles

    return count;
  }

  Widget _buildListItem(int index) {
    final sortedCategories = _byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int currentIndex = 0;

    // Summary cards row
    if (index == currentIndex++) {
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              title: 'This Month',
              amount: _thisMonth,
              currency: _currency,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: _SummaryCard(
              title: 'This Year',
              amount: _thisYear,
              currency: _currency,
              color: AppColors.secondary,
            ),
          ),
        ],
      );
    }

    // Spacing
    if (index == currentIndex++) {
      return const SizedBox(height: AppSpacing.sm2);
    }

    // All-time total card
    if (index == currentIndex++) {
      return _SummaryCard(
        title: 'All Time Total',
        amount: _totalSpent,
        currency: _currency,
        color: AppColors.success,
      );
    }

    // Spacing
    if (index == currentIndex++) {
      return const SizedBox(height: AppSpacing.lg);
    }

    // Category breakdown section
    if (_byCategory.isNotEmpty) {
      // "By Category" header
      if (index == currentIndex++) {
        return Text('By Category', style: AppTypography.headlineSmall);
      }

      // Spacing
      if (index == currentIndex++) {
        return const SizedBox(height: AppSpacing.sm2);
      }

      // Category bars
      if (index < currentIndex + sortedCategories.length) {
        final categoryEntry = sortedCategories[index - currentIndex];
        return _CategoryBar(
          category: categoryEntry.key,
          amount: categoryEntry.value,
          total: _totalSpent,
          currency: _currency,
        );
      }
      currentIndex += sortedCategories.length;

      // Spacing
      if (index == currentIndex++) {
        return const SizedBox(height: AppSpacing.lg);
      }
    }

    // "Recent Expenses" header
    if (index == currentIndex++) {
      return Text('Recent Expenses', style: AppTypography.headlineSmall);
    }

    // Spacing
    if (index == currentIndex++) {
      return const SizedBox(height: AppSpacing.sm2);
    }

    // Expense tiles
    final expenseIndex = index - currentIndex;
    return _ExpenseTile(
      expense: _expenses[expenseIndex],
      currency: _currency,
      onDelete: () => _deleteExpense(expenseIndex),
    );
  }

  void _showSettings() {
    showAppDialog(
      context: context,
      title: 'Settings',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Currency'),
            trailing: DropdownButton<String>(
              value: _currency,
              items: _currencyOptions(
                _currency,
              ).map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                setState(() => _currency = v ?? _localeCurrencySymbol());
                _saveExpenses();
                Navigator.maybePop(context);
              },
            ),
          ),
          ListTile(
            title: const Text('Clear All Data'),
            trailing: IconButton(
              tooltip: 'Delete expense',
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () async {
                await Navigator.maybePop(context);
                if (!mounted) return;
                await _confirmClear();
              },
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Close',
          onPressed: () => Navigator.maybePop(context),
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
      ],
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showAppDestructiveDialog(
      context: context,
      title: 'Clear All Expenses?',
      message:
          'This clears your saved expenses. You can undo within 5 seconds.',
      destructiveLabel: 'Clear All',
    );

    if (ok != true || !mounted) return;

    final clearedExpenses = List<_Expense>.from(_expenses);
    setState(() => _expenses = []);
    final saved = await _saveExpensesWithRollback(
      rollbackExpenses: clearedExpenses,
      errorMessage: "Couldn't clear expenses. Try again in a moment.",
      logMessage: 'Failed to persist cleared expenses',
    );

    if (!saved || !mounted) return;

    DanioSnackBar.show(
      context,
      'Expenses cleared',
      duration: const Duration(seconds: 5),
      actionLabel: 'Undo',
      onAction: () async {
        final previousExpenses = List<_Expense>.from(_expenses);
        setState(() => _expenses = List<_Expense>.from(clearedExpenses));
        await _saveExpensesWithRollback(
          rollbackExpenses: previousExpenses,
          errorMessage:
              "Couldn't restore those expenses. Try again in a moment.",
          logMessage: 'Failed to persist restored expenses',
        );
      },
    );
  }
}

class _CostTrackerReadableFrame extends StatelessWidget {
  final Widget child;

  const _CostTrackerReadableFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _maxCostTrackerReadableWidth,
        ),
        child: child,
      ),
    );
  }
}

class _Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  _Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
  };

  factory _Expense.fromJson(Map<String, dynamic> json) => _Expense(
    id: json['id'],
    description: json['description'],
    amount: json['amount'],
    category: json['category'],
    date: DateTime.parse(json['date']),
  );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: AppIconSizes.xxl,
              color: context.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Track Your Fishkeeping Expenses',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Keep track of fish, equipment, plants, and supplies. See where your money goes!',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Add First Expense',
              onPressed: onAdd,
              leadingIcon: Icons.add,
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$currency${amount.toStringAsFixed(2)}',
              style: AppTypography.headlineSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String category;
  final double amount;
  final double total;
  final String currency;

  const _CategoryBar({
    required this.category,
    required this.amount,
    required this.total,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? amount / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(category, style: AppTypography.labelLarge)),
              Text(
                '$currency${amount.toStringAsFixed(2)}',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: AppRadius.xsRadius,
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: context.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final _Expense expense;
  final String currency;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.currency,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: AppColors.onPrimary),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              borderRadius: AppRadius.smallRadius,
            ),
            child: Icon(
              _categoryIcon(expense.category),
              color: AppColors.primary,
              size: AppIconSizes.sm,
            ),
          ),
          title: Text(expense.description, style: AppTypography.labelLarge),
          subtitle: Text(
            '${expense.category} - ${DateFormat('d MMM y').format(expense.date)}',
            style: AppTypography.bodySmall,
          ),
          trailing: Text(
            '$currency${expense.amount.toStringAsFixed(2)}',
            style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'fish':
        return Icons.set_meal;
      case 'plants':
        return Icons.eco;
      case 'equipment':
        return Icons.build;
      case 'food':
        return Icons.restaurant;
      case 'medication':
        return Icons.medical_services;
      case 'decor':
        return Icons.landscape;
      case 'tank':
        return Icons.water;
      case 'test kits':
        return Icons.science;
      default:
        return Icons.shopping_bag;
    }
  }
}

class _AddExpenseSheet extends StatefulWidget {
  final String currency;
  final Future<void> Function(_Expense) onSave;

  const _AddExpenseSheet({required this.currency, required this.onSave});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String? _formValidationMessage;
  String _category = 'Fish';
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  final _categories = [
    'Fish',
    'Plants',
    'Equipment',
    'Food',
    'Medication',
    'Decor',
    'Tank',
    'Test Kits',
    'Other',
  ];

  String? get _validationMessage {
    if (_formValidationMessage != null) {
      return _formValidationMessage;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);
    if (amountText.isNotEmpty && amount != null && amount <= 0) {
      return 'Enter an amount greater than 0';
    }
    return null;
  }

  void _clearSubmitValidation() {
    if (_formValidationMessage != null) {
      setState(() => _formValidationMessage = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md +
            max(
              MediaQuery.of(context).viewInsets.bottom,
              MediaQuery.of(context).viewPadding.bottom,
            ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Expense', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'e.g., Neon Tetras x6',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onChanged: (_) => _clearSubmitValidation(),
          ),
          const SizedBox(height: AppSpacing.sm2),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: widget.currency,
              border: const OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            onChanged: (_) {
              if (_formValidationMessage != null) {
                _formValidationMessage = null;
              }
              setState(() {});
            },
          ),
          if (_validationMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              _validationMessage!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.sm2),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Other'),
          ),
          const SizedBox(height: AppSpacing.sm2),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(DateFormat('d MMMM y').format(_date)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null && mounted) {
                setState(() => _date = picked);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Save Expense',
            onPressed: () async {
              final description = _descController.text.trim();
              final amount = double.tryParse(_amountController.text);
              if (description.isEmpty || amount == null) {
                setState(
                  () => _formValidationMessage = 'Please fill in all fields',
                );
                AppFeedback.showWarning(context, 'Please fill in all fields');
                return;
              }
              if (amount <= 0) {
                setState(
                  () =>
                      _formValidationMessage = 'Enter an amount greater than 0',
                );
                AppFeedback.showWarning(
                  context,
                  'Enter an amount greater than 0',
                );
                return;
              }

              final navigator = Navigator.of(context);
              await widget.onSave(
                _Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  description: description,
                  amount: amount,
                  category: _category,
                  date: _date,
                ),
              );
              if (!mounted) return;
              await navigator.maybePop();
            },
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
