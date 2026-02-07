import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/species_database.dart';
import '../models/models.dart';
import '../models/learning.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/compatibility_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import 'livestock_detail_screen.dart';

const _uuid = Uuid();

class LivestockScreen extends ConsumerWidget {
  final String tankId;

  const LivestockScreen({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestockAsync = ref.watch(livestockProvider(tankId));
    final tankAsync = ref.watch(tankProvider(tankId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestock'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'add') _showAddDialog(context, ref);
              if (value == 'bulk') _showBulkAddDialog(context, ref);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'add', child: Text('Add livestock')),
              PopupMenuItem(value: 'bulk', child: Text('Bulk add')),
            ],
          ),
        ],
      ),
      body: livestockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          message: 'Failed to load livestock',
          details: 'Please check your connection and try again',
          onRetry: () => ref.invalidate(livestockProvider(tankId)),
        ),
        data: (livestock) {
          if (livestock.isEmpty) {
            return EmptyState(
              icon: Icons.set_meal,
              title: 'No livestock yet',
              message: 'Add fish, shrimp, or snails to track your aquatic friends',
              actionLabel: 'Add Livestock',
              onAction: () => _showAddDialog(context, ref),
            );
          }

          final totalCount = livestock.fold<int>(0, (sum, l) => sum + l.count);
          final tank = tankAsync.asData?.value;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.pets, color: AppColors.primary, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$totalCount total', style: AppTypography.headlineMedium),
                          Text('${livestock.length} species', style: AppTypography.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // List
              ...livestock.map((l) => _LivestockCard(
                livestock: l,
                tank: tank,
                allLivestock: livestock,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LivestockDetailScreen(tankId: tankId, livestock: l),
                  ),
                ),
                onEdit: () => _showEditDialog(context, ref, l),
                onDelete: () => _confirmDelete(context, ref, l),
              )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddLivestockSheet(tankId: tankId, ref: ref),
    );
  }

  void _showBulkAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BulkAddLivestockSheet(tankId: tankId, ref: ref),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Livestock livestock) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddLivestockSheet(tankId: tankId, ref: ref, existing: livestock),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Livestock livestock) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Livestock?'),
        content: Text('Remove ${livestock.count}× ${livestock.commonName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final storage = ref.read(storageServiceProvider);
              final now = DateTime.now();

              await storage.deleteLivestock(livestock.id);

              // Auto-create an activity log entry.
              await storage.saveLog(
                LogEntry(
                  id: _uuid.v4(),
                  tankId: tankId,
                  type: LogType.livestockRemoved,
                  timestamp: now,
                  title: 'Removed ${livestock.count}× ${livestock.commonName}',
                  relatedLivestockId: livestock.id,
                  createdAt: now,
                ),
              );

              ref.invalidate(livestockProvider(tankId));
              ref.invalidate(logsProvider(tankId));
              ref.invalidate(allLogsProvider(tankId));
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _LivestockCard extends StatelessWidget {
  final Livestock livestock;
  final Tank? tank;
  final List<Livestock> allLivestock;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LivestockCard({
    required this.livestock,
    this.tank,
    required this.allLivestock,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Check for species info and compatibility
    final species = SpeciesDatabase.lookup(livestock.commonName) ??
        (livestock.scientificName != null
            ? SpeciesDatabase.lookup(livestock.scientificName!)
            : null);

    List<CompatibilityIssue> issues = [];
    if (tank != null) {
      issues = CompatibilityService.checkLivestockCompatibility(
        livestock: livestock,
        tank: tank!,
        existingLivestock: allLivestock,
      );
    }
    
    final hasIssues = issues.isNotEmpty;
    final level = hasIssues ? CompatibilityService.overallLevel(issues) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: level == CompatibilityLevel.incompatible
          ? AppColors.error.withOpacity(0.05)
          : (level == CompatibilityLevel.warning
              ? AppColors.warning.withOpacity(0.05)
              : null),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.set_meal, color: AppColors.primary),
            ),
            if (hasIssues)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: level == CompatibilityLevel.incompatible
                        ? AppColors.error
                        : AppColors.warning,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    level == CompatibilityLevel.incompatible
                        ? Icons.error
                        : Icons.warning,
                    size: 10,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        title: Text(livestock.commonName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (livestock.scientificName != null || species != null)
              Text(
                livestock.scientificName ?? species?.scientificName ?? '',
                style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
              ),
            Row(
              children: [
                Text('×${livestock.count}', style: AppTypography.bodySmall),
                if (species != null) ...[
                  const SizedBox(width: 8),
                  Text('• ${species.temperament}', style: AppTypography.bodySmall),
                ],
              ],
            ),
            if (hasIssues)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${issues.length} compatibility ${issues.length == 1 ? 'note' : 'notes'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: level == CompatibilityLevel.incompatible
                        ? AppColors.error
                        : AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'view', child: Text('View Details')),
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Remove')),
          ],
          onSelected: (value) {
            if (value == 'view') onTap();
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
        ),
        onTap: onTap,
      ),
    );
  }
}

