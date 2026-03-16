import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/navigation_throttle.dart';
import '../widgets/common/common_widgets.dart';
import 'about_screen.dart';
import 'achievements_screen.dart';
import 'analytics_screen.dart';
import 'backup_restore_screen.dart';
import 'settings_screen.dart';
// friends_screen.dart — hidden until feature ships (CA-002)
// leaderboard_screen.dart — hidden until feature ships (CA-003)
import 'shop_street_screen.dart';
import 'workshop_screen.dart';

const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

/// Settings Hub - Consolidates all secondary features
/// This is Tab 3 in the new navigation structure
/// Includes: Profile, Friends, Leaderboard, Shop, Tools, Settings
class SettingsHubScreen extends ConsumerWidget {
  const SettingsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final items = _buildListItems(context, profile);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  List<Widget> _buildListItems(BuildContext context, profile) {
    return [
      // === Profile Card ===
      _buildProfileCard(context, profile),


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
          subtitle: 'Badges & achievements',
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
          iconColor: AppColors.primary, // BUG-10: was textSecondary (gray), now warm amber
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
        label: 'Backup and Restore, Back up and restore your data',
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 80),
          child: PrimaryActionTile(
            icon: Icons.backup,
            title: 'Backup & Restore',
            subtitle: 'Back up & restore your data',
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

      // === App Version Footer ===
      Center(
        child: Text(
          'Danio v$appVersion',
          style: AppTypography.bodySmall.copyWith(
            color: context.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
    ];
  }

  Widget _buildProfileCard(BuildContext context, profile) {
    final name = profile?.name ?? 'Aquarist';
    final level = profile?.currentLevel ?? 1;
    final xp = profile?.totalXp ?? 0;
    final streak = profile?.currentStreak ?? 0;
    return Semantics(
      label: '$name, Level $level, $xp XP, $streak day streak',
      child: CozyCard(
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: kAvatarSizeMd,
            backgroundColor: AppColors.primaryAlpha05,
            child: profile?.name != null && profile!.name.isNotEmpty
                ? Text(
                    profile.name[0].toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
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
                  profile?.name ?? 'Aquarist',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Level ${profile?.currentLevel ?? 1} • ${profile?.totalXp ?? 0} XP',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  // BUG-06: hide fire emoji when streak is 0
                  '${profile?.currentStreak ?? 0} day streak${(profile?.currentStreak ?? 0) > 0 ? " 🔥" : ""}',
                  style: AppTypography.bodySmall.copyWith(
                    color: (profile?.currentStreak ?? 0) > 0 ? AppColors.warning : context.textSecondary,
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
            color: AppColors.primary, // BUG-09: all section headers now use consistent warm amber
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
