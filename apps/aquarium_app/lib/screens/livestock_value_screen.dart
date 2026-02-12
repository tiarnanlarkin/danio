import 'package:flutter/material.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class LivestockValueScreen extends ConsumerStatefulWidget {
  final String tankId;
  final String tankName;

  const LivestockValueScreen({
    super.key,
    required this.tankId,
    required this.tankName,
  });

  @override
  ConsumerState<LivestockValueScreen> createState() =>
      _LivestockValueScreenState();
}

class _LivestockValueScreenState extends ConsumerState<LivestockValueScreen> {
  final Map<String, double> _prices = {};
  String _currency = '£';

  double _calculateTotal(List<Livestock> livestock) {
    double total = 0;
    for (final item in livestock) {
      final price = _prices[item.id] ?? 0;
      total += price * item.count;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final livestockAsync = ref.watch(livestockProvider(widget.tankId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tankName} Value'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.currency_exchange),
            initialValue: _currency,
            onSelected: (v) => setState(() => _currency = v),
            itemBuilder: (_) => [
              '£',
              '\$',
              '€',
              '¥',
            ].map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
          ),
        ],
      ),
      body: livestockAsync.when(
        loading: () => const Center(child: BubbleLoader()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (livestock) {
          if (livestock.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pets, size: 64, color: AppColors.textHint),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No Livestock Yet',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Add fish and invertebrates to your tank to estimate their value.',
                      style: AppTypography.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final totalValue = _calculateTotal(livestock);
          final totalAnimals = livestock.fold(0, (sum, l) => sum + l.count);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total value card
              AppCard(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                padding: AppCardPadding.spacious,
                child: Column(
                  children: [
                    Text(
                      'Estimated Total Value',
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$_currency${totalValue.toStringAsFixed(2)}',
                      style: AppTypography.headlineLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$totalAnimals animals',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              AppCard(
                backgroundColor: AppColors.warning.withOpacity(0.1),
                padding: AppCardPadding.compact,
                child: Row(
                  children: [
                    Icon(Icons.info, size: 18, color: AppColors.warning),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Enter prices below to calculate total value. Useful for insurance or selling.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text('Livestock Prices', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),

              ...livestock.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    padding: AppCardPadding.compact,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: AppRadius.smallRadius,
                          ),
                          child: Icon(
                            Icons.set_meal,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.commonName,
                                style: AppTypography.labelLarge,
                              ),
                              Text(
                                '× ${item.count}',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            decoration: InputDecoration(
                              prefixText: _currency,
                              hintText: '0.00',
                              isDense: true,
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d.]'),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() {
                                _prices[item.id] = double.tryParse(v) ?? 0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SizedBox(
                          width: 70,
                          child: Text(
                            '$_currency${((_prices[item.id] ?? 0) * item.count).toStringAsFixed(2)}',
                            style: AppTypography.labelLarge,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Tips
              Text('Pricing Tips', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),

              AppCard(
                padding: AppCardPadding.standard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _TipRow(
                      text:
                          'Check local fish store prices for common species',
                    ),
                    _TipRow(
                      text: 'Online retailers often have different pricing',
                    ),
                    _TipRow(text: 'Rare or breeding pairs are worth more'),
                    _TipRow(text: 'Consider age and size when estimating'),
                    _TipRow(
                      text: 'Shrimp colonies can be valued per individual',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ],
          );
        },
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String text;

  const _TipRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: AppTypography.bodyMedium),
          Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
