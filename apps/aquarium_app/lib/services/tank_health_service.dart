/// Tank Health Score calculator
/// Computes a 0-100 health score based on water change frequency,
/// water parameter quality, and maintenance regularity.
library;

import '../models/log_entry.dart';
import '../models/tank.dart';

class TankHealthScore {
  final int score;
  final String label;
  final String emoji;
  final TankHealthLevel level;
  final List<String> factors;

  const TankHealthScore({
    required this.score,
    required this.label,
    required this.emoji,
    required this.level,
    required this.factors,
  });
}

enum TankHealthLevel { excellent, good, fair, poor }

class TankHealthService {
  /// Calculate a 0-100 health score for a tank based on its logs.
  ///
  /// Scoring breakdown (100 total):
  /// - Water change recency: 0-35 points
  /// - Water parameter quality: 0-40 points
  /// - Logging regularity: 0-25 points
  static TankHealthScore calculateScore({
    required Tank tank,
    required List<LogEntry> logs,
  }) {
    final now = DateTime.now();
    final factors = <String>[];

    // --- 1. Water change recency (35 points) ---
    final waterChanges =
        logs.where((l) => l.type == LogType.waterChange).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int waterChangeScore;
    if (waterChanges.isEmpty) {
      waterChangeScore = 0;
      factors.add('No water changes logged yet');
    } else {
      final daysSince = now.difference(waterChanges.first.timestamp).inDays;
      if (daysSince <= 7) {
        waterChangeScore = 35;
        factors.add(
          'Water changed ${daysSince == 0 ? "today" : "$daysSince days ago"}',
        );
      } else if (daysSince <= 10) {
        waterChangeScore = 25;
        factors.add('Water change due — last one was $daysSince days ago');
      } else if (daysSince <= 14) {
        waterChangeScore = 15;
        factors.add(
          'Water change overdue — $daysSince days since the last one',
        );
      } else {
        waterChangeScore = 5;
        factors.add(
          'Water change very overdue — $daysSince days and counting!',
        );
      }
    }

    // --- 2. Water parameter quality (40 points) ---
    final waterTests =
        logs
            .where((l) => l.type == LogType.waterTest && l.waterTest != null)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int paramScore;
    if (waterTests.isEmpty) {
      paramScore = 20; // Neutral - no data
      factors.add('No water tests logged yet');
    } else {
      final latest = waterTests.first.waterTest!;
      final daysSinceTest = now.difference(waterTests.first.timestamp).inDays;

      // Stale test penalty
      if (daysSinceTest > 14) {
        paramScore = 15;
        factors.add(
          'Last water test was $daysSinceTest days ago — time for a fresh one!',
        );
      } else {
        int paramPoints = 0;
        int paramCount = 0;

        // Check ammonia (should be 0)
        if (latest.ammonia != null) {
          paramCount++;
          if (latest.ammonia! <= 0.0) {
            paramPoints += 10;
          } else if (latest.ammonia! <= 0.25) {
            paramPoints += 5;
            factors.add('Ammonia slightly elevated (${latest.ammonia} ppm)');
          } else {
            factors.add(
              'Ammonia at dangerous levels (${latest.ammonia} ppm) — act quickly!',
            );
          }
        }

        // Check nitrite (should be 0)
        if (latest.nitrite != null) {
          paramCount++;
          if (latest.nitrite! <= 0.0) {
            paramPoints += 10;
          } else if (latest.nitrite! <= 0.25) {
            paramPoints += 5;
            factors.add('Nitrite slightly elevated (${latest.nitrite} ppm)');
          } else {
            factors.add(
              'Nitrite at dangerous levels (${latest.nitrite} ppm) — act quickly!',
            );
          }
        }

        // Check nitrate (< 40 ideal, < 80 okay)
        if (latest.nitrate != null) {
          paramCount++;
          if (latest.nitrate! <= 20) {
            paramPoints += 10;
          } else if (latest.nitrate! <= 40) {
            paramPoints += 7;
          } else if (latest.nitrate! <= 80) {
            paramPoints += 3;
            factors.add('Nitrate high (${latest.nitrate} ppm)');
          } else {
            factors.add('Nitrate very high (${latest.nitrate} ppm)');
          }
        }

        // Check pH (in range for tank targets)
        if (latest.ph != null) {
          paramCount++;
          final phMin = tank.targets.phMin ?? 6.0;
          final phMax = tank.targets.phMax ?? 8.0;
          if (latest.ph! >= phMin && latest.ph! <= phMax) {
            paramPoints += 10;
          } else if (latest.ph! >= phMin - 0.5 && latest.ph! <= phMax + 0.5) {
            paramPoints += 5;
            factors.add('pH slightly out of range (${latest.ph})');
          } else {
            factors.add('pH out of range (${latest.ph})');
          }
        }

        if (paramCount == 0) {
          paramScore = 20; // No params tested
          factors.add('Test more parameters for a more accurate score');
        } else {
          // Scale to 40 points max
          paramScore = (paramPoints / (paramCount * 10) * 40).round();
          if (paramScore >= 35) {
            factors.add('Water parameters look great');
          }
        }
      }
    }

    // --- 3. Logging regularity (25 points) ---
    // How many logs in the last 30 days?
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentLogs = logs
        .where((l) => l.timestamp.isAfter(thirtyDaysAgo))
        .length;

    int regularityScore;
    if (recentLogs >= 12) {
      regularityScore = 25;
      factors.add('Excellent logging habit ($recentLogs entries this month)');
    } else if (recentLogs >= 8) {
      regularityScore = 20;
    } else if (recentLogs >= 4) {
      regularityScore = 15;
      factors.add('Log more often for richer insights');
    } else if (recentLogs >= 1) {
      regularityScore = 8;
      factors.add('Try logging at least weekly');
    } else {
      regularityScore = 0;
      factors.add('No activity logged recently — your fish are waiting! 🐟');
    }

    // --- Total ---
    final total = waterChangeScore + paramScore + regularityScore;
    final clamped = total.clamp(0, 100);

    final TankHealthLevel level;
    final String label;
    final String emoji;

    if (clamped >= 80) {
      level = TankHealthLevel.excellent;
      label = 'Excellent';
      emoji = '\u{1F7E2}'; // green circle
    } else if (clamped >= 60) {
      level = TankHealthLevel.good;
      label = 'Good';
      emoji = '\u{1F7E1}'; // yellow circle
    } else if (clamped >= 40) {
      level = TankHealthLevel.fair;
      label = 'Needs Attention';
      emoji = '\u{1F7E0}'; // orange circle
    } else {
      level = TankHealthLevel.poor;
      label = 'At Risk';
      emoji = '\u{1F534}'; // red circle
    }

    return TankHealthScore(
      score: clamped,
      label: label,
      emoji: emoji,
      level: level,
      factors: factors,
    );
  }

  /// Calculate water change streak (consecutive weeks with at least one
  /// water change logged).
  static int calculateWaterChangeStreak(List<LogEntry> logs) {
    final waterChanges =
        logs.where((l) => l.type == LogType.waterChange).toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (waterChanges.isEmpty) return 0;

    final now = DateTime.now();
    // Normalise to Monday of this week
    final todayStart = DateTime(now.year, now.month, now.day);
    final currentMonday = todayStart.subtract(
      Duration(days: todayStart.weekday - 1),
    );

    int streak = 0;
    var checkWeekMonday = currentMonday;

    while (true) {
      final weekEnd = checkWeekMonday.add(const Duration(days: 7));
      final hasChangeThisWeek = waterChanges.any(
        (l) =>
            !l.timestamp.isBefore(checkWeekMonday) &&
            l.timestamp.isBefore(weekEnd),
      );

      if (hasChangeThisWeek) {
        streak++;
        checkWeekMonday = checkWeekMonday.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    return streak;
  }
}
