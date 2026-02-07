import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard.dart';
import '../providers/leaderboard_provider.dart';
import '../theme/app_theme.dart';

/// Weekly leaderboard screen - Duolingo-style competition
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(weeklyLeaderboardProvider);

    return Scaffold(
      body: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading leaderboard: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(weeklyLeaderboardProvider.notifier).reload(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (leaderboard) {
          if (leaderboard == null) {
            return const Center(child: Text('No leaderboard data available'));
          }

          return CustomScrollView(
            slivers: [
              // === App Bar with League Badge ===
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: _getLeagueColor(leaderboard.league),
                flexibleSpace: FlexibleSpaceBar(
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        leaderboard.league.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        leaderboard.league.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getLeagueColor(leaderboard.league),
                          _getLeagueColor(leaderboard.league).withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            leaderboard.league.emoji,
                            style: const TextStyle(fontSize: 80),
                          ),
                          const SizedBox(height: 50), // Space for title
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // === Current User Status Card ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _CurrentUserStatusCard(leaderboard: leaderboard),
                ),
              ),

              // === Time Until Reset ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _TimeUntilResetCard(leaderboard: leaderboard),
                ),
              ),

              // === League Zones Legend ===
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _LeagueZonesLegend(league: leaderboard.league),
                ),
              ),

              // === Leaderboard Entries ===
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = leaderboard.entries[index];
                    final zone = _getZone(entry.rank, leaderboard.league);
                    
                    return _LeaderboardEntryTile(
                      entry: entry,
                      zone: zone,
                    );
                  },
                  childCount: leaderboard.entries.length,
                ),
              ),

              // === Bottom Padding ===
              const SliverToBoxAdapter(
                child: SizedBox(height: 80), // Space for bottom nav
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getLeagueColor(League league) {
    switch (league) {
      case League.bronze:
        return const Color(0xFFCD7F32);
      case League.silver:
        return const Color(0xFFC0C0C0);
      case League.gold:
        return const Color(0xFFFFD700);
      case League.diamond:
        return const Color(0xFF00CED1);
    }
  }

  _Zone _getZone(int rank, League league) {
    if (rank <= League.promotionThreshold && league != League.diamond) {
      return _Zone.promotion;
    } else if (rank > League.relegationSafeZone && league != League.bronze) {
      return _Zone.relegation;
    } else {
      return _Zone.safe;
    }
  }
}

enum _Zone { promotion, safe, relegation }

/// Current user status card
class _CurrentUserStatusCard extends StatelessWidget {
  final WeeklyLeaderboard leaderboard;

  const _CurrentUserStatusCard({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Rank',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '#${leaderboard.currentUserRank}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '/ ${leaderboard.entries.length}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Weekly XP',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${leaderboard.currentUserWeeklyXp} XP',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(leaderboard).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getStatusColor(leaderboard).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    leaderboard.statusMessage,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(leaderboard),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(WeeklyLeaderboard leaderboard) {
    if (leaderboard.currentUserRank == 1) {
      return const Color(0xFFFFD700); // Gold
    } else if (leaderboard.isInPromotionZone) {
      return Colors.green;
    } else if (leaderboard.isInRelegationZone) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}

/// Time until weekly reset
class _TimeUntilResetCard extends StatelessWidget {
  final WeeklyLeaderboard leaderboard;

  const _TimeUntilResetCard({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    final days = leaderboard.daysUntilReset;
    final hours = leaderboard.hoursUntilReset % 24;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_outlined, size: 20),
          const SizedBox(width: 8),
          Text(
            'Competition ends in $days days, $hours hours',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// League zones legend
class _LeagueZonesLegend extends StatelessWidget {
  final League league;

  const _LeagueZonesLegend({required this.league});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'League Zones',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (league != League.diamond)
              _ZoneLegendRow(
                color: Colors.green.shade100,
                icon: Icons.arrow_upward,
                iconColor: Colors.green,
                title: 'Promotion Zone',
                subtitle: 'Top 10 move up to ${_nextLeague(league).displayName}',
              ),
            const SizedBox(height: 8),
            _ZoneLegendRow(
              color: Colors.blue.shade50,
              icon: Icons.check_circle_outline,
              iconColor: Colors.blue,
              title: 'Safe Zone',
              subtitle: 'Ranks 11-15 stay in current league',
            ),
            if (league != League.bronze) ...[
              const SizedBox(height: 8),
              _ZoneLegendRow(
                color: Colors.orange.shade100,
                icon: Icons.arrow_downward,
                iconColor: Colors.orange,
                title: 'Relegation Zone',
                subtitle: 'Below rank 15 risk demotion to ${_previousLeague(league).displayName}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  League _nextLeague(League current) {
    final index = League.values.indexOf(current);
    return League.values[index + 1];
  }

  League _previousLeague(League current) {
    final index = League.values.indexOf(current);
    return League.values[index - 1];
  }
}

class _ZoneLegendRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ZoneLegendRow({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual leaderboard entry tile
class _LeaderboardEntryTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final _Zone zone;

  const _LeaderboardEntryTile({
    required this.entry,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withOpacity(0.1)
            : _getZoneColor(zone).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.primary
              : _getZoneColor(zone).withOpacity(0.2),
          width: entry.isCurrentUser ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: SizedBox(
          width: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (entry.rank <= 3)
                Text(
                  _getMedalEmoji(entry.rank),
                  style: const TextStyle(fontSize: 24),
                )
              else
                Text(
                  '#${entry.rank}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        title: Row(
          children: [
            Text(
              entry.avatarEmoji ?? '🐠',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                entry.displayName,
                style: TextStyle(
                  fontWeight: entry.isCurrentUser ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${entry.weeklyXp} XP',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '';
    }
  }

  Color _getZoneColor(_Zone zone) {
    switch (zone) {
      case _Zone.promotion:
        return Colors.green;
      case _Zone.safe:
        return Colors.blue;
      case _Zone.relegation:
        return Colors.orange;
    }
  }
}
