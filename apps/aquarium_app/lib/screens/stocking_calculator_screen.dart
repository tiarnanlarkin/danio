import 'dart:async';
import '../utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/species_database.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_text_field.dart';
class StockingCalculatorScreen extends StatefulWidget {
  const StockingCalculatorScreen({super.key});

  @override
  State<StockingCalculatorScreen> createState() =>
      _StockingCalculatorScreenState();
}

class _StockingCalculatorScreenState extends State<StockingCalculatorScreen> {
  final _tankVolumeController = TextEditingController(text: '100');
  final _filterRatingController = TextEditingController(text: '1.0');
  bool _hasLivePlants = true;

  final List<_StockEntry> _stock = [];
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _tankVolumeController.dispose();
    _filterRatingController.dispose();
    super.dispose();
  }

  double get _tankVolume => double.tryParse(_tankVolumeController.text) ?? 0;
  double get _filterRating =>
      double.tryParse(_filterRatingController.text) ?? 1.0;

  List<SpeciesInfo> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    return SpeciesDatabase.search(_searchQuery).take(8).toList();
  }

  // Bioload calculation using a simplified "inch per gallon" adapted for litres
  // with species-specific multipliers
  double get _bioload {
    double total = 0;
    for (final entry in _stock) {
      // Base bioload = adult size in cm * count * species multiplier
      final speciesMultiplier = _getBioloadMultiplier(entry.species);
      total += entry.species.adultSizeCm * entry.count * speciesMultiplier;
    }
    return total;
  }

  double _getBioloadMultiplier(SpeciesInfo species) {
    // Adjust based on species characteristics
    final name = species.commonName.toLowerCase();

    // High bioload fish
    if (name.contains('goldfish') ||
        name.contains('oscar') ||
        name.contains('pleco')) {
      return 2.0;
    }
    // Medium-high
    if (name.contains('cichlid') || name.contains('gourami')) {
      return 1.3;
    }
    // Low bioload
    if (name.contains('shrimp') ||
        name.contains('snail') ||
        name.contains('otocinclus')) {
      return 0.3;
    }
    // Tetras, rasboras, etc
    if (name.contains('tetra') ||
        name.contains('rasbora') ||
        name.contains('danio')) {
      return 0.8;
    }
    return 1.0;
  }

  // Capacity based on tank volume, filtration, and plants
  double get _capacity {
    double base = _tankVolume * 0.8; // 0.8 cm of fish per litre as baseline
    base *= _filterRating; // Better filtration = more capacity
    if (_hasLivePlants) base *= 1.2; // Plants help with waste
    return base;
  }

  double get _stockingPercent =>
      _capacity > 0 ? (_bioload / _capacity) * 100 : 0;

  String get _stockingLevel {
    if (_stockingPercent < 50) return 'Lightly Stocked';
    if (_stockingPercent < 75) return 'Moderately Stocked';
    if (_stockingPercent < 100) return 'Well Stocked';
    if (_stockingPercent < 120) return 'Fully Stocked';
    return 'Overstocked';
  }

  Color get _stockingColor {
    if (_stockingPercent < 75) return AppColors.success;
    if (_stockingPercent < 100) return AppColors.warning;
    return AppColors.error;
  }

  void _addStock(SpeciesInfo species) {
    final existing = _stock.indexWhere(
      (e) => e.species.commonName == species.commonName,
    );
    setState(() {
      if (existing >= 0) {
        _stock[existing] = _StockEntry(
          species: species,
          count: _stock[existing].count + 1,
        );
      } else {
        _stock.add(_StockEntry(species: species, count: 1));
      }
      _searchQuery = '';
    });
  }

  void _updateCount(_StockEntry entry, int delta) {
    final index = _stock.indexOf(entry);
    if (index < 0) return;

    final newCount = entry.count + delta;
    setState(() {
      if (newCount <= 0) {
        _stock.removeAt(index);
      } else {
        _stock[index] = _StockEntry(species: entry.species, count: newCount);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stocking Calculator')),
      body: Column(
        children: [
          // Tank setup
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    controller: _tankVolumeController,
                    label: 'Tank (L)',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    controller: _filterRatingController,
                    label: 'Filter ×',
                    hint: '1.0 = standard',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm2),
                Column(
                  children: [
                    Text(
                      'Plants',
                      style: Theme.of(context).textTheme.bodySmall!,
                    ),
                    Switch(
                      value: _hasLivePlants,
                      onChanged: (v) => setState(() => _hasLivePlants = v),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stocking meter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Card(
              color: _stockingColor.withAlpha(26),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_stockingPercent.toStringAsFixed(0)}%',
                          style: AppTypography.headlineLarge.copyWith(
                            color: _stockingColor,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm2),
                        Text(_stockingLevel, style: AppTypography.labelLarge),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm2),
                    ClipRRect(
                      borderRadius: AppRadius.smallRadius,
                      child: LinearProgressIndicator(
                        value: (_stockingPercent / 120).clamp(0, 1),
                        backgroundColor: context.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation(_stockingColor),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0%', style: AppTypography.bodySmall),
                        Text('75%', style: AppTypography.bodySmall),
                        Text('100%', style: AppTypography.bodySmall),
                        Text('120%', style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppSearchField(
              hint: 'Search fish to add...',
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(kDebounceDuration, () {
                  setState(() => _searchQuery = v);
                });
              },
            ),
          ),

          // Search results
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: AppRadius.mediumRadius,
                boxShadow: [
                  BoxShadow(color: AppOverlays.black12, blurRadius: 8),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (ctx, i) {
                  final species = _searchResults[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.add_circle_outline,
                      size: AppIconSizes.sm,
                    ),
                    title: Text(species.commonName),
                    subtitle: Text(
                      '${species.adultSizeCm.toStringAsFixed(0)}cm adult',
                    ),
                    onTap: () => _addStock(species),
                  );
                },
              ),
            ),

          // Current stock
          Expanded(
            child: _stock.isEmpty
                ? Center(
                    child: Text(
                      'Search and add fish above',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textHint,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: _stock.length,
                    itemBuilder: (ctx, i) {
                      final entry = _stock[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(entry.species.commonName),
                          subtitle: Text(
                            '${entry.species.adultSizeCm.toStringAsFixed(0)}cm × ${entry.count} = '
                            '${(entry.species.adultSizeCm * entry.count * _getBioloadMultiplier(entry.species)).toStringAsFixed(1)} bioload',
                            style: AppTypography.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Remove fish',
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _updateCount(entry, -1),
                              ),
                              Text(
                                '${entry.count}',
                                style: AppTypography.labelLarge,
                              ),
                              IconButton(
                                tooltip: 'Add fish',
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _updateCount(entry, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Tips
          if (_stock.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppOverlays.surfaceVariant50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_stockingPercent > 100)
                    Text(
                      '⚠️ Overstocked: Expect frequent water changes and potential aggression.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.error,
                      ),
                    )
                  else if (_stockingPercent > 75)
                    Text(
                      '💡 Tip: Weekly water changes recommended at this stocking level.',
                      style: AppTypography.bodySmall,
                    )
                  else
                    Text(
                      '✓ Good stocking level with room to grow.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StockEntry {
  final SpeciesInfo species;
  final int count;

  const _StockEntry({required this.species, required this.count});
}
