import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/species_database.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../services/compatibility_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../widgets/core/app_card.dart';

class LivestockDetailScreen extends ConsumerWidget {
  final String tankId;
  final Livestock livestock;

  const LivestockDetailScreen({
    super.key,
    required this.tankId,
    required this.livestock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tankAsync = ref.watch(tankProvider(tankId));
    final allLivestockAsync = ref.watch(livestockProvider(tankId));

    // Try to find species info
    final species =
        SpeciesDatabase.lookup(livestock.commonName) ??
        (livestock.scientificName != null
            ? SpeciesDatabase.lookup(livestock.scientificName!)
            : null);

    return Scaffold(
      appBar: AppBar(title: Text(livestock.commonName)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _HeaderCard(livestock: livestock, species: species),

            const SizedBox(height: AppSpacing.md),

            // Compatibility check (if we have tank data)
            tankAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
              data: (tank) {
                if (tank == null) return const SizedBox.shrink();

                return allLivestockAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xs),
                        Text('Unable to load', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warning)),
                      ],
                    ),
                  ),
                  data: (allLivestock) {
                    final issues =
                        CompatibilityService.checkLivestockCompatibility(
                          livestock: livestock,
                          tank: tank,
                          existingLivestock: allLivestock,
                        );

                    if (issues.isEmpty && species != null) {
                      return _CompatibilityCard(
                        level: CompatibilityLevel.compatible,
                        issues: const [],
                      );
                    }

                    if (issues.isNotEmpty) {
                      return _CompatibilityCard(
                        level: CompatibilityService.overallLevel(issues),
                        issues: issues,
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              },
            ),

            // Species care guide (if found)
            if (species != null) ...[
              const SizedBox(height: AppSpacing.md),
              _CareGuideCard(species: species),

              const SizedBox(height: AppSpacing.md),
              _ParametersCard(species: species),

              const SizedBox(height: AppSpacing.md),
              _CompatibilityNotesCard(species: species),
            ] else ...[
              const SizedBox(height: AppSpacing.md),
              _NoSpeciesDataCard(livestock: livestock),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Livestock livestock;
  final SpeciesInfo? species;

  const _HeaderCard({required this.livestock, this.species});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'livestock-${livestock.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: CircleAvatar(
                    radius: kAvatarSizeMd,
                    backgroundColor: AppOverlays.primary10,
                    child: const Icon(
                      Icons.set_meal,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        livestock.commonName,
                        style: AppTypography.headlineMedium,
                      ),
                      if (livestock.scientificName != null || species != null)
                        Text(
                          livestock.scientificName ??
                              species?.scientificName ??
                              '',
                          style: AppTypography.bodyMedium.copyWith(
                            fontStyle: FontStyle.italic,
                            color: context.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _InfoChip(icon: Icons.tag, label: '×${livestock.count}'),
                if (species != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(
                    icon: Icons.straighten,
                    label: '${species!.adultSizeCm.toStringAsFixed(0)} cm',
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(
                    icon: Icons.psychology,
                    label: species!.temperament,
                    color: _temperamentColor(species!.temperament),
                  ),
                ],
              ],
            ),
            if (species != null) ...[
              const SizedBox(height: AppSpacing.sm2),
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.school,
                    label: species!.careLevel,
                    color: _careLevelColor(species!.careLevel),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(
                    icon: Icons.family_restroom,
                    label: species!.family,
                  ),
                ],
              ),
            ],
          ],
        ),
      );
  }

  Color _temperamentColor(String temperament) {
    switch (temperament.toLowerCase()) {
      case 'peaceful':
        return AppColors.success;
      case 'semi-aggressive':
        return AppColors.warning;
      case 'aggressive':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _careLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm3, vertical: AppSpacing.xs2),
      decoration: BoxDecoration(
        color: Color((c.value & 0x00FFFFFF) | 0x19000000), // 10% opacity
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: Color((c.value & 0x00FFFFFF) | 0x4D000000)), // 30% opacity
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTypography.bodySmall.copyWith(color: c)),
        ],
      ),
    );
  }
}

class _CompatibilityCard extends StatelessWidget {
  final CompatibilityLevel level;
  final List<CompatibilityIssue> issues;

  const _CompatibilityCard({required this.level, required this.issues});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String title;

    switch (level) {
      case CompatibilityLevel.compatible:
        color = AppColors.success;
        icon = Icons.check_circle;
        title = 'Compatible with tank';
        break;
      case CompatibilityLevel.warning:
        color = AppColors.warning;
        icon = Icons.warning_amber;
        title = 'Potential issues';
        break;
      case CompatibilityLevel.incompatible:
        color = AppColors.error;
        icon = Icons.error;
        title = 'Compatibility concerns';
        break;
    }

    return AppCard(
      padding: AppCardPadding.standard,
      backgroundColor: Color((color.value & 0x00FFFFFF) | 0x0D000000), // 5% opacity
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTypography.headlineSmall.copyWith(color: color),
                ),
              ],
            ),
            if (issues.isEmpty && level == CompatibilityLevel.compatible) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Parameters and tankmates look good.',
                style: AppTypography.bodyMedium,
              ),
            ],
            if (issues.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm2),
              ...issues.map((issue) => _IssueRow(issue: issue)),
            ],
          ],
        ),
      );
  }
}

