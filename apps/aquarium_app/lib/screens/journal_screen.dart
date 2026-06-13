import 'package:flutter/material.dart';
import '../widgets/core/app_text_field.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/storage_provider.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_states.dart';
import '../widgets/empty_state.dart';
import '../widgets/mascot/mascot_widgets.dart';
import '../widgets/app_bottom_sheet.dart';

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
      body: AnimatedSwitcher(
        duration: AppDurations.medium4,
        switchInCurve: Curves.easeOutCubic,
        child: logsAsync.when(
          loading: () => const Center(child: BubbleLoader()),
          error: (e, _) => AppErrorState(
            title: 'Couldn\'t load your journal',
            message: 'Please check your connection and try again.',
            onRetry: () => ref.invalidate(allLogsProvider(tankId)),
          ),
          data: (logs) {
            final timelineEntries = [...logs]
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

            if (timelineEntries.isEmpty) {
              return EmptyState.withMascot(
                icon: Icons.book_outlined,
                title: 'Your story starts here!',
                message:
                    'Every great tank has a story. Start writing yours - observations, milestones, and little victories.',
                mascotContext: MascotContext.encouragement,
                actionLabel: 'Write First Entry',
                onAction: () => _addJournalEntry(context, ref),
              );
            }

            // Group by month
            final grouped = <String, List<LogEntry>>{};
            for (final entry in timelineEntries) {
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
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addJournalEntry(context, ref),
        icon: const Icon(Icons.edit),
        label: const Text('New Entry'),
      ),
    );
  }

  void _addJournalEntry(BuildContext context, WidgetRef ref) {
    showAppDragSheet(
      context: context,
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
          ref.invalidate(logsProvider(tankId));

          if (ctx.mounted) Navigator.maybePop(ctx);
        },
      ),
    );
  }
}

class _JournalEntryCard extends StatelessWidget {
  final LogEntry entry;

  const _JournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM').format(entry.timestamp);
    final timeStr = DateFormat('h:mm a').format(entry.timestamp);
    final notes = entry.notes?.trim();
    final summary = _summaryFor(entry);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm2),
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
                    child: Icon(
                      _iconFor(entry.type),
                      size: AppIconSizes.sm,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _titleFor(entry),
                        style: AppTypography.labelLarge.copyWith(
                          color: context.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${entry.typeName} | $dateStr | $timeStr',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm2),
              Text(summary, style: AppTypography.bodyMedium),
            ],
            if (notes != null && notes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm2),
              Text(notes, style: AppTypography.bodyMedium),
            ],
            if (summary.isEmpty && (notes == null || notes.isEmpty)) ...[
              const SizedBox(height: AppSpacing.sm2),
              Text(
                'Logged ${entry.typeName.toLowerCase()} event.',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
            if (entry.photoUrls != null && entry.photoUrls!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm2),
              Row(
                children: [
                  Icon(
                    Icons.image,
                    size: AppIconSizes.xs,
                    color: context.textSecondary,
                  ),
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

IconData _iconFor(LogType type) {
  switch (type) {
    case LogType.waterTest:
      return Icons.science;
    case LogType.waterChange:
      return Icons.water_drop;
    case LogType.feeding:
      return Icons.restaurant;
    case LogType.medication:
      return Icons.medication;
    case LogType.observation:
      return Icons.visibility;
    case LogType.livestockAdded:
      return Icons.add_circle;
    case LogType.livestockRemoved:
      return Icons.remove_circle;
    case LogType.equipmentMaintenance:
      return Icons.build;
    case LogType.taskCompleted:
      return Icons.task_alt;
    case LogType.other:
      return Icons.note;
  }
}

String _titleFor(LogEntry entry) {
  final title = entry.title?.trim();
  switch (entry.type) {
    case LogType.waterTest:
      return title != null && title.isNotEmpty ? title : 'Water Test';
    case LogType.waterChange:
      final suffix = entry.waterChangePercent != null
          ? ' (${entry.waterChangePercent}%)'
          : '';
      return title != null && title.isNotEmpty ? title : 'Water Change$suffix';
    case LogType.taskCompleted:
      return title != null && title.isNotEmpty
          ? 'Completed: $title'
          : 'Task completed';
    case LogType.observation:
      return title != null && title.isNotEmpty ? title : 'Journal entry';
    case LogType.feeding:
    case LogType.medication:
    case LogType.livestockAdded:
    case LogType.livestockRemoved:
    case LogType.equipmentMaintenance:
    case LogType.other:
      return title != null && title.isNotEmpty ? title : entry.typeName;
  }
}

String _summaryFor(LogEntry entry) {
  switch (entry.type) {
    case LogType.waterTest:
      final test = entry.waterTest;
      if (test == null || !test.hasValues) return '';
      return _waterTestSummary(test);
    case LogType.waterChange:
      final percent = entry.waterChangePercent;
      return percent == null ? '' : 'Changed $percent% of the water.';
    case LogType.feeding:
      return 'Feeding logged.';
    case LogType.medication:
      return 'Medication logged.';
    case LogType.livestockAdded:
      return 'Livestock added to the tank.';
    case LogType.livestockRemoved:
      return 'Livestock removed from the tank.';
    case LogType.equipmentMaintenance:
      return 'Equipment maintenance logged.';
    case LogType.taskCompleted:
    case LogType.observation:
    case LogType.other:
      return '';
  }
}

String _waterTestSummary(WaterTestResults test) {
  final parts = <String>[];

  void addReading(String label, double? value, {String? suffix}) {
    if (value == null) return;
    final unit = suffix == null ? '' : ' $suffix';
    parts.add('$label: ${value.toStringAsFixed(2)}$unit');
  }

  addReading('pH', test.ph);
  addReading('NH3', test.ammonia);
  addReading('NO2', test.nitrite);
  addReading('NO3', test.nitrate);
  addReading('Temp', test.temperature, suffix: 'C');
  addReading('GH', test.gh);
  addReading('KH', test.kh);
  addReading('PO4', test.phosphate);
  addReading('CO2', test.co2);

  return parts.join(' | ');
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
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md + bottomPadding,
      ),
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
                onPressed: () => Navigator.maybePop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            DateFormat('EEEE, d MMMM y').format(DateTime.now()),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _controller,
            focusNode: _focusNode,
            maxLines: 6,
            hint:
                'What\'s happening with your tank today?\n\nObservations, changes, milestones...',
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Save Entry',
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () => widget.onSave(_controller.text.trim()),
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }
}
