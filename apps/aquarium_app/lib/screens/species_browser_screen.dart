import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_database.dart';
import '../models/wishlist.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/core/app_text_field.dart';
import '../models/learning.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/debouncer.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/core/app_card.dart';
import '../widgets/core/app_button.dart';
import '../widgets/core/app_dialog.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/danio_snack_bar.dart';
import 'emergency_guide_screen.dart';
import 'stocking_calculator_screen.dart';

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
  final _searchDebouncer = Debouncer(delay: kSearchDebounce);

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
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: context.textHint,
                        ),
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
                        const SizedBox(height: AppSpacing.lg),
                        AppButton(
                          label: 'Request species',
                          leadingIcon: Icons.outgoing_mail,
                          onPressed: () => _showSpeciesRequestDialog(context),
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.small,
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

  void _showSpeciesRequestDialog(BuildContext context) {
    final searchedName = _searchQuery.trim();
    final requestedName = searchedName.isEmpty ? 'this species' : searchedName;

    showAppDialog<void>(
      context: context,
      title: 'Request Species',
      icon: Icons.outgoing_mail,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We could not find "$requestedName" in the local fish database.',
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Email larkintiarnanbizz@gmail.com with the common name, '
            'scientific name if you know it, and any care source or photo '
            'that would help us verify the entry.',
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Danio does not send this automatically in this local build.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        AppButton(
          label: 'Done',
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
          variant: AppButtonVariant.primary,
          isFullWidth: true,
        ),
      ],
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
        vertical: AppSpacing.xxs,
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

            AppCard(
              padding: AppCardPadding.compact,
              backgroundColor: AppOverlays.error10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emergency_outlined,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Species safety',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Urgent steps for illness, injury, gasping, or unsafe water',
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: 'Emergency Guide',
                    leadingIcon: Icons.emergency_outlined,
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                    onPressed: () => NavigationThrottle.push(
                      context,
                      const EmergencyGuideScreen(),
                      rootNavigator: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg2),

            Text(species.description, style: AppTypography.bodyLarge),

            const SizedBox(height: AppSpacing.lg2),

            _CareActionsCard(species: species),

            const SizedBox(height: AppSpacing.lg2),

            _SpeciesWatchForCard(species: species),

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

            if (species.medicationWarnings.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg2),
              Text('Treatment Warnings', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              ...species.medicationWarnings.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppOverlays.error10,
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(color: AppOverlays.error10),
                    ),
                    child: Text(warning, style: AppTypography.bodyMedium),
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _CareActionsCard extends ConsumerWidget {
  final SpeciesInfo species;

  const _CareActionsCard({required this.species});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref
        .watch(fishWishlistProvider)
        .any(
          (item) =>
              item.name.toLowerCase() == species.commonName.toLowerCase() ||
              item.species?.toLowerCase() ==
                  species.scientificName.toLowerCase(),
        );
    final actions = <_CareAction>[
      _CareAction(
        icon: Icons.home_work_outlined,
        text:
            'Use a tank of at least ${species.minTankLitres.toStringAsFixed(0)} L.',
      ),
      _CareAction(
        icon: Icons.groups_outlined,
        text: species.minSchoolSize > 1
            ? 'Plan a group of ${species.minSchoolSize} or more.'
            : 'Can be planned as a single fish when the tank setup fits.',
      ),
      _CareAction(
        icon: Icons.thermostat_outlined,
        text:
            'Keep water around ${_format(species.minTempC)}-${_format(species.maxTempC)} C and pH ${_formatPh(species.minPh)}-${_formatPh(species.maxPh)}.',
      ),
      _CareAction(
        icon: Icons.fact_check_outlined,
        text: species.avoidWith.isNotEmpty
            ? 'Check the avoid list before adding tankmates.'
            : 'Check adult size and temperament before adding tankmates.',
      ),
      if (species.medicationWarnings.isNotEmpty)
        const _CareAction(
          icon: Icons.medical_services_outlined,
          text: 'Review treatment warnings before medicating.',
        ),
    ];

    return AppCard(
      padding: AppCardPadding.compact,
      backgroundColor: AppOverlays.primary10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.checklist_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Care Actions', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          ...actions.map(
            (action) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CareActionRow(action: action),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppButton(
                label: isSaved ? 'Saved to wishlist' : 'Save to wishlist',
                leadingIcon: isSaved
                    ? Icons.bookmark_added_outlined
                    : Icons.bookmark_add_outlined,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: isSaved
                    ? null
                    : () async => _saveToWishlist(context, ref),
              ),
              AppButton(
                label: 'Plan stocking fit',
                leadingIcon: Icons.calculate_outlined,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: () => NavigationThrottle.push(
                  context,
                  StockingCalculatorScreen(initialSpecies: species),
                  rootNavigator: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _saveToWishlist(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(wishlistProvider.notifier)
          .addItem(
            WishlistItem(
              category: WishlistCategory.fish,
              name: species.commonName,
              species: species.scientificName,
              notes:
                  'Saved from Species Guide. Minimum group: ${species.minSchoolSize}. Minimum tank: ${species.minTankLitres.toStringAsFixed(0)} L.',
              quantity: species.minSchoolSize > 0 ? species.minSchoolSize : 1,
            ),
          );
      if (context.mounted) {
        DanioSnackBar.success(context, '${species.commonName} saved');
      }
    } catch (_) {
      if (context.mounted) {
        DanioSnackBar.error(context, 'Could not save ${species.commonName}');
      }
    }
  }

  String _format(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String _formatPh(double value) => value.toStringAsFixed(1);
}

class _SpeciesWatchForCard extends StatelessWidget {
  final SpeciesInfo species;

  const _SpeciesWatchForCard({required this.species});

  @override
  Widget build(BuildContext context) {
    final items = <_WatchForItem>[
      if (species.minSchoolSize > 1)
        _WatchForItem(
          icon: Icons.groups_outlined,
          text:
              'Small groups: plan ${species.minSchoolSize} or more, not a lone fish.',
        ),
      if (species.avoidWith.isNotEmpty)
        _WatchForItem(
          icon: Icons.warning_amber_outlined,
          text:
              'Tankmates: review ${species.avoidWith.join(', ')} before mixing.',
        ),
      _WatchForItem(
        icon: Icons.straighten,
        text:
            'Adult fit: plan around ${_formatSize(species.adultSizeCm)} cm adult size and ${species.minTankLitres.toStringAsFixed(0)} L minimum tank.',
      ),
      if (!_isBeginnerCare(species.careLevel))
        _WatchForItem(
          icon: Icons.speed_outlined,
          text: 'Care level: ${species.careLevel} needs steadier planning.',
        ),
      if (species.medicationWarnings.isNotEmpty)
        const _WatchForItem(
          icon: Icons.medical_services_outlined,
          text: 'Treatment: review medication warnings before dosing.',
        ),
    ];

    return AppCard(
      padding: AppCardPadding.compact,
      backgroundColor: AppOverlays.warning10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Watch For', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _WatchForRow(item: item),
            ),
          ),
        ],
      ),
    );
  }

  bool _isBeginnerCare(String careLevel) {
    final normalised = careLevel.toLowerCase();
    return normalised == 'beginner' || normalised == 'easy';
  }

  String _formatSize(double value) {
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }
}

class _WatchForItem {
  final IconData icon;
  final String text;

  const _WatchForItem({required this.icon, required this.text});
}

class _WatchForRow extends StatelessWidget {
  final _WatchForItem item;

  const _WatchForRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(item.icon, size: 18, color: AppColors.warning),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(item.text, style: AppTypography.bodyMedium)),
      ],
    );
  }
}

class _CareAction {
  final IconData icon;
  final String text;

  const _CareAction({required this.icon, required this.text});
}

class _CareActionRow extends StatelessWidget {
  final _CareAction action;

  const _CareActionRow({required this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(action.icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(action.text, style: AppTypography.bodyMedium)),
      ],
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
