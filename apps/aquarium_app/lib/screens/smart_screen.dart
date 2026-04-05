import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/smart/models/smart_models.dart';
import '../features/smart/smart_providers.dart';
import '../navigation/app_routes.dart';
import '../services/api_rate_limiter.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/compatibility_checker_widget.dart';
import '../widgets/core/bubble_loader.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/first_visit_tooltip.dart';
import 'compatibility_checker_screen.dart';
import '../widgets/danio_snack_bar.dart';
import '../widgets/core/app_button.dart';
import '../widgets/app_bottom_sheet.dart';
import '../utils/logger.dart';

/// Helper to show a snackbar when an AI feature is tapped while offline.
void _showOfflineSnackBar(BuildContext context) {
  DanioSnackBar.warning(context, "You're offline — AI features require an internet connection.");
}

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
  bool _showTooltip = true;

  @override
  void initState() {
    super.initState();
    _checkTooltip();
  }

  Future<void> _checkTooltip() async {
    final seen = await hasSeenTooltip('tooltip_seen_smart', ref);
    if (mounted) setState(() => _showTooltip = !seen);
  }

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

    // Offline check.
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      setState(() => _askResponse =
          "You're offline — check your connection and tap send to retry.");
      return;
    }

    // Rate limit check.
    final rateLimiter = ref.read(apiRateLimiterProvider);
    if (!rateLimiter.canRequest(AIFeature.askDanio)) {
      setState(() => _askResponse = OpenAIUserMessages.rateLimited);
      return;
    }

    setState(() {
      _askLoading = true;
      _askResponse = null;
    });

    try {
      final result = await openai.chatCompletion(
        messages: [
          const ChatMessage(
            role: 'system',
            content:
                'You are Danio AI, a friendly and knowledgeable aquarium '
                'expert. Answer questions about fishkeeping, water chemistry, '
                'fish compatibility, diseases, plants, equipment, and tank '
                'maintenance. Be concise (2-4 sentences) and practical. '
                'If the question is not about aquariums, politely redirect.',
          ),
          ChatMessage(role: 'user', content: question),
        ],
        maxTokens: 300,
      );
      rateLimiter.recordRequest(AIFeature.askDanio);
      ref
          .read(aiHistoryProvider.notifier)
          .add(
            type: 'ask_danio',
            summary:
                'Asked: ${question.length > 40 ? '${question.substring(0, 40)}...' : question}',
          );
      if (!mounted) return;
      setState(() => _askResponse = result.text);
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _askResponse = OpenAIUserMessages.timeout);
    } catch (e, st) {
      logError('SmartScreen: AI ask failed: $e', stackTrace: st, tag: 'SmartScreen');
      if (!mounted) return;
      final isAuthError =
          e is OpenAIException && (e.statusCode == 401 || e.statusCode == 403);
      setState(
        () => _askResponse = isAuthError
            ? 'Your API key appears to be invalid or expired.'
            : "Sorry, I couldn't answer that right now. Please check your connection and try again.",
      );
    } finally {
      if (mounted) setState(() => _askLoading = false);
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

      final items = <Widget>[
            // First-visit tooltip
            if (_showTooltip)
              FirstVisitTooltip(
                prefsKey: 'tooltip_seen_smart',
                emoji: '🧠',
                message: 'Smart Hub — AI tools to help you care for your fish!',
                onDismissed: () => setState(() => _showTooltip = false),
              ),

            // API status / connectivity
            if (!openai.isConfigured)
              const _OfflineBanner()
            else
              ref.watch(isOnlineProvider)
                  ? _UsageChip(callCount: openai.apiCallsThisMonth)
                  : const OfflineIndicatorCompact(),

            const SizedBox(height: AppSpacing.md),

            // Feature cards — gated behind API key (CA-004) + connectivity
            _FeatureCard(
              icon: Icons.camera_alt,
              title: 'Fish & Plant ID',
              subtitle: openai.isConfigured
                  ? 'Snap a photo to identify species'
                  : 'Requires AI setup',
              color: AppColors.primary,
              onTap: openai.isConfigured
                  ? () {
                      if (!ref.read(isOnlineProvider)) {
                        _showOfflineSnackBar(context);
                        return;
                      }
                      AppRoutes.toFishId(context);
                    }
                  : null,
            ).animate(delay: 0.ms).fadeIn().slideX(begin: 0.05),

            _FeatureCard(
              icon: Icons.healing,
              title: 'Symptom Checker',
              subtitle: openai.isConfigured
                  ? 'Describe symptoms, get instant advice'
                  : 'Requires AI setup',
              color: AppColors.error,
              onTap: openai.isConfigured
                  ? () {
                      if (!ref.read(isOnlineProvider)) {
                        _showOfflineSnackBar(context);
                        return;
                      }
                      AppRoutes.toSymptomTriage(context);
                    }
                  : null,
            ).animate(delay: 50.ms).fadeIn().slideX(begin: 0.05),

            _FeatureCard(
              icon: Icons.calendar_month,
              title: 'Weekly Care Plan',
              subtitle: openai.isConfigured
                  ? 'Your personalised maintenance schedule'
                  : 'Requires AI setup',
              color: AppColors
                  .primary, // BUG-11: was textSecondary (gray), now warm amber to match siblings
              onTap: openai.isConfigured
                  ? () {
                      if (!ref.read(isOnlineProvider)) {
                        _showOfflineSnackBar(context);
                        return;
                      }
                      AppRoutes.toWeeklyPlan(context);
                    }
                  : null,
            ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.05),
            // Compatibility Checker (AI version when key configured)
            if (openai.isConfigured) ...[
              const SizedBox(height: AppSpacing.sm),
              const CompatibilityCheckerWidget(),
            ],

            // Offline Compatibility Checker — always available (uses local species data)
            if (!openai.isConfigured) ...[
              const SizedBox(height: AppSpacing.sm),
              _FeatureCard(
                icon: Icons.compare_arrows,
                title: 'Compatibility Checker',
                subtitle: 'Check if your fish are compatible — works offline!',
                color: AppColors.success,
                onTap: () => NavigationThrottle.push(
                  context,
                  const CompatibilityCheckerScreen(),
                ),
              ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.05),
            ],

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
                          Icon(
                            Icons.chat_bubble_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
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
                                  padding: EdgeInsets.all(AppSpacing.sm2),
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: BubbleLoader(),
                                  ),
                                )
                              : IconButton(
                                  tooltip: 'Send question',
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
                            color: AppColors.primaryAlpha05,
                            borderRadius: AppRadius.smallRadius,
                          ),
                          child: Semantics(
                            liveRegion: true,
                            child: SelectableText(
                              _askResponse!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.4,
                              ),
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
              icon: activeAnomalies.isEmpty ? Icons.check_circle_outline : Icons.warning_amber,
              title: 'Anomaly History',
              subtitle: activeAnomalies.isEmpty
                  ? 'All clear — no issues detected'
                  : '${activeAnomalies.length} active anomal${activeAnomalies.length == 1 ? "y" : "ies"}',
              color: activeAnomalies.isEmpty ? AppColors.success : AppColors.warning,
              onTap: () => _showAnomalyHistory(context, ref),
            ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.05),

            const SizedBox(height: AppSpacing.lg),

            // Recent AI interactions
            if (history.isNotEmpty) ...[
              Semantics(
                header: true,
                child: Text(
                  'Recent AI Activity',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...history
                  .take(10)
                  .map(
                    (interaction) => _InteractionTile(interaction: interaction),
                  ),
            ],
      ];

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('🧠 Smart'), centerTitle: true),
        body: ListView.builder(
          // BUG-04: bottom padding so Anomaly History card isn't clipped by bottom nav
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          itemBuilder: (context, index) => items[index],
          itemCount: items.length,
        ),
      ),
    );
  }

  void _showAnomalyHistory(BuildContext context, WidgetRef ref) {
    showAppScrollableSheet(
      context: context,
      initialSize: 0.6,
      maxSize: 0.9,
      minSize: 0.3,
      builder: (ctx, scrollController) {
          // Use Consumer so the sheet rebuilds reactively when anomalies change.
          return Consumer(
            builder: (ctx, innerRef, _) {
              final anomalies = innerRef.watch(anomalyHistoryProvider);
              if (anomalies.isEmpty) {
                return Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Anomaly History',
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.monitor_heart_outlined,
                      size: 56,
                      color: ctx.textHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No anomalies detected — looking good! 🐟',
                      style: AppTypography.bodyLarge.copyWith(
                        color: ctx.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Anomaly detection runs automatically\nwhen you log water parameters.',
                      style: AppTypography.bodySmall.copyWith(
                        color: ctx.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: 'Run Symptom Triage',
                      onPressed: () {
                        Navigator.maybePop(ctx);
                        AppRoutes.toSymptomTriage(context);
                      },
                      leadingIcon: Icons.medical_services_outlined,
                      variant: AppButtonVariant.primary,
                    ),
                    const Spacer(),
                  ],
                );
              }
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  top: 0,
                ),
                itemCount: anomalies.length + 2,
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return const SizedBox(height: AppSpacing.sm);
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
                    title: Text(
                      a.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      a.dismissed
                          ? '${a.parameter} · ${_formatTime(a.detectedAt)} · Dismissed — will flag again if detected.'
                          : '${a.parameter} · ${_formatTime(a.detectedAt)}',
                    ),
                    dense: true,
                    trailing: a.dismissed
                        ? null
                        : TextButton(
                            onPressed: () {
                              innerRef
                                  .read(anomalyHistoryProvider.notifier)
                                  .dismiss(a.id);
                            },
                            child: const Text('Dismiss'),
                          ),
                  );
                },
              );
            },
          );
        },
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
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryAlpha08,
            DanioColors.topaz.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.primaryAlpha15),
      ),
      child: Column(
        children: [
          Text('🤖', style: Theme.of(context).textTheme.headlineMedium!),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Smart AI Features',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Some Smart features are coming soon. Fish & Plant ID, Symptom Checker, '
            'and Weekly Care Plan will be available in a future update.',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Compatibility Checker and Anomaly History work offline — ready to use! 👇',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
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
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$callCount AI call${callCount == 1 ? "" : "s"} this month',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: context.textSecondary),
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
  final VoidCallback? onTap;

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

    final isDisabled = onTap == null;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md2Radius),
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
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDisabled)
                  Icon(Icons.lock_outline, color: context.textSecondary)
                else
                  Icon(Icons.chevron_right, color: context.textSecondary),
              ],
            ),
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
      leading: Icon(icon, size: AppIconSizes.sm, color: context.textSecondary),
      title: Text(interaction.summary, style: theme.textTheme.bodySmall),
      trailing: Text(
        _SmartScreenState._formatTime(interaction.timestamp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: context.textSecondary,
        ),
      ),
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }
}
