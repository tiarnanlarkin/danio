import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tank_provider.dart';
import '../services/openai_service.dart';
import '../features/smart/smart_providers.dart';
import '../theme/app_theme.dart';

/// AI-powered tank compatibility checker.
/// User enters a species, AI checks if it's compatible with their tank.
class CompatibilityCheckerWidget extends ConsumerStatefulWidget {
  const CompatibilityCheckerWidget({super.key});

  @override
  ConsumerState<CompatibilityCheckerWidget> createState() =>
      _CompatibilityCheckerWidgetState();
}

class _CompatibilityCheckerWidgetState
    extends ConsumerState<CompatibilityCheckerWidget> {
  final _speciesController = TextEditingController();
  String? _selectedTankId;
  String? _result;
  bool _loading = false;

  @override
  void dispose() {
    _speciesController.dispose();
    super.dispose();
  }

  Future<void> _checkCompatibility() async {
    final species = _speciesController.text.trim();
    if (species.isEmpty || _selectedTankId == null) return;

    final openai = ref.read(openAIServiceProvider);
    if (!openai.isConfigured) return;

    // Get tank details
    final tankAsync = ref.read(tankProvider(_selectedTankId!));
    final tank = tankAsync.value;
    if (tank == null) return;

    // Get livestock for this tank
    final livestockAsync = ref.read(livestockProvider(_selectedTankId!));
    final livestock = livestockAsync.value ?? [];

    final tankSize = tank.volumeLitres.toStringAsFixed(0);
    final fishList = livestock.isEmpty
        ? 'no fish yet'
        : livestock.map((l) => '${l.count}x ${l.commonName}').join(', ');

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final result = await openai.chatCompletion(
        messages: [
          const ChatMessage(
            role: 'system',
            content:
                'You are an expert aquarium advisor. Give concise, practical '
                'compatibility advice. Answer in exactly 3 sections:\n'
                '1. Compatibility verdict (use one: Compatible, Caution, or Incompatible)\n'
                '2. Reasons (2-3 bullet points)\n'
                '3. Recommendations (1-2 practical tips)\n'
                'Keep it under 150 words total.',
          ),
          ChatMessage(
            role: 'user',
            content: 'I have a $tankSize litre ${tank.type.name} tank with: '
                '$fishList. Is a $species compatible? Check temperament, '
                'water parameters, space requirements, and schooling needs.',
          ),
        ],
        maxTokens: 300,
      );

      ref.read(aiHistoryProvider.notifier).add(
            type: 'compatibility_check',
            summary: 'Checked: $species in ${tank.name}',
          );

      setState(() => _result = result.text);
    } catch (e) {
      setState(() =>
          _result = 'Could not check compatibility right now. Try again later.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tanksAsync = ref.watch(tanksProvider);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md2Radius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Compatibility Checker',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Tank selector
            tanksAsync.when(
              data: (tanks) {
                if (tanks.isEmpty) {
                  return Text(
                    'Add a tank first to check compatibility.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  );
                }
                if (_selectedTankId == null && tanks.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() => _selectedTankId = tanks.first.id);
                    }
                  });
                }
                return DropdownButtonFormField<String>(
                  value: _selectedTankId,
                  decoration: const InputDecoration(
                    labelText: 'Select tank',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: tanks
                      .map((t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(t.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedTankId = v),
                );
              },
              loading: () => const SizedBox(
                  height: 48,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const Text('Could not load tanks'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _speciesController,
              decoration: InputDecoration(
                hintText: 'e.g. "Neon Tetra" or "Cherry Shrimp"',
                labelText: 'Species to check',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _checkCompatibility,
                      ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _checkCompatibility(),
            ),
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _resultColor.withValues(alpha: 0.08),
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(
                    color: _resultColor.withValues(alpha: 0.2),
                  ),
                ),
                child: SelectableText(
                  _result!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color get _resultColor {
    if (_result == null) return AppColors.textSecondary;
    final lower = _result!.toLowerCase();
    if (lower.contains('incompatible')) return AppColors.error;
    if (lower.contains('caution')) return AppColors.warning;
    if (lower.contains('compatible')) return AppColors.success;
    return AppColors.textSecondary;
  }
}
