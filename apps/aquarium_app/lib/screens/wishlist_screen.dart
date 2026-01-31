import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/species_database.dart';
import '../theme/app_theme.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  List<_WishlistItem> _items = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('fish_wishlist');
    if (json != null) {
      final list = jsonDecode(json) as List;
      setState(() {
        _items = list.map((e) => _WishlistItem.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_items.map((i) => i.toJson()).toList());
    await prefs.setString('fish_wishlist', json);
  }

  List<SpeciesInfo> get _searchResults {
    if (_searchQuery.length < 2) return [];
    return SpeciesDatabase.search(_searchQuery)
        .where((s) => !_items.any((i) => i.speciesName == s.commonName))
        .take(8)
        .toList();
  }

  void _addToWishlist(SpeciesInfo species) {
    setState(() {
      _items.add(_WishlistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        speciesName: species.commonName,
        notes: '',
        priority: 'medium',
        addedDate: DateTime.now(),
      ));
      _searchQuery = '';
    });
    _saveWishlist();
  }

  void _removeItem(int index) {
    final item = _items[index];
    setState(() {
      _items.removeAt(index);
    });
    _saveWishlist();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed ${item.speciesName}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _items.insert(index, item);
            });
            _saveWishlist();
          },
        ),
      ),
    );
  }

  void _updatePriority(int index, String priority) {
    setState(() {
      _items[index] = _items[index].copyWith(priority: priority);
    });
    _saveWishlist();
  }

  @override
  Widget build(BuildContext context) {
    final highPriority = _items.where((i) => i.priority == 'high').toList();
    final mediumPriority = _items.where((i) => i.priority == 'medium').toList();
    final lowPriority = _items.where((i) => i.priority == 'low').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish Wishlist'),
        actions: [
          if (_items.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  '${_items.length} fish',
                  style: AppTypography.bodySmall,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search fish to add...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Search results
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (ctx, i) {
                  final species = _searchResults[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.add_circle_outline, size: 20),
                    title: Text(species.commonName),
                    subtitle: Text('${species.careLevel} • ${species.temperament}'),
                    onTap: () => _addToWishlist(species),
                  );
                },
              ),
            ),

          // Wishlist
          Expanded(
            child: _items.isEmpty
                ? _EmptyState()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (highPriority.isNotEmpty) ...[
                        _SectionHeader(title: '🔥 Must Have', count: highPriority.length),
                        ...highPriority.map((item) => _WishlistTile(
                          item: item,
                          onDelete: () => _removeItem(_items.indexOf(item)),
                          onPriorityChanged: (p) => _updatePriority(_items.indexOf(item), p),
                        )),
                        const SizedBox(height: 16),
                      ],
                      if (mediumPriority.isNotEmpty) ...[
                        _SectionHeader(title: '⭐ Want', count: mediumPriority.length),
                        ...mediumPriority.map((item) => _WishlistTile(
                          item: item,
                          onDelete: () => _removeItem(_items.indexOf(item)),
                          onPriorityChanged: (p) => _updatePriority(_items.indexOf(item), p),
                        )),
                        const SizedBox(height: 16),
                      ],
                      if (lowPriority.isNotEmpty) ...[
                        _SectionHeader(title: '💭 Maybe Someday', count: lowPriority.length),
                        ...lowPriority.map((item) => _WishlistTile(
                          item: item,
                          onDelete: () => _removeItem(_items.indexOf(item)),
                          onPriorityChanged: (p) => _updatePriority(_items.indexOf(item), p),
                        )),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _WishlistItem {
  final String id;
  final String speciesName;
  final String notes;
  final String priority; // high, medium, low
  final DateTime addedDate;

  const _WishlistItem({
    required this.id,
    required this.speciesName,
    required this.notes,
    required this.priority,
    required this.addedDate,
  });

  _WishlistItem copyWith({String? notes, String? priority}) {
    return _WishlistItem(
      id: id,
      speciesName: speciesName,
      notes: notes ?? this.notes,
      priority: priority ?? this.priority,
      addedDate: addedDate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'speciesName': speciesName,
    'notes': notes,
    'priority': priority,
    'addedDate': addedDate.toIso8601String(),
  };

  factory _WishlistItem.fromJson(Map<String, dynamic> json) => _WishlistItem(
    id: json['id'],
    speciesName: json['speciesName'],
    notes: json['notes'] ?? '',
    priority: json['priority'] ?? 'medium',
    addedDate: DateTime.parse(json['addedDate']),
  );
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('Your Wishlist is Empty', style: AppTypography.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Search and add fish you\'d love to keep someday!',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(width: 8),
          Text('($count)', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _WishlistTile extends StatelessWidget {
  final _WishlistItem item;
  final VoidCallback onDelete;
  final Function(String) onPriorityChanged;

  const _WishlistTile({
    required this.item,
    required this.onDelete,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final species = SpeciesDatabase.lookup(item.speciesName);

    return Dismissible(
      key: Key(item.id),
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
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.set_meal, color: AppColors.primary, size: 20),
          ),
          title: Text(item.speciesName, style: AppTypography.labelLarge),
          subtitle: species != null
              ? Text(
                  '${species.careLevel} • ${species.temperament} • ${species.adultSizeCm.toStringAsFixed(0)}cm',
                  style: AppTypography.bodySmall,
                )
              : null,
          trailing: PopupMenuButton<String>(
            initialValue: item.priority,
            onSelected: onPriorityChanged,
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'high', child: Text('🔥 Must Have')),
              const PopupMenuItem(value: 'medium', child: Text('⭐ Want')),
              const PopupMenuItem(value: 'low', child: Text('💭 Maybe')),
            ],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _priorityColor(item.priority).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _priorityEmoji(item.priority),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high': return AppColors.error;
      case 'medium': return AppColors.warning;
      default: return AppColors.textHint;
    }
  }

  String _priorityEmoji(String priority) {
    switch (priority) {
      case 'high': return '🔥';
      case 'medium': return '⭐';
      default: return '💭';
    }
  }
}
