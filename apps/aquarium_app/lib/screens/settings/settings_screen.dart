import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_constants.dart';
import '../about_screen.dart';
import '../difficulty_settings_screen.dart';
import '../learn_screen.dart';
import '../onboarding/consent_screen.dart';
import '../privacy_policy_screen.dart';
import '../../navigation/app_routes.dart';
import '../../models/adaptive_difficulty.dart';
import '../../models/user_profile.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/reduced_motion_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/tank_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../features/smart/ai_disclosure_preferences.dart';
import '../../services/ai_proxy_service.dart';
import '../../services/openai_service.dart';
import '../../services/onboarding_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/danio_surface_visuals.dart';
import '../../utils/app_feedback.dart';
import '../../utils/navigation_throttle.dart';
import '../../providers/room_theme_provider.dart';
import '../../widgets/core/app_list_tile.dart';
import '../home/home_sheets_theme.dart';
import 'settings_account_section.dart';
import 'settings_data_section.dart';
import 'settings_debug_section.dart';
import 'settings_notifications_section.dart';
import 'widgets/guides_section.dart';
import '../../widgets/core/app_button.dart';
import '../../widgets/core/app_dialog.dart';
import '../../widgets/core/bubble_loader.dart';
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
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.xxl,
        ),
        itemCount: sections.length,
        itemBuilder: (ctx, i) => sections[i](ctx),
      ),
    );
  }

  List<WidgetBuilder> _buildSections(BuildContext context, WidgetRef ref) {
    return [
      // ── GROUP 1: Account ─────────────────────────────────────────────
      (_) => const _SectionHeader(title: 'Account'),
      (_) => const SettingsAccountSection(),

      (_) => const Divider(),

      // ── GROUP 2: Your Progress (XP, learning, goals) ─────────────────
      (_) => const _SectionHeader(title: 'Your Progress'),
      (_) => const _LearnCard(),
      (_) => NavListTile(
        icon: Icons.flag,
        title: 'Daily Goal',
        subtitle: 'Set your daily XP target',
        onTap: () => _showDailyGoalPicker(context, ref),
      ),

      (_) => const Divider(),

      // GROUP 3: App Settings (appearance, accessibility, notifications)
      (_) => const _SectionHeader(title: 'App Settings'),
      (_) => const _ThemeModeTile(),
      (_) => const _RoomThemeTile(),
      (_) => const _UnitsTile(),
      (_) => const _SectionHeader(title: 'Setup Details'),
      (_) => const _RegionProfileTile(),
      (_) => const _TankStageProfileTile(),
      (_) => const _ExperienceLevelProfileTile(),
      (_) => const _GoalsProfileTile(),
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
      (_) => const _ReducedMotionToggle(),
      (_) => const _HapticFeedbackToggle(),

      (_) => const Divider(),

      // Notifications
      (_) => const _SectionHeader(title: 'Notifications'),
      (_) => const SettingsNotificationsSection(),

      (_) => const Divider(),

      // Smart Hub (local intelligence and optional AI)
      (_) => const _SectionHeader(title: 'Smart Hub'),
      (_) => const _ConfigureAiTile(),

      (_) => const Divider(),

      // GROUP 4: Guides & Education
      (_) => const _SectionHeader(title: 'Guides & Education'),
      (_) => const GuidesSection(),

      (_) => const Divider(),

      // GROUP 5: About & Privacy
      (_) => const _SectionHeader(title: 'About & Privacy'),
      (_) => AppListTile(
        leading: const Icon(Icons.water_drop),
        title: 'Danio',
        subtitle: 'Version $kAppVersion',
        onTap: kDebugMode ? () => handleVersionTap(context) : null,
      ),
      (_) => const _AnalyticsConsentToggle(),
      (_) => NavListTile(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy Policy',
        subtitle: 'Local data, crash reports, and optional services',
        onTap: () =>
            NavigationThrottle.push(context, const PrivacyPolicyScreen()),
      ),
      (_) => SettingsDataSection(ref: ref),

      (_) => const Divider(),

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
        title: 'Reset Sample Tank',
        subtitle: 'Replaces demo data without touching your real tanks',
        onTap: () async {
          try {
            final actions = ref.read(tankActionsProvider);
            final demoTank = await actions.addDemoTank();
            if (context.mounted) {
              AppFeedback.showSuccess(context, 'Sample tank ready!');
              AppRoutes.toTankDetail(context, demoTank.id);
            }
          } catch (e, st) {
            logError(
              'SettingsScreen: add sample tank failed: $e',
              stackTrace: st,
              tag: 'SettingsScreen',
            );
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
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'Version info and features',
        onTap: () => NavigationThrottle.push(context, const AboutScreen()),
      ),

      (_) => const Divider(),

      // Danger zone
      (_) => const _SectionHeader(title: 'Danger Zone', color: AppColors.error),
      (_) => AppListTile(
        leading: const Icon(
          Icons.delete_forever_outlined,
          color: AppColors.error,
        ),
        title: 'Clear All Data',
        subtitle: 'Delete tanks, logs, tasks, and photos',
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
              visualKey: DanioSurfaceVisualKey.dailyGoalCasual,
            ),
            _GoalOption(
              ref: ref,
              goal: 50,
              label: 'Regular',
              description: 'One lesson per day',
              current: currentGoal,
              visualKey: DanioSurfaceVisualKey.dailyGoalRegular,
            ),
            _GoalOption(
              ref: ref,
              goal: 100,
              label: 'Serious',
              description: 'Multiple lessons',
              current: currentGoal,
              visualKey: DanioSurfaceVisualKey.dailyGoalSerious,
            ),
            _GoalOption(
              ref: ref,
              goal: 200,
              label: 'Intense',
              description: 'Max dedication',
              current: currentGoal,
              visualKey: DanioSurfaceVisualKey.dailyGoalIntense,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _replayOnboarding(BuildContext context, WidgetRef ref) async {
    try {
      final service = await OnboardingService.getInstance();
      await service.resetOnboarding();

      if (context.mounted) {
        ref.invalidate(onboardingCompletedProvider);
        Navigator.of(
          context,
          rootNavigator: true,
        ).popUntil((route) => route.isFirst);
      }
    } catch (e, st) {
      logError(
        'SettingsScreen: replay onboarding failed: $e',
        stackTrace: st,
        tag: 'SettingsScreen',
      );
      if (context.mounted) {
        AppFeedback.showError(
          context,
          'Couldn\'t replay onboarding. Try again.',
        );
      }
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg2,
        AppSpacing.xl,
        AppSpacing.lg2,
        AppSpacing.sm2,
      ),
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
              borderRadius: AppRadius.xxsRadius,
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
  Future<void> chooseTheme(BuildContext sheetContext, AppThemeMode mode) async {
    final saved = await ref.read(settingsProvider.notifier).setThemeMode(mode);
    if (!sheetContext.mounted) return;
    if (saved) {
      Navigator.maybePop(sheetContext);
    } else {
      AppFeedback.showError(sheetContext, 'Couldn\'t save theme. Try again.');
    }
  }

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
              chooseTheme(ctx, AppThemeMode.system);
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
              chooseTheme(ctx, AppThemeMode.light);
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
              chooseTheme(ctx, AppThemeMode.dark);
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
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return NavListTile(
      icon: Icons.palette_outlined,
      title: 'Light/Dark Mode',
      subtitle: _themeModeLabel(themeMode),
      onTap: () => _showThemePicker(context, ref, themeMode),
    );
  }
}

String _unitsLabel(bool useMetric) {
  return useMetric ? 'Metric (litres, cm, C)' : 'US units (gallons, inches, F)';
}

const _regionLabels = {
  'gb_ie': 'UK & Ireland',
  'europe': 'Europe',
  'us': 'United States',
  'canada': 'Canada',
  'aus_nz': 'Australia & New Zealand',
  'other': 'Other / not listed',
};

const _tankStageLabels = {
  'planning': 'Planning a tank',
  'cycling': 'Cycling / setting up',
  'active': 'Tank running with livestock',
};

String _regionLabel(String? regionCode) {
  if (regionCode == null) return 'Not set - helps localise guidance';
  return _regionLabels[regionCode] ?? 'Other / not listed';
}

String _tankStageLabel(String? tankStatus) {
  if (tankStatus == null) return 'Not set - helps tune care prompts';
  return _tankStageLabels[tankStatus] ?? 'Not set - helps tune care prompts';
}

String _experienceLabel(ExperienceLevel level) => level.displayName;

const _goalOrder = [
  UserGoal.keepFishAlive,
  UserGoal.learnTheScience,
  UserGoal.beautifulDisplay,
  UserGoal.relaxation,
  UserGoal.breeding,
  UserGoal.competition,
  UserGoal.masterTheHobby,
];

String _goalsLabel(List<UserGoal> goals) {
  if (goals.isEmpty) return 'Not set - helps personalise guidance';
  final ordered = _goalOrder.where(goals.contains).toList(growable: false);
  final visible = ordered.take(2).map((goal) => goal.displayName).join(', ');
  final extra = ordered.length - 2;
  return extra > 0 ? '$visible +$extra more' : visible;
}

void _showUnitsPicker(BuildContext context, WidgetRef ref, bool useMetric) {
  showAppDragSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Choose Units',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          AppListTile(
            leading: const Icon(Icons.straighten),
            title: 'Metric',
            subtitle: 'Litres, centimetres, Celsius',
            isSelected: useMetric,
            trailing: useMetric
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () async {
              final saved = await ref
                  .read(settingsProvider.notifier)
                  .setUseMetric(true);
              if (!ctx.mounted) return;
              if (saved) {
                Navigator.maybePop(ctx);
              } else {
                AppFeedback.showError(ctx, 'Couldn\'t save units. Try again.');
              }
            },
          ),
          AppListTile(
            leading: const Icon(Icons.speed),
            title: 'US units',
            subtitle: 'Gallons, inches, Fahrenheit',
            isSelected: !useMetric,
            trailing: !useMetric
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () async {
              final saved = await ref
                  .read(settingsProvider.notifier)
                  .setUseMetric(false);
              if (!ctx.mounted) return;
              if (saved) {
                Navigator.maybePop(ctx);
              } else {
                AppFeedback.showError(ctx, 'Couldn\'t save units. Try again.');
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

class _UnitsTile extends ConsumerWidget {
  const _UnitsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useMetric = ref.watch(settingsProvider.select((s) => s.useMetric));
    return NavListTile(
      icon: Icons.straighten,
      title: 'Units',
      subtitle: _unitsLabel(useMetric),
      onTap: () => _showUnitsPicker(context, ref, useMetric),
    );
  }
}

void _showRegionPicker(
  BuildContext context,
  WidgetRef ref,
  String? currentRegion,
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
              'Choose Region',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final entry in _regionLabels.entries)
            AppListTile(
              leading: const Icon(Icons.public),
              title: entry.value,
              isSelected: currentRegion == entry.key,
              trailing: currentRegion == entry.key
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                final saved = await _saveProfilePickerEdit(
                  context,
                  label: 'region',
                  save: () => ref
                      .read(userProfileProvider.notifier)
                      .updateProfile(regionCode: entry.key),
                );
                if (saved && ctx.mounted) Navigator.maybePop(ctx);
              },
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

void _showTankStagePicker(
  BuildContext context,
  WidgetRef ref,
  String? currentTankStage,
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
              'Choose Tank Stage',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final entry in _tankStageLabels.entries)
            AppListTile(
              leading: const Icon(Icons.water),
              title: entry.value,
              isSelected: currentTankStage == entry.key,
              trailing: currentTankStage == entry.key
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                final saved = await _saveProfilePickerEdit(
                  context,
                  label: 'tank stage',
                  save: () => ref
                      .read(userProfileProvider.notifier)
                      .updateProfile(tankStatus: entry.key),
                );
                if (saved && ctx.mounted) Navigator.maybePop(ctx);
              },
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

void _showExperiencePicker(
  BuildContext context,
  WidgetRef ref,
  ExperienceLevel currentLevel,
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
              'Choose Experience Level',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          for (final level in ExperienceLevel.values)
            AppListTile(
              leading: const Icon(Icons.school_outlined),
              title: level.displayName,
              subtitle: level.description,
              isSelected: currentLevel == level,
              trailing: currentLevel == level
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                final saved = await _saveProfilePickerEdit(
                  context,
                  label: 'experience level',
                  save: () => ref
                      .read(userProfileProvider.notifier)
                      .updateProfile(experienceLevel: level),
                );
                if (saved && ctx.mounted) Navigator.maybePop(ctx);
              },
            ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}

void _showGoalsPicker(
  BuildContext context,
  WidgetRef ref,
  List<UserGoal> currentGoals,
) {
  final selectedGoals = currentGoals.toSet();
  showAppDragSheet(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setSheetState) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Choose Goals',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final goal in _goalOrder)
                    CheckboxListTile(
                      secondary: const Icon(Icons.flag_outlined),
                      title: Text(goal.displayName),
                      value: selectedGoals.contains(goal),
                      onChanged: (checked) {
                        setSheetState(() {
                          if (checked ?? false) {
                            selectedGoals.add(goal);
                          } else {
                            selectedGoals.remove(goal);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppButton(
                label: 'Save goals',
                isFullWidth: true,
                onPressed: selectedGoals.isEmpty
                    ? null
                    : () async {
                        final orderedGoals = _goalOrder
                            .where(selectedGoals.contains)
                            .toList(growable: false);
                        final saved = await _saveProfilePickerEdit(
                          context,
                          label: 'goals',
                          save: () => ref
                              .read(userProfileProvider.notifier)
                              .updateProfile(goals: orderedGoals),
                        );
                        if (saved && ctx.mounted) Navigator.maybePop(ctx);
                      },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> _saveProfilePickerEdit(
  BuildContext context, {
  required String label,
  required Future<void> Function() save,
}) async {
  try {
    await save();
    return true;
  } catch (_) {
    if (context.mounted) {
      AppFeedback.showError(context, 'Couldn\'t update $label. Try again.');
    }
    return false;
  }
}

class _RegionProfileTile extends ConsumerWidget {
  const _RegionProfileTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regionCode = ref.watch(
      userProfileProvider.select((profile) => profile.valueOrNull?.regionCode),
    );
    return NavListTile(
      icon: Icons.public,
      title: 'Region',
      subtitle: _regionLabel(regionCode),
      onTap: () => _showRegionPicker(context, ref, regionCode),
    );
  }
}

class _TankStageProfileTile extends ConsumerWidget {
  const _TankStageProfileTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tankStage = ref.watch(
      userProfileProvider.select((profile) => profile.valueOrNull?.tankStatus),
    );
    return NavListTile(
      icon: Icons.water,
      title: 'Tank stage',
      subtitle: _tankStageLabel(tankStage),
      onTap: () => _showTankStagePicker(context, ref, tankStage),
    );
  }
}

class _ExperienceLevelProfileTile extends ConsumerWidget {
  const _ExperienceLevelProfileTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experienceLevel = ref.watch(
      userProfileProvider.select(
        (profile) =>
            profile.valueOrNull?.experienceLevel ?? ExperienceLevel.beginner,
      ),
    );
    return NavListTile(
      icon: Icons.school_outlined,
      title: 'Experience level',
      subtitle: _experienceLabel(experienceLevel),
      onTap: () => _showExperiencePicker(context, ref, experienceLevel),
    );
  }
}

class _GoalsProfileTile extends ConsumerWidget {
  const _GoalsProfileTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(
      userProfileProvider.select(
        (profile) => profile.valueOrNull?.goals ?? const <UserGoal>[],
      ),
    );
    return NavListTile(
      icon: Icons.flag_outlined,
      title: 'Goals',
      subtitle: _goalsLabel(goals),
      onTap: () => _showGoalsPicker(context, ref, goals),
    );
  }
}

class _RoomThemeTile extends ConsumerWidget {
  const _RoomThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentRoomThemeProvider);
    return NavListTile(
      icon: Icons.color_lens_outlined,
      title: 'Room Theme',
      subtitle: theme.name,
      onTap: () => showThemePicker(context, ref),
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
      onChanged: (value) async {
        final saved = await ref
            .read(settingsProvider.notifier)
            .setAmbientLightingEnabled(value);
        if (!context.mounted) return;
        if (!saved) {
          AppFeedback.showError(
            context,
            'Couldn\'t update day/night ambiance. Try again.',
          );
        }
      },
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
      onChanged: (value) async {
        final saved = await ref
            .read(settingsProvider.notifier)
            .setHapticFeedbackEnabled(value);
        if (!context.mounted) return;
        if (!saved) {
          AppFeedback.showError(
            context,
            'Couldn\'t update haptic feedback. Try again.',
          );
        }
      },
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
    // Select only the three fields this card renders — avoids rebuilds when
    // unrelated stats fields (longestStreak, lessonsCompleted, etc.) change.
    final stats = ref.watch(
      learningStatsProvider.select(
        (s) => s == null
            ? null
            : (
                levelTitle: s.levelTitle,
                totalXp: s.totalXp,
                currentStreak: s.currentStreak,
              ),
      ),
    );
    final profile = ref.watch(
      userProfileProvider.select(
        (p) => (
          p.asData?.value?.hasStreakFreeze,
          p.asData?.value?.streakFreezeUsedThisWeek,
        ),
      ),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    void openLessons() => NavigationThrottle.push(context, const LearnScreen());

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg2,
        vertical: AppSpacing.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.largeRadius,
        child: Semantics(
          button: true,
          label: 'Learn Fishkeeping. Tap to open lessons',
          onTap: openLessons,
          excludeSemantics: true,
          child: InkWell(
            onTap: openLessons,
            borderRadius: AppRadius.largeRadius,
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
                borderRadius: AppRadius.largeRadius,
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
                              color: AppColors.whiteAlpha70,
                            ),
                          ),
                          if (stats.currentStreak > 0) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              '${stats.currentStreak}-day streak',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.whiteAlpha70,
                              ),
                            ),
                            if (profile.$1 == true || profile.$2 == true) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                profile.$1 == true
                                    ? 'Streak freeze available'
                                    : 'Streak freeze used this week',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.whiteAlpha70,
                                ),
                              ),
                            ],
                          ],
                        ] else
                          Text(
                            'Start your learning journey',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.whiteAlpha70,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.whiteAlpha70,
                  ),
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
  final DanioSurfaceVisualKey visualKey;

  const _GoalOption({
    required this.ref,
    required this.goal,
    required this.label,
    required this.description,
    required this.current,
    required this.visualKey,
  });

  @override
  State<_GoalOption> createState() => _GoalOptionState();
}

class _GoalOptionState extends State<_GoalOption> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.goal == widget.current;
    final visual = danioSurfaceVisual(widget.visualKey);

    return ListTile(
      leading: _isLoading
          ? const BubbleLoader.small()
          : Icon(visual.icon, color: visual.color),
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

// FB-H6: Converted to ConsumerStatefulWidget to load/save skill profile
// from SharedPreferences so settings persist across navigation.
class _DifficultySettingsWrapper extends ConsumerStatefulWidget {
  const _DifficultySettingsWrapper();

  @override
  ConsumerState<_DifficultySettingsWrapper> createState() =>
      _DifficultySettingsWrapperState();
}

class _DifficultySettingsWrapperState
    extends ConsumerState<_DifficultySettingsWrapper> {
  UserSkillProfile _profile = UserSkillProfile.empty();
  bool _loaded = false;

  static const String _profileKey = 'user_skill_profile';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final json = prefs.getString(_profileKey);
      if (json != null && mounted) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        setState(() {
          _profile = UserSkillProfile.fromJson(decoded);
          _loaded = true;
        });
        return;
      }
    } catch (_) {
      // Fall through to empty profile
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<bool> _onProfileUpdated(UserSkillProfile updatedProfile) async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final saved = await prefs.setString(
        _profileKey,
        jsonEncode(updatedProfile.toJson()),
      );
      if (!saved) {
        throw StateError('User skill profile preference write returned false.');
      }
      if (!mounted) return false;
      setState(() {
        _profile = updatedProfile;
      });
      return true;
    } catch (error, stackTrace) {
      logError(
        'Difficulty settings profile save failed: $error',
        stackTrace: stackTrace,
        tag: 'SettingsScreen',
      );
      if (!mounted) return false;
      AppFeedback.showError(
        context,
        "Couldn't save difficulty setting. Try again.",
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
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
            final saved = value == reducedMotion.systemPreference
                ? await ref
                      .read(reducedMotionProvider.notifier)
                      .setUserPreference(null)
                : await ref
                      .read(reducedMotionProvider.notifier)
                      .setUserPreference(value);

            if (!context.mounted) return;

            if (!saved) {
              AppFeedback.showError(
                context,
                'Couldn\'t save reduce motion preference. Try again.',
              );
              return;
            }

            if (value == reducedMotion.systemPreference) {
              AppFeedback.showInfo(context, 'Following system motion setting');
              return;
            }

            AppFeedback.showInfo(
              context,
              value
                  ? 'Reduced motion enabled - animations simplified'
                  : 'Reduced motion disabled - full animations',
            );
          },
        ),
        if (reducedMotion.systemPreference &&
            reducedMotion.userOverride == false)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              72,
              0,
              AppSpacing.md,
              AppSpacing.sm2,
            ),
            child: Text(
              'Your system has animations disabled, but you\'ve manually enabled them in this app.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (reducedMotion.isEnabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              72,
              0,
              AppSpacing.md,
              AppSpacing.sm2,
            ),
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

class _AnalyticsConsentToggle extends ConsumerStatefulWidget {
  const _AnalyticsConsentToggle();

  @override
  ConsumerState<_AnalyticsConsentToggle> createState() =>
      _AnalyticsConsentToggleState();
}

class _AnalyticsConsentToggleState
    extends ConsumerState<_AnalyticsConsentToggle> {
  bool _enabled = false;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final consent = prefs.getBool(kGdprAnalyticsConsentKey) ?? false;
    if (mounted) {
      setState(() {
        _enabled = consent;
        _loaded = true;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    if (_saving) return;

    final previous = _enabled;
    setState(() => _saving = true);

    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      final saved = await prefs.setBool(kGdprAnalyticsConsentKey, value);
      if (!saved) {
        throw StateError(
          'SharedPreferences returned false for $kGdprAnalyticsConsentKey',
        );
      }
      await applyAnalyticsConsent(value);
      if (!mounted) return;
      setState(() {
        _enabled = value;
        _saving = false;
      });
    } catch (e, stackTrace) {
      appLog(
        'SettingsScreen: crash report consent save failed: $e\n$stackTrace',
        tag: 'SettingsScreen',
      );
      if (!mounted) return;
      setState(() {
        _enabled = previous;
        _saving = false;
      });
      AppFeedback.showError(
        context,
        "Couldn't update crash reports. Try again.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox.shrink();
    return SwitchListTile(
      secondary: const Icon(Icons.bug_report_outlined),
      title: const Text('Crash Reports'),
      subtitle: const Text('Share crash diagnostics to help fix bugs'),
      value: _enabled,
      onChanged: _saving ? null : _toggle,
    );
  }
}

// ---------------------------------------------------------------------------
// Smart Hub - optional AI tile
// ---------------------------------------------------------------------------

class _ConfigureAiTile extends ConsumerStatefulWidget {
  const _ConfigureAiTile();

  @override
  ConsumerState<_ConfigureAiTile> createState() => _ConfigureAiTileState();
}

class _ConfigureAiTileState extends ConsumerState<_ConfigureAiTile> {
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
    final hasProxy = AiProxyService.hasProxy;
    final proxyReady = AiProxyService.proxyAuthToken.isNotEmpty;

    return AppListTile(
      leading: const Icon(Icons.smart_toy_outlined),
      title: 'Optional AI',
      subtitle: hasProxy
          ? (proxyReady
                ? 'Danio-managed AI active'
                : 'Optional AI is not ready in this version of Danio')
          : (_hasUserKey
                ? 'Custom API key active - tap to manage'
                : 'Smart Hub works locally; add a key for photo ID and Ask Danio'),
      trailing: hasProxy
          ? Icon(
              proxyReady ? Icons.check_circle : Icons.error_outline,
              color: proxyReady ? AppColors.success : AppColors.warning,
            )
          : _hasUserKey
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : null,
      onTap: () => _showConfigureAiDialog(context),
    );
  }

  Future<void> _showConfigureAiDialog(BuildContext context) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (!context.mounted) return;
    await _ConfigureAiDialog.show(context, prefs, () {
      _reload();
      ref.invalidate(aiProxyHasKeyProvider);
      ref.invalidate(openAIConfiguredProvider);
    });
  }
}

class _ConfigureAiDialog extends StatefulWidget {
  final SharedPreferences prefs;
  final VoidCallback onDismissed;

  const _ConfigureAiDialog({required this.prefs, required this.onDismissed});

  static Future<void> show(
    BuildContext context,
    SharedPreferences prefs,
    VoidCallback onDismissed,
  ) {
    return showDialog<void>(
      context: context,
      builder: (ctx) =>
          _ConfigureAiDialog(prefs: prefs, onDismissed: onDismissed),
    );
  }

  @override
  State<_ConfigureAiDialog> createState() => _ConfigureAiDialogState();
}

class _ConfigureAiDialogState extends State<_ConfigureAiDialog> {
  final _controller = TextEditingController();
  bool _obscureText = true;
  bool _isBusy = false;
  bool _hasUserKey = false;
  bool _aiDisclosureAccepted = false;
  String? _statusMessage;
  bool _statusIsError = false;

  bool get _hasProxy => AiProxyService.hasProxy;
  bool get _proxyReady => AiProxyService.proxyAuthToken.isNotEmpty;

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
    final disclosureAccepted = AiDisclosurePreferences.isAccepted(widget.prefs);
    if (mounted) {
      setState(() {
        _hasUserKey = hasKey;
        _aiDisclosureAccepted = disclosureAccepted;
      });
    }
  }

  Future<void> _saveKey() async {
    if (_hasProxy) return;

    final key = _controller.text.trim();
    if (key.isEmpty) {
      setState(() {
        _statusMessage = 'Enter an OpenAI API key first.';
        _statusIsError = true;
      });
      return;
    }
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
          _statusMessage = 'Key saved. Optional AI tools are active.';
          _statusIsError = false;
          _isBusy = false;
        });
        _controller.clear();
      }
    } catch (e, st) {
      logError(
        'SettingsScreen: API key save failed: $e',
        stackTrace: st,
        tag: 'SettingsScreen',
      );
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
    if (_hasProxy) return;

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
      logError(
        'SettingsScreen: API key clear failed: $e',
        stackTrace: st,
        tag: 'SettingsScreen',
      );
      if (mounted) {
        setState(() {
          _statusMessage = 'Couldn\'t clear the key. Try again.';
          _statusIsError = true;
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _resetAiDisclosure() async {
    setState(() => _isBusy = true);
    try {
      await AiDisclosurePreferences.reset(widget.prefs);
      if (mounted) {
        setState(() {
          _aiDisclosureAccepted = false;
          _statusMessage =
              'AI disclosure will be shown again before Optional AI sends data.';
          _statusIsError = false;
          _isBusy = false;
        });
      }
    } catch (e, st) {
      logError(
        'SettingsScreen: AI disclosure reset failed: $e',
        stackTrace: st,
        tag: 'SettingsScreen',
      );
      if (mounted) {
        setState(() {
          _statusMessage = 'Couldn\'t reset the disclosure. Try again.';
          _statusIsError = true;
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: 'Optional AI',
      actions: [
        if (!_hasProxy && _hasUserKey) ...[
          AppButton(
            label: 'Remove key',
            onPressed: _isBusy ? null : _clearKey,
            variant: AppButtonVariant.destructive,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        if (_aiDisclosureAccepted) ...[
          AppButton(
            label: 'Reset AI disclosure',
            onPressed: _isBusy ? null : _resetAiDisclosure,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        AppButton(
          label: 'Review AI privacy',
          onPressed: _isBusy
              ? null
              : () => NavigationThrottle.push(
                  context,
                  const PrivacyPolicyScreen(),
                ),
          variant: AppButtonVariant.secondary,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.xs),
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
        if (!_hasProxy)
          AppButton(
            label: 'Save',
            onPressed: _isBusy ? null : _saveKey,
            isLoading: _isBusy,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),
      ],
      child: SingleChildScrollView(
        child: _hasProxy
            ? _ProxyAiStatus(isReady: _proxyReady)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Local Smart Hub checks work without AI. Your key is stored on this device and never shared with us.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const _AiProviderStatusCard(),
                  const SizedBox(height: AppSpacing.md),
                  _AiDisclosurePreferenceStatus(
                    isAccepted: _aiDisclosureAccepted,
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
                        tooltip: _obscureText
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                        color: _statusIsError
                            ? AppColors.error
                            : AppColors.success,
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

class _AiProviderStatusCard extends StatelessWidget {
  const _AiProviderStatusCard();

  static const _targetProviders = [
    'Anthropic',
    'Google Gemini',
    'OpenRouter',
    'Mistral',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm2),
      decoration: BoxDecoration(
        color: AppColors.primaryAlpha05,
        borderRadius: AppRadius.md2Radius,
        border: Border.all(color: AppColors.primaryAlpha15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended provider',
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OpenAI',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Current bring-your-own key provider',
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
          Text(
            'Provider targets',
            style: AppTypography.labelMedium.copyWith(
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          for (final provider in _targetProviders) ...[
            _ProviderTargetRow(provider: provider),
            if (provider != _targetProviders.last)
              const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _ProviderTargetRow extends StatelessWidget {
  const _ProviderTargetRow({required this.provider});

  final String provider;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.radio_button_unchecked, color: context.textHint, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Not available for local keys in this version',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProxyAiStatus extends StatelessWidget {
  const _ProxyAiStatus({required this.isReady});

  final bool isReady;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isReady ? Icons.shield_outlined : Icons.error_outline,
          color: isReady ? AppColors.success : AppColors.warning,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            isReady
                ? 'Danio-managed Optional AI is active. No OpenAI API key is stored on this device.'
                : OpenAIUserMessages.proxyUnavailable,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AiDisclosurePreferenceStatus extends StatelessWidget {
  const _AiDisclosurePreferenceStatus({required this.isAccepted});

  final bool isAccepted;

  @override
  Widget build(BuildContext context) {
    final color = isAccepted ? AppColors.success : AppColors.info;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm2),
      decoration: BoxDecoration(
        color: isAccepted ? AppColors.successAlpha10 : AppColors.infoAlpha10,
        borderRadius: AppRadius.md2Radius,
        border: Border.all(
          color: isAccepted ? AppColors.successAlpha30 : AppColors.infoAlpha30,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isAccepted ? Icons.verified_user_outlined : Icons.info_outline,
            color: color,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAccepted
                      ? 'AI disclosure accepted'
                      : 'AI disclosure not accepted yet',
                  style: AppTypography.labelMedium.copyWith(
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isAccepted
                      ? 'Danio will not show the disclosure again unless you reset it.'
                      : 'Danio will ask before Optional AI sends photos, text, or tank context.',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
