import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../providers/storage_provider.dart';
import '../../providers/tank_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/xp_animation_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_text_field.dart';
import '../../utils/logger.dart';

const _bulkUuid = Uuid();

/// Bottom sheet for bulk-adding multiple livestock entries at once.
/// Accepts a free-text list; supports several parsing formats.
class LivestockBulkAddDialog extends ConsumerStatefulWidget {
  final String tankId;

  const LivestockBulkAddDialog({super.key, required this.tankId});

  @override
  ConsumerState<LivestockBulkAddDialog> createState() =>
      _LivestockBulkAddDialogState();
}

class _LivestockBulkAddDialogState
    extends ConsumerState<LivestockBulkAddDialog> {
  final _controller = TextEditingController();
  bool _isSaving = false;
  List<_BulkItem> _items = const [];
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
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: max(
              MediaQuery.of(context).viewInsets.bottom,
              MediaQuery.of(context).viewPadding.bottom,
            ) +
            16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bulk add livestock', style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'One per line. Formats supported: "Neon Tetra, 10", "10 Neon Tetra", "Neon Tetra x10".',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm2),
            AppTextField(
              controller: _controller,
              maxLines: 8,
              label: 'List',
              hint: 'Neon Tetra, 12\nCorydoras x6\n2 Mystery Snail',
              errorText: _parseError,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: AppSpacing.sm2),
            if (_items.isNotEmpty) ...[
              Text('Preview (${_items.length})', style: AppTypography.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              ..._items.map(
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(i.name, style: AppTypography.bodyMedium),
                      ),
                      const SizedBox(width: AppSpacing.sm2),
                      Text('×${i.count}', style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.md),
            AppButton(
              onPressed: _isSaving ? null : _save,
              label:
                  'Add ${_items.isEmpty ? '' : '(${_items.length}) '}livestock',
              leadingIcon: Icons.playlist_add,
              isLoading: _isSaving,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_items.isEmpty) {
      AppFeedback.showWarning(context, 'Add at least one line to continue');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final storage = ref.read(storageServiceProvider);
      final now = DateTime.now();

      for (final item in _items) {
        final livestock = Livestock(
          id: _bulkUuid.v4(),
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
            id: _bulkUuid.v4(),
            tankId: widget.tankId,
            type: LogType.livestockAdded,
            timestamp: now,
            title: 'Added ${livestock.count}× ${livestock.commonName}',
            relatedLivestockId: livestock.id,
            createdAt: now,
          ),
        );
      }

      ref.invalidate(livestockProvider(widget.tankId));
      ref.invalidate(logsProvider(widget.tankId));
      ref.invalidate(allLogsProvider(widget.tankId));

      final totalXp = _items.length * XpRewards.addLivestock;
      await ref.read(userProfileProvider.notifier).recordActivity(xp: totalXp);

      if (mounted && totalXp > 0) {
        ref.showXpAnimation(totalXp);
      }

      if (mounted) {
        Navigator.maybePop(context);
        AppFeedback.showSuccess(
          context,
          'Welcome aboard, new friends! \u{1F420} ${_items.length} added',
        );
      }
    } catch (e, st) {
      logError('LivestockBulkAddDialog: bulk save failed: $e', stackTrace: st, tag: 'LivestockBulkAddDialog');
      if (mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t add that right now. Try again!',
          onRetry: _save,
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

    final items = <_BulkItem>[];

    for (final line in lines) {
      final item = _parseLine(line);
      if (item == null) {
        return _ParseResult(items: items, error: 'Could not parse: "$line"');
      }
      items.add(item);
    }

    return _ParseResult(items: items);
  }

  _BulkItem? _parseLine(String line) {
    // 1) comma format: Name, 10
    if (line.contains(',')) {
      final parts = line.split(',');
      if (parts.length >= 2) {
        final name = parts[0].trim();
        final count = int.tryParse(parts.sublist(1).join(',').trim());
        if (name.isNotEmpty && count != null && count > 0) {
          return _BulkItem(name: name, count: count);
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
        return _BulkItem(name: name, count: count);
      }
    }

    // 3) 10 Name
    final leading = RegExp(r'^(\d+)\s+(.*)$');
    final leadingMatch = leading.firstMatch(line);
    if (leadingMatch != null) {
      final count = int.tryParse(leadingMatch.group(1) ?? '');
      final name = (leadingMatch.group(2) ?? '').trim();
      if (name.isNotEmpty && count != null && count > 0) {
        return _BulkItem(name: name, count: count);
      }
    }

    // 4) fallback: just a name = count 1
    if (line.isNotEmpty) {
      return _BulkItem(name: line, count: 1);
    }

    return null;
  }
}

class _BulkItem {
  final String name;
  final int count;

  const _BulkItem({required this.name, required this.count});
}

class _ParseResult {
  final List<_BulkItem> items;
  final String? error;

  const _ParseResult({required this.items, this.error});
}
