import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_database.dart';
import '../models/learning.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class SpeciesBrowserScreen extends ConsumerStatefulWidget {
  const SpeciesBrowserScreen({super.key});

  @override
  ConsumerState<SpeciesBrowserScreen> createState() => _SpeciesBrowserScreenState();
}

class _SpeciesBrowserScreenState extends ConsumerState<SpeciesBrowserScreen> {
  String _searchQuery = '';
  String? _careLevelFilter;
  String? _temperamentFilter;
  final Set<String> _researchedSpecies = {}; // Track researched species this session

  List<SpeciesInfo> get _filteredSpecies {
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
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search fish by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.mediumRadius,
                ),
                filled: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _buildCareLevelChip('Easy'),
                const SizedBox(width: AppSpacing.sm),
                _buildCareLevelChip('Moderate'),
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
                  TextButton(
                    onPressed: () => setState(() {
                      _careLevelFilter = null;
                      _temperamentFilter = null;
                    }),
                    child: const Text('Clear filters'),
                  ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
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

  Widget _buildCareLevelChip(String level) {
    return FilterChip(
      label: Text(level),
      selected: _careLevelFilter == level,
      onSelected: (_) => setState(
        () => _careLevelFilter = _careLevelFilter == level ? null : level,
      ),
    );
  }

  Widget _buildTemperamentChip(String temperament) {
    return FilterChip(
      label: Text(temperament),
      selected: _temperamentFilter == temperament,
      onSelected: (_) => setState(
        () => _temperamentFilter = _temperamentFilter == temperament
            ? null
            : temperament,
      ),
    );
  }

  Future<void> _showSpeciesDetail(BuildContext context, SpeciesInfo species) async {
    // Award XP for researching a new species (once per session per species)
    if (!_researchedSpecies.contains(species.scientificName)) {
      _researchedSpecies.add(species.scientificName);
      await ref
          .read(userProfileProvider.notifier)
          .recordActivity(xp: XpRewards.speciesResearched);
    }

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _SpeciesDetailSheet(
          species: species,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  final SpeciesInfo species;
  final VoidCallback onTap;

  const _SpeciesCard({required this.species, required this.onTap});

  Color _careLevelColor() {
    switch (species.careLevel) {
      case 'Easy':
        return AppColors.success;
      case 'Moderate':
        return AppColors.warning;
      case 'Advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _temperamentColor() {
    switch (species.temperament) {
      case 'Peaceful':
        return AppColors.success;
      case 'Semi-aggressive':
        return AppColors.warning;
      case 'Aggressive':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppOverlays.primary10,
            borderRadius: AppRadius.smallRadius,
          ),
          child: const Icon(Icons.set_meal, color: AppColors.primary),
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
                _MiniChip(label: species.careLevel, color: _careLevelColor()),
                _MiniChip(
                  label: species.temperament,
                  color: _temperamentColor(),
                ),
                _MiniChip(
                  label: '${species.adultSizeCm.toStringAsFixed(0)}cm',
                  color: AppColors.info,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadius.smallRadius,
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(color: color, fontSize: 11),
      ),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.lg2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
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
                _StatChip(label: species.temperament, icon: Icons.pets),
                _StatChip(
                  label: '${species.adultSizeCm.toStringAsFixed(0)} cm adult',
                  icon: Icons.straighten,
                ),
                _StatChip(label: species.family, icon: Icons.account_tree),
              ],
            ),

            const SizedBox(height: 20),

            Text(species.description, style: AppTypography.bodyLarge),

            const SizedBox(height: 20),

            // Parameters
            Text('Ideal Parameters', style: AppTypography.headlineSmall),
            const SizedBox(height: 12),
            AppCard(
              padding: AppCardPadding.compact,
              child: Column(
                children: [
                  _ParamRow(
                    label: 'Temperature',
                    value: '${species.minTempC}–${species.maxTempC}°C',
                  ),
                  _ParamRow(
                    label: 'pH',
                    value: '${species.minPh}–${species.maxPh}',
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

            const SizedBox(height: 20),

            // Diet
            Text('Diet', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm),
            Text(species.diet, style: AppTypography.bodyMedium),

            const SizedBox(height: 20),

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}
