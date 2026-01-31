import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

class LivestockValueScreen extends ConsumerStatefulWidget {
  final String tankId;
  final String tankName;

  const LivestockValueScreen({
    super.key,
    required this.tankId,
    required this.tankName,
  });

  @override
  ConsumerState<LivestockValueScreen> createState() => _LivestockValueScreenState();
}

class _LivestockValueScreenState extends ConsumerState<LivestockValueScreen> {
  final Map<String, double> _prices = {};
  String _currency = '£';

  double get _totalValue {
    final tank = ref.read(tanksProvider).value?.firstWhere((t) => t.id == widget.tankId);
    if (tank == null) return 0;

    double total = 0;
    for (final livestock in tank.livestock) {
      final price = _prices[livestock.id] ?? 0;
      total += price * livestock.quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final tankAsync = ref.watch(tanksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.tankName} Value'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.currency_exchange),
            initialValue: _currency,
            onSelected: (v) => setState(() => _currency = v),
            itemBuilder: (_) => ['£', '\$', '€', '¥'].map((c) => 
              PopupMenuItem(value: c, child: Text(c))
            ).toList(),
          ),
        ],
      ),
      body: tankAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tanks) {
          final tank = tanks.firstWhere((t) => t.id == widget.tankId);

          if (tank.livestock.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pets, size: 64, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text('No Livestock Yet', style: AppTypography.headlineSmall),
                    const SizedBox(height: 8),
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

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total value card
              Card(
                color: AppColors.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text('Estimated Total Value', style: AppTypography.labelLarge),
                      const SizedBox(height: 8),
                      Text(
                        '$_currency${_totalValue.toStringAsFixed(2)}',
                        style: AppTypography.headlineLarge.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tank.livestock.fold(0, (sum, l) => sum + l.quantity)} animals',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Card(
                color: AppColors.warning.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 18, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Enter prices below to calculate total value. Useful for insurance or selling.',
                          style: AppTypography.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text('Livestock Prices', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),

              ...tank.livestock.map((livestock) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          livestock.type == 'fish' ? Icons.set_meal : Icons.bug_report,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(livestock.species, style: AppTypography.labelLarge),
                            Text(
                              '× ${livestock.quantity}',
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                          onChanged: (v) {
                            setState(() {
                              _prices[livestock.id] = double.tryParse(v) ?? 0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 70,
                        child: Text(
                          '$_currency${((_prices[livestock.id] ?? 0) * livestock.quantity).toStringAsFixed(2)}',
                          style: AppTypography.labelLarge,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              )),

              const SizedBox(height: 24),

              // Tips
              Text('Pricing Tips', style: AppTypography.headlineSmall),
              const SizedBox(height: 12),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _TipRow(text: 'Check local fish store prices for common species'),
                      _TipRow(text: 'Online retailers often have different pricing'),
                      _TipRow(text: 'Rare or breeding pairs are worth more'),
                      _TipRow(text: 'Consider age and size when estimating'),
                      _TipRow(text: 'Shrimp colonies can be valued per individual'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
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
