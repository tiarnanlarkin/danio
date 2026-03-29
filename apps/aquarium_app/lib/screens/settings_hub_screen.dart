import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/common/common_widgets.dart';
import '../widgets/first_visit_tooltip.dart';
import '../widgets/xp_progress_bar.dart';
import 'about_screen.dart';
import 'achievements_screen.dart';
import 'analytics_screen.dart';
import 'backup_restore_screen.dart';
import 'debug_menu_screen.dart';
import 'settings_screen.dart';
// friends_screen.dart — hidden until feature ships (CA-002)
// leaderboard_screen.dart — hidden until feature ships (CA-003)
import 'shop_street_screen.dart';
import 'workshop_screen.dart';

const String appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0',
);

/// Settings Hub - Consolidates all secondary features
/// This is Tab 3 in the new navigation structure
/// Includes: Profile, Friends, Leaderboard, Shop, Tools, Settings
class SettingsHubScreen extends ConsumerStatefulWidget {
  const SettingsHubScreen({super.key});

  @override
  ConsumerState<SettingsHubScreen> createState() => _SettingsHubScreenState();
}

class _SettingsHubScreenState extends ConsumerState<SettingsHubScreen> {
  bool _showTooltip = true;

  // ── Debug menu tap gate ──────────────────────────────────────────────────
  int _versionTapCount = 0;
  DateTime? _firstVersionTap;

  @override
  void initState() {
    super.initState();
    _checkTooltip();
  }

  Future<void> _checkTooltip() async {
    final seen = await hasSeenTooltip('tooltip_seen_more', ref);
    if (mounted) setState(() => _showTooltip = !seen);
  }

  void _handleVersionTap() {
    if (!kDebugMode) return;

    final now = DateTime.now();
    if (_firstVersionTap == null ||
        now.difference(_firstVersionTap!).inSeconds > 3) {
      _versionTapCount = 1;
      _firstVersionTap = now;
    } else {
      _versionTapCount++;
    }

    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      _firstVersionTap = null;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DebugMenuScreen()),
      );
    }
  }
  // ── End debug menu tap gate ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider.select((p) => (p.value?.name, p.value?.currentLevel, p.value?.totalXp, p.value?.currentStreak)));
    final name = profile.$1 ?? 'Aquarist';
    final level = profile.$2 ?? 1;
    final xp = profile.$3 ?? 0;
    final streak = profile.$4 ?? 0;
    final items = _buildListItems(context, name, level, xp, streak);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  List<Widget> _buildListItems(BuildContext context, String name, int level, int xp, int streak) {
    return [
      if (_showTooltip)
        FirstVisitTooltip(
          prefsKey: 'tooltip_seen_more',
          emoji: '🧰',
          message: 'More — your toolbox for settings, profile, and extras!',
          onDismissed: () => setState(() => _showTooltip = false),
        ),

      // === Profile Card ===
      _buildProfileCard(context, name, level, xp, streak),

      const SizedBox(height: AppSpacing.lg),

      // === Section: Shop & Rewards ===
      _buildSectionHeader('Shop & Rewards'),
      const SizedBox(height: AppSpacing.sm),

      Semantics(
        button: true,
        label: 'Shop Street, Discover local aquarium shops',
        child: PrimaryActionTile(
          icon: Icons.storefront,
          title: 'Shop Street',
          subtitle: 'Discover local aquarium shops',
          iconColor: AppColors.success,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            NavigationThrottle.push(context, const ShopStreetScreen());
          },
        ),
      ),

      const SizedBox(height: AppSpacing.sm),

      Semantics(
        button: true,
        label: 'Achievements, Badges and achievements',
        child: PrimaryActionTile(
          icon: Icons.emoji_events,
          title: 'Achievements',
          subtitle: 'Your badges & milestones',
          iconColor: AppColors.warning,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            NavigationThrottle.push(context, const AchievementsScreen());
          },
        ),
      ),

      const SizedBox(height: AppSpacing.lg),

      // === Section: Tools ===
      _buildSectionHeader('Tank Tools'),
      const SizedBox(height: AppSpacing.sm),

      Semantics(
        button: true,
        label: 'Workshop, Calculators, guides and planners',
        child: PrimaryActionTile(
          icon: Icons.build,
          title: 'Workshop',
          subtitle: 'Calculators, guides & planners',
          iconColor: AppColors
              .primary, // BUG-10: was textSecondary (gray), now warm amber
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            NavigationThrottle.push(context, const WorkshopScreen());
          },
        ),
      ),

      const SizedBox(height: AppSpacing.sm),

      Semantics(
        button: true,
        label: 'Analytics, Progress charts and statistics',
        child: PrimaryActionTile(
          icon: Icons.analytics,
          title: 'Analytics',
          subtitle: 'Progress charts & statistics',
          iconColor: AppColors.primary,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            NavigationThrottle.push(context, const AnalyticsScreen());
          },
        ),
      ),

      const SizedBox(height: AppSpacing.lg),

      // === Section: App Settings ===
      _buildSectionHeader('App Settings'),
      const SizedBox(height: AppSpacing.sm),

      Semantics(
        button: true,
        label: 'Preferences, Theme, sounds and notifications',
        child: PrimaryActionTile(
          icon: Icons.tune,
          title: 'Preferences',
          subtitle: 'Theme, sounds & notifications',
          iconColor: context.textSecondary,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            NavigationThrottle.push(context, const SettingsScreen());
          },
        ),
      ),

      const SizedBox(height: AppSpacing.sm),

      // P3-003: wrap with ConstrainedBox so the card is never less than 80 px tall
      Semantics(
        button: true,
        label: 'Backup and Restore, Export or sync your aquarium data',
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: PrimaryActionTile(
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Export or sync your aquarium data',
            iconColor: context.textSecondary,
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              NavigationThrottle.push(context, const BackupRestoreScreen());
            },
          ),
        ),
      ),

      const SizedBox(height: AppSpacing.sm),

      Semantics(
        button: true,
        label: 'About, Version, privacy and support',
        child: PrimaryActionTile(
          icon: Icons.info,
          title: 'About',
          subtitle: 'Version, privacy & support',
          iconColor: context.textSecondary,
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            NavigationThrottle.push(context, const AboutScreen());
          },
        ),
      ),

      const SizedBox(height: AppSpacing.xl),

      // === App Version Footer (debug: tap 5x for debug menu) ===
      Center(
        child: GestureDetector(
          onTap: _handleVersionTap,
          child: Text(
            'Danio v$appVersion',
            style: AppTypography.bodySmall.copyWith(color: context.textSecondary),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
    ];
  }

  Widget _buildProfileCard(BuildContext context, String name, int level, int xp, int streak) {
    return Semantics(
      label: '$name, Level $level, $xp XP, $streak-day streak',
      child: CozyCard(
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: kAvatarSizeMd,
              backgroundColor: AppColors.primaryAlpha05,
              child: name.isNotEmpty
                  ? Text(
                      name[0].toUpperCase(),
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    )
                  : const Icon(
                      Icons.person,
                      size: AppIconSizes.lg,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Profile Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Level $level • $xp XP',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const XpProgressBar(
                    height: 8,
                    showLabels: false,
                    showLevel: false,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    // BUG-06: hide fire emoji when streak is 0
                    '$streak-day streak${streak > 0 ? " 🔥" : ""}',
                    style: AppTypography.bodySmall.copyWith(
                      color: streak > 0
                          ? AppColors.warning
                          : context.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.edit),
              onPressed: () {
                NavigationThrottle.push(context, const SettingsScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors
                .primary, // BUG-09: all section headers now use consistent warm amber
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