class _IssueRow extends StatelessWidget {
  final CompatibilityIssue issue;

  const _IssueRow({required this.issue});

  @override
  Widget build(BuildContext context) {
    final color = issue.level == CompatibilityLevel.incompatible
        ? AppColors.error
        : AppColors.warning;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                issue.level == CompatibilityLevel.incompatible
                    ? Icons.error_outline
                    : Icons.warning_amber_outlined,
                size: AppIconSizes.xs,
                color: color,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: AppTypography.labelLarge.copyWith(color: color),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(issue.description, style: AppTypography.bodySmall),
                    if (issue.suggestion != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '💡 ${issue.suggestion}',
                        style: AppTypography.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CareGuideCard extends StatelessWidget {
  final SpeciesInfo species;

  const _CareGuideCard({required this.species});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_stories, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Care Guide', style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm2),
            Text(species.description, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.md),

            _CareRow(
              icon: Icons.restaurant,
              label: 'Diet',
              value: species.diet,
            ),
            _CareRow(
              icon: Icons.water,
              label: 'Swim Level',
              value: species.swimLevel,
            ),
            _CareRow(
              icon: Icons.group,
              label: 'Min School Size',
              value: species.minSchoolSize == 1
                  ? 'Can be kept singly'
                  : '${species.minSchoolSize}+',
            ),
            _CareRow(
              icon: Icons.straighten,
              label: 'Min Tank Size',
              value: '${species.minTankLitres.toStringAsFixed(0)} litres',
            ),
          ],
        ),
      );
  }
}

class _CareRow extends StatelessWidget{
  final IconData icon;
  final String label;
  final String value;

  const _CareRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: context.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTypography.bodyMedium)),
        ],
      ),
    );
  }
}

class _ParametersCard extends StatelessWidget {
  final SpeciesInfo species;

  const _ParametersCard({required this.species});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Ideal Parameters', style: AppTypography.headlineSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ParamPill(
                  label: 'Temp',
                  value:
                      '${species.minTempC.toStringAsFixed(0)}-${species.maxTempC.toStringAsFixed(0)}',
                  unit: '°C',
                ),
                _ParamPill(
                  label: 'pH',
                  value:
                      '${species.minPh.toStringAsFixed(1)}-${species.maxPh.toStringAsFixed(1)}',
                ),
                if (species.minGh != null && species.maxGh != null)
                  _ParamPill(
                    label: 'GH',
                    value:
                        '${species.minGh!.toStringAsFixed(0)}-${species.maxGh!.toStringAsFixed(0)}',
                    unit: 'dGH',
                  ),
              ],
            ),
          ],
        ),
      );
  }
}

class _ParamPill extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;

  const _ParamPill({required this.label, required this.value, this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm4, vertical: AppSpacing.sm3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppOverlays.surfaceVariant60),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            unit == null ? value : '$value $unit',
            style: AppTypography.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _CompatibilityNotesCard extends StatelessWidget {
  final SpeciesInfo species;

  const _CompatibilityNotesCard({required this.species});

  @override
  Widget build(BuildContext context) {
    if (species.compatibleWith.isEmpty && species.avoidWith.isEmpty) {
      return const SizedBox.shrink();
    }

    return AppCard(
      padding: AppCardPadding.standard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Tank Mates', style: AppTypography.headlineSmall),
              ],
            ),
            if (species.compatibleWith.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good matches:', style: AppTypography.labelLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: species.compatibleWith
                              .map((s) => _CompanionChip(name: s, isGood: true))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (species.avoidWith.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.do_not_disturb,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Avoid:', style: AppTypography.labelLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: species.avoidWith
                              .map(
                                (s) => _CompanionChip(name: s, isGood: false),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
  }
}

class _CompanionChip extends StatelessWidget {
  final String name;
  final bool isGood;

  const _CompanionChip({required this.name, required this.isGood});

  @override
  Widget build(BuildContext context) {
    final color = isGood ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm3, vertical: 4),
      decoration: BoxDecoration(
        color: Color((color.value & 0x00FFFFFF) | 0x19000000), // 10% opacity
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: Color((color.value & 0x00FFFFFF) | 0x4D000000)), // 30% opacity
      ),
      child: Text(name, style: AppTypography.bodySmall.copyWith(color: color)),
    );
  }
}

class _NoSpeciesDataCard extends StatelessWidget {
  final Livestock livestock;

  const _NoSpeciesDataCard({required this.livestock});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.standard,
      backgroundColor: AppOverlays.surfaceVariant50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: context.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Species info not found',
                  style: AppTypography.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'We don\'t have care data for "${livestock.commonName}" in our database yet.\n\n'
              'Consider researching:\n'
              '• Temperature and pH requirements\n'
              '• Minimum tank size\n'
              '• Schooling needs\n'
              '• Compatible tank mates',
              style: AppTypography.bodyMedium,
            ),
          ],
        ),
      );
  }
}
