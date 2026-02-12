import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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
            padding: const EdgeInsets.all(16),
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
        onSave: (notes) async {
          final now = DateTime.now();
          final entry = LogEntry(
            id: now.millisecondsSinceEpoch.toString(),
            tankId: tankId,
            type: LogType.observation,
            timestamp: now,
            createdAt: now,
            notes: notes,
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
        padding: const EdgeInsets.all(32),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
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
            if (entry.photoUrls != null && entry.photoUrls!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.image, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${entry.photoUrls!.length} photo(s) attached',
                    style: AppTypography.bodySmall,
                  ),
                ],
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
  final Function(String notes) onSave;

  const _NewJournalEntrySheet({required this.tankId, required this.onSave});

  @override
  State<_NewJournalEntrySheet> createState() => _NewJournalEntrySheetState();
}

class _NewJournalEntrySheetState extends State<_NewJournalEntrySheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
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
          const SizedBox(height: AppSpacing.sm),
          Text(
            DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText:
                  'What\'s happening with your tank today?\n\nObservations, changes, milestones...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _controller.text.trim().isEmpty
                  ? null
                  : () => widget.onSave(_controller.text.trim()),
              child: const Text('Save Entry'),
            ),
          ),
        ],
      ),
    );
  }
}
