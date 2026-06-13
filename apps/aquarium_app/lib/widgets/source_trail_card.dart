import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/care_sources.dart';
import '../theme/app_theme.dart';
import 'core/app_button.dart';
import 'core/app_card.dart';
import 'danio_snack_bar.dart';

class SourceTrailCard extends StatelessWidget {
  final List<CareSource> sources;

  const SourceTrailCard({super.key, required this.sources});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: AppCardPadding.compact,
      backgroundColor: AppOverlays.primary10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Source trail', style: AppTypography.headlineSmall),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Broad references behind Danio\'s care guidance. Always check species-specific needs before acting.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm2),
          ...sources.map(
            (source) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SourceRow(source: source),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  final CareSource source;

  const _SourceRow({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withAlpha(184),
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source.title, style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '${source.publisher} - ${source.note}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            label: 'Open',
            leadingIcon: Icons.open_in_new,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            onPressed: () => _openSource(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openSource(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(source.url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      DanioSnackBar.error(context, 'Could not open source');
    }
  }
}
