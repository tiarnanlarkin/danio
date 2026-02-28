import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/common_widgets.dart';
import 'settings_screen.dart';
import 'friends_screen.dart';
import 'leaderboard_screen.dart';
import 'shop_street_screen.dart';
import 'workshop_screen.dart';
import 'achievements_screen.dart';
import 'analytics_screen.dart';
import 'backup_restore_screen.dart';
import 'about_screen.dart';

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
        title: const Text('⚙️ Settings & More'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 80),
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

      // === Section: Community ===
      _buildSectionHeader('Community'),
      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.people,
        title: 'Friends',
        subtitle: 'Connect with other aquarium enthusiasts',
        iconColor: AppColors.primary,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FriendsScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.leaderboard,
        title: 'Leaderboard',
        subtitle: 'See how you rank among others',
        iconColor: AppColors.warning,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LeaderboardScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.lg),

      // === Section: Shop & Rewards ===
      _buildSectionHeader('Shop & Rewards'),
      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.storefront,
        title: 'Shop Street',
        subtitle: 'Browse local aquarium shops and deals',
        iconColor: AppColors.success,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShopStreetScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.emoji_events,
        title: 'Achievements',
        subtitle: 'View your badges and milestones',
        iconColor: AppColors.warning,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AchievementsScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.lg),

      // === Section: Tools ===
      _buildSectionHeader('Aquarium Tools'),
      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.build,
        title: 'Workshop',
        subtitle: 'Calculators, guides, and planning tools',
        iconColor: AppColors.info,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WorkshopScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.analytics,
        title: 'Analytics',
        subtitle: 'View your learning and tank statistics',
        iconColor: AppColors.primary,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnalyticsScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.lg),

      // === Section: App Settings ===
      _buildSectionHeader('App Settings'),
      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.tune,
        title: 'Preferences',
        subtitle: 'Theme, notifications, and more',
        iconColor: AppColors.textSecondary,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SettingsScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.backup,
        title: 'Backup & Restore',
        subtitle: 'Save and restore your data',
        iconColor: AppColors.info,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BackupRestoreScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.sm),

      PrimaryActionTile(
        icon: Icons.info,
        title: 'About',
        subtitle: 'App version, privacy, and support',
        iconColor: AppColors.textSecondary,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AboutScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: AppSpacing.xl),

      // === App Version Footer ===
      Center(
        child: Text(
          'Aquarium App v1.0.0',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.sm),
    ];
  }

  Widget _buildProfileCard(BuildContext context, profile) {
    return CozyCard(
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryAlpha05,
            child: profile?.name != null && profile!.name.isNotEmpty
                ? Text(
                    profile.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
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
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${profile?.currentStreak ?? 0} day streak 🔥',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Edit button
          IconButton(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.3,
        ).copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
