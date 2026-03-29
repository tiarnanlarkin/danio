// R-058: This file is now a barrel re-export.
// All imports of 'user_profile_provider.dart' continue to work unchanged.
//
// Split into:
//   user_profile_notifier.dart        — UserProfileNotifier, userProfileProvider,
//                                       sharedPreferencesProvider, streakFreezeUsedProvider,
//                                       streakResetProvider
//   user_profile_derived_providers.dart — needsOnboardingProvider, learningStatsProvider,
//                                         todaysDailyGoalProvider, recentDailyGoalsProvider,
//                                         LearningStats, LevelUpEvent, LevelUpEventNotifier,
//                                         levelUpEventProvider

export 'user_profile_notifier.dart';
export 'user_profile_derived_providers.dart';
