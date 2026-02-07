/// Wave 3 Features - Interactive Demo Screen
/// 
/// This screen demonstrates all 6 Wave 3 features in action:
/// 1. Adaptive Difficulty System
/// 2. Achievement System
/// 3. Hearts/Lives System
/// 4. Spaced Repetition System
/// 5. Analytics Dashboard
/// 6. Social/Friends Features
///
/// Use this as a reference implementation or integrate directly into your app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/models/adaptive_difficulty.dart';
import 'package:aquarium_app/models/achievements.dart';
import 'package:aquarium_app/models/spaced_repetition.dart';
import 'package:aquarium_app/services/difficulty_service.dart';
import 'package:aquarium_app/widgets/difficulty_badge.dart';
import 'package:aquarium_app/widgets/hearts_widgets.dart';
import 'package:aquarium_app/widgets/achievement_card.dart';
import 'package:aquarium_app/widgets/achievement_notification.dart';
import 'package:aquarium_app/data/achievements.dart' as achievement_data;
import 'dart:math' as math;

class Wave3DemoScreen extends ConsumerStatefulWidget {
  const Wave3DemoScreen({super.key});

  @override
  ConsumerState<Wave3DemoScreen> createState() => _Wave3DemoScreenState();
}

class _Wave3DemoScreenState extends ConsumerState<Wave3DemoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo state
  int _demoHearts = 5;
  DifficultyLevel _demoDifficulty = DifficultyLevel.medium;
  double _demoSkillLevel = 0.65;
  int _demoCorrectAnswers = 0;
  int _demoIncorrectAnswers = 0;
  final List<String> _unlockedAchievements = [];
  int _demoXP = 1250;
  int _demoStreak = 5;
  final Map<String, int> _dailyXP = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _initializeDemoData();
  }

  void _initializeDemoData() {
    // Initialize demo daily XP for last 7 days
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      _dailyXP[dateKey] = math.Random().nextInt(150) + 50;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wave 3 Features Demo'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.insights), text: 'Difficulty'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
            Tab(icon: Icon(Icons.favorite), text: 'Hearts'),
            Tab(icon: Icon(Icons.refresh), text: 'Reviews'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.people), text: 'Social'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDifficultyDemo(),
          _buildAchievementsDemo(),
          _buildHeartsDemo(),
          _buildSpacedRepetitionDemo(),
          _buildAnalyticsDemo(),
          _buildSocialDemo(),
        ],
      ),
    );
  }

  // ============================================================================
  // Feature 1: Adaptive Difficulty Demo
  // ============================================================================

  Widget _buildDifficultyDemo() {
    final difficultyService = DifficultyService();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          icon: Icons.insights,
          title: 'Adaptive Difficulty System',
          subtitle: 'AI-powered difficulty adjustment',
        ),
        const SizedBox(height: 16),

        // Current Difficulty Display
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Difficulty',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Center(
                  child: DifficultyBadge(
                    difficulty: _demoDifficulty,
                    size: 2.0,
                    showLabel: true,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  difficultyService.getDifficultyDescription(_demoDifficulty),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Skill Level Indicator
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Skill Level',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: _demoSkillLevel,
                        minHeight: 20,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getSkillLevelColor(_demoSkillLevel),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(_demoSkillLevel * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getSkillLevelLabel(_demoSkillLevel),
                  style: TextStyle(
                    color: _getSkillLevelColor(_demoSkillLevel),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Interactive Demo
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Try it Out!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Answer questions to see difficulty adapt',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: _handleCorrectAnswer,
                        icon: const Icon(Icons.check),
                        label: const Text('Correct Answer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: _handleIncorrectAnswer,
                        icon: const Icon(Icons.close),
                        label: const Text('Wrong Answer'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Correct: $_demoCorrectAnswers | Incorrect: $_demoIncorrectAnswers',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // All Difficulty Levels
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Difficulty Levels',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...DifficultyLevel.values.map((level) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          DifficultyBadge(difficulty: level),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  difficultyService.getDifficultyName(level),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  difficultyService
                                      .getDifficultyDescription(level),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleCorrectAnswer() {
    setState(() {
      _demoCorrectAnswers++;

      // Increase skill level
      _demoSkillLevel = math.min(1.0, _demoSkillLevel + 0.05);

      // Adjust difficulty after 3 consecutive correct
      if (_demoCorrectAnswers % 3 == 0 && _demoDifficulty != DifficultyLevel.expert) {
        _demoDifficulty = DifficultyLevel.values[_demoDifficulty.index + 1];
        _showDifficultyChangeSnackBar(true);
      }
    });
  }

  void _handleIncorrectAnswer() {
    setState(() {
      _demoIncorrectAnswers++;

      // Decrease skill level
      _demoSkillLevel = math.max(0.0, _demoSkillLevel - 0.08);

      // Adjust difficulty after 3 incorrect
      if (_demoIncorrectAnswers % 3 == 0 && _demoDifficulty != DifficultyLevel.easy) {
        _demoDifficulty = DifficultyLevel.values[_demoDifficulty.index - 1];
        _showDifficultyChangeSnackBar(false);
      }
    });
  }

  void _showDifficultyChangeSnackBar(bool increased) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          increased
              ? '🎯 Great job! Difficulty increased to ${DifficultyService().getDifficultyName(_demoDifficulty)}'
              : '💡 Let\'s try an easier level: ${DifficultyService().getDifficultyName(_demoDifficulty)}',
        ),
        backgroundColor: increased ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _getSkillLevelColor(double skill) {
    if (skill >= 0.8) return Colors.green;
    if (skill >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getSkillLevelLabel(double skill) {
    if (skill >= 0.9) return 'Mastered';
    if (skill >= 0.7) return 'Proficient';
    if (skill >= 0.5) return 'Familiar';
    if (skill >= 0.3) return 'Learning';
    return 'Beginner';
  }

  // ============================================================================
  // Feature 2: Achievements Demo
  // ============================================================================

  Widget _buildAchievementsDemo() {
    final achievements = achievement_data.Achievements.all;
    final unlockedCount = _unlockedAchievements.length;
    final completionPercentage = (unlockedCount / achievements.length * 100);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          icon: Icons.emoji_events,
          title: 'Achievement System',
          subtitle: '47 achievements across 5 categories',
        ),
        const SizedBox(height: 16),

        // Progress Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.amber, size: 48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$unlockedCount / ${achievements.length} unlocked',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: completionPercentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.amber),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${completionPercentage.toStringAsFixed(0)}% complete',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Demo Actions
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Try Unlocking!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _unlockRandomAchievement,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Unlock Random Achievement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Achievement Categories
        const Text(
          'Achievement Categories',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...AchievementCategory.values.map((category) {
          final categoryAchievements = achievements
              .where((a) => a.category == category)
              .toList();
          final categoryUnlocked = categoryAchievements
              .where((a) => _unlockedAchievements.contains(a.id))
              .length;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(_getCategoryIcon(category)),
              title: Text(_getCategoryName(category)),
              subtitle: Text(
                '$categoryUnlocked / ${categoryAchievements.length} unlocked',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryAchievements.take(6).map((achievement) {
                      final isUnlocked =
                          _unlockedAchievements.contains(achievement.id);
                      return AchievementCard(
                        achievement: achievement,
                        isUnlocked: isUnlocked,
                        onTap: () => _showAchievementDetail(achievement, isUnlocked),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _unlockRandomAchievement() {
    final achievements = achievement_data.Achievements.all;
    final locked = achievements
        .where((a) => !_unlockedAchievements.contains(a.id))
        .toList();

    if (locked.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All achievements unlocked! 🎉')),
      );
      return;
    }

    final random = math.Random();
    final achievement = locked[random.nextInt(locked.length)];

    setState(() {
      _unlockedAchievements.add(achievement.id);
      _demoXP += _getXPForRarity(achievement.rarity);
    });

    // Show notification
    AchievementNotification.show(
      context,
      achievement,
      _getXPForRarity(achievement.rarity),
    );
  }

  int _getXPForRarity(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.bronze:
        return 50;
      case AchievementRarity.silver:
        return 100;
      case AchievementRarity.gold:
        return 150;
      case AchievementRarity.platinum:
        return 200;
    }
  }

  void _showAchievementDetail(Achievement achievement, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(achievement.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 64),
              ),
            ),
            const SizedBox(height: 16),
            Text(achievement.description),
            const SizedBox(height: 12),
            Text(
              'Rarity: ${achievement.rarity.name.toUpperCase()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _getRarityColor(achievement.rarity),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'XP Reward: ${_getXPForRarity(achievement.rarity)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (!isUnlocked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, size: 16),
                    SizedBox(width: 8),
                    Text('Not unlocked yet'),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.learningProgress:
        return Icons.school;
      case AchievementCategory.streaks:
        return Icons.local_fire_department;
      case AchievementCategory.xpMilestones:
        return Icons.auto_awesome;
      case AchievementCategory.special:
        return Icons.star;
      case AchievementCategory.engagement:
        return Icons.favorite;
    }
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.learningProgress:
        return 'Learning Progress';
      case AchievementCategory.streaks:
        return 'Streaks';
      case AchievementCategory.xpMilestones:
        return 'XP Milestones';
      case AchievementCategory.special:
        return 'Special';
      case AchievementCategory.engagement:
        return 'Engagement';
    }
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.bronze:
        return const Color(0xFFCD7F32);
      case AchievementRarity.silver:
        return const Color(0xFFC0C0C0);
      case AchievementRarity.gold:
        return const Color(0xFFFFD700);
      case AchievementRarity.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  // ============================================================================
  // Feature 3: Hearts/Lives Demo
  // ============================================================================

  Widget _buildHeartsDemo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          icon: Icons.favorite,
          title: 'Hearts/Lives System',
          subtitle: 'Duolingo-style mistake limiting',
        ),
        const SizedBox(height: 16),

        // Current Hearts Display
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Your Hearts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                HeartsDisplay(
                  hearts: _demoHearts,
                  maxHearts: 5,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '$_demoHearts / 5 hearts remaining',
                  style: TextStyle(
                    fontSize: 16,
                    color: _getHeartsColor(_demoHearts),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Demo Controls
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Try it Out!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: _demoHearts > 0 ? _loseHeart : null,
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Lose Heart'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.all(16),
                        ),
                        onPressed: _demoHearts < 5 ? _earnHeart : null,
                        icon: const Icon(Icons.favorite),
                        label: const Text('Earn Heart'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: _refillAllHearts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refill All Hearts'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Info Cards
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How Hearts Work',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.school,
                  title: 'Start with 5 hearts',
                  subtitle: 'Begin each quiz with full hearts',
                ),
                _buildInfoRow(
                  icon: Icons.close,
                  title: 'Lose 1 heart per mistake',
                  subtitle: 'Wrong answers cost hearts',
                ),
                _buildInfoRow(
                  icon: Icons.block,
                  title: 'Out of hearts?',
                  subtitle: 'Practice mode or wait to refill',
                ),
                _buildInfoRow(
                  icon: Icons.schedule,
                  title: 'Auto-refill',
                  subtitle: '1 heart every 5 hours',
                ),
                _buildInfoRow(
                  icon: Icons.fitness_center,
                  title: 'Practice mode',
                  subtitle: 'Earn hearts back safely',
                ),
              ],
            ),
          ),
        ),

        if (_demoHearts == 0) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Out of Hearts!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Complete a practice session to earn hearts, or wait for them to refill.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      _earnHeart();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Practice completed! +1 heart'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Practice Mode'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _loseHeart() {
    if (_demoHearts > 0) {
      setState(() => _demoHearts--);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lost a heart! $_demoHearts remaining'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _earnHeart() {
    if (_demoHearts < 5) {
      setState(() => _demoHearts++);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Earned a heart! $_demoHearts / 5'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _refillAllHearts() {
    setState(() => _demoHearts = 5);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All hearts refilled! ❤️'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Color _getHeartsColor(int hearts) {
    if (hearts >= 4) return Colors.green;
    if (hearts >= 2) return Colors.orange;
    return Colors.red;
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Feature 4: Spaced Repetition Demo
  // ============================================================================

  Widget _buildSpacedRepetitionDemo() {
    // Sample review cards for demo
    final demoCards = [
      _createDemoCard('Nitrogen Cycle', 0.85, ReviewInterval.week1, true),
      _createDemoCard('pH Levels', 0.65, ReviewInterval.day3, false),
      _createDemoCard('Water Changes', 0.40, ReviewInterval.day1, true),
      _createDemoCard('Filter Types', 0.90, ReviewInterval.week2, false),
      _createDemoCard('Plant Nutrients', 0.55, ReviewInterval.day3, false),
    ];

    final dueCards = demoCards.where((c) => c.isDue).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          icon: Icons.refresh,
          title: 'Spaced Repetition System',
          subtitle: 'Intelligent review scheduling',
        ),
        const SizedBox(height: 16),

        // Reviews Due Card
        Card(
          color: dueCards.isNotEmpty ? Colors.orange[50] : Colors.green[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  dueCards.isNotEmpty ? Icons.warning : Icons.check_circle,
                  color: dueCards.isNotEmpty ? Colors.orange : Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  '${dueCards.length} Review${dueCards.length == 1 ? '' : 's'} Due',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dueCards.isNotEmpty
                      ? 'Time to strengthen your knowledge!'
                      : 'All caught up! Great job!',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Review Cards List
        const Text(
          'Your Review Cards',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...demoCards.map((card) => _buildReviewCardWidget(card)),

        const SizedBox(height: 16),

        // Mastery Levels
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mastery Levels',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...MasteryLevel.values.reversed.map((level) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _getMasteryColor(level).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getMasteryIcon(level),
                              color: _getMasteryColor(level),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getMasteryName(level),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  _getMasteryDescription(level),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  ReviewCard _createDemoCard(
    String topic,
    double strength,
    ReviewInterval interval,
    bool isDue,
  ) {
    final now = DateTime.now();
    final nextReview = isDue ? now.subtract(const Duration(hours: 1)) : now.add(interval.duration);

    return ReviewCard(
      id: 'demo_${topic.toLowerCase().replaceAll(' ', '_')}',
      conceptId: topic,
      conceptType: ConceptType.lesson,
      strength: strength,
      lastReviewed: now.subtract(const Duration(days: 2)),
      nextReview: nextReview,
      reviewCount: 5,
      correctCount: 4,
      incorrectCount: 1,
      currentInterval: interval,
      history: [],
    );
  }

  Widget _buildReviewCardWidget(ReviewCard card) {
    final masteryLevel = card.masteryLevel;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getMasteryColor(masteryLevel).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getMasteryIcon(masteryLevel),
            color: _getMasteryColor(masteryLevel),
          ),
        ),
        title: Text(
          card.conceptId,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: card.strength,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getMasteryColor(masteryLevel),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(card.strength * 100).toInt()}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              card.isDue
                  ? 'Due now!'
                  : 'Next review: ${_formatNextReview(card.nextReview)}',
              style: TextStyle(
                color: card.isDue ? Colors.red : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: card.isDue
            ? const Icon(Icons.warning, color: Colors.orange)
            : null,
      ),
    );
  }

  String _formatNextReview(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays > 0) {
      return 'in ${difference.inDays} day${difference.inDays == 1 ? '' : 's'}';
    } else if (difference.inHours > 0) {
      return 'in ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'}';
    } else {
      return 'soon';
    }
  }

  Color _getMasteryColor(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return Colors.grey;
      case MasteryLevel.learning:
        return Colors.orange;
      case MasteryLevel.familiar:
        return Colors.blue;
      case MasteryLevel.proficient:
        return Colors.purple;
      case MasteryLevel.mastered:
        return Colors.green;
    }
  }

  IconData _getMasteryIcon(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return Icons.fiber_new;
      case MasteryLevel.learning:
        return Icons.school;
      case MasteryLevel.familiar:
        return Icons.lightbulb;
      case MasteryLevel.proficient:
        return Icons.star;
      case MasteryLevel.mastered:
        return Icons.emoji_events;
    }
  }

  String _getMasteryName(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return 'New';
      case MasteryLevel.learning:
        return 'Learning';
      case MasteryLevel.familiar:
        return 'Familiar';
      case MasteryLevel.proficient:
        return 'Proficient';
      case MasteryLevel.mastered:
        return 'Mastered';
    }
  }

  String _getMasteryDescription(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.new_:
        return 'Just starting to learn';
      case MasteryLevel.learning:
        return 'Building understanding';
      case MasteryLevel.familiar:
        return 'Getting comfortable';
      case MasteryLevel.proficient:
        return 'Strong knowledge';
      case MasteryLevel.mastered:
        return 'Expert level!';
    }
  }

  // ============================================================================
  // Feature 5: Analytics Demo
  // ============================================================================

  Widget _buildAnalyticsDemo() {
    final today = DateTime.now();
    final thisWeekXP = _dailyXP.values.reduce((a, b) => a + b);
    final avgDailyXP = (thisWeekXP / 7).round();
    final maxXP = _dailyXP.values.reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          icon: Icons.analytics,
          title: 'Analytics Dashboard',
          subtitle: 'Track your progress and insights',
        ),
        const SizedBox(height: 16),

        // Summary Cards
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.auto_awesome,
                label: 'Total XP',
                value: '$_demoXP',
                color: Colors.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_fire_department,
                label: 'Streak',
                value: '$_demoStreak days',
                color: Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                label: 'This Week',
                value: '$thisWeekXP XP',
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.schedule,
                label: 'Daily Avg',
                value: '$avgDailyXP XP',
                color: Colors.blue,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // XP Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily XP (Last 7 Days)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: _buildXPChart(maxXP),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Learning Insights
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Learning Insights',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildInsightItem(
                  icon: Icons.trending_up,
                  title: 'Great consistency!',
                  subtitle: 'You\'ve studied 5 days in a row',
                  color: Colors.green,
                ),
                _buildInsightItem(
                  icon: Icons.schedule,
                  title: 'Peak learning time',
                  subtitle: 'You learn best around 7:00 PM',
                  color: Colors.blue,
                ),
                _buildInsightItem(
                  icon: Icons.star,
                  title: 'Top topic',
                  subtitle: 'Water chemistry is your strongest area',
                  color: Colors.amber,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXPChart(int maxXP) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final date = DateTime.now().subtract(Duration(days: 6 - index));
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final xp = _dailyXP[dateKey] ?? 0;
        final height = (xp / maxXP * 150).clamp(20.0, 150.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$xp',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1],
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Feature 6: Social/Friends Demo
  // ============================================================================

  Widget _buildSocialDemo() {
    final demoFriends = [
      _createDemoFriend('Alex', 15, 2340, 8, true),
      _createDemoFriend('Sam', 12, 1890, 12, false),
      _createDemoFriend('Jordan', 18, 3120, 5, true),
      _createDemoFriend('Taylor', 10, 1450, 15, false),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader(
          icon: Icons.people,
          title: 'Social Features',
          subtitle: 'Connect and compete with friends',
        ),
        const SizedBox(height: 16),

        // Friends Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSocialStat(
                  icon: Icons.people,
                  label: 'Friends',
                  value: '${demoFriends.length}',
                ),
                _buildSocialStat(
                  icon: Icons.leaderboard,
                  label: 'Rank',
                  value: '#2',
                ),
                _buildSocialStat(
                  icon: Icons.emoji_events,
                  label: 'Wins',
                  value: '12',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Friends List
        const Text(
          'Your Friends',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...demoFriends.map((friend) => _buildFriendCard(friend)),

        const SizedBox(height: 16),

        // Leaderboard Preview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.leaderboard, color: Colors.amber),
                    SizedBox(width: 8),
                    Text(
                      'This Week\'s Leaderboard',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLeaderboardEntry(1, 'Jordan', 3120, true),
                _buildLeaderboardEntry(2, 'You', _demoXP, false, isCurrentUser: true),
                _buildLeaderboardEntry(3, 'Alex', 2340, false),
                _buildLeaderboardEntry(4, 'Sam', 1890, false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _createDemoFriend(
    String name,
    int level,
    int xp,
    int streak,
    bool isOnline,
  ) {
    return {
      'name': name,
      'level': level,
      'xp': xp,
      'streak': streak,
      'isOnline': isOnline,
    };
  }

  Widget _buildSocialStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildFriendCard(Map<String, dynamic> friend) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              child: Text(friend['name'][0]),
            ),
            if (friend['isOnline'])
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(friend['name']),
        subtitle: Text(
          'Level ${friend['level']} • ${friend['xp']} XP • ${friend['streak']} day streak',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildLeaderboardEntry(
    int rank,
    String name,
    int xp,
    bool showTrophy, {
    bool isCurrentUser = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue[50] : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Colors.amber : Colors.grey,
              ),
            ),
          ),
          if (showTrophy)
            Icon(
              Icons.emoji_events,
              color: rank == 1 ? Colors.amber : Colors.grey[400],
            ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            child: Text(name[0]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '$xp XP',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Helper Widgets
  // ============================================================================

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 32, color: Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