class _AddLivestockSheet extends StatefulWidget {
  final String tankId;
  final WidgetRef ref;
  final Livestock? existing;

  const _AddLivestockSheet({required this.tankId, required this.ref, this.existing});

  @override
  State<_AddLivestockSheet> createState() => _AddLivestockSheetState();
}

class _AddLivestockSheetState extends State<_AddLivestockSheet> {
  late TextEditingController _nameController;
  late TextEditingController _scientificController;
  late TextEditingController _countController;
  bool _isSaving = false;
  List<SpeciesInfo> _suggestions = [];
  SpeciesInfo? _selectedSpecies;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.commonName ?? '');
    _scientificController = TextEditingController(text: widget.existing?.scientificName ?? '');
    _countController = TextEditingController(text: widget.existing?.count.toString() ?? '1');
    
    _nameController.addListener(_onNameChanged);
    
    // Check if existing livestock matches a known species
    if (widget.existing != null) {
      _selectedSpecies = SpeciesDatabase.lookup(widget.existing!.commonName);
    }
  }

  void _onNameChanged() {
    final query = _nameController.text.trim();
    if (query.length >= 2) {
      setState(() {
        _suggestions = SpeciesDatabase.search(query).take(5).toList();
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _selectSpecies(SpeciesInfo species) {
    setState(() {
      _selectedSpecies = species;
      _nameController.text = species.commonName;
      _scientificController.text = species.scientificName;
      _suggestions = [];
      
      // Auto-set count to min school size if adding new
      if (widget.existing == null && species.minSchoolSize > 1) {
        _countController.text = species.minSchoolSize.toString();
      }
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _scientificController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing != null ? 'Edit Livestock' : 'Add Livestock',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: 16),
            
            // Name with autocomplete
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Common Name *',
                hintText: 'e.g., Neon Tetra',
                suffixIcon: _selectedSpecies != null
                    ? Icon(Icons.check_circle, color: AppColors.success, size: 20)
                    : null,
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            
            // Suggestions
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: _suggestions.map((species) => ListTile(
                    dense: true,
                    title: Text(species.commonName),
                    subtitle: Text(
                      '${species.scientificName} • ${species.temperament}',
                      style: AppTypography.bodySmall,
                    ),
                    trailing: Text(
                      species.careLevel,
                      style: AppTypography.bodySmall.copyWith(
                        color: _careLevelColor(species.careLevel),
                      ),
                    ),
                    onTap: () => _selectSpecies(species),
                  )).toList(),
                ),
              ),
            
            // Species info tip
            if (_selectedSpecies != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Species Info', style: AppTypography.labelLarge),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_selectedSpecies!.temperament} • ${_selectedSpecies!.adultSizeCm.toStringAsFixed(0)}cm adult • ${_selectedSpecies!.careLevel}',
                      style: AppTypography.bodySmall,
                    ),
                    if (_selectedSpecies!.minSchoolSize > 1)
                      Text(
                        'Schooling fish — keep ${_selectedSpecies!.minSchoolSize}+ together',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.info),
                      ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            TextFormField(
              controller: _scientificController,
              decoration: const InputDecoration(
                labelText: 'Scientific Name (optional)',
                hintText: 'e.g., Paracheirodon innesi',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countController,
              decoration: InputDecoration(
                labelText: 'Count *',
                hintText: _selectedSpecies != null && _selectedSpecies!.minSchoolSize > 1
                    ? 'Recommended: ${_selectedSpecies!.minSchoolSize}+'
                    : 'How many?',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.existing != null ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Color _careLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final count = int.tryParse(_countController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }
    if (count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Count must be at least 1')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = widget.ref.read(storageServiceProvider);
      final now = DateTime.now();

      final livestock = Livestock(
        id: widget.existing?.id ?? _uuid.v4(),
        tankId: widget.tankId,
        commonName: name,
        scientificName: _scientificController.text.trim().isNotEmpty
            ? _scientificController.text.trim()
            : null,
        count: count,
        dateAdded: widget.existing?.dateAdded ?? now,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      await storage.saveLivestock(livestock);

      // If this is a brand new livestock entry, also create a log entry + XP.
      if (widget.existing == null) {
        await storage.saveLog(
          LogEntry(
            id: _uuid.v4(),
            tankId: widget.tankId,
            type: LogType.livestockAdded,
            timestamp: now,
            title: 'Added ${livestock.count}× ${livestock.commonName}',
            relatedLivestockId: livestock.id,
            createdAt: now,
          ),
        );

        widget.ref.invalidate(logsProvider(widget.tankId));
        widget.ref.invalidate(allLogsProvider(widget.tankId));

        await widget.ref
            .read(userProfileProvider.notifier)
            .recordActivity(xp: XpRewards.addLivestock);
      }

      widget.ref.invalidate(livestockProvider(widget.tankId));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _BulkAddLivestockSheet extends StatefulWidget {
  final String tankId;
  final WidgetRef ref;

  const _BulkAddLivestockSheet({required this.tankId, required this.ref});

  @override
  State<_BulkAddLivestockSheet> createState() => _BulkAddLivestockSheetState();
}

class _BulkAddLivestockSheetState extends State<_BulkAddLivestockSheet> {
  final _controller = TextEditingController();
  bool _isSaving = false;
  List<_BulkLivestockItem> _items = const [];
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuildPreview);
    _rebuildPreview();
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuildPreview);
    _controller.dispose();
    super.dispose();
  }

  void _rebuildPreview() {
    final parsed = _parseItems(_controller.text);
    setState(() {
      _items = parsed.items;
      _parseError = parsed.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bulk add livestock', style: AppTypography.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'One per line. Formats supported: “Neon Tetra, 10”, “10 Neon Tetra”, “Neon Tetra x10”.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'List',
                hintText: 'Neon Tetra, 12\nCorydoras x6\n2 Mystery Snail',
                errorText: _parseError,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            if (_items.isNotEmpty) ...[
              Text('Preview (${_items.length})', style: AppTypography.labelLarge),
              const SizedBox(height: 8),
              ..._items.map(
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(i.name, style: AppTypography.bodyMedium)),
                      const SizedBox(width: 12),
                      Text('×${i.count}', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.playlist_add),
              label: Text(_isSaving ? 'Adding…' : 'Add ${_items.isEmpty ? '' : '(${_items.length}) '}livestock'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one line to continue')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = widget.ref.read(storageServiceProvider);
      final now = DateTime.now();

      for (final item in _items) {
        final livestock = Livestock(
          id: _uuid.v4(),
          tankId: widget.tankId,
          commonName: item.name,
          scientificName: null,
          count: item.count,
          dateAdded: now,
          createdAt: now,
          updatedAt: now,
        );

        await storage.saveLivestock(livestock);
        await storage.saveLog(
          LogEntry(
            id: _uuid.v4(),
            tankId: widget.tankId,
            type: LogType.livestockAdded,
            timestamp: now,
            title: 'Added ${livestock.count}× ${livestock.commonName}',
            relatedLivestockId: livestock.id,
            createdAt: now,
          ),
        );
      }

      widget.ref.invalidate(livestockProvider(widget.tankId));
      widget.ref.invalidate(logsProvider(widget.tankId));
      widget.ref.invalidate(allLogsProvider(widget.tankId));

      await widget.ref.read(userProfileProvider.notifier).recordActivity(
            xp: _items.length * XpRewards.addLivestock,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${_items.length} livestock entries'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  _ParseResult _parseItems(String raw) {
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final items = <_BulkLivestockItem>[];

    for (final line in lines) {
      final item = _parseLine(line);
      if (item == null) {
        return _ParseResult(
          items: items,
          error: 'Could not parse: “$line”',
        );
      }
      items.add(item);
    }

    return _ParseResult(items: items);
  }

  _BulkLivestockItem? _parseLine(String line) {
    // 1) comma format: Name, 10
    if (line.contains(',')) {
      final parts = line.split(',');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final count = int.tryParse(parts.sublist(1).join(',').trim());
        if (name.isNotEmpty && count != null && count > 0) {
          return _BulkLivestockItem(name: name, count: count);
        }
      }
    }

    // 2) Name x10 / Name ×10 / Name x 10
    final mult = RegExp(r'^(.*?)(?:\s*[x×]\s*)(\d+)$', caseSensitive: false);
    final multMatch = mult.firstMatch(line);
    if (multMatch != null) {
      final name = (multMatch.group(1) ?? '').trim();
      final count = int.tryParse(multMatch.group(2) ?? '');
      if (name.isNotEmpty && count != null && count > 0) {
        return _BulkLivestockItem(name: name, count: count);
      }
    }

    // 3) 10 Name
    final leading = RegExp(r'^(\d+)\s+(.*)$');
    final leadingMatch = leading.firstMatch(line);
    if (leadingMatch != null) {
      final count = int.tryParse(leadingMatch.group(1) ?? '');
      final name = (leadingMatch.group(2) ?? '').trim();
      if (name.isNotEmpty && count != null && count > 0) {
        return _BulkLivestockItem(name: name, count: count);
      }
    }

    // 4) fallback: just a name = count 1
    if (line.isNotEmpty) {
      return _BulkLivestockItem(name: line, count: 1);
    }

    return null;
  }
}

class _BulkLivestockItem {
  final String name;
  final int count;

  const _BulkLivestockItem({required this.name, required this.count});
}

class _ParseResult {
  final List<_BulkLivestockItem> items;
  final String? error;

  const _ParseResult({required this.items, this.error});
}
