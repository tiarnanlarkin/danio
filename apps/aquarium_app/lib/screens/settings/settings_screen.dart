import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import '../about_screen.dart';
import '../backup_restore_screen.dart';
import '../difficulty_settings_screen.dart';
import '../learn_screen.dart';
import '../onboarding/consent_screen.dart';
import '../shop_street_screen.dart';
import '../tank_detail/tank_detail_screen.dart';
import '../theme_gallery_screen.dart';
import '../../models/adaptive_difficulty.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/reduced_motion_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tank_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../services/ai_proxy_service.dart';
import '../../services/onboarding_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_feedback.dart';
import '../../utils/navigation_throttle.dart';
import '../../widgets/core/app_list_tile.dart';
import '../../widgets/room_navigation.dart';
import 'settings_account_section.dart';
import 'settings_data_section.dart';
import 'settings_debug_section.dart';
import 'settings_notifications_section.dart';
import 'widgets/guides_section.dart';
import 'widgets/tools_section.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../utils/logger.dart';

export 'settings_account_section.dart';
export 'settings_data_section.dart';
export 'settings_debug_section.dart';
export 'settings_notifications_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = _buildSections(context, ref);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferences')),
      body: ListView.builder(
        itemCount: sections.length,
        itemBuilder: (ctx, i) => sections[i](ctx),
      ),
    );
  }

  List<WidgetBuilder> _buildSections(BuildContext context, WidgetRef ref) {
    return [
      // Account & Cloud Sync
      (_) => const _SectionHeader(title: 'Account'),
      (_) => const SettingsAccountSection(),

      // Learning System (Duolingo-style)
      (_) => const _SectionHeader(title: 'Learn'),
      (_) => const _LearnCard(),

      // Daily Goal Settings
      (_) => NavListTile(
        icon: Icons.flag,
        title: 'Daily Goal',
        subtitle: 'Set your daily XP target',
        onTap: () => _showDailyGoalPicker(context, ref),
      ),

      // House Navigation (Rooms)
      (_) => const _SectionHeader(title: 'Explore'),
      (_) => const RoomNavigation(),

      // Appearance
      (_) => const _SectionHeader(title: 'Appearance'),
      (_) => const _ThemeModeTile(),
      (_) => NavListTile(
        icon: Icons.color_lens_outlined,
        title: 'Room Themes',
        subtitle: 'Customize your living room style',
        onTap: () =>
            NavigationThrottle.push(context, const ThemeGalleryScreen()),
      ),
      (_) => NavListTile(
        icon: Icons.tune,
        title: 'Difficulty Settings',
        subtitle: 'Adjust app complexity level',
        onTap: () => NavigationThrottle.push(
          context,
          const _DifficultySettingsWrapper(),
        ),
      ),
      (_) => const _AmbientLightingToggle(),

      (_) => const Divider(),

      // Accessibility
      (_) => const _SectionHeader(title: 'Accessibility'),
      (_) => const _ReducedMotionToggle(),
      (_) => const _HapticFeedbackToggle(),

      (_) => const Divider(),

      // Notifications
      (_) => const _SectionHeader(title: 'Notifications'),
      (_) => const SettingsNotificationsSection(),

      (_) => const Divider(),

      // Smart Hub (AI features)
      (_) => const _SectionHeader(title: 'Smart Hub'),
      (_) => const _ConfigureAiTile(),

      (_) => const Divider(),

      // Tools section
      (_) => const _SectionHeader(title: 'Tools'),
      (_) => const ToolsSection(),

      // Shop Street
      (_) => const _SectionHeader(title: 'Shop'),
      (_) => NavListTile(
        icon: Icons.storefront,
        title: 'Shop Street',
        subtitle: 'Find aquarium supplies online',
        onTap: () =>
            NavigationThrottle.push(context, const ShopStreetScreen()),
      ),

      (_) => const Divider(),

      // App Info
      (_) => const _SectionHeader(title: 'App Info'),
      (_) => AppListTile(
        leading: const Icon(Icons.water_drop),
        title: 'Danio',
        subtitle: 'Version 0.1.0',
        onTap: kDebugMode ? () => handleVersionTap(context) : null,
      ),
      (_) => AppListTile(
        leading: const Icon(Icons.info_outline),
        title: 'About',
        onTap: () => _showAboutDialog(context),
      ),

      (_) => const Divider(),

      // Privacy
      (_) => const _SectionHeader(title: 'Privacy'),
      (_) => const _AnalyticsConsentToggle(),

      (_) => const Divider(),

      // Data section
      (_) => const _SectionHeader(title: 'Data'),
      (_) => SettingsDataSection(ref: ref),

      (_) => const Divider(),

      // Guides & Education
      (_) => const _SectionHeader(title: 'Guides & Education'),
      (_) => const GuidesSection(),

      // Help & Support
      (_) => const _SectionHeader(title: 'Help & Support'),
      (_) => AppListTile(
        leading: const Icon(Icons.replay_outlined),
        title: 'Replay Onboarding',
        subtitle: 'See the intro screens again',
        onTap: () => _replayOnboarding(context, ref),
      ),
      (_) => AppListTile(
        leading: const Icon(Icons.auto_awesome),
        title: 'Add Sample Tank',
        subtitle: 'Explore the app with demo data',
        onTap: () async {
          try {
            final actions = ref.read(tankActionsProvider);
            final demoTank = await actions.addDemoTank();
            if (context.mounted) {
              AppFeedback.showSuccess(context, 'Sample tank added!');
              NavigationThrottle.push(
                context,
                TankDetailScreen(tankId: demoTank.id),
              );
            }
          } catch (e, st) {
            logError('SettingsScreen: add sample tank failed: $e', stackTrace: st, tag: 'SettingsScreen');
            if (context.mounted) {
              AppFeedback.showError(
                context,
                'Couldn\'t add sample tank. Give it another go!',
              );
            }
          }
        },
      ),
      (_) => NavListTile(
        icon: Icons.backup,
        title: 'Backup & Restore',
        subtitle: 'Export or import your tank data',
        onTap: () =>
            NavigationThrottle.push(context, const BackupRestoreScreen()),
      ),
      (_) => NavListTile(
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'Version info and features',
        onTap: () => NavigationThrottle.push(context, const AboutScreen()),
      ),

      (_) => const Divider(),

      // Danger zone
      (_) =>
          const _SectionHeader(title: 'Danger Zone', color: AppColors.error),
      (_) => AppListTile(
        leading: const Icon(
          Icons.delete_forever_outlined,
          color: AppColors.error,
        ),
        title: 'Clear All Data',
        subtitle: 'Delete all tanks, logs, and settings',
        isDestructive: true,
        onTap: () => confirmClearData(context, ref),
      ),
      (_) => AppListTile(
        leading: const Icon(
          Icons.person_remove_outlined,
          color: AppColors.error,
        ),
        title: 'Delete My Data',
        subtitle: 'Erase all data & exercise your privacy rights',
        isDestructive: true,
        onTap: () => confirmDeleteMyData(context, ref),
      ),
      if (kDebugMode) (_) => const SettingsDebugSection(),
    ];
  }

  void _showDailyGoalPicker(BuildContext context, WidgetRef ref) {
    final profile = ref.read(userProfileProvider).value;
    final currentGoal = profile?.dailyXpGoal ?? 50;

    showAppDragSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    'Daily XP Goal',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Complete your goal every day to maintain your streak',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _GoalOption(
              ref: ref,
              goal: 25,
              label: 'Casual',
              description: 'Just a few minutes',
              current: currentGoal,
              icon: '🐢',
            ),
            _GoalOption(
              ref: ref,
              goal: 50,
              label: 'Regular',
              description: 'One lesson per day',
              current: currentGoal,
              icon: '🐟',
            ),
            _GoalOption(
              ref: ref,
              goal: 100,
              label: 'Serious',
              description: 'Multiple lessons',
              current: currentGoal,
              icon: '🦈',
            ),
            _GoalOption(
              ref: ref,
              goal: 200,
              label: 'Intense',
              description: 'Max dedication',
              current: currentGoal,
              icon: '🐋',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Danio',
      applicationVersion: '0.1.0 (MVP)',
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppOverlays.primary10,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.water_drop, color: AppColors.primary),
      ),
      children: [
        const Text(
          'Personal aquarium management - track tanks, livestock, equipment & maintenance.',
        ),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Your data is stored locally on this device.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Future<void> _replayOnboarding(BuildContext context, WidgetRef ref) async {
    final service = await OnboardingService.getInstance();
    await service.resetOnboarding();

    if (context.mounted) {
      ref.invalidate(onboardingCompletedProvider);
      Navigator.of(
        context,
        rootNavigator: true,
      ).popUntil((route) => route.isFirst);
    }
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;

  const _SectionHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.primaryAlpha50],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          Text(
            title.toUpperCase(),
            style: AppTypography.labelLarge.copyWith(
              color: color ?? (context.textSecondary),
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Appearance widgets
// ---------------------------------------------------------------------------

String _themeModeLabel(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return 'System default';
    case AppThemeMode.light:
      return 'Light';
    case AppThemeMode.dark:
      return 'Dark';
  }
}

void _showThemePicker(
  BuildContext context,
  WidgetRef ref,
  AppThemeMode current,
) {
  showAppDragSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Choose Theme',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          AppListTile(
            leading: const Icon(Icons.brightness_auto),
            title: 'System default',
            subtitle: 'Follow device settings',
            isSelected: current == AppThemeMode.system,
            trailing: current == AppThemeMode.system
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setThemeMode(AppThemeMode.system);
              Navigator.maybePop(ctx);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.light_mode),
            title: 'Light',
            isSelected: current == AppThemeMode.light,
            trailing: current == AppThemeMode.light
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setThemeMode(AppThemeMode.light);
              Navigator.maybePop(ctx);
            },
          ),
          AppListTile(
            leading: const Icon(Icons.dark_mode),
            title: 'Dark',
            isSelected: current == AppThemeMode.dark,
            trailing: current == AppThemeMode.dark
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              ref
                  .read(settingsProvider.notifier)
                  .setThemeMode(AppThemeMode.dark);
              Navigator.maybePop(ctx);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

class _ThemeModeTile extends ConsumerWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(settingsProvider.select((s) => s.themeMode));
    return NavListTile(
      icon: Icons.palette_outlined,
      title: 'Light/Dark Mode',
      subtitle: _themeModeLabel(themeMode),
      onTap: () => _showThemePicker(context, ref, themeMode),
    );
  }
}

