// Widget tests for AnalyticsScreen.
//
// Run: flutter test test/widget_tests/analytics_screen_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/user_profile_provider.dart';
import 'package:danio/screens/analytics/analytics_screen.dart';
import 'package:danio/screens/analytics/analytics_stat_card.dart';
import 'package:danio/widgets/skeleton_loader.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap({Size size = const Size(390, 844)}) {
  return ProviderScope(
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: const MaterialApp(home: AnalyticsScreen()),
    ),
  );
}

Widget _wrapAfterProfileLoad({Size size = const Size(390, 844)}) {
  return ProviderScope(
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: const MaterialApp(home: _AnalyticsAfterProfileLoad()),
    ),
  );
}

class _AnalyticsAfterProfileLoad extends ConsumerWidget {
  const _AnalyticsAfterProfileLoad();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    return profile.maybeWhen(
      data: (_) => const AnalyticsScreen(),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

Map<String, dynamic> _profileJson() {
  final now = DateTime.now();
  final dateKey =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  final isoNow = now.toIso8601String();

  return {
    'id': 'analytics-test-user',
    'experienceLevel': 'beginner',
    'primaryTankType': 'freshwater',
    'goals': ['keepFishAlive'],
    'totalXp': 120,
    'currentStreak': 2,
    'longestStreak': 2,
    'completedLessons': ['nc_intro'],
    'achievements': <String>[],
    'lessonProgress': <String, dynamic>{},
    'completedStories': <String>[],
    'storyProgress': <String, dynamic>{},
    'hasCompletedPlacementTest': false,
    'hasSkippedPlacementTest': false,
    'dailyXpGoal': 50,
    'dailyXpHistory': <String, int>{dateKey: 120},
    'hasStreakFreeze': true,
    'hearts': 5,
    'league': 'bronze',
    'weeklyXP': 120,
    'inventory': <dynamic>[],
    'dailyTipsEnabled': true,
    'streakRemindersEnabled': true,
    'hasSeenTutorial': false,
    'weekendActivityDates': <String>[],
    'fullHeartDates': <String>[],
    'perfectScoreCount': 0,
    'createdAt': isoNow,
    'updatedAt': isoNow,
  };
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AnalyticsScreen', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('shows Analytics app bar title', (tester) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('shows empty/no-data state when no profile activity', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      // No profile stored → summary has all zeros → empty state shown
      expect(find.text('No data yet'), findsOneWidget);
    });

    testWidgets('hides share/export button when no data loaded', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      // Share button is hidden when there is no data (empty state shown).
      // It only appears once meaningful analytics data has loaded.
      expect(find.byIcon(Icons.share), findsNothing);
    });

    testWidgets('shows default selected range in the initial viewport', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(_profileJson()),
      });

      await tester.pumpWidget(_wrapAfterProfileLoad());
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      final last30Days = find.text('Last 30 Days');
      expect(last30Days, findsWidgets);
      expect(tester.getTopLeft(last30Days.first).dx, greaterThanOrEqualTo(0));
      expect(tester.getTopRight(last30Days.first).dx, lessThanOrEqualTo(390));
    });

    testWidgets('tablet keeps analytics skeleton cards in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_wrap(size: const Size(2000, 1200)));

      expect(find.byType(SkeletonCard), findsWidgets);
      expect(
        tester.getSize(find.byType(SkeletonCard).first).width,
        lessThanOrEqualTo(720),
      );
    });

    testWidgets('tablet keeps analytics stat cards in a readable rail', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(2000, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({
        'user_profile': jsonEncode(_profileJson()),
      });

      await tester.pumpWidget(
        _wrapAfterProfileLoad(size: const Size(2000, 1200)),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      expect(find.byType(AnalyticsStatCard), findsWidgets);
      expect(
        tester.getSize(find.byType(AnalyticsStatCard).first).width,
        lessThanOrEqualTo(720),
      );
    });
  });
}
