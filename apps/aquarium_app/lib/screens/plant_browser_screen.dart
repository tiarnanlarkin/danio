import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plant_database.dart';
import '../widgets/core/app_text_field.dart';
import '../models/learning.dart';
import '../providers/user_profile_provider.dart';
import '../services/xp_animation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_button.dart';
import '../widgets/app_bottom_sheet.dart';

class PlantBrowserScreen extends ConsumerStatefulWidget {
  const PlantBrowserScreen({super.key});

  @override
  ConsumerState<PlantBrowserScreen> createState() => _PlantBrowserScreenState();
}

class _PlantBrowserScreenState extends ConsumerState<PlantBrowserScreen> {
  String _searchQuery = '';
  String? _difficultyFilter;
  String? _placementFilter;
  bool _lowTechOnly = false;
  final Set<String> _researchedPlants =
      {}; // Track researched plants this session
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  List<PlantInfo> get _filteredPlants {
    var results = PlantDatabase.plants;

    if (_searchQuery.isNotEmpty) {
      results = PlantDatabase.search(_searchQuery);
    }

    if (_difficultyFilter != null) {
      results = results
          .where((p) => p.difficulty == _difficultyFilter)
          .toList();
    }

    if (_placementFilter != null) {
      results = results
          .where(
            (p) => p.placement.toLowerCase().contains(
              _placementFilter!.toLowerCase(),
            ),
          )
          .toList();
    }

    if (_lowTechOnly) {
      results = results.where((p) => !p.needsCO2).toList();
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final plants = _filteredPlants;

    return Scaffold(
      appBar: AppBar(title: const Text('Plant Database')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSearchField(
              hint: 'Search plants...',
              onChanged: (v) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() => _searchQuery = v);
                });
              },
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Low Tech'),
                  selected: _lowTechOnly,
                  onSelected: (v) => setState(() => _lowTechOnly = v),
                ),
                const SizedBox(width: AppSpacing.sm),
                _buildDifficultyChip('Easy'),
                const SizedBox(width: AppSpacing.sm),
                _buildDifficultyChip('Medium'),
                const SizedBox(width: AppSpacing.sm),
                _buildDifficultyChip('Hard'),
                const SizedBox(width: AppSpacing.sm),
                _buildPlacementChip('Foreground'),
                const SizedBox(width: AppSpacing.sm),
                _buildPlacementChip('Background'),
                const SizedBox(width: AppSpacing.sm),
                _buildPlacementChip('Floating'),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Text('${plants.length} plants', style: AppTypography.bodySmall),
                const Spacer(),
                if (_difficultyFilter != null ||
                    _placementFilter != null ||
                    _lowTechOnly)
                  AppButton(
                    label: 'Clear filters',
                    onPressed: () => setState(() {
                      _difficultyFilter = null;
                      _placementFilter = null;
                      _lowTechOnly = false;
                    }),
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                  ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: plants.length,
              itemBuilder: (ctx, i) => _PlantCard(
                plant: plants[i],
                onTap: () => _showPlantDetail(context, plants[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    return FilterChip(
      label: Text(difficulty),
      selected: _difficultyFilter == difficulty,
      onSelected: (v) =>
          setState(() => _difficultyFilter = v ? difficulty : null),
    );
  }

  Widget _buildPlacementChip(String placement) {
    return FilterChip(
      label: Text(placement),
      selected: _placementFilter == placement,
      onSelected: (v) =>
          setState(() => _placementFilter = v ? placement : null),
    );
  }

  Future<void> _showPlantDetail(BuildContext context, PlantInfo plant) async {
    // Award XP for researching a new plant (once per session per plant)
    if (!_researchedPlants.contains(plant.scientificName)) {
      _researchedPlants.add(plant.scientificName);
      await ref
          .read(userProfileProvider.notifier)
          .recordActivity(xp: XpRewards.plantResearched);

      // Show XP animation
      if (mounted) {
        ref.showXpAnimation(XpRewards.plantResearched);
      }
    }

    if (!context.mounted) return;

    showAppScrollableSheet(
      context: context,
      initialSize: 0.85,
      minSize: 0.5,
      maxSize: 0.95,
      builder: (_, scrollController) =>
          _PlantDetailSheet(plant: plant, scrollController: scrollController),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final PlantInfo plant;
  final VoidCallback onTap;

  const _PlantCard({required this.plant, required this.onTap});

  Color _difficultyColor(BuildContext context) {
    switch (plant.difficulty) {
      case 'Easy':
        return AppColors.success;
      case 'Medium':
      case 'Medium-Hard':
        return AppColors.warning;
      case 'Hard':
        return AppColors.error;
      default:
        return context.textSecondary;
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
            color: AppOverlays.success10,
            borderRadius: AppRadius.smallRadius,
          ),
          child: const Icon(Icons.eco, color: AppColors.success),
        ),
        title: Text(plant.commonName, style: AppTypography.labelLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plant.scientificName,
              style: AppTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 6,
              children: [
                _MiniChip(
                  label: plant.difficulty,
                  color: _difficultyColor(context),
                ),
                _MiniChip(
                  label: plant.lightLevel,
                  color: AppColors.paramWarning,
                ),
                if (plant.needsCO2)
                  _MiniChip(label: 'CO₂', color: context.textSecondary),
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

class _PlantDetailSheet extends StatelessWidget {
  final PlantInfo plant;
  final ScrollController scrollController;

  const _PlantDetailSheet({
    required this.plant,
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
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textHint,
                  borderRadius: BorderRadius.circular(AppRadius.xxs),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg2),

            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppOverlays.success10,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppColors.success,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.commonName,
                        style: AppTypography.headlineMedium,
                      ),
                      Text(
                        plant.scientificName,
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
                _StatChip(label: plant.difficulty, icon: Icons.speed),
                _StatChip(
                  label: '${plant.lightLevel} Light',
                  icon: Icons.wb_sunny,
                ),
                _StatChip(
                  label: '${plant.growthRate} Growth',
                  icon: Icons.trending_up,
                ),
                _StatChip(label: plant.placement, icon: Icons.layers),
                if (plant.needsCO2)
                  _StatChip(label: 'CO₂ Required', icon: Icons.bubble_chart),
                if (!plant.needsCO2)
                  _StatChip(label: 'No CO₂ Needed', icon: Icons.check_circle),
              ],
            ),

            const SizedBox(height: AppSpacing.lg2),

            // Description
            Text(plant.description, style: AppTypography.bodyLarge),

            const SizedBox(height: AppSpacing.lg2),

            // Details
            _DetailSection(
              title: 'Details',
              children: [
                _DetailRow(label: 'Family', value: plant.family),
                _DetailRow(label: 'Origin', value: plant.origin),
                _DetailRow(
                  label: 'Height',
                  value:
                      '${plant.minHeightCm.toStringAsFixed(0)}-${plant.maxHeightCm.toStringAsFixed(0)} cm',
                ),
                _DetailRow(label: 'Propagation', value: plant.propagation),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Tips
            _DetailSection(
              title: 'Care Tips',
              children: [
                ...plant.tips.map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.eco,
                          size: AppIconSizes.xs,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(tip, style: AppTypography.bodyMedium),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

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

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.headlineSmall),
        const SizedBox(height: AppSpacing.sm2),
        ...children,
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTypography.bodySmall),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}
