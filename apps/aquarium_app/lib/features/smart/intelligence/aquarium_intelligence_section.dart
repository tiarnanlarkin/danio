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

class AquariumIntelligenceSection extends ConsumerWidget {
  const AquariumIntelligenceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(aquariumIntelligenceProvider);

    return reportAsync.when(
      loading: () => _IntelligenceShell(
        child: Text(
          'Checking local tank data...',
          style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
        ),
      ),
      error: (_, __) => _IntelligenceShell(
        child: Text(
          'Local checks could not load. Try opening Smart again.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
        ),
      ),
      data: (report) => _ReportBody(report: report),
    );
  }
}

class _ReportBody extends StatelessWidget {
  final AquariumIntelligenceReport report;

  const _ReportBody({required this.report});

  @override
  Widget build(BuildContext context) {
    if (report.tankCount == 0) {
      return _IntelligenceShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a tank to unlock local checks.',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Create Tank',
              leadingIcon: Icons.add,
              size: AppButtonSize.small,
              variant: AppButtonVariant.secondary,
              onPressed: () => AppRoutes.toCreateTank(context),
            ),
          ],
        ),
      );
    }

    return _IntelligenceShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _MetricChip(
                icon: Icons.warning_amber_outlined,
                label: 'Risks',
                value: report.criticalRiskCount,
                color: report.criticalRiskCount > 0
                    ? AppColors.error
                    : AppColors.success,
              ),
              _MetricChip(
                icon: Icons.checklist_outlined,
                label: 'Care',
                value: report.careActionCount,
                color: report.careActionCount > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
              _MetricChip(
                icon: Icons.compare_arrows,
                label: 'Compatibility',
                value: report.compatibilityIssueCount,
                color: report.compatibilityIssueCount > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
              _MetricChip(
                icon: Icons.history,
                label: 'Anomalies',
                value: report.activeAnomalyCount,
                color: report.activeAnomalyCount > 0
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (report.items.isEmpty)
            Text(
              'No urgent local risks found right now.',
              style: AppTypography.bodyMedium.copyWith(
                color: context.textSecondary,
              ),
            )
          else
            ...report.topItems.map((item) => _IntelligenceItemRow(item: item)),
        ],
      ),
    );
  }
}

class _IntelligenceShell extends StatelessWidget {
  final Widget child;

  const _IntelligenceShell({required this.child});

  @override
  Widget build(BuildContext context) {
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
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.psychology_alt_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aquarium Intelligence',
                        style: AppTypography.titleMedium.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Local checks, no AI key needed',
                        style: AppTypography.bodySmall.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _MetricChip({
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

class _IntelligenceItemRow extends StatelessWidget {
  final AquariumIntelligenceItem item;

  const _IntelligenceItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(item.severity);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.smallRadius,
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_severityIcon(item.severity), color: color, size: 20),
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
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.reason,
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
              if (item.action != AquariumIntelligenceAction.none) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: item.actionLabel,
                  leadingIcon: _actionIcon(item.action),
                  size: AppButtonSize.small,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _handleAction(context, item),
                ),
              ],
            ],
          ),
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
