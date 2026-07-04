import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/smart/models/smart_models.dart';
import '../features/smart/intelligence/aquarium_intelligence_section.dart';
import '../features/smart/openai_disclosure_gate.dart';
import '../features/smart/smart_providers.dart';
import '../navigation/app_routes.dart';
import '../providers/guidance_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/api_rate_limiter.dart';
import '../services/guidance_service.dart';
import '../services/openai_service.dart';
import '../theme/app_theme.dart';
import '../theme/danio_surface_visuals.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/compatibility_checker_widget.dart';
import '../widgets/core/bubble_loader.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/first_visit_tooltip.dart';
import '../widgets/danio_snack_bar.dart';
import '../widgets/core/app_button.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/themed_tab_header.dart';
import '../widgets/danio_bottom_dock.dart';
import '../utils/logger.dart';
import 'emergency_guide_screen.dart';
import 'settings_screen.dart';

const double _maxSmartReadableWidth = 720;

/// Helper to show a snackbar when an AI feature is tapped while offline.
void _showOfflineSnackBar(BuildContext context) {
  DanioSnackBar.warning(
    context,
    "You're offline - AI features require an internet connection.",
  );
}

/// Smart Hub - local aquarium intelligence with optional AI tools.
class SmartScreen extends ConsumerStatefulWidget {
  final bool hasPersistentBottomDock;

  const SmartScreen({super.key, this.hasPersistentBottomDock = false});

  @override
  ConsumerState<SmartScreen> createState() => _SmartScreenState();
}

class _SmartScreenState extends ConsumerState<SmartScreen> {
  static const double _fishIdDockMargin = 12;
  static const int _fishIdScrollMaxAttempts = 8;
  static const Duration _fishIdScrollRetryDelay = Duration(milliseconds: 120);

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _fishIdCardKey = GlobalKey();
  final _askController = TextEditingController();
  Timer? _fishIdRetryTimer;
  bool _hasScrolledToFishIdCard = false;
  bool _fishIdScrollScheduled = false;
  String? _askResponse;
  bool _askLoading = false;
  bool _showTooltip = true;

  @override
  void initState() {
    super.initState();
    _checkTooltip();
  }

  Future<void> _checkTooltip() async {
    final service = await ref.read(guidanceServiceProvider.future);
    final decision = await service.shouldShow(
      GuidancePromptId.smartFirstVisit,
      const GuidanceContext(surface: GuidanceSurface.smart),
    );
    if (mounted) setState(() => _showTooltip = decision.shouldShow);
  }

  @override
  void dispose() {
    _fishIdRetryTimer?.cancel();
    _scrollController.dispose();
    _askController.dispose();
    super.dispose();
  }

  bool get _isVisibleTab => TickerMode.valuesOf(context).enabled;

  void _maybeScrollFishIdAboveDock() {
    if (!widget.hasPersistentBottomDock) return;
    if (!_isVisibleTab) return;
    if (_hasScrolledToFishIdCard) return;
    if (_fishIdScrollScheduled) return;

    _scheduleFishIdScroll(duration: const Duration(milliseconds: 500));
  }

