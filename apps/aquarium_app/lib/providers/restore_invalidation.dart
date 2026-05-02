import '../features/smart/smart_providers.dart';
import 'achievement_provider.dart';
import 'gems_provider.dart';
import 'inventory_provider.dart';
import 'onboarding_provider.dart';
import 'reduced_motion_provider.dart';
import 'room_theme_provider.dart';
import 'settings_provider.dart';
import 'spaced_repetition_provider.dart';
import 'species_unlock_provider.dart';
import 'tank_provider.dart';
import 'user_profile_provider.dart';
import 'wishlist_provider.dart';

void invalidateTankDataProviders(dynamic ref, Iterable<String> tankIds) {
  final ids = tankIds.where((id) => id.isNotEmpty).toSet();

  ref.invalidate(tanksProvider);
  ref.invalidate(tasksProvider(null));

  for (final tankId in ids) {
    ref.invalidate(tankProvider(tankId));
    ref.invalidate(livestockProvider(tankId));
    ref.invalidate(equipmentProvider(tankId));
    ref.invalidate(logsProvider(tankId));
    ref.invalidate(allLogsProvider(tankId));
    ref.invalidate(recentLogsProvider(tankId));
    ref.invalidate(latestWaterTestProvider(tankId));
    ref.invalidate(latestWaterTestEntryProvider(tankId));
    ref.invalidate(testStreakProvider(tankId));
    ref.invalidate(waterChangeStreakProvider(tankId));
    ref.invalidate(tankHeaterProvider(tankId));
    ref.invalidate(tasksProvider(tankId));
  }
}

void invalidateRestoredPreferenceProviders(dynamic ref) {
  ref.read(achievementProgressProvider.notifier).cancelPendingSaveForRestore();

  ref.invalidate(sharedPreferencesProvider);
  ref.invalidate(userProfileProvider);
  ref.invalidate(learningStatsProvider);
  ref.invalidate(gemsProvider);
  ref.invalidate(inventoryProvider);
  ref.invalidate(settingsProvider);
  ref.invalidate(roomThemeProvider);
  ref.invalidate(reducedMotionProvider);
  ref.invalidate(spacedRepetitionProvider);
  ref.invalidate(achievementProgressProvider);
  ref.invalidate(speciesUnlockProvider);
  ref.invalidate(wishlistProvider);
  ref.invalidate(budgetProvider);
  ref.invalidate(localShopsProvider);
  ref.invalidate(onboardingCompletedProvider);
  ref.invalidate(aiHistoryProvider);
  ref.invalidate(anomalyHistoryProvider);
  ref.invalidate(weeklyPlanProvider);
}
