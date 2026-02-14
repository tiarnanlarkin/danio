import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../utils/app_feedback.dart';

class CostTrackerScreen extends ConsumerStatefulWidget {
  const CostTrackerScreen({super.key});

  @override
  ConsumerState<CostTrackerScreen> createState() => _CostTrackerScreenState();
}

class _CostTrackerScreenState extends ConsumerState<CostTrackerScreen> {
  List<_Expense> _expenses = [];
  String _currency = '£';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('cost_tracker_expenses');
    final currency = prefs.getString('cost_tracker_currency') ?? '£';

    if (json != null) {
      final list = jsonDecode(json) as List;
      setState(() {
        _expenses = list.map((e) => _Expense.fromJson(e)).toList();
        _currency = currency;
      });
    }
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_expenses.map((e) => e.toJson()).toList());
    await prefs.setString('cost_tracker_expenses', json);
    await prefs.setString('cost_tracker_currency', _currency);
  }

  void _addExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddExpenseSheet(
        currency: _currency,
        onSave: (expense) {
          setState(() {
            _expenses.insert(0, expense);
          });
          _saveExpenses();
        },
      ),
    );
  }

  void _deleteExpense(int index) {
    final expense = _expenses[index];
    setState(() {
      _expenses.removeAt(index);
    });
    _saveExpenses();

    // Use native snackbar for undo functionality (AppFeedback doesn't support actions yet)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted: ${expense.description}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _expenses.insert(index, expense);
            });
            _saveExpenses();
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
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
    return Scaffold(
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
          ? _EmptyState(onAdd: _addExpense)
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _buildItemCount(),
              itemBuilder: (context, index) {
                return _buildListItem(index);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
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
          const SizedBox(width: 12),
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
      return const SizedBox(height: 12);
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
        return const SizedBox(height: 12);
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
      return const SizedBox(height: 12);
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Currency'),
              trailing: DropdownButton<String>(
                value: _currency,
                items: ['£', '\$', '€', '¥', 'A\$', 'C\$']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _currency = v ?? '£');
                  _saveExpenses();
                  Navigator.pop(ctx);
                },
              ),
            ),
            ListTile(
              title: const Text('Clear All Data'),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: AppColors.error),
                onPressed: () {
                  Navigator.pop(ctx);
                  _confirmClear();
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Expenses?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              setState(() => _expenses = []);
              _saveExpenses();
              Navigator.pop(ctx);
            },
            child: const Text('Clear All'),
          ),
        ],
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
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Track Your Aquarium Expenses',
              style: AppTypography.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Keep track of fish, equipment, plants, and supplies. See where your money goes!',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add First Expense'),
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
      color: color.withOpacity(0.1),
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
      padding: const EdgeInsets.only(bottom: 8),
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
              backgroundColor: AppColors.surfaceVariant,
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
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
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
              size: 20,
            ),
          ),
          title: Text(expense.description, style: AppTypography.labelLarge),
          subtitle: Text(
            '${expense.category} • ${DateFormat('MMM d, y').format(expense.date)}',
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
  final Function(_Expense) onSave;

  const _AddExpenseSheet({required this.currency, required this.onSave});

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
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
          ),
          const SizedBox(height: 12),
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
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Other'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date'),
            subtitle: Text(DateFormat('MMMM d, y').format(_date)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _date = picked);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (_descController.text.isEmpty || amount == null) {
                  AppFeedback.showWarning(context, 'Please fill in all fields');
                  return;
                }

                widget.onSave(
                  _Expense(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    description: _descController.text,
                    amount: amount,
                    category: _category,
                    date: _date,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save Expense'),
            ),
          ),
        ],
      ),
    );
  }
}
