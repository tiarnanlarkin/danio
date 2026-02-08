/// Demo screen for testing XP animations and level-up dialog
/// This is for development/testing only - can be removed in production
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/xp_award_animation.dart';
import '../widgets/level_up_dialog.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_theme.dart';

class XpAnimationsDemoScreen extends ConsumerWidget {
  const XpAnimationsDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('XP Animations Demo'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Current stats
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Current Stats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Level ${profile.currentLevel}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        profile.levelTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${profile.totalXp} Total XP',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Text(
                  'Test Animations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // XP Animation buttons
                const Text(
                  'XP Award Animation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showXpAnimation(context, 10),
                      child: const Text('+10 XP'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showXpAnimation(context, 25),
                      child: const Text('+25 XP'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showXpAnimation(context, 50),
                      child: const Text('+50 XP'),
                    ),
                    ElevatedButton(
                      onPressed: () => _showXpAnimation(context, 100),
                      child: const Text('+100 XP'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Level-up dialog button
                const Text(
                  'Level Up Celebration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                ElevatedButton.icon(
                  onPressed: () => _showLevelUpDialog(context, profile),
                  icon: const Icon(Icons.celebration),
                  label: const Text('Show Level Up Dialog'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Add XP buttons (for testing level-up)
                const Text(
                  'Add XP to Profile (for testing)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton(
                      onPressed: () => _addXpToProfile(ref, 10),
                      child: const Text('+10 XP'),
                    ),
                    OutlinedButton(
                      onPressed: () => _addXpToProfile(ref, 50),
                      child: const Text('+50 XP'),
                    ),
                    OutlinedButton(
                      onPressed: () => _addXpToProfile(ref, 100),
                      child: const Text('+100 XP'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to Test',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Click XP buttons to see the floating animation\n'
                        '2. Click "Show Level Up" to preview the celebration\n'
                        '3. Add XP to your profile to test real level-ups\n'
                        '4. Complete quizzes to see animations in action',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  void _showXpAnimation(BuildContext context, int xpAmount) {
    XpAwardOverlay.show(
      context,
      xpAmount: xpAmount,
      onComplete: () {
        // Show snackbar when animation completes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('XP animation complete (+$xpAmount XP)'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }
  
  void _showLevelUpDialog(BuildContext context, dynamic profile) {
    LevelUpDialog.show(
      context,
      newLevel: profile.currentLevel + 1,
      levelTitle: _getNextLevelTitle(profile.currentLevel + 1),
      totalXp: profile.totalXp,
      unlockMessage: 'This is a demo of the level-up celebration!',
    );
  }
  
  Future<void> _addXpToProfile(WidgetRef ref, int xpAmount) async {
    await ref.read(userProfileProvider.notifier).addXp(xpAmount);
    
    // Show snackbar
    final context = ref.context;
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $xpAmount XP to profile!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  String _getNextLevelTitle(int level) {
    const levels = {
      0: 'Beginner',
      1: 'Novice',
      2: 'Hobbyist',
      3: 'Aquarist',
      4: 'Expert',
      5: 'Master',
      6: 'Guru',
    };
    return levels[level] ?? 'Legend';
  }
}
