import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_database.dart';
import '../widgets/core/app_text_field.dart';
import '../models/learning.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/debouncer.dart';
import '../widgets/core/app_card.dart';
import '../widgets/core/app_button.dart';
import '../widgets/app_bottom_sheet.dart';

class SpeciesBrowserScreen extends ConsumerStatefulWidget {
  const SpeciesBrowserScreen({super.key});

  @override
  ConsumerState<SpeciesBrowserScreen> createState() =>
      _SpeciesBrowserScreenState();
}

class _SpeciesBrowserScreenState extends ConsumerState<SpeciesBrowserScreen> {
  String _searchQuery = '';
  String? _careLevelFilter;
  String? _temperamentFilter;
  final Set<String> _researchedSpecies =
      {}; // Track researched species this session

  /// Debounce search input to avoid filtering on every keystroke
  final _searchDebouncer = Debouncer(delay: const Duration(milliseconds: 250));

  /// Cached filtered results — invalidated when filters change
  List<SpeciesInfo>? _cachedFilteredSpecies;

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }

  void _invalidateCache() {
    _cachedFilteredSpecies = null;
  }

  List<SpeciesInfo> get _filteredSpecies {
    if (_cachedFilteredSpecies != null) return _cachedFilteredSpecies!;
    var results = SpeciesDatabase.species;

    if (_searchQuery.isNotEmpty) {
      results = SpeciesDatabase.search(_searchQuery);
    }

    if (_careLevelFilter != null) {
      results = results.where((s) => s.careLevel == _careLevelFilter).toList();
    }

    if (_temperamentFilter != null) {
      results = results
          .where((s) => s.temperament == _temperamentFilter)
          .toList();
    }

    _cachedFilteredSpecies = results;
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final species = _filteredSpecies;

    return Scaffold(
      appBar: AppBar(title: const Text('Fish Database')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSearchField(
              hint: 'Search fish by name...',
              onChanged: (v) {
                _searchDebouncer.run(() {
                  if (mounted) {
                    setState(() {
                      _searchQuery = v;
                      _invalidateCache();
                    });
                  }
                });
              },
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _buildAllChip(),
                const SizedBox(width: AppSpacing.sm),
                _buildCareLevelChip('Beginner'),
                const SizedBox(width: AppSpacing.sm),
                _buildCareLevelChip('Intermediate'),
                const SizedBox(width: AppSpacing.sm),
                _buildCareLevelChip('Advanced'),
                const SizedBox(width: AppSpacing.md),
                _buildTemperamentChip('Peaceful'),
                const SizedBox(width: AppSpacing.sm),
                _buildTemperamentChip('Semi-aggressive'),
                const SizedBox(width: AppSpacing.sm),
                _buildTemperamentChip('Aggressive'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Text(
                  '${species.length} species',
                  style: AppTypography.bodySmall,
                ),
                const Spacer(),
                if (_careLevelFilter != null || _temperamentFilter != null)
                  AppButton(
                    label: 'Clear filters',
                    onPressed: () => setState(() {
                      _careLevelFilter = null;
                      _temperamentFilter = null;
                      _invalidateCache();
                    }),
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                  ),
              ],
            ),
          ),

          Expanded(
            child: species.isEmpty && _searchQuery.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: AppSpacing.sm2),
                        Text('No matches', style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Try a different name or clear filters',
                          style: AppTypography.bodyMedium.copyWith(
                            color: context.textHint,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: species.length,
                    itemBuilder: (ctx, i) => _SpeciesCard(
                      species: species[i],
                      onTap: () => _showSpeciesDetail(context, species[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllChip() {
    final isActive = _careLevelFilter == null && _temperamentFilter == null;
    return FilterChip(
      label: const Text('All'),
      selected: isActive,
      onSelected: (_) => setState(() {
        _careLevelFilter = null;
        _temperamentFilter = null;
        _invalidateCache();
      }),
    );
  }

  Widget _buildCareLevelChip(String level) {
    return FilterChip(
      label: Text(level),
      selected: _careLevelFilter == level,
      onSelected: (_) => setState(() {
        _careLevelFilter = _careLevelFilter == level ? null : level;
        _invalidateCache();
      }),
    );
  }

  Widget _buildTemperamentChip(String temperament) {
    return FilterChip(
      label: Text(temperament),
      selected: _temperamentFilter == temperament,
      onSelected: (_) => setState(() {
        _temperamentFilter = _temperamentFilter == temperament
            ? null
            : temperament;
        _invalidateCache();
      }),
    );
  }

  Future<void> _showSpeciesDetail(
    BuildContext context,
    SpeciesInfo species,
  ) async {
    // Award XP for researching a new species (once per session per species)
    if (!_researchedSpecies.contains(species.scientificName)) {
      _researchedSpecies.add(species.scientificName);
      await ref
          .read(userProfileProvider.notifier)
          .recordActivity(xp: XpRewards.speciesResearched);
    }

    if (!context.mounted) return;

    showAppScrollableSheet(
      context: context,
      initialSize: 0.85,
      minSize: 0.5,
      maxSize: 0.95,
      builder: (_, scrollController) => _SpeciesDetailSheet(
        species: species,
        scrollController: scrollController,
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final SpeciesInfo species;
  final VoidCallback onTap;

  const _SpeciesCard({required this.species, required this.onTap});

  Color _careLevelColor(BuildContext context) {
    switch (species.careLevel) {
      case 'Easy':
        return AppColors.success;
      case 'Moderate':
        return AppColors.warning;
      case 'Advanced':
        return AppColors.error;
      default:
        return context.textSecondary;
    }
  }

  Color _temperamentColor(BuildContext context) {
    switch (species.temperament) {
      case 'Peaceful':
        return AppColors.success;
      case 'Semi-aggressive':
        return AppColors.warning;
      case 'Aggressive':
        return AppColors.error;
      default:
        return context.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm2),
      child: ListTile(
        onTap: onTap,
        leading: Hero(
          tag: 'species-icon-${species.scientificName}',
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppOverlays.primary10,
              borderRadius: AppRadius.smallRadius,
            ),
            child: const Icon(Icons.set_meal, color: AppColors.primary),
          ),
        ),
        title: Text(species.commonName, style: AppTypography.labelLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              species.scientificName,
              style: AppTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 6,
              children: [
                _MiniChip(
                  label: species.careLevel,
                  color: _careLevelColor(context),
                ),
                _MiniChip(
                  label: species.temperament,
                  color: _temperamentColor(context),
                ),
                _MiniChip(
                  label: '${species.adultSizeCm.toStringAsFixed(0)}cm',
                  color: context.textSecondary,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: AppIconSizes.sm),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadius.smallRadius,
      ),
      child: Text(label, style: AppTypography.bodySmall.copyWith(color: color)),
    );
  }
}

class _SpeciesDetailSheet extends StatelessWidget {
  final SpeciesInfo species;
  final ScrollController scrollController;

  const _SpeciesDetailSheet({
    required this.species,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Hero(
                  tag: 'species-icon-${species.scientificName}',
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppOverlays.primary10,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: const Icon(
                      Icons.set_meal,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        species.commonName,
                        style: AppTypography.headlineMedium,
                      ),
                      Text(
                        species.scientificName,
                        style: AppTypography.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Quick stats
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatChip(label: species.careLevel, icon: Icons.speed),
                _StatChip(label: species.temperament, icon: Icons.set_meal),
                _StatChip(
                  label: '${species.adultSizeCm.toStringAsFixed(0)} cm adult',
                  icon: Icons.straighten,
                ),
                _StatChip(label: species.family, icon: Icons.account_tree),
              ],
            ),

            const SizedBox(height: AppSpacing.lg2),

            Text(species.description, style: AppTypography.bodyLarge),

            const SizedBox(height: AppSpacing.lg2),

            // Parameters
            Text('Ideal Parameters', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm2),
            AppCard(
              padding: AppCardPadding.compact,
              child: Column(
                children: [
                  _ParamRow(
                    label: 'Temperature',
                    value: '${species.minTempC}-${species.maxTempC}°C',
                  ),
                  _ParamRow(
                    label: 'pH',
                    value: '${species.minPh}-${species.maxPh}',
                  ),
                  _ParamRow(
                    label: 'Min tank size',
                    value: '${species.minTankLitres.toStringAsFixed(0)} L',
                  ),
                  _ParamRow(
                    label: 'Min school size',
                    value: '${species.minSchoolSize}+',
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg2),

            // Diet
            Text('Diet', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(species.diet, style: AppTypography.bodyMedium),

            const SizedBox(height: AppSpacing.lg2),

            // Compatibility
            if (species.compatibleWith.isNotEmpty) ...[
              Text('Compatible With', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: species.compatibleWith
                    .map(
                      (c) => Chip(
                        label: Text(c, style: AppTypography.bodySmall),
                        backgroundColor: AppOverlays.success10,
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (species.avoidWith.isNotEmpty) ...[
              Text('Avoid With', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: species.avoidWith
                    .map(
                      (c) => Chip(
                        label: Text(c, style: AppTypography.bodySmall),
                        backgroundColor: AppOverlays.error10,
                        side: BorderSide.none,
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm3,
        vertical: AppSpacing.xs2,
      ),
      decoration: BoxDecoration(
        color: context.surfaceVariant,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.textSecondary),
          const SizedBox(width: AppSpacing.xs2),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _ParamRow extends StatelessWidget {
  final String label;
  final String value;

  const _ParamRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}
