import 'dart:async';
import '../utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_database.dart';
import '../models/log_entry.dart';
import '../models/tank.dart';
import '../widgets/core/app_text_field.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/core/app_card.dart';
import 'add_log_screen.dart';

const double _maxCompatibilityReadableWidth = 720;

class CompatibilityCheckerScreen extends ConsumerStatefulWidget {
  final String? tankId;

  const CompatibilityCheckerScreen({super.key, this.tankId});

  @override
  ConsumerState<CompatibilityCheckerScreen> createState() =>
      _CompatibilityCheckerScreenState();
}

class _CompatibilityCheckerScreenState
    extends ConsumerState<CompatibilityCheckerScreen> {
  final List<SpeciesInfo> _selectedSpecies = [];
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<SpeciesInfo> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    return SpeciesDatabase.search(
      _searchQuery,
    ).where((s) => !_selectedSpecies.contains(s)).take(10).toList();
  }

  void _addSpecies(SpeciesInfo species) {
    setState(() {
      _selectedSpecies.add(species);
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _removeSpecies(SpeciesInfo species) {
    setState(() {
      _selectedSpecies.remove(species);
    });
  }

  bool _isBettaNeonPair(SpeciesInfo a, SpeciesInfo b) {
    final names = [a.commonName.toLowerCase(), b.commonName.toLowerCase()];
    return names.any((name) => name.contains('betta')) &&
        names.any((name) => name.contains('neon tetra'));
  }

  String _issueTitle(_CompatibilityIssue issue) {
    return issue.species2.trim().isEmpty
        ? issue.species1
        : '${issue.species1} + ${issue.species2}';
  }

  Tank? _tankReference(List<Tank>? tanks) {
    if (tanks == null || tanks.isEmpty) return null;

    final tankId = widget.tankId;
    if (tankId != null) {
      for (final tank in tanks) {
        if (tank.id == tankId) return tank;
      }
    }

    return tanks.reduce(
      (largest, tank) =>
          largest.volumeLitres >= tank.volumeLitres ? largest : tank,
    );
  }

  List<_CompatibilityIssue> _issuesForTanks(List<Tank>? tanks) {
    final issues = <_CompatibilityIssue>[];

    for (var i = 0; i < _selectedSpecies.length; i++) {
      for (var j = i + 1; j < _selectedSpecies.length; j++) {
        final a = _selectedSpecies[i];
        final b = _selectedSpecies[j];

        if (_isBettaNeonPair(a, b)) {
          issues.add(
            _CompatibilityIssue(
              species1: 'Betta + Neon Tetra',
              species2: '',
              severity: _Severity.warning,
              reason:
                  'Betta temperament varies. This can work in a planted tank with cover, but watch for chasing, fin nipping, and stress during the first week.',
            ),
          );
        }

        // Check explicit incompatibility (exact match on name/family)
        if (a.avoidWith.any(
          (name) =>
              b.commonName.toLowerCase() == name.toLowerCase() ||
              b.family.toLowerCase() == name.toLowerCase(),
        )) {
          issues.add(
            _CompatibilityIssue(
              species1: a.commonName,
              species2: b.commonName,
              severity: _Severity.bad,
              reason:
                  '${a.commonName} is known to be incompatible with ${b.commonName}',
            ),
          );
        } else if (b.avoidWith.any(
          (name) =>
              a.commonName.toLowerCase() == name.toLowerCase() ||
              a.family.toLowerCase() == name.toLowerCase(),
        )) {
          issues.add(
            _CompatibilityIssue(
              species1: a.commonName,
              species2: b.commonName,
              severity: _Severity.bad,
              reason:
                  '${b.commonName} is known to be incompatible with ${a.commonName}',
            ),
          );
        }

        // Check temperament conflicts
        if (a.temperament == 'Aggressive' && b.temperament == 'Peaceful') {
          issues.add(
            _CompatibilityIssue(
              species1: a.commonName,
              species2: b.commonName,
              severity: _Severity.warning,
              reason:
                  '${a.commonName} (aggressive) may harass ${b.commonName} (peaceful)',
            ),
          );
        } else if (b.temperament == 'Aggressive' &&
            a.temperament == 'Peaceful') {
          issues.add(
            _CompatibilityIssue(
              species1: a.commonName,
              species2: b.commonName,
              severity: _Severity.warning,
              reason:
                  '${b.commonName} (aggressive) may harass ${a.commonName} (peaceful)',
            ),
          );
        }

        // Check temperature overlap
        if (a.maxTempC < b.minTempC || b.maxTempC < a.minTempC) {
          issues.add(
            _CompatibilityIssue(
              species1: a.commonName,
              species2: b.commonName,
              severity: _Severity.bad,
              reason:
                  'Temperature ranges don\'t overlap: '
                  '${a.commonName} (${a.minTempC}-${a.maxTempC} deg C) vs '
                  '${b.commonName} (${b.minTempC}-${b.maxTempC} deg C)',
            ),
          );
        }

        // Check pH overlap
        if (a.maxPh < b.minPh || b.maxPh < a.minPh) {
          issues.add(
            _CompatibilityIssue(
              species1: a.commonName,
              species2: b.commonName,
              severity: _Severity.bad,
              reason:
                  'pH ranges don\'t overlap: '
                  '${a.commonName} (${a.minPh}-${a.maxPh}) vs '
                  '${b.commonName} (${b.minPh}-${b.maxPh})',
            ),
          );
        }

        // Size difference warning
        final sizeRatio = a.adultSizeCm > b.adultSizeCm
            ? a.adultSizeCm / b.adultSizeCm
            : b.adultSizeCm / a.adultSizeCm;
        if (sizeRatio > 4) {
          final larger = a.adultSizeCm > b.adultSizeCm ? a : b;
          final smaller = a.adultSizeCm > b.adultSizeCm ? b : a;
          issues.add(
            _CompatibilityIssue(
              species1: a.commonName,
              species2: b.commonName,
              severity: _Severity.warning,
              reason:
                  'Large size difference: ${larger.commonName} (${larger.adultSizeCm.toStringAsFixed(0)}cm) '
                  'may see ${smaller.commonName} (${smaller.adultSizeCm.toStringAsFixed(0)}cm) as food',
            ),
          );
        }
      }
    }

    // Tank size check: selected tank if supplied, otherwise largest owned tank.
    final tankReference = _tankReference(tanks);
    if (tankReference != null && _selectedSpecies.isNotEmpty) {
      for (final species in _selectedSpecies) {
        if (species.minTankLitres > tankReference.volumeLitres) {
          issues.add(
            _CompatibilityIssue(
              species1: species.commonName,
              species2: '',
              severity: _Severity.warning,
              reason:
                  '${species.commonName} requires at least ${species.minTankLitres.toStringAsFixed(0)} litres - ${tankReference.name} may be too small',
            ),
          );
        }
      }
    }

    return issues;
  }

  double get _minTankSize {
    if (_selectedSpecies.isEmpty) return 0;
    return _selectedSpecies
        .map((s) => s.minTankLitres)
        .reduce((a, b) => a > b ? a : b);
  }

  (double, double) get _tempRange {
    if (_selectedSpecies.isEmpty) return (0, 0);
    final minTemp = _selectedSpecies
        .map((s) => s.minTempC)
        .reduce((a, b) => a > b ? a : b);
    final maxTemp = _selectedSpecies
        .map((s) => s.maxTempC)
        .reduce((a, b) => a < b ? a : b);
    return (minTemp, maxTemp);
  }

  (double, double) get _phRange {
    if (_selectedSpecies.isEmpty) return (0, 0);
    final minPh = _selectedSpecies
        .map((s) => s.minPh)
        .reduce((a, b) => a > b ? a : b);
    final maxPh = _selectedSpecies
        .map((s) => s.maxPh)
        .reduce((a, b) => a < b ? a : b);
    return (minPh, maxPh);
  }

  String _verdictFor(List<_CompatibilityIssue> issues) {
    final badIssues = issues.where((i) => i.severity == _Severity.bad).length;
    final warningIssues = issues
        .where((i) => i.severity == _Severity.warning)
        .length;

    if (badIssues > 0) return 'Not Recommended';
    if (warningIssues > 0) return 'Proceed with Caution';
    return 'Good Match!';
  }

  String _formatTankReference(Tank? tank) {
    if (tank == null) return 'No tank selected';
    return '${tank.name} (${tank.volumeLitres.toStringAsFixed(0)} L)';
  }

  String get _compatibilitySummary {
    final tanks = ref.read(tanksProvider).valueOrNull;
    final issues = _issuesForTanks(tanks);
    final issueLines = issues.isEmpty
        ? 'No issues found by the local checker.'
        : issues
              .map((issue) => '- ${_issueTitle(issue)}: ${issue.reason}')
              .join('\n');

    return 'Compatibility check\n'
        'Tank reference: ${_formatTankReference(_tankReference(tanks))}\n'
        'Species: ${_selectedSpecies.map((s) => s.commonName).join(', ')}\n'
        'Verdict: ${_verdictFor(issues)}\n'
        'Minimum tank: ${_minTankSize.toStringAsFixed(0)}+ litres\n'
        'Temperature: ${_tempRange.$1 <= _tempRange.$2 ? '${_tempRange.$1.toStringAsFixed(0)}-${_tempRange.$2.toStringAsFixed(0)} deg C' : 'No overlap'}\n'
        'pH range: ${_phRange.$1 <= _phRange.$2 ? '${_phRange.$1.toStringAsFixed(1)}-${_phRange.$2.toStringAsFixed(1)}' : 'No overlap'}\n'
        'Issues:\n'
        '$issueLines\n'
        'This is educational planning guidance. Watch actual behaviour, provide cover and group sizes, and separate fish if stress or aggression appears.';
  }

  void _logCompatibilityCheck() {
    final tankId = widget.tankId;
    if (tankId == null || _selectedSpecies.length < 2) return;

    NavigationThrottle.push(
      context,
      AddLogScreen(
        tankId: tankId,
        initialType: LogType.observation,
        initialNotes: _compatibilitySummary,
      ),
      rootNavigator: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tanks = ref.watch(tanksProvider).valueOrNull;
    final issues = _issuesForTanks(tanks);
    final badIssues = issues.where((i) => i.severity == _Severity.bad).length;
    final warningIssues = issues
        .where((i) => i.severity == _Severity.warning)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Compatibility Checker')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Search bar
            _CompatibilityReadableFrame(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppSearchField(
                  controller: _searchController,
                  hint: 'Search fish to add...',
                  onChanged: (v) {
                    _debounce?.cancel();
                    _debounce = Timer(kDebounceDuration, () {
                      setState(() => _searchQuery = v);
                    });
                  },
                ),
              ),
            ),

            // Search results
            if (_searchResults.isNotEmpty)
              _CompatibilityReadableFrame(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppRadius.mediumRadius,
                    boxShadow: [
                      BoxShadow(color: AppOverlays.black12, blurRadius: 8),
                    ],
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (ctx, i) {
                        final species = _searchResults[i];
                        return ListTile(
                          leading: const Icon(Icons.add_circle_outline),
                          title: Text(species.commonName),
                          subtitle: Text(species.temperament),
                          onTap: () => _addSpecies(species),
                        );
                      },
                    ),
                  ),
                ),
              ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Selected species
                  if (_selectedSpecies.isEmpty)
                    _CompatibilityReadableFrame(
                      child: AppCard(
                        padding: AppCardPadding.spacious,
                        child: Column(
                          children: [
                            Icon(
                              Icons.set_meal,
                              size: AppIconSizes.xl,
                              color: context.textHint,
                            ),
                            const SizedBox(height: AppSpacing.sm2),
                            Text(
                              'Add Fish to Check',
                              style: AppTypography.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Search and add fish above to check if they\'re compatible',
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _CompatibilityReadableFrame(
                      child: Text(
                        'Selected Fish (${_selectedSpecies.length})',
                        style: AppTypography.headlineSmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _CompatibilityReadableFrame(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedSpecies
                            .map(
                              (s) => Chip(
                                backgroundColor: context.surfaceVariant,
                                label: Text(
                                  s.commonName,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: context.textPrimary,
                                  ),
                                ),
                                deleteIcon: Icon(
                                  Icons.close,
                                  size: AppIconSizes.xs,
                                  color: context.textSecondary,
                                ),
                                onDeleted: () => _removeSpecies(s),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Compatibility verdict
                    if (_selectedSpecies.length >= 2) ...[
                      _CompatibilityReadableFrame(
                        child: AppCard(
                          backgroundColor: badIssues > 0
                              ? AppOverlays.error10
                              : warningIssues > 0
                              ? AppOverlays.warning10
                              : AppOverlays.success10,
                          padding: AppCardPadding.standard,
                          child: Row(
                            children: [
                              Icon(
                                badIssues > 0
                                    ? Icons.cancel
                                    : warningIssues > 0
                                    ? Icons.warning
                                    : Icons.check_circle,
                                color: badIssues > 0
                                    ? AppColors.error
                                    : warningIssues > 0
                                    ? AppColors.warning
                                    : AppColors.success,
                                size: 32,
                              ),
                              const SizedBox(width: AppSpacing.sm2),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      badIssues > 0
                                          ? 'Not Recommended'
                                          : warningIssues > 0
                                          ? 'Proceed with Caution'
                                          : 'Good Match!',
                                      style: AppTypography.labelLarge,
                                    ),
                                    Text(
                                      badIssues > 0
                                          ? '$badIssues serious issue${badIssues > 1 ? 's' : ''} found'
                                          : warningIssues > 0
                                          ? '$warningIssues warning${warningIssues > 1 ? 's' : ''} to consider'
                                          : 'These fish should work well together',
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Issues list
                      if (issues.isNotEmpty) ...[
                        _CompatibilityReadableFrame(
                          child: Text(
                            'Issues Found',
                            style: AppTypography.headlineSmall,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...issues.map(
                          (issue) => _CompatibilityReadableFrame(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: AppCard(
                                padding: AppCardPadding.none,
                                child: ListTile(
                                  leading: Icon(
                                    issue.severity == _Severity.bad
                                        ? Icons.error
                                        : Icons.warning,
                                    color: issue.severity == _Severity.bad
                                        ? AppColors.error
                                        : AppColors.warning,
                                  ),
                                  title: Text(_issueTitle(issue)),
                                  subtitle: Text(
                                    issue.reason,
                                    style: AppTypography.bodySmall,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // Recommended parameters
                      _CompatibilityReadableFrame(
                        child: Text(
                          'Recommended Setup',
                          style: AppTypography.headlineSmall,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _CompatibilityReadableFrame(
                        child: AppCard(
                          padding: AppCardPadding.standard,
                          child: Column(
                            children: [
                              _ParamRow(
                                icon: Icons.water,
                                label: 'Minimum tank',
                                value:
                                    '${_minTankSize.toStringAsFixed(0)}+ litres',
                              ),
                              _ParamRow(
                                icon: Icons.thermostat,
                                label: 'Temperature',
                                value: _tempRange.$1 <= _tempRange.$2
                                    ? '${_tempRange.$1.toStringAsFixed(0)}-${_tempRange.$2.toStringAsFixed(0)} deg C'
                                    : 'No overlap!',
                                valueColor: _tempRange.$1 > _tempRange.$2
                                    ? AppColors.error
                                    : null,
                              ),
                              _ParamRow(
                                icon: Icons.science,
                                label: 'pH range',
                                value: _phRange.$1 <= _phRange.$2
                                    ? '${_phRange.$1.toStringAsFixed(1)}-${_phRange.$2.toStringAsFixed(1)}'
                                    : 'No overlap!',
                                valueColor: _phRange.$1 > _phRange.$2
                                    ? AppColors.error
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (widget.tankId != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        _CompatibilityReadableFrame(
                          child: AppCard(
                            backgroundColor: AppOverlays.info10,
                            padding: AppCardPadding.standard,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.route_outlined,
                                      color: AppColors.info,
                                      size: AppIconSizes.sm,
                                    ),
                                    const SizedBox(width: AppSpacing.sm2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Guided next step',
                                            style: AppTypography.labelLarge,
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'Save this compatibility check to the tank journal before you buy or move fish.',
                                            style: AppTypography.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                FilledButton.icon(
                                  onPressed: _logCompatibilityCheck,
                                  icon: const Icon(Icons.edit_note_rounded),
                                  label: const Text('Log compatibility check'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompatibilityReadableFrame extends StatelessWidget {
  final Widget child;

  const _CompatibilityReadableFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: _maxCompatibilityReadableWidth,
        ),
        child: child,
      ),
    );
  }
}

enum _Severity { warning, bad }

class _CompatibilityIssue {
  final String species1;
  final String species2;
  final _Severity severity;
  final String reason;

  const _CompatibilityIssue({
    required this.species1,
    required this.species2,
    required this.severity,
    required this.reason,
  });
}

class _ParamRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _ParamRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(label, style: AppTypography.bodyMedium)),
          Text(
            value,
            style: AppTypography.labelLarge.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}
