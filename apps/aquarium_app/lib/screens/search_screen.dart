import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_database.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import 'livestock_detail_screen.dart';
import 'tank_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tanksAsync = ref.watch(tanksProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search tanks, fish, equipment...',
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: (value) => setState(() => _query = value.toLowerCase()),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear search',
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: _query.isEmpty
          ? _EmptySearchState()
          : tanksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (tanks) =>
                  _SearchResults(query: _query, tanks: tanks, ref: ref),
            ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text('Search your aquarium data', style: AppTypography.bodyMedium),
          const SizedBox(height: 8),
          Text(
            'Find tanks, fish, equipment, or browse species',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final String query;
  final List<Tank> tanks;
  final WidgetRef ref;

  const _SearchResults({
    required this.query,
    required this.tanks,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final results = <_SearchResult>[];

    // Search tanks
    for (final tank in tanks) {
      if (tank.name.toLowerCase().contains(query)) {
        results.add(
          _SearchResult(
            type: _ResultType.tank,
            title: tank.name,
            subtitle:
                '${tank.volumeLitres.toStringAsFixed(0)}L ${tank.type.name}',
            icon: Icons.water,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TankDetailScreen(tankId: tank.id),
              ),
            ),
          ),
        );
      }
    }

    // Search livestock across all tanks
    for (final tank in tanks) {
      final livestockAsync = ref.read(livestockProvider(tank.id));
      livestockAsync.whenData((livestock) {
        for (final l in livestock) {
          if (l.commonName.toLowerCase().contains(query) ||
              (l.scientificName?.toLowerCase().contains(query) ?? false)) {
            results.add(
              _SearchResult(
                type: _ResultType.livestock,
                title: l.commonName,
                subtitle: 'in ${tank.name} (×${l.count})',
                icon: Icons.set_meal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LivestockDetailScreen(tankId: tank.id, livestock: l),
                  ),
                ),
              ),
            );
          }
        }
      });

      // Search equipment
      final equipmentAsync = ref.read(equipmentProvider(tank.id));
      equipmentAsync.whenData((equipment) {
        for (final e in equipment) {
          if (e.name.toLowerCase().contains(query) ||
              e.typeName.toLowerCase().contains(query) ||
              (e.brand?.toLowerCase().contains(query) ?? false)) {
            results.add(
              _SearchResult(
                type: _ResultType.equipment,
                title: e.name,
                subtitle: '${e.typeName} in ${tank.name}',
                icon: Icons.build,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TankDetailScreen(tankId: tank.id),
                  ),
                ),
              ),
            );
          }
        }
      });
    }

    // Search species database
    final speciesResults = SpeciesDatabase.search(query);
    for (final species in speciesResults.take(10)) {
      results.add(
        _SearchResult(
          type: _ResultType.species,
          title: species.commonName,
          subtitle: '${species.scientificName} • ${species.careLevel}',
          icon: Icons.pets,
          onTap: () => _showSpeciesInfo(context, species),
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('No results for "$query"', style: AppTypography.bodyMedium),
          ],
        ),
      );
    }

    // Group results by type
    final tankResults = results
        .where((r) => r.type == _ResultType.tank)
        .toList();
    final livestockResults = results
        .where((r) => r.type == _ResultType.livestock)
        .toList();
    final equipmentResults = results
        .where((r) => r.type == _ResultType.equipment)
        .toList();
    final speciesResultsList = results
        .where((r) => r.type == _ResultType.species)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (tankResults.isNotEmpty) ...[
          _SectionHeader(title: 'Tanks', count: tankResults.length),
          ...tankResults.map((r) => _ResultTile(result: r)),
          const SizedBox(height: 16),
        ],
        if (livestockResults.isNotEmpty) ...[
          _SectionHeader(title: 'Livestock', count: livestockResults.length),
          ...livestockResults.map((r) => _ResultTile(result: r)),
          const SizedBox(height: 16),
        ],
        if (equipmentResults.isNotEmpty) ...[
          _SectionHeader(title: 'Equipment', count: equipmentResults.length),
          ...equipmentResults.map((r) => _ResultTile(result: r)),
          const SizedBox(height: 16),
        ],
        if (speciesResultsList.isNotEmpty) ...[
          _SectionHeader(
            title: 'Species Database',
            count: speciesResultsList.length,
          ),
          ...speciesResultsList.map((r) => _ResultTile(result: r)),
        ],
      ],
    );
  }

  void _showSpeciesInfo(BuildContext context, SpeciesInfo species) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
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
              Text(species.commonName, style: AppTypography.headlineMedium),
              Text(
                species.scientificName,
                style: AppTypography.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(label: species.careLevel),
                  _InfoChip(label: species.temperament),
                  _InfoChip(
                    label: '${species.adultSizeCm.toStringAsFixed(0)}cm',
                  ),
                  _InfoChip(label: species.family),
                ],
              ),
              const SizedBox(height: 16),
              Text(species.description, style: AppTypography.bodyLarge),
              const SizedBox(height: 16),
              Text('Parameters', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Temperature: ${species.minTempC}–${species.maxTempC}°C\n'
                'pH: ${species.minPh}–${species.maxPh}\n'
                'Min tank: ${species.minTankLitres.toStringAsFixed(0)}L\n'
                'School size: ${species.minSchoolSize}+',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text('Diet', style: AppTypography.headlineSmall),
              const SizedBox(height: 8),
              Text(species.diet, style: AppTypography.bodyMedium),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;

  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: AppTypography.bodySmall),
    );
  }
}

enum _ResultType { tank, livestock, equipment, species }

class _SearchResult {
  final _ResultType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title, style: AppTypography.labelLarge),
          const SizedBox(width: 8),
          Text('($count)', style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final _SearchResult result;

  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(result.icon, color: AppColors.primary, size: 20),
        ),
        title: Text(result.title),
        subtitle: Text(result.subtitle, style: AppTypography.bodySmall),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: result.onTap,
      ),
    );
  }
}
