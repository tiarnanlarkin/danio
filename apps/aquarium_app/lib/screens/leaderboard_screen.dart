import 'package:aquarium_app/theme/app_theme.dart';
import '../widgets/core/bubble_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../data/mock_leaderboard.dart';
import '../providers/user_profile_provider.dart';

/// Duolingo-style competitive leaderboard
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('No profile found')));
        }

        // Generate leaderboard with current user
        final entries = MockLeaderboard.generate(
          currentUserId: 'current_user',
          currentUsername: profile.name ?? 'You',
          currentUserXP: profile.weeklyXP,
          currentUserLeague: profile.league,
        );

        final currentWeek = WeekPeriod.current();
        final currentEntry = entries.firstWhere((e) => e.isCurrentUser);

        return _buildLeaderboard(
          context,
          entries,
          currentWeek,
          currentEntry,
          profile.league,
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: BubbleLoader())),
      error: (error, stack) =>
          Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildLeaderboard(
    BuildContext context,
    List<LeaderboardEntry> entries,
    WeekPeriod currentWeek,
    LeaderboardEntry currentEntry,
    League league,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard'), centerTitle: true),
      body: Column(
        children: [
          // Week timer and league header
          _buildHeader(context, currentWeek, currentEntry, league),

          // Promotion/demotion zones indicator
          _buildPromoInfo(context, currentEntry, entries.length, league),

          // Leaderboard list
          Expanded(
            child: ListView.builder(
              itemCount: entries.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return _buildLeaderboardTile(
                  context,
                  entry,
                  currentEntry,
                  league,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WeekPeriod week,
    LeaderboardEntry currentEntry,
    League league,
  ) {
    final timeLeft = week.timeRemaining;
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _leagueColors(league),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // League badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_leagueIcon(league), color: Colors.white, size: 32),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${league.displayName} League',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Countdown
          Text(
            'Competition ends in ${hours}h ${minutes}m',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoInfo(
    BuildContext context,
    LeaderboardEntry currentEntry,
    int totalUsers,
    League league,
  ) {
    final willPromote =
        currentEntry.rank <= LeagueThresholds.topPromotion &&
        league != League.diamond;
    final willDemote =
        currentEntry.rank > totalUsers - LeagueThresholds.bottomDemotion &&
        league != League.bronze;

    if (!willPromote && !willDemote) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: willPromote ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: AppRadius.smallRadius,
        border: Border.all(
          color: willPromote ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            willPromote ? Icons.arrow_upward : Icons.arrow_downward,
            color: willPromote ? Colors.green : Colors.red,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              willPromote
                  ? 'You\'re in the promotion zone! Finish top 3 to advance to ${_nextLeague(league)?.displayName} League!'
                  : 'You\'re at risk of demotion. Finish higher to stay in ${league.displayName} League!',
              style: TextStyle(
                color: willPromote
                    ? Colors.green.shade900
                    : Colors.red.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(
    BuildContext context,
    LeaderboardEntry entry,
    LeaderboardEntry currentEntry,
    League league,
  ) {
    final isTopThree = entry.rank <= 3;
    final isCurrentUser = entry.isCurrentUser;
    final isPromotionZone = entry.rank <= LeagueThresholds.topPromotion;
    final isDemotionZone = entry.rank > 50 - LeagueThresholds.bottomDemotion;

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          borderRadius: AppRadius.smallRadius,
          border: isCurrentUser
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
        ),
        child: ListTile(
          leading: SizedBox(
            width: 40,
            child: Center(
              child: isTopThree
                  ? Icon(
                      Icons.emoji_events,
                      color: _rankMedalColor(entry.rank),
                      size: 28,
                    )
                  : Text(
                      '${entry.rank}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  entry.displayName,
                  style: TextStyle(
                    fontWeight: isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (isCurrentUser)
                const Chip(
                  label: Text('YOU', style: TextStyle(fontSize: 10)),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          subtitle: Row(
            children: [
              Icon(_leagueIcon(league), size: 16, color: Colors.grey.shade600),
              const SizedBox(width: AppSpacing.xs),
              Text(league.displayName),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.weeklyXp} XP',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (isPromotionZone && league != League.diamond)
                const Icon(Icons.arrow_upward, color: Colors.green, size: 16)
              else if (isDemotionZone && league != League.bronze)
                const Icon(Icons.arrow_downward, color: Colors.red, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _leagueColors(League league) {
    switch (league) {
      case League.bronze:
        return [Colors.brown.shade300, Colors.brown.shade600];
      case League.silver:
        return [Colors.grey.shade300, Colors.grey.shade600];
      case League.gold:
        return [Colors.amber.shade300, Colors.amber.shade600];
      case League.diamond:
        return [Colors.cyan.shade300, Colors.cyan.shade600];
    }
  }

  IconData _leagueIcon(League league) {
    switch (league) {
      case League.bronze:
        return Icons.workspace_premium;
      case League.silver:
        return Icons.workspace_premium;
      case League.gold:
        return Icons.workspace_premium;
      case League.diamond:
        return Icons.diamond;
    }
  }

  Color _rankMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold medal
      case 2:
        return Colors.grey.shade400; // Silver medal
      case 3:
        return Colors.brown.shade300; // Bronze medal
      default:
        return Colors.grey;
    }
  }

  League? _nextLeague(League current) {
    final leagues = League.values;
    final index = leagues.indexOf(current);
    if (index < leagues.length - 1) {
      return leagues[index + 1];
    }
    return null;
  }
}
