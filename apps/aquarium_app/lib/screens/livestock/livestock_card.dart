import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/species_database.dart';
import '../../models/models.dart';
import '../../services/compatibility_service.dart';
import '../../theme/app_theme.dart';
import '../../data/species_sprites.dart';

/// A card widget displaying a single livestock entry with compatibility info,
/// health status, and context-menu actions.
class LivestockCard extends StatelessWidget {
  final Livestock livestock;
  final Tank? tank;
  final List<Livestock> allLivestock;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LivestockCard({
    super.key,
    required this.livestock,
    this.tank,
    required this.allLivestock,
    this.isSelectMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final species =
        SpeciesDatabase.lookup(livestock.commonName) ??
        (livestock.scientificName != null
            ? SpeciesDatabase.lookup(livestock.scientificName!)
            : null);

    List<CompatibilityIssue> issues = [];
    if (tank != null) {
      issues = CompatibilityService.checkLivestockCompatibility(
        livestock: livestock,
        tank: tank!,
        existingLivestock: allLivestock,
      );
    }

    final hasIssues = issues.isNotEmpty;
    final level = hasIssues ? CompatibilityService.overallLevel(issues) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm2),
      color: isSelected
          ? AppColors.primaryAlpha15
          : (level == CompatibilityLevel.incompatible
                ? AppColors.errorAlpha05
                : (level == CompatibilityLevel.warning
                      ? AppColors.warningAlpha05
                      : null)),
      child: ListTile(
        leading: isSelectMode
            ? Checkbox(value: isSelected, onChanged: (_) => onTap())
            : Stack(
                children: [
                  Hero(
                    tag: 'livestock-${livestock.id}',
                    child: Material(
                      type: MaterialType.transparency,
                      child: CircleAvatar(
                        backgroundColor: AppOverlays.primary10,
                        backgroundImage: livestock.imageUrl != null
                            ? CachedNetworkImageProvider(livestock.imageUrl!)
                            : (SpeciesSprites.thumbFor(livestock.commonName) !=
                                    null
                                ? AssetImage(
                                    SpeciesSprites.thumbFor(
                                      livestock.commonName,
                                    )!,
                                  )
                                : null),
                        onBackgroundImageError: (_, __) {},
                        child: livestock.imageUrl == null &&
                                SpeciesSprites.thumbFor(livestock.commonName) ==
                                    null
                            ? const Icon(
                                Icons.set_meal,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                  if (hasIssues)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: level == CompatibilityLevel.incompatible
                              ? AppColors.error
                              : AppColors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          level == CompatibilityLevel.incompatible
                              ? Icons.error
                              : Icons.warning,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
        title: Text(livestock.commonName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (livestock.scientificName != null || species != null)
              Text(
                livestock.scientificName ?? species?.scientificName ?? '',
                style: AppTypography.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            Row(
              children: [
                Text('×${livestock.count}', style: AppTypography.bodySmall),
                if (species != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '• ${species.temperament}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ],
            ),
            // Health status chip
            if (livestock.healthStatus != HealthStatus.healthy)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: LivestockHealthChip(status: livestock.healthStatus),
              ),
            if (hasIssues && !isSelectMode)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  '${issues.length} compatibility ${issues.length == 1 ? 'note' : 'notes'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: level == CompatibilityLevel.incompatible
                        ? AppColors.error
                        : AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
        trailing: isSelectMode
            ? null
            : PopupMenuButton(
                tooltip: 'Livestock actions',
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'view', child: Text('View Details')),
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Remove')),
                ],
                onSelected: (value) {
                  if (value == 'view') onTap();
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
              ),
        onTap: onTap,
      ),
    );
  }
}

/// Health status chip widget.
class LivestockHealthChip extends StatelessWidget {
  final HealthStatus status;
  const LivestockHealthChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, emoji) = switch (status) {
      HealthStatus.healthy => ('Healthy', AppColors.success, '\u{1F7E2}'),
      HealthStatus.sick => ('Sick', AppColors.warning, '\u{1F7E1}'),
      HealthStatus.quarantine => ('Quarantine', AppColors.error, '\u{1F534}'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: AppRadius.md2Radius,
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: Theme.of(context).textTheme.labelSmall!),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
