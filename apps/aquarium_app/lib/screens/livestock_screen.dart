import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

const _uuid = Uuid();

class LivestockScreen extends ConsumerWidget {
  final String tankId;

  const LivestockScreen({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livestockAsync = ref.watch(livestockProvider(tankId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestock'),
      ),
      body: livestockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (livestock) {
          if (livestock.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.set_meal, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text('No livestock yet', style: AppTypography.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Add fish, shrimp, or snails', style: AppTypography.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Livestock'),
                  ),
                ],
              ),
            );
          }

          final totalCount = livestock.fold<int>(0, (sum, l) => sum + l.count);

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
              await ref.read(storageServiceProvider).deleteLivestock(livestock.id);
              ref.invalidate(livestockProvider(tankId));
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
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LivestockCard({
    required this.livestock,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.set_meal, color: AppColors.primary),
        ),
        title: Text(livestock.commonName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (livestock.scientificName != null)
              Text(
                livestock.scientificName!,
                style: AppTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
              ),
            Text('×${livestock.count}', style: AppTypography.bodySmall),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'delete', child: Text('Remove')),
          ],
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
        ),
        onTap: onEdit,
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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.commonName ?? '');
    _scientificController = TextEditingController(text: widget.existing?.scientificName ?? '');
    _countController = TextEditingController(text: widget.existing?.count.toString() ?? '1');
  }

  @override
  void dispose() {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing != null ? 'Edit Livestock' : 'Add Livestock',
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Common Name *',
              hintText: 'e.g., Neon Tetra',
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
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
            decoration: const InputDecoration(
              labelText: 'Count *',
              hintText: 'How many?',
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
    );
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