class _AmbientLightingToggle extends ConsumerWidget {
  const _AmbientLightingToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      settingsProvider.select((s) => s.ambientLightingEnabled),
    );
    return SwitchListTile(
      secondary: const Icon(Icons.wb_twilight),
      title: const Text('Day/Night Ambiance'),
      subtitle: const Text('Subtle lighting based on time of day'),
      value: enabled,
      onChanged: (value) => ref
          .read(settingsProvider.notifier)
          .setAmbientLightingEnabled(value),
    );
  }
}

class _HapticFeedbackToggle extends ConsumerWidget {
  const _HapticFeedbackToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      settingsProvider.select((s) => s.hapticFeedbackEnabled),
    );
    return SwitchListTile(
      secondary: const Icon(Icons.vibration),
      title: const Text('Haptic Feedback'),
      subtitle: const Text('Vibration for important interactions'),
      value: enabled,
      onChanged: (value) => ref
          .read(settingsProvider.notifier)
          .setHapticFeedbackEnabled(value),
    );
  }
}

// ---------------------------------------------------------------------------
// Learn card
// ---------------------------------------------------------------------------

class _LearnCard extends ConsumerWidget {
  const _LearnCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(learningStatsProvider);
    final profile = ref.watch(
      userProfileProvider.select(
        (p) => (
          p.asData?.value?.hasStreakFreeze,
          p.asData?.value?.streakFreezeUsedThisWeek,
        ),
      ),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg2,
        vertical: AppSpacing.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Semantics(
          button: true,
          label: 'Learn Fishkeeping. Tap to open lessons',
          child: InkWell(
            onTap: () =>
                NavigationThrottle.push(context, const LearnScreen()),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryAlpha85,
                    AppColors.secondaryAlpha90,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.primaryAlpha40
                        : AppColors.primaryAlpha25,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: isDark
                        ? AppColors.blackAlpha30
                        : AppColors.blackAlpha10,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppOverlays.white20,
                      borderRadius: AppRadius.mediumRadius,
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn Fishkeeping',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        if (stats != null) ...[
                          Text(
                            '${stats.levelTitle} • ${stats.totalXp} XP',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          if (stats.currentStreak > 0) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              '🔥 ${stats.currentStreak}-day streak',
                              style: AppTypography.bodySmall.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            if (profile.$1 == true || profile.$2 == true) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                profile.$1 == true
                                    ? '🧊 Streak freeze available'
                                    : '🧊 Streak freeze used this week',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ],
                        ] else
                          Text(
                            'Start your learning journey',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Goal picker option
// ---------------------------------------------------------------------------

class _GoalOption extends StatefulWidget {
  final WidgetRef ref;
  final int goal;
  final String label;
  final String description;
  final int current;
  final String icon;

  const _GoalOption({
    required this.ref,
    required this.goal,
    required this.label,
    required this.description,
    required this.current,
    required this.icon,
  });

  @override
  State<_GoalOption> createState() => _GoalOptionState();
}

class _GoalOptionState extends State<_GoalOption> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.goal == widget.current;

    return ListTile(
      leading: _isLoading
          ? const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              widget.icon,
              style:
                  Theme.of(context).textTheme.headlineMedium!.copyWith(),
            ),
      title: Text('${widget.goal} XP/day'),
      subtitle: Text('${widget.label} • ${widget.description}'),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      selected: isSelected,
      enabled: !_isLoading,
      onTap: () async {
        setState(() => _isLoading = true);
        try {
          await widget.ref
              .read(userProfileProvider.notifier)
              .setDailyGoal(widget.goal);
          if (mounted) {
            Navigator.maybePop(this.context);
            AppFeedback.showSuccess(
              this.context,
              'Daily goal updated to ${widget.goal} XP',
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Difficulty settings wrapper
// ---------------------------------------------------------------------------

class _DifficultySettingsWrapper extends StatefulWidget {
  const _DifficultySettingsWrapper();

  @override
  State<_DifficultySettingsWrapper> createState() =>
      _DifficultySettingsWrapperState();
}

class _DifficultySettingsWrapperState
    extends State<_DifficultySettingsWrapper> {
  late UserSkillProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = const UserSkillProfile(
      skillLevels: {},
      performanceHistory: {},
      manualOverrides: {},
    );
  }

  void _onProfileUpdated(UserSkillProfile updatedProfile) {
    setState(() {
      _profile = updatedProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DifficultySettingsScreen(
      skillProfile: _profile,
      onProfileUpdated: _onProfileUpdated,
    );
  }
}

// ---------------------------------------------------------------------------
// Accessibility widgets
// ---------------------------------------------------------------------------

class _ReducedMotionToggle extends ConsumerWidget {
  const _ReducedMotionToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reducedMotion = ref.watch(reducedMotionProvider);

    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.accessibility_new),
          title: const Text('Reduce Motion'),
          subtitle: Text(
            reducedMotion.systemPreference
                ? 'System setting detected - animations simplified'
                : reducedMotion.userOverride == true
                ? 'Manually enabled - animations simplified'
                : 'Minimize animations for comfort',
          ),
          value: reducedMotion.isEnabled,
          onChanged: (value) async {
            if (value == reducedMotion.systemPreference) {
              await ref
                  .read(reducedMotionProvider.notifier)
                  .setUserPreference(null);
            } else {
              await ref
                  .read(reducedMotionProvider.notifier)
                  .setUserPreference(value);
            }

            if (context.mounted) {
              AppFeedback.showInfo(
                context,
                value
                    ? 'Reduced motion enabled - animations simplified'
                    : 'Reduced motion disabled - full animations',
              );
            }
          },
        ),
        if (reducedMotion.systemPreference &&
            reducedMotion.userOverride == false)
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
            child: Text(
              'ℹ️ Your system has animations disabled, but you\'ve manually enabled them in this app.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (reducedMotion.isEnabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
            child: Text(
              'Benefits: Reduces motion sickness, improves battery life, and makes the app more comfortable for users with vestibular disorders.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.success,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Privacy
// ---------------------------------------------------------------------------

class _AnalyticsConsentToggle extends StatefulWidget {
  const _AnalyticsConsentToggle();

  @override
  State<_AnalyticsConsentToggle> createState() =>
      _AnalyticsConsentToggleState();
}

class _AnalyticsConsentToggleState extends State<_AnalyticsConsentToggle> {
  bool _enabled = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final consent = prefs.getBool(kGdprAnalyticsConsentKey) ?? false;
    if (mounted) {
      setState(() {
        _enabled = consent;
        _loaded = true;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kGdprAnalyticsConsentKey, value);
    await applyAnalyticsConsent(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SwitchListTile(
      secondary: const Icon(Icons.analytics_outlined),
      title: const Text('Analytics & Crash Reports'),
      subtitle: const Text(
        'Send anonymous usage data to help improve Danio',
      ),
      value: _enabled,
      onChanged: _toggle,
    );
  }
}

// ---------------------------------------------------------------------------
// Smart Hub — Configure AI tile
// ---------------------------------------------------------------------------

class _ConfigureAiTile extends StatefulWidget {
  const _ConfigureAiTile();

  @override
  State<_ConfigureAiTile> createState() => _ConfigureAiTileState();
}

class _ConfigureAiTileState extends State<_ConfigureAiTile> {
  bool _hasUserKey = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final hasKey = await AiProxyService.hasUserKey;
    if (mounted) setState(() => _hasUserKey = hasKey);
  }

  @override
  Widget build(BuildContext context) {
    return AppListTile(
      leading: const Icon(Icons.smart_toy_outlined),
      title: 'Configure AI',
      subtitle: _hasUserKey
          ? 'Custom API key active — tap to manage'
          : 'Add your OpenAI API key to enable Smart Hub features',
      trailing: _hasUserKey
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : null,
      onTap: () => _showConfigureAiDialog(context),
    );
  }

  Future<void> _showConfigureAiDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ConfigureAiDialog(onDismissed: _reload),
    );
  }
}

class _ConfigureAiDialog extends StatefulWidget {
  final VoidCallback onDismissed;

  const _ConfigureAiDialog({required this.onDismissed});

  @override
  State<_ConfigureAiDialog> createState() => _ConfigureAiDialogState();
}

class _ConfigureAiDialogState extends State<_ConfigureAiDialog> {
  final _controller = TextEditingController();
  bool _obscureText = true;
  bool _isBusy = false;
  bool _hasUserKey = false;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    final hasKey = await AiProxyService.hasUserKey;
    if (mounted) setState(() => _hasUserKey = hasKey);
  }

  Future<void> _saveKey() async {
    final key = _controller.text.trim();
    if (key.isEmpty) return;
    if (!key.startsWith('sk-')) {
      setState(() {
        _statusMessage = 'OpenAI keys start with "sk-". Double-check yours.';
        _statusIsError = true;
      });
      return;
    }
    setState(() {
      _isBusy = true;
      _statusMessage = null;
    });
    try {
      await AiProxyService.saveApiKey(key);
      if (mounted) {
        setState(() {
          _hasUserKey = true;
          _statusMessage = 'Key saved! Smart Hub features are now active.';
          _statusIsError = false;
          _isBusy = false;
        });
        _controller.clear();
      }
    } catch (e, st) {
      logError('SettingsScreen: API key save failed: $e', stackTrace: st, tag: 'SettingsScreen');
      if (mounted) {
        setState(() {
          _statusMessage = 'Couldn\'t save the key. Try again.';
          _statusIsError = true;
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _clearKey() async {
    setState(() => _isBusy = true);
    try {
      await AiProxyService.clearApiKey();
      if (mounted) {
        setState(() {
          _hasUserKey = false;
          _statusMessage = 'API key removed.';
          _statusIsError = false;
          _isBusy = false;
        });
      }
    } catch (e, st) {
      logError('SettingsScreen: API key clear failed: $e', stackTrace: st, tag: 'SettingsScreen');
      if (mounted) {
        setState(() {
          _statusMessage = 'Couldn\'t clear the key. Try again.';
          _statusIsError = true;
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Configure AI',
      actions: [
        if (_hasUserKey) ...[
          AppButton(
            label: 'Remove key',
            onPressed: _isBusy ? null : _clearKey,
            variant: AppButtonVariant.destructive,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        AppButton(
          label: 'Close',
          onPressed: () {
            widget.onDismissed();
            Navigator.maybePop(context);
          },
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: 'Save',
          onPressed: _isBusy ? null : _saveKey,
          isLoading: _isBusy,
          variant: AppButtonVariant.primary,
          isFullWidth: true,
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your key is stored locally on your device and never shared with us.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_hasUserKey) ...[
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Custom API key is active.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            TextField(
              controller: _controller,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'OpenAI API key',
                hintText: 'sk-...',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                ),
              ),
              maxLength: kNotesMaxLength,
              enabled: !_isBusy,
            ),
            if (_statusMessage != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _statusMessage!,
                style: TextStyle(
                  color: _statusIsError ? AppColors.error : AppColors.success,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
