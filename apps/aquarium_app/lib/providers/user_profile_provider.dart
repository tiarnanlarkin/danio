import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/tank.dart'; // For TankType enum
import '../models/user_profile.dart';
import '../models/learning.dart'; // AchievementTier
import '../data/achievements.dart'; // New canonical achievement definitions
import '../models/achievements.dart'; // AchievementRarity
import '../models/daily_goal.dart';
import '../models/lesson_progress.dart';
import '../models/gem_economy.dart';
import '../models/gem_transaction.dart';
import '../models/leaderboard.dart'; // For League and WeekPeriod
import '../models/shop_item.dart'; // For InventoryItem
import '../models/spaced_repetition.dart'; // For ConceptType
import 'lesson_provider.dart';
import 'gems_provider.dart';
import 'spaced_repetition_provider.dart'; // For creating review cards
import '../services/offline_aware_service.dart';
import '../utils/debouncer.dart';

const _uuid = Uuid();

/// Provider for user profile management
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      return UserProfileNotifier(ref);
    });

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    _load();
    _lifecycleListener = _ProfileLifecycleListener(_flushPendingSave);
    WidgetsBinding.instance.addObserver(_lifecycleListener);
  }

  final Ref ref;
  static const _key = 'user_profile';
  late final _ProfileLifecycleListener _lifecycleListener;

  /// Debouncer collapses rapid successive saves (e.g. lesson complete → XP → gems)
  /// into a single disk write after 200ms of inactivity.
  final _saveDebouncer = Debouncer(delay: const Duration(milliseconds: 200));

  /// The latest profile pending a debounced write.
  UserProfile? _pendingSave;

  /// Flush any pending debounced save immediately (called on lifecycle pause/detach).
  void _flushPendingSave() {
    _saveDebouncer.flush();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_key);

      if (json != null) {
        final profile = UserProfile.fromJson(jsonDecode(json));
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _save(UserProfile profile) async {
    _pendingSave = profile;
    _saveDebouncer.run(() async {
      final toSave = _pendingSave;
      if (toSave == null) return;
      _pendingSave = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(toSave.toJson()));
    });
  }

  /// Save immediately, bypassing debounce. Use for critical state changes
  /// (XP, streaks, lesson completions, achievements) that must not be lost.
  Future<void> _saveImmediate(UserProfile profile) async {
    _pendingSave = null;
    _saveDebouncer.cancel();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_lifecycleListener);
    // Flush any pending save before disposal
    _saveDebouncer.flush();
    _saveDebouncer.dispose();
    super.dispose();
  }

  /// Create initial profile during onboarding
  Future<void> createProfile({
    String? name,
    required ExperienceLevel experienceLevel,
    TankType primaryTankType = TankType.freshwater,
    required List<UserGoal> goals,
  }) async {
    try {
      final now = DateTime.now();
      final profile = UserProfile(
        id: _uuid.v4(),
        name: name,
        experienceLevel: experienceLevel,
        primaryTankType: primaryTankType,
        goals: goals,
        createdAt: now,
        updatedAt: now,
      );

      await _save(profile);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update profile settings
  Future<void> updateProfile({
    String? name,
    ExperienceLevel? experienceLevel,
    TankType? primaryTankType,
    List<UserGoal>? goals,
    int? dailyXpGoal,
    List<InventoryItem>? inventory,
    bool? dailyTipsEnabled,
    bool? streakRemindersEnabled,
    bool? hasSeenTutorial,
    String? morningReminderTime,
    String? eveningReminderTime,
    String? nightReminderTime,
    String? learningStylePreference,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      name: name ?? current.name,
      experienceLevel: experienceLevel ?? current.experienceLevel,
      primaryTankType: primaryTankType ?? current.primaryTankType,
      goals: goals ?? current.goals,
      dailyXpGoal: dailyXpGoal ?? current.dailyXpGoal,
      inventory: inventory ?? current.inventory,
      dailyTipsEnabled: dailyTipsEnabled ?? current.dailyTipsEnabled,
      streakRemindersEnabled:
          streakRemindersEnabled ?? current.streakRemindersEnabled,
      hasSeenTutorial: hasSeenTutorial ?? current.hasSeenTutorial,
      morningReminderTime: morningReminderTime ?? current.morningReminderTime,
      eveningReminderTime: eveningReminderTime ?? current.eveningReminderTime,
      nightReminderTime: nightReminderTime ?? current.nightReminderTime,
      learningStylePreference: learningStylePreference ?? current.learningStylePreference,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Mark placement test as skipped
  Future<void> skipPlacementTest() async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(hasSkippedPlacementTest: true);
    state = AsyncValue.data(updated);
    await _save(updated);
  }

  /// Get today's XP progress
  int getTodayXp() {
    final current = state.value;
    if (current == null) return 0;

    final today = _formatDate(DateTime.now());
    return current.dailyXpHistory[today] ?? 0;
  }

  /// Format date as YYYY-MM-DD for dailyXpHistory key
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Set daily XP goal (25, 50, 100, or 200)
  Future<void> setDailyGoal(int goal) async {
    await updateProfile(dailyXpGoal: goal);
  }

  /// Add a streak freeze (purchased from shop)
  Future<void> addStreakFreeze() async {
    final current = state.value;
    if (current == null) return;

    // Grant the streak freeze
    final updated = current.copyWith(
      hasStreakFreeze: true,
      streakFreezeGrantedDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Award XP and handle streak logic (with streak freeze support)
  /// Now uses offline-aware service to queue changes when offline
  /// If xpBoostActive is true, the XP amount will be doubled
  Future<void> recordActivity({int xp = 0, bool xpBoostActive = false}) async {
    // Apply XP boost multiplier if active
    final effectiveXp = xpBoostActive ? xp * 2 : xp;
    try {
      var current = state.value;
      if (current == null) return;

      // Use offline-aware service to handle XP award
      final offlineService = ref.read(offlineAwareServiceProvider);

      await offlineService.awardXp(
        amount: effectiveXp,
        localUpdate: () async {
          // Shadow current into c so Dart flow analysis can track non-nullability
          // across this async closure boundary.
          var c = current;
          if (c == null) return;

          // Reset streak freeze weekly if needed
          if (c.shouldResetStreakFreeze) {
            c = c.copyWith(
              hasStreakFreeze: true,
              streakFreezeGrantedDate: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            current = c;
          }

          final now = DateTime.now().toUtc();
          final today = _normalizeDate(now);

          int newStreak = c.currentStreak;
          int longestStreak = c.longestStreak;
          bool usedFreeze = false;

          if (c.lastActivityDate != null) {
            final lastDate = _normalizeDate(c.lastActivityDate!);
            final dayDifference = today.difference(lastDate).inDays;

            if (dayDifference == 0) {
              // Same day - keep current streak, no increment
              newStreak = c.currentStreak;
            } else if (dayDifference == 1) {
              // Consecutive day - increment streak
              newStreak = c.currentStreak + 1;
            } else if (dayDifference == 2 &&
                c.hasStreakFreeze &&
                !c.streakFreezeUsedThisWeek &&
                c.currentStreak > 0) {
              // 1 day gap + freeze available = use freeze to save streak
              newStreak = c.currentStreak + 1; // Continue streak
              usedFreeze = true;
            } else {
              // Gap in activity - reset streak
              newStreak = 1;
            }
          } else {
            // First activity ever
            newStreak = 1;
          }

          if (newStreak > longestStreak) {
            longestStreak = newStreak;
          }

          // Bonus XP for streak milestones (only when streak increases)
          int bonusXp = 0;
          if (newStreak > c.currentStreak) {
            bonusXp = XpRewards.dailyStreak;
          }

          // Update daily XP history
          final todayKey = _formatDate(today);
          final previousTodayXp = c.dailyXpHistory[todayKey] ?? 0;
          final todayXp = previousTodayXp + effectiveXp + bonusXp;
          var updatedHistory = {
            ...c.dailyXpHistory,
            todayKey: todayXp,
          };

          // Prune dailyXpHistory to last 365 entries
          if (updatedHistory.length > 365) {
            final sorted = updatedHistory.entries.toList()
              ..sort((a, b) => b.key.compareTo(a.key));
            updatedHistory = Map.fromEntries(sorted.take(365));
          }

          final updated = c.copyWith(
            totalXp: c.totalXp + effectiveXp + bonusXp,
            currentStreak: newStreak,
            longestStreak: longestStreak,
            lastActivityDate: now,
            dailyXpHistory: updatedHistory,
            hasStreakFreeze: usedFreeze ? false : c.hasStreakFreeze,
            streakFreezeUsedDate: usedFreeze
                ? now
                : c.streakFreezeUsedDate,
            updatedAt: now,
          );

          await _saveImmediate(updated);
          state = AsyncValue.data(updated);

          // Award gems for milestones
          final gemsNotifier = ref.read(gemsProvider.notifier);

          // Streak milestone gems (7, 14, 30, 50, 100 days)
          if (newStreak > c.currentStreak) {
            final streakGems = GemRewards.getStreakMilestoneReward(newStreak);
            if (streakGems > 0) {
              await gemsNotifier.addGems(
                amount: streakGems,
                reason: GemEarnReason.streakMilestone,
                customReason: '$newStreak day streak!',
              );
            }
          }

          // Daily goal completion gems (first time reaching goal today)
          if (previousTodayXp < c.dailyXpGoal &&
              todayXp >= c.dailyXpGoal) {
            await gemsNotifier.addGems(
              amount: GemRewards.dailyGoalMet,
              reason: GemEarnReason.dailyGoalMet,
            );
          }
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Normalize a DateTime to UTC midnight for consistent date comparisons
  /// Using UTC prevents timezone shifts and DST from resetting streaks
  DateTime _normalizeDate(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  /// Add XP and update daily progress
  /// If xpBoostActive is true, doubles the XP amount
  Future<void> addXp(int amount, {bool xpBoostActive = false}) async {
    if (amount <= 0) return;

    final current = state.value;
    if (current == null) return;

    // Apply XP boost multiplier if active
    final effectiveAmount = xpBoostActive ? amount * 2 : amount;

    // Check and reset weekly XP if needed
    final currentWeek = WeekPeriod.current();
    final weekStart = current.weekStartDate;
    int weeklyXP = current.weeklyXP;
    DateTime? newWeekStart = weekStart;

    if (weekStart == null || !_isSameWeek(weekStart, currentWeek.start)) {
      // Week changed - reset weekly XP
      weeklyXP = 0;
      newWeekStart = currentWeek.start;
    }

    // Add to weekly XP
    weeklyXP += effectiveAmount;

    // Determine league based on weekly XP
    final newLeague = _calculateLeagueFromXP(weeklyXP);

    // Update today's XP in history
    final todayKey = getTodayKey();
    final updatedHistory = Map<String, int>.from(current.dailyXpHistory);
    updatedHistory[todayKey] = (updatedHistory[todayKey] ?? 0) + effectiveAmount;

    // Prune dailyXpHistory to last 365 entries to prevent unbounded growth
    Map<String, int> prunedHistory = updatedHistory;
    if (updatedHistory.length > 365) {
      final sorted = updatedHistory.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key));
      prunedHistory = Map.fromEntries(sorted.take(365));
    }

    final updated = current.copyWith(
      totalXp: current.totalXp + effectiveAmount,
      weeklyXP: weeklyXP,
      weekStartDate: newWeekStart,
      league: newLeague,
      dailyXpHistory: prunedHistory,
      updatedAt: DateTime.now(),
    );

    await _saveImmediate(updated);
    state = AsyncValue.data(updated);

    /// XP Flow:
    /// 1. addXp() - adds base XP to totalXp and dailyXpHistory
    /// 2. recordActivity(xp: 0) - handles streak bonus, daily goal, weekly reset
    ///    Note: xp: 0 is intentional — base XP already added by addXp()
    ///    The streak bonusXp is added here on TOP of the base XP.
    /// DO NOT refactor these into a single method without understanding
    /// the streak bonus logic in recordActivity().
    // Record activity for streak tracking
    await recordActivity(xp: 0); // XP already added above
  }

  /// Check if two dates are in the same week (Monday-Sunday)
  bool _isSameWeek(DateTime date1, DateTime date2) {
    final monday1 = _getMondayOfWeek(date1);
    final monday2 = _getMondayOfWeek(date2);

    return monday1.year == monday2.year &&
        monday1.month == monday2.month &&
        monday1.day == monday2.day;
  }

  /// Get the Monday of the week containing the given date
  DateTime _getMondayOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: daysFromMonday));
  }

  /// Determine league based on weekly XP
  League _calculateLeagueFromXP(int weeklyXP) {
    if (weeklyXP >= League.diamond.minWeeklyXP) return League.diamond;
    if (weeklyXP >= League.gold.minWeeklyXP) return League.gold;
    if (weeklyXP >= League.silver.minWeeklyXP) return League.silver;
    return League.bronze;
  }

  /// Mark a lesson as completed
  Future<void> completeLesson(String lessonId, int xpReward) async {
    try {
      final current = state.value;
      if (current == null) return;

      // Don't double-count if already completed
      if (current.completedLessons.contains(lessonId)) return;

      // Create new lesson progress entry
      final now = DateTime.now();
      final progress = LessonProgress(
        lessonId: lessonId,
        completedDate: now,
        lastReviewDate: null,
        reviewCount: 0,
        strength: 100.0,
      );

      // Update lesson progress map
      final updatedProgress = Map<String, LessonProgress>.from(
        current.lessonProgress,
      );
      updatedProgress[lessonId] = progress;

      // Update today's XP in history
      final todayKey = getTodayKey();
      final updatedHistory = Map<String, int>.from(current.dailyXpHistory);
      updatedHistory[todayKey] = (updatedHistory[todayKey] ?? 0) + xpReward;

      // Track previous level for level-up detection
      final previousLevel = current.currentLevel;

      final updated = current.copyWith(
        completedLessons: [...current.completedLessons, lessonId],
        lessonProgress: updatedProgress,
        totalXp: current.totalXp + xpReward,
        dailyXpHistory: updatedHistory,
        updatedAt: now,
      );

      await _saveImmediate(updated);
      state = AsyncValue.data(updated);

      // Award gems for lesson completion
      final gemsNotifier = ref.read(gemsProvider.notifier);
      await gemsNotifier.addGems(
        amount: GemRewards.lessonComplete,
        reason: GemEarnReason.lessonComplete,
      );

      // Check for level up and award bonus gems
      if (updated.currentLevel > previousLevel) {
        final levelUpGems = GemRewards.getLevelUpReward(updated.currentLevel);
        await gemsNotifier.addGems(
          amount: levelUpGems,
          reason: GemEarnReason.levelUp,
          customReason: 'Level up to ${updated.levelTitle}',
        );
      }

      /// XP Flow: xp: 0 is intentional — base XP already added above.
      /// recordActivity() handles streak bonus, daily goal, weekly reset.
      /// See addXp() for the full XP flow documentation.
      await recordActivity(xp: 0);

      // AUTO-SEED REVIEW CARDS: Create spaced repetition cards for this lesson
      await _createReviewCardsForLesson(lessonId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Create spaced repetition review cards for a completed lesson
  /// Seeds 3-5 cards from key lesson concepts
  Future<void> _createReviewCardsForLesson(String lessonId) async {
    try {
      // Import is at top of file, access via ref
      final spacedRepetitionNotifier = ref.read(
        spacedRepetitionProvider.notifier,
      );

      // Find the lesson in lesson content (lazy-loads path if needed)
      final lesson = await _findLessonById(lessonId);
      if (lesson == null) return; // Lesson not found, skip

      // Extract reviewable concepts from lesson
      final concepts = _extractReviewableConceptsFromLesson(lesson);

      // Create a review card for each concept (3-5 cards per lesson)
      for (final concept in concepts.take(5)) {
        await spacedRepetitionNotifier.createCard(
          conceptId: concept,
          conceptType: ConceptType.lesson,
        );
      }
    } catch (e) {
      // Don't fail lesson completion if card creation fails
      // Just log and continue
      debugPrint(
        'Warning: Failed to create review cards for lesson $lessonId: $e',
      );
    }
  }

  /// Find a lesson by ID using the lazy lesson provider.
  /// First checks already-loaded paths, then loads the required path on demand.
  Future<Lesson?> _findLessonById(String lessonId) async {
    final lessonNotifier = ref.read(lessonProvider.notifier);

    // 1. Check already-loaded paths first (no I/O)
    final cached = ref.read(lessonProvider).getLesson(lessonId);
    if (cached != null) return cached;

    // 2. Find which path contains this lesson via lightweight metadata
    for (final meta in LessonProvider.allPathMetadata) {
      if (meta.lessonIds.contains(lessonId)) {
        // Load only the required path
        await lessonNotifier.loadPath(meta.id);
        return ref.read(lessonProvider).getLesson(lessonId);
      }
    }
    return null;
  }

  /// Extract 3-5 reviewable concepts from a lesson
  /// Creates concept IDs from key points, tips, warnings, and quiz questions
  List<String> _extractReviewableConceptsFromLesson(Lesson lesson) {
    final concepts = <String>[];

    // Extract key points, tips, and warnings from sections
    for (var i = 0; i < lesson.sections.length; i++) {
      final section = lesson.sections[i];
      if (section.type == LessonSectionType.keyPoint ||
          section.type == LessonSectionType.tip ||
          section.type == LessonSectionType.warning) {
        // Use lesson ID + section index as concept ID
        concepts.add('${lesson.id}_section_$i');
      }
    }

    // Extract quiz questions
    if (lesson.quiz != null) {
      for (var i = 0; i < lesson.quiz!.questions.length; i++) {
        concepts.add('${lesson.id}_quiz_$i');
      }
    }

    // Return 3-5 concepts (prioritize key points and quiz questions)
    return concepts.take(5).toList();
  }

  /// Complete placement test and apply results
  Future<void> completePlacementTest({
    required String resultId,
    required List<String> lessonsToSkip,
    required int xpToAward,
  }) async {
    final current = state.value;
    if (current == null) return;

    // Mark lessons as completed (tested out)
    final now = DateTime.now();
    final updatedCompletedLessons = [
      ...current.completedLessons,
      ...lessonsToSkip.where((id) => !current.completedLessons.contains(id)),
    ];

    // Create lesson progress entries for skipped lessons
    final updatedProgress = Map<String, LessonProgress>.from(
      current.lessonProgress,
    );
    for (final lessonId in lessonsToSkip) {
      if (!updatedProgress.containsKey(lessonId)) {
        updatedProgress[lessonId] = LessonProgress(
          lessonId: lessonId,
          completedDate: now,
          lastReviewDate: null,
          reviewCount: 0,
          strength: 75.0, // Lower strength since they tested out
        );
      }
    }

    // Update today's XP in history
    final todayKey = getTodayKey();
    final updatedHistory = Map<String, int>.from(current.dailyXpHistory);
    updatedHistory[todayKey] = (updatedHistory[todayKey] ?? 0) + xpToAward;

    final updated = current.copyWith(
      hasCompletedPlacementTest: true,
      placementResultId: resultId,
      placementTestDate: now,
      completedLessons: updatedCompletedLessons,
      lessonProgress: updatedProgress,
      totalXp: current.totalXp + xpToAward,
      dailyXpHistory: updatedHistory,
      updatedAt: now,
    );

    await _saveImmediate(updated);
    state = AsyncValue.data(updated);

    // Award gems for placement test
    final gemsNotifier = ref.read(gemsProvider.notifier);
    await gemsNotifier.addGems(
      amount: GemRewards.placementTest,
      reason: GemEarnReason.placementTest,
    );

    // Record activity for streak tracking
    await recordActivity(xp: 0); // XP already added above
  }

  /// Mark a lesson as reviewed (for spaced repetition)
  Future<void> reviewLesson(String lessonId, int xpReward) async {
    final current = state.value;
    if (current == null) return;

    // Check if lesson exists in progress
    final progress = current.lessonProgress[lessonId];
    if (progress == null) return; // Can't review if never completed

    // Update lesson progress with review
    final updatedProgressEntry = progress.reviewed();
    final updatedProgress = Map<String, LessonProgress>.from(
      current.lessonProgress,
    );
    updatedProgress[lessonId] = updatedProgressEntry;

    // Update today's XP in history
    final todayKey = getTodayKey();
    final updatedHistory = Map<String, int>.from(current.dailyXpHistory);
    updatedHistory[todayKey] = (updatedHistory[todayKey] ?? 0) + xpReward;

    final now = DateTime.now();
    final updated = current.copyWith(
      lessonProgress: updatedProgress,
      totalXp: current.totalXp + xpReward,
      dailyXpHistory: updatedHistory,
      updatedAt: now,
    );

    await _saveImmediate(updated);
    state = AsyncValue.data(updated);

    // Award gems for review
    final gemsNotifier = ref.read(gemsProvider.notifier);
    await gemsNotifier.addGems(
      amount: GemRewards.reviewLesson,
      reason: GemEarnReason.lessonComplete,
      customReason: 'Lesson review',
    );

    // Record activity for streak tracking
    await recordActivity(xp: 0); // XP already added above
  }

  /// Award gems for quiz performance
  Future<void> awardQuizGems({required bool isPerfect}) async {
    try {
      final gemsNotifier = ref.read(gemsProvider.notifier);
      if (isPerfect) {
        await gemsNotifier.addGems(
          amount: GemRewards.quizPerfect,
          reason: GemEarnReason.quizPerfect,
        );
      } else {
        await gemsNotifier.addGems(
          amount: GemRewards.quizPass,
          reason: GemEarnReason.quizPass,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Get today's date key for dailyXpHistory
  String getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get lessons that need review (strength < 50)
  List<LessonProgress> getLessonsNeedingReview() {
    final current = state.value;
    if (current == null) return [];

    return current.lessonProgress.values
        .where((progress) => progress.needsReview)
        .toList()
      ..sort((a, b) => a.currentStrength.compareTo(b.currentStrength));
  }

  /// Get the 5 weakest lessons for review
  List<LessonProgress> getWeakestLessons({int count = 5}) {
    final needingReview = getLessonsNeedingReview();
    return needingReview.take(count).toList();
  }

  /// Award an achievement
  Future<void> unlockAchievement(String achievementId) async {
    final current = state.value;
    if (current == null) return;

    // Don't double-count
    if (current.achievements.contains(achievementId)) return;

    // Use the new canonical AchievementDefinitions (55+ achievements)
    // Falls back to legacy Achievements for IDs not yet in the new system
    final newAchievement = AchievementDefinitions.getById(achievementId);
    final legacyAchievement = Achievements.getById(achievementId);
    final bonusXp = newAchievement?.rarity.xpReward
        ?? legacyAchievement?.tier.xpBonus
        ?? 0;

    final updated = current.copyWith(
      achievements: [...current.achievements, achievementId],
      totalXp: current.totalXp + bonusXp,
      updatedAt: DateTime.now(),
    );

    await _saveImmediate(updated);
    state = AsyncValue.data(updated);

    // Award gems for achievement — map rarity to legacy tier for GemRewards
    final effectiveTier = newAchievement != null
        ? _rarityToTier(newAchievement.rarity)
        : legacyAchievement?.tier;
    if (effectiveTier != null) {
      final gemsNotifier = ref.read(gemsProvider.notifier);
      final gemReward = GemRewards.getAchievementReward(effectiveTier);
      final displayName = newAchievement?.name ?? legacyAchievement?.title ?? achievementId;
      await gemsNotifier.addGems(
        amount: gemReward,
        reason: GemEarnReason.achievementUnlock,
        customReason: 'Achievement: $displayName',
      );
    }
  }

  /// Update achievements list and award XP (for new achievement system)
  Future<void> updateAchievements({
    required List<String> achievements,
    int xpToAdd = 0,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      achievements: achievements,
      totalXp: current.totalXp + xpToAdd,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);
  }

  /// Update hearts count (for hearts/lives system)
  /// Set [clearLastHeartRefill] to true to explicitly null out lastHeartRefill
  /// (e.g. after refillToMax so no stale timer remains).
  Future<void> updateHearts({
    required int hearts,
    DateTime? lastHeartRefill,
    bool clearLastHeartRefill = false,
  }) async {
    try {
      final current = state.value;
      if (current == null) return;

      // copyWith can't null out fields, so roundtrip through JSON when clearing
      UserProfile updated;
      if (clearLastHeartRefill) {
        final json = current.toJson();
        json['hearts'] = hearts;
        json['lastHeartRefill'] = null;
        json['updatedAt'] = DateTime.now().toIso8601String();
        updated = UserProfile.fromJson(json);
      } else {
        updated = current.copyWith(
          hearts: hearts,
          lastHeartRefill: lastHeartRefill ?? current.lastHeartRefill,
          updatedAt: DateTime.now(),
        );
      }

      await _save(updated);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Check if profile exists (for routing)
  bool get hasProfile => state.value != null;

  /// Update story progress
  Future<void> updateStoryProgress({
    required String storyId,
    required Map<String, dynamic> progressData,
    bool isCompleted = false,
    int xpReward = 0,
  }) async {
    final current = state.value;
    if (current == null) return;

    // Update story progress map
    final updatedProgress = Map<String, dynamic>.from(current.storyProgress);
    updatedProgress[storyId] = progressData;

    // Add to completed stories if newly completed
    List<String> completedStories = List.from(current.completedStories);
    bool newlyCompleted = false;

    if (isCompleted && !completedStories.contains(storyId)) {
      completedStories.add(storyId);
      newlyCompleted = true;
    }

    // Update profile
    final updated = current.copyWith(
      storyProgress: updatedProgress,
      completedStories: completedStories,
      updatedAt: DateTime.now(),
    );

    await _save(updated);
    state = AsyncValue.data(updated);

    // Award XP if newly completed
    if (newlyCompleted && xpReward > 0) {
      await recordActivity(xp: xpReward);
    }
  }

  /// Reset profile (for testing/debugging)
  Future<void> resetProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncValue.data(null);
  }
}

/// Provider to check if onboarding is needed
final needsOnboardingProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.when(
    loading: () => false, // Don't redirect while loading
    error: (_, __) => true, // Show onboarding on error
    data: (p) => p == null, // Need onboarding if no profile
  );
});

/// Provider for learning progress stats
final learningStatsProvider = Provider<LearningStats?>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return null;

  return LearningStats(
    totalXp: profile.totalXp,
    currentLevel: profile.currentLevel,
    levelTitle: profile.levelTitle,
    levelProgress: profile.levelProgress,
    xpToNextLevel: profile.xpToNextLevel,
    currentStreak: profile.currentStreak,
    longestStreak: profile.longestStreak,
    lessonsCompleted: profile.completedLessons.length,
    achievementsUnlocked: profile.achievements.length,
  );
});

/// Provider for today's daily goal
final todaysDailyGoalProvider = Provider<DailyGoal?>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  if (profile == null) return null;

  return DailyGoal.today(
    dailyXpGoal: profile.dailyXpGoal,
    dailyXpHistory: profile.dailyXpHistory,
  );
});

/// Provider for recent daily goals (for streak calendar).
/// Uses select() to only recompute when dailyXpHistory or dailyXpGoal
/// actually change, not on every profile update.
final recentDailyGoalsProvider = Provider<List<DailyGoal>>((ref) {
  final dailyXpHistory = ref.watch(
    userProfileProvider.select((p) => p.value?.dailyXpHistory),
  );
  final dailyXpGoal = ref.watch(
    userProfileProvider.select((p) => p.value?.dailyXpGoal),
  );
  if (dailyXpHistory == null || dailyXpGoal == null) return [];

  return DailyGoal.getRecentDays(
    days: 90, // Last 3 months
    dailyXpGoal: dailyXpGoal,
    dailyXpHistory: dailyXpHistory,
  );
});

class LearningStats {
  final int totalXp;
  final int currentLevel;
  final String levelTitle;
  final double levelProgress;
  final int xpToNextLevel;
  final int currentStreak;
  final int longestStreak;
  final int lessonsCompleted;
  final int achievementsUnlocked;

  const LearningStats({
    required this.totalXp,
    required this.currentLevel,
    required this.levelTitle,
    required this.levelProgress,
    required this.xpToNextLevel,
    required this.currentStreak,
    required this.longestStreak,
    required this.lessonsCompleted,
    required this.achievementsUnlocked,
  });
}

/// Level up event data
class LevelUpEvent {
  final int newLevel;
  final String levelTitle;
  final DateTime timestamp;

  const LevelUpEvent({
    required this.newLevel,
    required this.levelTitle,
    required this.timestamp,
  });
}

/// Provider that tracks level changes and emits level-up events
/// Use this in UI widgets to trigger level-up celebrations
final levelUpEventProvider = StateNotifierProvider<LevelUpEventNotifier, LevelUpEvent?>((ref) {
  return LevelUpEventNotifier(ref);
});

class LevelUpEventNotifier extends StateNotifier<LevelUpEvent?> {
  LevelUpEventNotifier(this.ref) : super(null) {
    // Watch for profile changes and detect level ups
    ref.listen<AsyncValue<UserProfile?>>(userProfileProvider, (previous, next) {
      final prevProfile = previous?.value;
      final nextProfile = next.value;
      
      if (prevProfile != null && nextProfile != null) {
        final prevLevel = prevProfile.currentLevel;
        final nextLevel = nextProfile.currentLevel;
        
        // Level up detected!
        if (nextLevel > prevLevel) {
          state = LevelUpEvent(
            newLevel: nextLevel,
            levelTitle: nextProfile.levelTitle,
            timestamp: DateTime.now(),
          );
        }
      }
    });
  }

  final Ref ref;

  /// Clear the level up event after it's been handled
  void clearEvent() {
    state = null;
  }
  
  /// Manually trigger a level up event (for testing)
  void triggerLevelUp(int level, String title) {
    state = LevelUpEvent(
      newLevel: level,
      levelTitle: title,
      timestamp: DateTime.now(),
    );
  }
}

/// Maps new AchievementRarity to legacy AchievementTier for GemRewards compat.
AchievementTier _rarityToTier(AchievementRarity rarity) {
  switch (rarity) {
    case AchievementRarity.bronze:
      return AchievementTier.bronze;
    case AchievementRarity.silver:
      return AchievementTier.silver;
    case AchievementRarity.gold:
      return AchievementTier.gold;
    case AchievementRarity.platinum:
      return AchievementTier.platinum;
  }
}

/// Lifecycle observer that flushes pending profile saves when the app
/// is paused or detached, preventing XP/data loss on sudden app kill.
class _ProfileLifecycleListener extends WidgetsBindingObserver {
  _ProfileLifecycleListener(this._onFlush);

  final VoidCallback _onFlush;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _onFlush();
    }
  }
}
