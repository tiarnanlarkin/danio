import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';
import '../theme/room_identity.dart';
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
        title: const Text('🧥 Closet'),
        backgroundColor: RoomIdentity.closetTint,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) => items[index],
      ),
    );
  }

  List<Widget> _buildListItems(BuildContext context, profile) {
    return [
      // === Profile Card ===
      _buildProfileCard(context, profile),

      const SizedBox(height: 24),

      // === Section: Community ===
      _buildSectionHeader('Community'),
      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'Friends',
        subtitle: 'Connect with other aquarium enthusiasts',
        icon: Icons.people,
        iconColor: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FriendsScreen()),
          );
        },
      ),

      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'Leaderboard',
        subtitle: 'See how you rank among others',
        icon: Icons.leaderboard,
        iconColor: AppColors.warning,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
          );
        },
      ),

      const SizedBox(height: 24),

      // === Section: Shop & Rewards ===
      _buildSectionHeader('Shop & Rewards'),
      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'Shop Street',
        subtitle: 'Browse local aquarium shops and deals',
        icon: Icons.storefront,
        iconColor: AppColors.success,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShopStreetScreen()),
          );
        },
      ),

      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'Achievements',
        subtitle: 'View your badges and milestones',
        icon: Icons.emoji_events,
        iconColor: AppColors.warning,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AchievementsScreen()),
          );
        },
      ),

      const SizedBox(height: 24),

      // === Section: Tools ===
      _buildSectionHeader('Aquarium Tools'),
      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'Workshop',
        subtitle: 'Calculators, guides, and planning tools',
        icon: Icons.build,
        iconColor: RoomIdentity.workshopAccent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WorkshopScreen()),
          );
        },
      ),

      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'Analytics',
        subtitle: 'View your learning and tank statistics',
        icon: Icons.analytics,
        iconColor: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
          );
        },
      ),

      const SizedBox(height: 24),

      // === Section: App Settings ===
      _buildSectionHeader('App Settings'),
      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'Preferences',
        subtitle: 'Theme, notifications, and more',
        icon: Icons.tune,
        iconColor: AppColors.textSecondary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),

      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'Backup & Restore',
        subtitle: 'Save and restore your data',
        icon: Icons.backup,
        iconColor: AppColors.info,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BackupRestoreScreen(),
            ),
          );
        },
      ),

      const SizedBox(height: 8),

      _buildMenuCard(
        context,
        title: 'About',
        subtitle: 'App version, privacy, and support',
        icon: Icons.info,
        iconColor: AppColors.textSecondary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AboutScreen()),
          );
        },
      ),

      const SizedBox(height: 32),

      // === App Version Footer ===
      Center(
        child: Text(
          'Aquarium App v1.0.0',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _buildProfileCard(BuildContext context, profile) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withOpacity(0.1),
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
                      size: 32,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(width: 16),
            // Profile Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile?.name ?? 'Aquarist',
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${profile?.currentLevel ?? 1} • ${profile?.totalXp ?? 0} XP',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
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
              icon: const Icon(Icons.edit),
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
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: AppRadius.smallRadius,
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