  void _scheduleFishIdScroll({required Duration duration, int attempt = 0}) {
    if (attempt == 0) {
      if (_fishIdScrollScheduled) return;
      _fishIdScrollScheduled = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_isVisibleTab) {
        _fishIdScrollScheduled = false;
        _fishIdRetryTimer?.cancel();
        _fishIdRetryTimer = null;
        return;
      }

      final keyContext = _fishIdCardKey.currentContext;
      final settled =
          keyContext != null &&
          _scrollFishIdAboveFloatingDock(keyContext, duration: duration);

      if (settled) {
        _hasScrolledToFishIdCard = true;
        _fishIdScrollScheduled = false;
        _fishIdRetryTimer?.cancel();
        _fishIdRetryTimer = null;
        return;
      }

      if (attempt >= _fishIdScrollMaxAttempts) {
        _fishIdScrollScheduled = false;
        _fishIdRetryTimer?.cancel();
        _fishIdRetryTimer = null;
        return;
      }

      _fishIdRetryTimer?.cancel();
      _fishIdRetryTimer = Timer(duration + _fishIdScrollRetryDelay, () {
        _fishIdRetryTimer = null;
        if (!mounted) return;
        _scheduleFishIdScroll(duration: duration, attempt: attempt + 1);
      });
    });
  }

  bool _scrollFishIdAboveFloatingDock(
    BuildContext targetContext, {
    required Duration duration,
  }) {
    if (!_scrollController.hasClients) return false;
    final renderObject = targetContext.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return false;
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) {
      return false;
    }

    final targetBottom = renderObject
        .localToGlobal(Offset(0, renderObject.size.height))
        .dy;
    final clearBottom =
        mediaQuery.size.height -
        mediaQuery.viewPadding.bottom -
        DanioBottomDock.contentClearance -
        _fishIdDockMargin;
    final overlap = targetBottom - clearBottom;
    if (overlap <= 0) {
      return true;
    }

    final position = _scrollController.position;
    final targetOffset = (position.pixels + overlap).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if ((targetOffset - position.pixels).abs() < 0.5) return true;

    position.animateTo(
      targetOffset,
      duration: duration,
      curve: Curves.easeOutCubic,
    );
    return false;
  }

  Future<bool> _ensureOpenAIDisclosure() {
    return ensureOpenAIDisclosureAccepted(
      ref: ref,
      context: context,
      logTag: 'SmartScreen',
      message:
          'The text you enter in Ask Danio is sent to OpenAI servers in the US '
          'for aquarium advice. OpenAI may retain API inputs and outputs for '
          'abuse monitoring for up to 30 days, and does not use API data for '
          'model training unless the API account opts in.',
      onSaveFailure: (message) {
        if (mounted) setState(() => _askResponse = message);
      },
    );
  }

  Future<void> _askDanio() async {
    final question = _askController.text.trim();
    if (question.isEmpty) {
      setState(() => _askResponse = 'Ask a fishkeeping question first.');
      return;
    }

    final accepted = await _ensureOpenAIDisclosure();
    if (!accepted || !mounted) return;

    final openai = ref.read(openAIServiceProvider);
    if (!await openai.isConfiguredAsync()) return;

    // Offline check.
    final isOnline = ref.read(isOnlineProvider);
    if (!isOnline) {
      setState(
        () => _askResponse =
            "You're offline - check your connection and tap send to retry.",
      );
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
      unawaited(
        ref
            .read(aiHistoryProvider.notifier)
            .add(
              type: 'ask_danio',
              summary:
                  'Asked: ${question.length > 40 ? '${question.substring(0, 40)}...' : question}',
            )
            .catchError((Object e, StackTrace st) {
              logError(
                'SmartScreen: failed to save AI history: $e',
                stackTrace: st,
                tag: 'SmartScreen',
              );
            }),
      );
      if (!mounted) return;
      setState(() => _askResponse = result.text);
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _askResponse = OpenAIUserMessages.timeout);
    } catch (e, st) {
      logError(
        'SmartScreen: AI ask failed: $e',
        stackTrace: st,
        tag: 'SmartScreen',
      );
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
    final aiConfigured = ref
        .watch(openAIConfiguredProvider)
        .maybeWhen(
          data: (configured) => configured,
          orElse: () => openai.isConfigured,
        );
    final history = ref.watch(aiHistoryProvider);
    final anomalies = ref.watch(anomalyHistoryProvider);
    final activeAnomalies = anomalies.where((a) => !a.dismissed).toList();
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final needsSetupContext =
        profile != null &&
        (profile.regionCode == null || profile.tankStatus == null);

    final items = <Widget>[
      // First-visit tooltip
      if (_showTooltip)
        FirstVisitTooltip(
          prefsKey: GuidanceService.storageKey(
            GuidancePromptId.smartFirstVisit,
          ),
          icon: danioSurfaceVisual(DanioSurfaceVisualKey.smart).icon,
          iconColor: danioSurfaceVisual(DanioSurfaceVisualKey.smart).color,
          message:
              'Smart Hub combines local checks with optional AI tools for extra help.',
          onDismissed: () => setState(() => _showTooltip = false),
        ),

      // API status / connectivity
      if (!aiConfigured)
        _AiSetupBanner(
          onOpenPreferences: () => NavigationThrottle.push(
            context,
            const SettingsScreen(),
            rootNavigator: true,
          ),
        )
      else
        ref.watch(isOnlineProvider)
            ? _UsageChip(callCount: openai.apiCallsThisMonth)
            : const OfflineIndicatorCompact(),

      if (needsSetupContext) ...[
        const SizedBox(height: AppSpacing.sm),
        _SetupContextBanner(
          onOpenPreferences: () => NavigationThrottle.push(
            context,
            const SettingsScreen(),
            rootNavigator: true,
          ),
        ),
      ],

      const SizedBox(height: AppSpacing.md),

      const AquariumIntelligenceSection(),

      const SizedBox(height: AppSpacing.md),

      _FeatureCard(
        icon: Icons.emergency_outlined,
        title: 'Emergency Guide',
        subtitle: 'Fast steps for urgent water and fish issues',
        color: AppColors.error,
        onTap: () => NavigationThrottle.push(
          context,
          const EmergencyGuideScreen(),
          rootNavigator: true,
        ),
      ).animate(delay: 0.ms).fadeIn().slideX(begin: 0.05),

      // Feature cards gated behind API key (CA-004) + connectivity
      KeyedSubtree(
        key: _fishIdCardKey,
        child: _FeatureCard(
          icon: Icons.camera_alt,
          title: 'Fish & Plant ID',
          subtitle: aiConfigured
              ? 'Snap a photo to identify species'
              : 'Optional AI setup in Preferences',
          color: AppColors.primary,
          isLocked: !aiConfigured,
          onTap: aiConfigured
              ? () {
                  if (!ref.read(isOnlineProvider)) {
                    _showOfflineSnackBar(context);
                    return;
                  }
                  AppRoutes.toFishId(context);
                }
              : () => _showAiSetupSheet(context),
        ).animate(delay: 0.ms).fadeIn().slideX(begin: 0.05),
      ),

      _FeatureCard(
        icon: Icons.healing,
        title: 'Symptom Checker',
        subtitle: aiConfigured
            ? 'Describe symptoms, get instant advice'
            : 'Optional AI setup in Preferences',
        color: AppColors.error,
        isLocked: !aiConfigured,
        onTap: aiConfigured
            ? () {
                if (!ref.read(isOnlineProvider)) {
                  _showOfflineSnackBar(context);
                  return;
                }
                AppRoutes.toSymptomTriage(context);
              }
            : () => _showAiSetupSheet(context),
      ).animate(delay: 50.ms).fadeIn().slideX(begin: 0.05),

      _FeatureCard(
        icon: Icons.calendar_month,
        title: 'Weekly Care Plan',
        subtitle: aiConfigured
            ? 'Your personalised maintenance schedule'
            : 'Optional AI setup in Preferences',
        color: AppColors
            .primary, // BUG-11: was textSecondary (gray), now warm amber to match siblings
        isLocked: !aiConfigured,
        onTap: aiConfigured
            ? () {
                if (!ref.read(isOnlineProvider)) {
                  _showOfflineSnackBar(context);
                  return;
                }
                AppRoutes.toWeeklyPlan(context);
              }
            : () => _showAiSetupSheet(context),
      ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.05),
      // Compatibility Checker (optional AI advice when a key is configured)
      if (aiConfigured) ...[
        const SizedBox(height: AppSpacing.sm),
        const CompatibilityCheckerWidget(),
      ],

      // Offline compatibility advice links to the Workshop-owned checker.
      if (!aiConfigured) ...[
        const SizedBox(height: AppSpacing.sm),
        _FeatureCard(
          icon: Icons.compare_arrows,
          title: 'Workshop Compatibility Checker',
          subtitle: 'Check fish matches with local species data',
          color: AppColors.success,
          onTap: () => AppRoutes.toWorkshop(context),
        ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.05),
      ],

      // Ask Danio - quick question
      if (aiConfigured) ...[
        const SizedBox(height: AppSpacing.md),
        Card(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.md2Radius),
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
        icon: activeAnomalies.isEmpty
            ? Icons.check_circle_outline
            : Icons.warning_amber,
        title: 'Anomaly History',
        subtitle: activeAnomalies.isEmpty
            ? 'All clear - no issues detected'
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
            .map((interaction) => _InteractionTile(interaction: interaction)),
      ],
    ];

    _maybeScrollFishIdAboveDock();

    return GestureDetector(
      excludeFromSemantics: true,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Themed Smart Header
            ThemedTabHeader(
              tab: TabHeaderContext.smart,
              height: 160,
              overlays: [
                Positioned(
                  top: 16,
                  left: 16,
                  child: SafeArea(
                    bottom: false,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.blackAlpha35,
                        borderRadius: AppRadius.md2Radius,
                      ),
                      child: Text(
                        'Smart',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Content
            SliverPadding(
              // BUG-04: bottom padding so Anomaly History card isn't clipped by bottom nav
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                MediaQuery.of(context).viewPadding.bottom +
                    DanioBottomDock.contentClearance,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _SmartReadableFrame(child: items[index]),
                  childCount: items.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAiSetupSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
      child: Builder(
        builder: (sheetContext) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    danioSurfaceVisual(DanioSurfaceVisualKey.aiSetup).icon,
                    color: danioSurfaceVisual(
                      DanioSurfaceVisualKey.aiSetup,
                    ).color,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Optional AI tools',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Local Smart Hub checks are ready now. Add optional AI for photo ID, symptom triage, and weekly care planning.',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Open Preferences',
                leadingIcon: Icons.tune,
                isFullWidth: true,
                onPressed: () {
                  Navigator.maybePop(sheetContext);
                  NavigationThrottle.push(
                    context,
                    const SettingsScreen(),
                    rootNavigator: true,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              AppButton(
                label: 'Not now',
                isFullWidth: true,
                variant: AppButtonVariant.text,
                onPressed: () => Navigator.maybePop(sheetContext),
              ),
            ],
          );
        },
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
                    'No anomalies detected - looking good.',
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
                        ? '${a.parameter} | ${_formatTime(a.detectedAt)} | Dismissed - will flag again if detected.'
                        : '${a.parameter} | ${_formatTime(a.detectedAt)}',
                  ),
                  dense: true,
                  trailing: a.dismissed
                      ? null
                      : TextButton(
                          onPressed: () async {
                            try {
                              await innerRef
                                  .read(anomalyHistoryProvider.notifier)
                                  .dismiss(a.id);
                            } catch (e, st) {
                              logError(
                                'SmartScreen: failed to dismiss anomaly: $e',
                                stackTrace: st,
                                tag: 'SmartScreen',
                              );
                              if (!ctx.mounted) return;
                              DanioSnackBar.warning(
                                ctx,
                                "Couldn't dismiss that alert. Try again.",
                              );
                            }
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

// Subwidgets

class _SmartReadableFrame extends StatelessWidget {
  final Widget child;

  const _SmartReadableFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxSmartReadableWidth),
        child: child,
      ),
    );
  }
}

class _AiSetupBanner extends StatelessWidget {
  final VoidCallback onOpenPreferences;

  const _AiSetupBanner({required this.onOpenPreferences});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                danioSurfaceVisual(DanioSurfaceVisualKey.aiSetup).icon,
                color: danioSurfaceVisual(DanioSurfaceVisualKey.aiSetup).color,
                size: AppIconSizes.lg,
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Optional AI tools',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Local compatibility checks and Anomaly History are ready now. '
                      'Add optional AI for photo ID, symptom triage, and weekly care planning.',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          AppButton(
            label: 'Open Preferences',
            leadingIcon: Icons.tune,
            onPressed: onOpenPreferences,
            variant: AppButtonVariant.secondary,
          ),
        ],
      ),
    );
  }
}

class _SetupContextBanner extends StatelessWidget {
  final VoidCallback onOpenPreferences;

  const _SetupContextBanner({required this.onOpenPreferences});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.md2Radius,
        border: Border.all(color: AppColors.accentText.withValues(alpha: 0.35)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentText.withValues(alpha: 0.12),
              borderRadius: AppRadius.smallRadius,
            ),
            child: const Icon(Icons.tune_outlined, color: AppColors.accentText),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete setup details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Add your region and tank stage so Smart can tune risks, reminders, and care plans.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: 'Open Preferences',
                  onPressed: onOpenPreferences,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                ),
              ],
            ),
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
  final bool isLocked;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDisabled = onTap == null;
    final semanticLabel = isLocked
        ? '$title. Optional AI setup required. Open Preferences to configure AI.'
        : '$title. $subtitle';

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: onTap != null,
      enabled: onTap != null,
      onTap: onTap,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: isDisabled ? 0.6 : (isLocked ? 0.75 : 1.0),
          child: Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.md2Radius),
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.md2Radius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm2,
                ),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLocked || isDisabled)
                      Icon(Icons.lock_outline, color: context.textSecondary)
                    else
                      Icon(Icons.chevron_right, color: context.textSecondary),
                  ],
                ),
              ),
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
