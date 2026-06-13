import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../navigation/app_routes.dart';
import '../../../screens/emergency_guide_screen.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/navigation_throttle.dart';
import '../../../widgets/core/app_button.dart';
import '../smart_providers.dart';
import 'aquarium_intelligence_service.dart';

class AquariumIntelligenceScreen extends ConsumerWidget {
  const AquariumIntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(aquariumIntelligenceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Aquarium Intelligence')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _StatusMessage(
          icon: Icons.error_outline,
          title: 'Local checks could not load',
          body: 'Open Smart again or try after the latest tank data is saved.',
          color: AppColors.error,
        ),
        data: (report) => _IntelligenceDetail(report: report),
      ),
    );
  }
}

class _IntelligenceDetail extends StatelessWidget {
  final AquariumIntelligenceReport report;

  const _IntelligenceDetail({required this.report});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        MediaQuery.of(context).viewPadding.bottom + AppSpacing.lg,
      ),
      children: [
        Text(
          'Local checks, no AI key needed',
          style: AppTypography.bodyMedium.copyWith(
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _SummaryPill(
              icon: Icons.warning_amber_outlined,
              label: 'Risks',
              value: report.criticalRiskCount,
              color: report.criticalRiskCount > 0
                  ? AppColors.error
                  : AppColors.success,
            ),
            _SummaryPill(
              icon: Icons.checklist_outlined,
              label: 'Care',
              value: report.careActionCount,
              color: report.careActionCount > 0
                  ? AppColors.warning
                  : AppColors.success,
            ),
            _SummaryPill(
              icon: Icons.compare_arrows,
              label: 'Compatibility',
              value: report.compatibilityIssueCount,
              color: report.compatibilityIssueCount > 0
                  ? AppColors.warning
                  : AppColors.success,
            ),
            _SummaryPill(
              icon: Icons.history,
              label: 'Anomalies',
              value: report.activeAnomalyCount,
              color: report.activeAnomalyCount > 0
                  ? AppColors.warning
                  : AppColors.success,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle(
          icon: Icons.fact_check_outlined,
          title: 'Local care plan',
        ),
        const SizedBox(height: AppSpacing.sm),
        if (report.items.isEmpty)
          _StatusMessage(
            icon: Icons.check_circle_outline,
            title: 'No urgent local actions',
            body:
                'Danio did not find urgent care risks in the saved tank data.',
            color: AppColors.success,
          )
        else
          ...report.items.map((item) => _DetailItemCard(item: item)),
        const SizedBox(height: AppSpacing.lg),
        _SectionTitle(
          icon: Icons.rule_folder_outlined,
          title: 'What Danio checked',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _CheckedList(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppIconSizes.sm, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.smallRadius,
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSizes.xs, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$label $value',
            style: AppTypography.labelSmall.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItemCard extends StatelessWidget {
  final AquariumIntelligenceItem item;

  const _DetailItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(item.severity);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md2Radius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_severityIcon(item.severity), color: color),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.tankName,
                        style: AppTypography.labelSmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.reason,
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
              ),
            ),
            if (item.action != AquariumIntelligenceAction.none) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: item.actionLabel,
                leadingIcon: _actionIcon(item.action),
                size: AppButtonSize.small,
                variant:
                    item.action == AquariumIntelligenceAction.emergencyGuide
                    ? AppButtonVariant.primary
                    : AppButtonVariant.secondary,
                onPressed: () => _handleAction(context, item),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void _handleAction(
    BuildContext context,
    AquariumIntelligenceItem item,
  ) {
    switch (item.action) {
      case AquariumIntelligenceAction.emergencyGuide:
        NavigationThrottle.push(
          context,
          const EmergencyGuideScreen(),
          rootNavigator: true,
        );
      case AquariumIntelligenceAction.waterTest:
        AppRoutes.toAddLog(
          context,
          item.tankId,
          initialType: LogType.waterTest,
        );
      case AquariumIntelligenceAction.tankDetail:
        AppRoutes.toTankDetail(context, item.tankId);
      case AquariumIntelligenceAction.workshop:
        AppRoutes.toWorkshop(context);
      case AquariumIntelligenceAction.none:
        break;
    }
  }

  static Color _severityColor(AquariumIntelligenceSeverity severity) {
    return switch (severity) {
      AquariumIntelligenceSeverity.critical => AppColors.error,
      AquariumIntelligenceSeverity.warning => AppColors.warning,
      AquariumIntelligenceSeverity.info => AppColors.primary,
      AquariumIntelligenceSeverity.clear => AppColors.success,
    };
  }

  static IconData _severityIcon(AquariumIntelligenceSeverity severity) {
    return switch (severity) {
      AquariumIntelligenceSeverity.critical => Icons.error_outline,
      AquariumIntelligenceSeverity.warning => Icons.warning_amber_outlined,
      AquariumIntelligenceSeverity.info => Icons.info_outline,
      AquariumIntelligenceSeverity.clear => Icons.check_circle_outline,
    };
  }

  static IconData _actionIcon(AquariumIntelligenceAction action) {
    return switch (action) {
      AquariumIntelligenceAction.emergencyGuide => Icons.emergency_outlined,
      AquariumIntelligenceAction.waterTest => Icons.science_outlined,
      AquariumIntelligenceAction.tankDetail => Icons.water_outlined,
      AquariumIntelligenceAction.workshop => Icons.compare_arrows,
      AquariumIntelligenceAction.none => Icons.chevron_right,
    };
  }
}

class _CheckedList extends StatelessWidget {
  const _CheckedList();

  static const _items = [
    (
      'Water safety',
      'Ammonia, nitrite, nitrate, pH, temperature, and staleness',
    ),
    ('Care schedule', 'Enabled tasks that are due or overdue'),
    ('Livestock health', 'Fish marked sick or in quarantine'),
    ('Compatibility', 'Species data, group size, tank size, and water targets'),
    ('Anomaly history', 'Active local anomalies from recent logs'),
    ('Equipment maintenance', 'Registered filter and equipment service timing'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _items
          .map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
              ),
              title: Text(item.$1),
              subtitle: Text(item.$2),
            ),
          )
          .toList(),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _StatusMessage({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md2Radius),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    body,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
