import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/smart/fish_id/fish_id_screen.dart';
import '../features/smart/models/smart_models.dart';
import '../features/smart/smart_providers.dart';
import '../features/smart/symptom_triage/symptom_triage_screen.dart';
import '../features/smart/weekly_plan/weekly_plan_screen.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';

/// Smart Hub — central screen for all AI-powered features.
class SmartScreen extends ConsumerWidget {
  const SmartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final openai = ref.watch(openAIServiceProvider);
    final history = ref.watch(aiHistoryProvider);
    final anomalies = ref.watch(anomalyHistoryProvider);
    final activeAnomalies = anomalies.where((a) => !a.dismissed).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Smart'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // API status
          if (!openai.isConfigured)
            _OfflineBanner()
          else
            _UsageChip(callCount: openai.apiCallsThisMonth),

          const SizedBox(height: AppSpacing.md),

          // Feature cards
          _FeatureCard(
            icon: Icons.camera_alt,
            title: 'Fish & Plant ID',
            subtitle: 'Snap a photo to identify species',
            color: AppColors.primary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FishIdScreen()),
            ),
            isEnabled: openai.isConfigured,
          ).animate(delay: 0.ms).fadeIn().slideX(begin: 0.05),

          _FeatureCard(
            icon: Icons.healing,
            title: 'Symptom Triage',
            subtitle: 'Diagnose fish health issues',
            color: AppColors.error,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SymptomTriageScreen()),
            ),
            isEnabled: openai.isConfigured,
          ).animate(delay: 50.ms).fadeIn().slideX(begin: 0.05),

          _FeatureCard(
            icon: Icons.calendar_month,
            title: 'Weekly Plan',
            subtitle: 'AI-generated maintenance schedule',
            color: AppColors.info,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WeeklyPlanScreen()),
            ),
            isEnabled: openai.isConfigured,
          ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.05),

          _FeatureCard(
            icon: Icons.warning_amber,
            title: 'Anomaly History',
            subtitle: '${activeAnomalies.length} active anomal${activeAnomalies.length == 1 ? "y" : "ies"}',
            color: AppColors.warning,
            onTap: () => _showAnomalyHistory(context, ref),
          ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.05),

          const SizedBox(height: AppSpacing.lg),

          // Recent AI interactions
          if (history.isNotEmpty) ...[
            Text(
              'Recent AI Activity',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...history.take(10).map((interaction) => _InteractionTile(
              interaction: interaction,
            )),
          ],

          const SizedBox(height: AppSpacing.md),
          const _AquariumTipCard(),
        ],
      ),
    );
  }

  void _showAnomalyHistory(BuildContext context, WidgetRef ref) {
    final anomalies = ref.read(anomalyHistoryProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) {
          if (anomalies.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text('No anomalies detected yet.'),
              ),
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: anomalies.length + 1,
            itemBuilder: (ctx, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    'Anomaly History',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              final a = anomalies[i - 1];
              return ListTile(
                leading: _severityIcon(a.severity),
                title: Text(a.description),
                subtitle: Text(
                  '${a.parameter} · ${_formatTime(a.detectedAt)}'
                  '${a.dismissed ? " · dismissed" : ""}',
                ),
                dense: true,
              );
            },
          );
        },
      ),
    );
  }

  static Widget _severityIcon(AnomalySeverity severity) {
    final (icon, color) = switch (severity) {
      AnomalySeverity.critical => (Icons.error, AppColors.error),
      AnomalySeverity.alert => (Icons.warning, AppColors.warning),
      AnomalySeverity.warning => (Icons.info, AppColors.info),
    };
    return Icon(icon, color: color, size: AppIconSizes.sm);
  }

  static String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Subwidgets ──────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 32)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'AI Features Coming Soon',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Smart features like species identification and health triage '
              'are powered by AI. Stay tuned for the next update!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsageChip extends StatelessWidget {
  final int callCount;

  const _UsageChip({required this.callCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.bolt, size: AppIconSizes.xs, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          '$callCount AI call${callCount == 1 ? "" : "s"} this month',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isEnabled;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !isEnabled,
        child: Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEnabled)
                const Icon(Icons.chevron_right, color: AppColors.textSecondary)
              else
                const Icon(Icons.lock_outline, color: AppColors.textHint, size: 18),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }
}

class _AquariumTipCard extends StatelessWidget {
  const _AquariumTipCard();

  static const _tips = [
    'A healthy aquarium cycle takes 4–6 weeks. Patience is key!',
    'Most tropical fish thrive between 24–26°C (75–79°F).',
    'Test your water weekly — ammonia and nitrite should always read zero.',
    'Live plants help absorb nitrates and give fish places to hide.',
    'Overfeeding is the #1 cause of poor water quality. Feed small amounts.',
    'A 10–20% water change each week keeps your tank in top shape.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tip = _tips[DateTime.now().day % _tips.length];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: AppColors.warning, size: AppIconSizes.sm),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Did You Know?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tip,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionTile extends StatelessWidget {
  final AIInteraction interaction;

  const _InteractionTile({required this.interaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = switch (interaction.type) {
      'fish_id' => Icons.camera_alt,
      'symptom_triage' => Icons.healing,
      'anomaly' => Icons.warning_amber,
      'weekly_plan' => Icons.calendar_month,
      _ => Icons.smart_toy,
    };

    return ListTile(
      leading: Icon(icon, size: AppIconSizes.sm, color: AppColors.textSecondary),
      title: Text(interaction.summary, style: theme.textTheme.bodySmall),
      trailing: Text(
        SmartScreen._formatTime(interaction.timestamp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
