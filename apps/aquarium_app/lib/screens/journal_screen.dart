import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/error_state.dart';

/// Tags for journal/timeline event categorisation
enum JournalTag {
  general,
  milestone,
  waterChange,
  newAnimal,
  plantChange,
  equipment,
  health,
  observation,
}

extension JournalTagExt on JournalTag {
  String get label {
    switch (this) {
      case JournalTag.general: return 'General';
      case JournalTag.milestone: return '🏆 Milestone';
      case JournalTag.waterChange: return '💧 Water Change';
      case JournalTag.newAnimal: return '🐠 New Animal';
      case JournalTag.plantChange: return '🌿 Plants';
      case JournalTag.equipment: return '🔧 Equipment';
      case JournalTag.health: return '🩺 Health';
      case JournalTag.observation: return '👁 Observation';
    }
  }

  Color get color {
    switch (this) {
      case JournalTag.general: return AppColors.textSecondary;
      case JournalTag.milestone: return Colors.amber;
      case JournalTag.waterChange: return AppColors.secondary;
      case JournalTag.newAnimal: return AppColors.primary;
      case JournalTag.plantChange: return Colors.green;
      case JournalTag.equipment: return Colors.brown;
      case JournalTag.health: return Colors.red;
      case JournalTag.observation: return Colors.purple;
    }
  }
}

class JournalScreen extends ConsumerWidget {
  final String tankId;

  const JournalScreen({super.key, required this.tankId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(allLogsProvider(tankId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tank Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add journal entry',
            onPressed: () => _addJournalEntry(context, ref),
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (e, _) => ErrorState(
          message: 'Failed to load journal',
          details: 'Please check your connection and try again.',
          onRetry: () => ref.invalidate(allLogsProvider(tankId)),
        ),
        data: (logs) {
          // Get observation logs as journal entries
          final journalEntries =
              logs.where((l) => l.type == LogType.observation).toList()
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (journalEntries.isEmpty) {
            return _EmptyJournal(onAdd: () => _addJournalEntry(context, ref));
          }

          // Group by month
          final grouped = <String, List<LogEntry>>{};
          for (final entry in journalEntries) {
            final month = DateFormat('MMMM yyyy').format(entry.timestamp);
            grouped.putIfAbsent(month, () => []).add(entry);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: grouped.length,
            itemBuilder: (ctx, i) {
              final month = grouped.keys.elementAt(i);
              final entries = grouped[month]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(month, style: AppTypography.headlineSmall),
                  ),
                  ...entries.map((e) => _JournalEntryCard(entry: e)),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addJournalEntry(context, ref),
        icon: const Icon(Icons.edit),
        label: const Text('New Entry'),
      ),
    );
  }

  void _addJournalEntry(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _NewJournalEntrySheet(
        tankId: tankId,
        onSave: (notes, photoPaths, tag) async {
          final now = DateTime.now();
          final tagPrefix = tag != JournalTag.general ? '[${tag.label}] ' : '';
          final entry = LogEntry(
            id: now.millisecondsSinceEpoch.toString(),
            tankId: tankId,
            type: LogType.observation,
            timestamp: now,
            createdAt: now,
            title: tagPrefix.isEmpty ? null : tag.label,
            notes: notes,
            photoUrls: photoPaths.isNotEmpty ? photoPaths : null,
          );

          final storage = ref.read(storageServiceProvider);
          await storage.saveLog(entry);
          ref.invalidate(allLogsProvider(tankId));

          if (ctx.mounted) Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyJournal({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.book_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: AppSpacing.md),
            Text('No journal entries yet', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Keep a diary of your tank\'s journey — observations, milestones, changes, and memories.',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.edit),
              label: const Text('Write First Entry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final LogEntry entry;

  const _JournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMMM d').format(entry.timestamp);
    final timeStr = DateFormat('h:mm a').format(entry.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppOverlays.primary10,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.timestamp.day}',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr, style: AppTypography.labelLarge),
                    Text(timeStr, style: AppTypography.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(entry.notes ?? '', style: AppTypography.bodyMedium),
            // Tag chip (if title encodes tag)
            if (entry.title != null && entry.title!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppOverlays.primary10,
                  borderRadius: AppRadius.pillRadius,
                ),
                child: Text(
                  entry.title!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            if (entry.photoUrls != null && entry.photoUrls!.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: entry.photoUrls!.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final path = entry.photoUrls![i];
                    return ClipRRect(
                      borderRadius: AppRadius.smallRadius,
                      child: Image.file(
                        File(path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 80,
                          color: AppColors.surfaceVariant,
                          child: Icon(Icons.image, color: AppColors.textHint),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NewJournalEntrySheet extends StatefulWidget {
  final String tankId;
  final Function(String notes, List<String> photoPaths, JournalTag tag) onSave;

  const _NewJournalEntrySheet({required this.tankId, required this.onSave});

  @override
  State<_NewJournalEntrySheet> createState() => _NewJournalEntrySheetState();
}

class _NewJournalEntrySheetState extends State<_NewJournalEntrySheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  JournalTag _selectedTag = JournalTag.general;
  final List<String> _photoPaths = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (image != null) {
      setState(() => _photoPaths.add(image.path));
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (image != null) {
      setState(() => _photoPaths.add(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('New Journal Entry', style: AppTypography.headlineSmall),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Text(
              DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),

            // Event tag selector
            Text('Category', style: AppTypography.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: JournalTag.values.map((tag) {
                  final selected = _selectedTag == tag;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tag.label),
                      selected: selected,
                      selectedColor: tag.color.withOpacity(0.25),
                      onSelected: (_) => setState(() => _selectedTag = tag),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'What\'s happening with your tank today?\n\nObservations, changes, milestones...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Photo attachments
            Row(
              children: [
                Text('Photos', style: AppTypography.labelLarge),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.photo_library_outlined),
                  tooltip: 'Gallery',
                  onPressed: _pickPhoto,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  tooltip: 'Camera',
                  onPressed: _takePhoto,
                ),
              ],
            ),

            if (_photoPaths.isNotEmpty) ...[
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photoPaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.smallRadius,
                        child: Image.file(
                          File(_photoPaths[i]),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _photoPaths.removeAt(i)),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],

            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: (_isSaving || _controller.text.trim().isEmpty)
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        await widget.onSave(
                          _controller.text.trim(),
                          List.from(_photoPaths),
                          _selectedTag,
                        );
                        if (mounted) setState(() => _isSaving = false);
                      },
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
