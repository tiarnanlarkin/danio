/// League ranking and week period models
library;

/// League tier for competitive ranking
enum League {
  bronze,
  silver,
  gold,
  diamond;

  String get displayName {
    switch (this) {
      case League.bronze:
        return 'Bronze League';
      case League.silver:
        return 'Silver League';
      case League.gold:
        return 'Gold League';
      case League.diamond:
        return 'Diamond League';
    }
  }

  String get emoji {
    switch (this) {
      case League.bronze:
        return '🥉';
      case League.silver:
        return '🥈';
      case League.gold:
        return '🥇';
      case League.diamond:
        return '💎';
    }
  }

  String get colorHex {
    switch (this) {
      case League.bronze:
        return '#CD7F32';
      case League.silver:
        return '#C0C0C0';
      case League.gold:
        return '#FFD700';
      case League.diamond:
        return '#B9F2FF';
    }
  }

  /// XP threshold to enter this league
  int get minWeeklyXP {
    switch (this) {
      case League.bronze:
        return 0;
      case League.silver:
        return 300;
      case League.gold:
        return 800;
      case League.diamond:
        return 1500;
    }
  }

  String toJson() => name;

  static League fromJson(String value) {
    return League.values.firstWhere(
      (e) => e.name == value,
      orElse: () => League.bronze,
    );
  }
}

/// Weekly competition period
class WeekPeriod {
  final DateTime start;
  final DateTime end;

  const WeekPeriod({required this.start, required this.end});

  /// Get current week period (Monday 00:00 to Sunday 23:59)
  static WeekPeriod current() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);
    final end = start
        .add(const Duration(days: 7))
        .subtract(const Duration(microseconds: 1));
    return WeekPeriod(start: start, end: end);
  }
}
