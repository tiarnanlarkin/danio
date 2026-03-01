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
import '../widgets/compatibility_checker_widget.dart';

/// Smart Hub - central screen for all AI-powered features.
class SmartScreen extends ConsumerStatefulWidget {
  const SmartScreen({super.key});

  @override
  ConsumerState<SmartScreen> createState() => _SmartScreenState();
}

class _SmartScreenState extends ConsumerState<SmartScreen> {
  final _askController = TextEditingController();
  String? _askResponse;
  bool _askLoading = false;

  @override
  void dispose() {
    _askController.dispose();
    super.dispose();
  }

  Future<void> _askDanio() async {
    final question = _askController.text.trim();
    if (question.isEmpty) return;

    final openai = ref.read(openAIServiceProvider);
    if (!openai.isConfigured) return;

    setState(() {
      _askLoading = true;
      _askResponse = null;
    });

    try {
      final result = await openai.chatCompletion(
        messages: [
          const ChatMessage(
            role: 'system',
            content: 'You are Danio AI, a friendly and knowledgeable aquarium '
                'expert. Answer questions about fishkeeping, water chemistry, '
                'fish compatibility, diseases, plants, equipment, and tank '
                'maintenance. Be concise (2-4 sentences) and practical. '
                'If the question is not about aquariums, politely redirect.',
          ),
          ChatMessage(role: 'user', content: question),
        ],
        maxTokens: 300,
      );
      ref.read(aiHistoryProvider.notifier).add(
        type: 'ask_danio',
        summary: 'Asked: ${question.length > 40 ? '${question.substring(0, 40)}...' : question}',
      );
      setState(() => _askResponse = result.text);
    } catch (e) {
      setState(() => _askResponse = 'Sorry, I couldn\'t answer that right now. Try again later.');
    } finally {
      setState(() => _askLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
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
          ).animate(delay: 0.ms).fadeIn().slideX(begin: 0.05),

          _FeatureCard(
            icon: Icons.healing,
            title: 'Symptom Triage',
            subtitle: 'Diagnose fish health issues',
            color: AppColors.error,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SymptomTriageScreen()),
            ),
          ).animate(delay: 50.ms).fadeIn().slideX(begin: 0.05),

          _FeatureCard(
            icon: Icons.calendar_month,
            title: 'Weekly Plan',
            subtitle: 'AI-generated maintenance schedule',
            color: AppColors.textSecondary,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WeeklyPlanScreen()),
            ),
          ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.05),
          // Compatibility Checker
          if (openai.isConfigured) ...[const SizedBox(height: AppSpacing.sm), const CompatibilityCheckerWidget()],

          // Ask Danio - quick question
          if (openai.isConfigured) ...[
            const SizedBox(height: AppSpacing.md),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.md2Radius,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Ask Danio',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _askController,
                      decoration: InputDecoration(
                        hintText: 'e.g. "Can neon tetras live with bettas?"',
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: _askLoading
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : IconButton(
                              tooltip: 'Refresh',
                                icon: const Icon(Icons.send),
                                onPressed: _askDanio,
                              ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _askDanio(),
                      maxLines: 2,
                      minLines: 1,
                    ),
                    if (_askResponse != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: AppRadius.smallRadius,
                        ),
                        child: SelectableText(
                          _askResponse!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.05),
          ],

          const SizedBox(height: AppSpacing.sm),

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
        ],
      ),
    );
  }

  void _showAnomalyHistory(BuildContext context, WidgetRef ref) {
    final anomalies = ref.read(anomalyHistoryProvider);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) {
          if (anomalies.isEmpty) {
            return Column(
              children: [
                // Drag handle
                Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Anomaly History',
                  style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Icon(Icons.monitor_heart_outlined, size: 56, color: AppColors.textHint),
                const SizedBox(height: AppSpacing.md),
                Text('No anomalies detected yet.',
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text('Anomaly detection runs automatically\nwhen you log water parameters.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textHint),
                  textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    // Navigate to symptom triage
                  },
                  icon: const Icon(Icons.medical_services_outlined, size: 18),
                  label: const Text('Run Symptom Triage'),
                ),
                const Spacer(),
              ],
            );
          }
          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.only(
              left: AppSpacing.md, right: AppSpacing.md,
              bottom: AppSpacing.md, top: 0),
            itemCount: anomalies.length + 2,
            itemBuilder: (ctx, i) {
              if (i == 0) {
                return Column(children: [
                  Container(width: 40, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
                ]);
              }
              if (i == 1) {
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
              final a = anomalies[i - 2];
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
      AnomalySeverity.warning => (Icons.info, AppColors.textSecondary),
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            DanioColors.topaz.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primary, size: AppIconSizes.lg),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'AI Features Need Setup 🔑',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Smart features like fish identification, health triage, and '
            'personalised care plans require an OpenAI API key.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Text(
              'Build with:\nflutter run --dart-define=OPENAI_API_KEY=sk-...',
              style: AppTypography.bodySmall.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Features still work without AI - you can browse the fish '
            'database, log water parameters, and manage your tanks.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.md2Radius,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md2Radius,
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
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
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
        _SmartScreenState._formatTime(interaction.timestamp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
