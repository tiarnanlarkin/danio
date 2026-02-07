import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/leaderboard.dart';
import '../models/user_profile.dart';
import 'user_profile_provider.dart';

/// Provider for weekly leaderboard
final weeklyLeaderboardProvider = StateNotifierProvider<LeaderboardNotifier, AsyncValue<WeeklyLeaderboard?>>((ref) {
  final notifier = LeaderboardNotifier(ref);
  
  // Listen to user profile changes to update weekly XP
  ref.listen<AsyncValue<UserProfile?>>(
    userProfileProvider,
    (previous, next) {
      next.whenData((profile) {
        if (profile != null) {
          notifier.updateFromUserProfile(profile);
        }
      });
    },
  );
  
  return notifier;
});

class LeaderboardNotifier extends StateNotifier<AsyncValue<WeeklyLeaderboard?>> {
  LeaderboardNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref ref;
  static const _key = 'leaderboard_user_data';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);
      
      LeaderboardUserData userData;
      if (json != null) {
        userData = LeaderboardUserData.fromJson(jsonDecode(json));
        
        // Check if weekly reset is needed
        if (_shouldResetWeek(userData.lastResetDate)) {
          userData = await _performWeeklyReset(userData);
        }
      } else {
        // First time - create initial data
        userData = LeaderboardUserData(
          lastResetDate: _getWeekStartDate(DateTime.now()),
        );
        await _save(userData);
      }
      
      // Generate leaderboard with mock data
      final leaderboard = _generateLeaderboard(userData);
      state = AsyncValue.data(leaderboard);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _save(LeaderboardUserData userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(userData.toJson()));
  }

  /// Check if it's Monday and week should reset
  bool _shouldResetWeek(DateTime lastReset) {
    final now = DateTime.now();
    final currentWeekStart = _getWeekStartDate(now);
    final lastWeekStart = _getWeekStartDate(lastReset);
    
    return currentWeekStart.isAfter(lastWeekStart);
  }

  /// Get the Monday 00:00 of the current week
  DateTime _getWeekStartDate(DateTime date) {
    final weekday = date.weekday; // Monday = 1, Sunday = 7
    final daysFromMonday = weekday - 1;
    final monday = date.subtract(Duration(days: daysFromMonday));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Get the Sunday 23:59 of the current week
  DateTime _getWeekEndDate(DateTime weekStart) {
    return weekStart.add(const Duration(days: 7)).subtract(const Duration(seconds: 1));
  }

  /// Perform weekly reset logic
  Future<LeaderboardUserData> _performWeeklyReset(LeaderboardUserData oldData) async {
    // Determine promotion/relegation based on final rank
    // For mock implementation, we'll simulate a random outcome
    final random = Random();
    final finalRank = random.nextInt(50) + 1; // Random rank 1-50
    
    League newLeague = oldData.currentLeague;
    bool promoted = false;
    bool relegated = false;
    int bonusXp = 0;
    
    // Promotion logic (top 10)
    if (finalRank <= League.promotionThreshold && oldData.currentLeague != League.diamond) {
      newLeague = League.values[oldData.currentLeague.index + 1];
      promoted = true;
      bonusXp = newLeague.promotionXp;
    }
    // Relegation logic (bottom 35, i.e., rank > 15)
    else if (finalRank > League.relegationSafeZone && oldData.currentLeague != League.bronze) {
      newLeague = League.values[oldData.currentLeague.index - 1];
      relegated = true;
    }
    
    // Award bonus XP for promotion
    if (bonusXp > 0) {
      final userProfileNotifier = ref.read(userProfileProvider.notifier);
      await userProfileNotifier.addXp(bonusXp);
    }
    
    final newData = LeaderboardUserData(
      currentLeague: newLeague,
      weeklyXpTotal: 0,
      lastResetDate: _getWeekStartDate(DateTime.now()),
      dailyXpThisWeek: {},
      previousLeague: oldData.currentLeague,
      justPromoted: promoted,
      justRelegated: relegated,
    );
    
    await _save(newData);
    return newData;
  }

  /// Update leaderboard when user earns XP
  Future<void> updateFromUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    
    if (json == null) {
      await _load();
      return;
    }
    
    var userData = LeaderboardUserData.fromJson(jsonDecode(json));
    
    // Check for weekly reset
    if (_shouldResetWeek(userData.lastResetDate)) {
      userData = await _performWeeklyReset(userData);
    }
    
    // Calculate this week's XP from user profile
    final weekStart = _getWeekStartDate(DateTime.now());
    int weeklyXp = 0;
    final Map<String, int> dailyXpThisWeek = {};
    
    profile.dailyXpHistory.forEach((dateStr, xp) {
      final date = DateTime.parse(dateStr);
      if (date.isAfter(weekStart) || date.isAtSameMomentAs(weekStart)) {
        weeklyXp += xp;
        dailyXpThisWeek[dateStr] = xp;
      }
    });
    
    // Update user data
    userData = userData.copyWith(
      weeklyXpTotal: weeklyXp,
      dailyXpThisWeek: dailyXpThisWeek,
    );
    
    await _save(userData);
    
    // Regenerate leaderboard
    final leaderboard = _generateLeaderboard(userData);
    state = AsyncValue.data(leaderboard);
  }

  /// Generate leaderboard with 49 AI users + current user
  WeeklyLeaderboard _generateLeaderboard(LeaderboardUserData userData) {
    final random = Random(DateTime.now().millisecondsSinceEpoch ~/ 1000); // Stable seed per second
    final entries = <LeaderboardEntry>[];
    
    // Current user entry
    final currentUserEntry = LeaderboardEntry(
      userId: 'current_user',
      displayName: 'You',
      avatarEmoji: _getRandomEmoji(random),
      weeklyXp: userData.weeklyXpTotal,
      rank: 0, // Will be calculated after sorting
      isCurrentUser: true,
    );
    
    entries.add(currentUserEntry);
    
    // Generate 49 AI users with varied XP
    final names = _generateAINames();
    for (int i = 0; i < 49; i++) {
      final aiXp = _generateAIXp(random, userData.currentLeague);
      entries.add(
        LeaderboardEntry(
          userId: 'ai_user_$i',
          displayName: names[i],
          avatarEmoji: _getRandomEmoji(random),
          weeklyXp: aiXp,
          rank: 0, // Will be calculated after sorting
        ),
      );
    }
    
    // Sort by XP (descending) and assign ranks
    entries.sort((a, b) => b.weeklyXp.compareTo(a.weeklyXp));
    final rankedEntries = entries.asMap().entries.map((entry) {
      return entry.value.copyWith(rank: entry.key + 1);
    }).toList();
    
    // Find current user rank
    final currentUserRank = rankedEntries
        .firstWhere((e) => e.isCurrentUser)
        .rank;
    
    final weekStart = _getWeekStartDate(DateTime.now());
    final weekEnd = _getWeekEndDate(weekStart);
    
    return WeeklyLeaderboard(
      league: userData.currentLeague,
      entries: rankedEntries,
      weekStartDate: weekStart,
      weekEndDate: weekEnd,
      currentUserRank: currentUserRank,
      currentUserWeeklyXp: userData.weeklyXpTotal,
    );
  }

  /// Generate realistic XP values based on league
  int _generateAIXp(Random random, League league) {
    // XP ranges vary by league
    switch (league) {
      case League.bronze:
        return random.nextInt(300); // 0-300 XP
      case League.silver:
        return 100 + random.nextInt(400); // 100-500 XP
      case League.gold:
        return 200 + random.nextInt(600); // 200-800 XP
      case League.diamond:
        return 400 + random.nextInt(800); // 400-1200 XP
    }
  }

  /// Generate diverse AI user names
  List<String> _generateAINames() {
    return [
      'AquaExplorer', 'FishWhisperer', 'TankMaster', 'ReefKeeper', 'PlantedTank',
      'CichlidLover', 'BettaBuddy', 'GuppyGuru', 'TetraFan', 'CoralCrafter',
      'ShrimpSquad', 'AlgaeHunter', 'FreshwaterPro', 'SaltwaterSage', 'NanoTanker',
      'AquascapeArt', 'FishyBusiness', 'TropicalVibes', 'MarineLife', 'PlantParent',
      'SnailMail', 'CrabbyPatty', 'ClownfishKid', 'AngelfishAce', 'DiscusKing',
      'MollyCrew', 'PlatyPal', 'SwordtailStar', 'RainbowFish', 'NeonKnight',
      'GoldfishGang', 'KoiEnthusiast', 'BettaBreeder', 'CatfishCrew', 'LoachLover',
      'OscarOwner', 'GouramiFan', 'BarbelBoss', 'PufferPal', 'TangTime',
      'WrasseWarrior', 'DamselfishFan', 'BlennyCrew', 'GobyGuru', 'DottybackDan',
      'CardinalFish', 'ChromisChill', 'FirefishFan', 'HawkfishHero', 'LionLover',
    ];
  }

  /// Random emoji avatars
  String _getRandomEmoji(Random random) {
    const emojis = [
      '🐠', '🐡', '🐟', '🦈', '🐙', '🦑', '🦞', '🦀', '🦐', '🐚',
      '🪸', '🌊', '🐬', '🐳', '🐋', '🦭', '🦦', '🪼', '🐢', '🦎',
    ];
    return emojis[random.nextInt(emojis.length)];
  }

  /// Force reload (for debugging/testing)
  Future<void> reload() async {
    await _load();
  }

  /// Reset leaderboard data (for testing)
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await _load();
  }

  /// Clear promotion/relegation flags after user acknowledges
  Future<void> clearPromotionFlags() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return;
    
    var userData = LeaderboardUserData.fromJson(jsonDecode(json));
    userData = userData.copyWith(
      justPromoted: false,
      justRelegated: false,
    );
    
    await _save(userData);
  }
}

/// Provider to check if user just got promoted/relegated
/// Note: Returns null initially, use FutureProvider if async reading needed
final leaderboardPromotionStatusProvider = FutureProvider<({bool promoted, bool relegated, League? previousLeague})?> ((ref) async {
  final leaderboardAsync = ref.watch(weeklyLeaderboardProvider);
  
  return leaderboardAsync.when(
    loading: () => null,
    error: (_, __) => null,
    data: (leaderboard) async {
      if (leaderboard == null) return null;
      
      // Check stored promotion flags
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('leaderboard_user_data');
      if (json == null) return null;
      
      final userData = LeaderboardUserData.fromJson(jsonDecode(json));
      return (
        promoted: userData.justPromoted,
        relegated: userData.justRelegated,
        previousLeague: userData.previousLeague,
      );
    },
  );
});
