// Widget tests for TabNavigator.
//
// Run: flutter test test/widget_tests/tab_navigator_test.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/models/user_profile.dart';
import 'package:danio/screens/tab_navigator.dart';
import 'package:danio/providers/lesson_provider.dart';
import 'package:danio/providers/spaced_repetition_provider.dart';
import 'package:danio/models/spaced_repetition.dart';
import 'package:danio/widgets/danio_bottom_dock.dart';

// ---------------------------------------------------------------------------
// No-op platform implementation for FlutterLocalNotifications
// ---------------------------------------------------------------------------

class _MockNotificationsPlatform extends FlutterLocalNotificationsPlatform
    with MockPlatformInterfaceMixin {
  Future<bool?> initialize(
    dynamic settings, {
    dynamic onDidReceiveNotificationResponse,
    dynamic onDidReceiveBackgroundNotificationResponse,
  }) async => true;

  @override
  Future<void> show(
    int id,
    String? title,
    String? body, {
    String? payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async => null;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Register the no-op notifications platform so initialize() never throws.
void _registerMockNotifications() {
  FlutterLocalNotificationsPlatform.instance = _MockNotificationsPlatform();
}

Widget _wrap({
  int dueCards = 0,
  UserProfile? profile,
  bool learnGuidanceSeen = true,
  int initialTab = 0,
}) {
  SharedPreferences.setMockInitialValues({
    if (profile != null) 'user_profile': jsonEncode(profile.toJson()),
    if (profile != null && learnGuidanceSeen)
      'guidance_seen_learnFirstVisit': true,
    if (dueCards > 0)
      'spaced_repetition_cards': jsonEncode(
        _dueReviewCards(dueCards).map((card) => card.toJson()).toList(),
      ),
  });

  return ProviderScope(
    overrides: [
      currentTabProvider.overrideWith((ref) => initialTab),
      spacedRepetitionProvider.overrideWith(
        (ref) => _FrozenSpacedRepetitionNotifier(ref, dueCards: dueCards),
      ),
    ],
    child: const MaterialApp(home: TabNavigator()),
  );
}

final _deferredPathMetadataProvider = StateProvider<List<PathMetadata>>(
  (ref) => const [],
);

Widget _wrapWithDeferredLearnPaths({required UserProfile profile}) {
  SharedPreferences.setMockInitialValues({
    'user_profile': jsonEncode(profile.toJson()),
    'guidance_seen_learnFirstVisit': true,
  });

  return ProviderScope(
    overrides: [
      pathMetadataProvider.overrideWith(
        (ref) => ref.watch(_deferredPathMetadataProvider),
      ),
      spacedRepetitionProvider.overrideWith(
        (ref) => _FrozenSpacedRepetitionNotifier(ref, dueCards: 0),
      ),
    ],
    child: const MaterialApp(home: TabNavigator()),
  );
}

UserProfile _profile() => UserProfile(
  id: 'tab-nav-profile',
  name: 'Test User',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

List<ReviewCard> _dueReviewCards(int count) {
  final now = DateTime.now();
  return List.generate(
    count,
    (index) => ReviewCard(
      id: 'due-card-$index',
      conceptId: 'concept-$index',
      conceptType: ConceptType.lesson,
      strength: 0.2,
      lastReviewed: now.subtract(const Duration(days: 2)),
      nextReview: now.subtract(const Duration(days: 1)),
    ),
  );
}

/// Subclass that uses the real Ref but resets to empty state after init.
class _FrozenSpacedRepetitionNotifier extends SpacedRepetitionNotifier {
  _FrozenSpacedRepetitionNotifier(super.ref, {required int dueCards}) {
    state = SpacedRepetitionState(
      cards: const [],
      stats: ReviewStats(
        totalCards: dueCards,
        dueCards: dueCards,
        weakCards: 0,
        masteredCards: 0,
        averageStrength: 0.0,
        cardsByMastery: const {},
        reviewsToday: 0,
        currentStreak: 0,
      ),
    );
  }
}

Future<void> _advance(WidgetTester tester) async {
  // Pump through all async operations, provider loads, and animations.
  // We run multiple small increments to drain flutter_animate timers (which
  // restart on every pump) and also cover longer delays (HomeScreen 4s tooltip).
  for (var i = 0; i < 60; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    _registerMockNotifications();
  });

  group('TabNavigator — smoke tests', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(TabNavigator), findsOneWidget);
    });

    testWidgets('shows custom bottom dock instead of Material NavigationBar', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byKey(const ValueKey('danio-bottom-dock')), findsOneWidget);
    });

    testWidgets('exposes semantic tabs without visible dock labels', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      final dock = find.byKey(const ValueKey('danio-bottom-dock'));
      expect(
        find.descendant(of: dock, matching: find.byType(Semantics)),
        findsAtLeastNWidgets(5),
      );
      expect(
        find.descendant(of: dock, matching: find.text('Learn')),
        findsNothing,
      );
      expect(
        find.descendant(of: dock, matching: find.text('Practice')),
        findsNothing,
      );
      expect(
        find.descendant(of: dock, matching: find.text('Tank')),
        findsNothing,
      );
      expect(
        find.descendant(of: dock, matching: find.text('Smart')),
        findsNothing,
      );
      expect(
        find.descendant(of: dock, matching: find.text('More')),
        findsNothing,
      );
    });

    testWidgets('tab 0 is selected by default', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      expect(
        find.byKey(const ValueKey('danio-bottom-dock-item-learn-selected')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('danio-bottom-dock-item-learn-glow')),
        findsOneWidget,
      );
    });

    testWidgets('uses floating rail without globally shrinking tab content', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(
        find.byKey(const ValueKey('danio-bottom-dock-floating-rail')),
        findsOneWidget,
      );

      final indexedStack = find.byType(IndexedStack);
      final globalPadding = find.ancestor(
        of: indexedStack,
        matching: find.byWidgetPredicate((widget) {
          return widget is Padding &&
              widget.padding is EdgeInsets &&
              (widget.padding as EdgeInsets).bottom == DanioBottomDock.height;
        }),
      );
      expect(globalPadding, findsNothing);
    });

    testWidgets('Learn empty-profile unlock list fits phone width', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrap());
      await _advance(tester);

      expect(
        find.text('Complete your profile setup to start learning!'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Learn auto-scroll keeps learning paths above bottom dock', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrap(profile: _profile()));
      await _advance(tester);

      final learningPathsFinder = find.text('Learning Paths');
      final firstPathFinder = find.text('The Nitrogen Cycle').last;
      final dockFinder = find.byKey(const ValueKey('danio-bottom-dock'));
      expect(learningPathsFinder, findsOneWidget);
      expect(firstPathFinder, findsOneWidget);
      expect(dockFinder, findsOneWidget);

      final learningPathsRect = tester.getRect(learningPathsFinder);
      final firstPathRect = tester.getRect(firstPathFinder);
      final dockRect = tester.getRect(dockFinder);

      expect(learningPathsRect.bottom, lessThanOrEqualTo(dockRect.top - 12));
      expect(firstPathRect.bottom, lessThanOrEqualTo(dockRect.top - 12));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Smart offline cards start clear of the bottom dock', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrap(initialTab: 3));
      await _advance(tester);

      final compatibilityFinder = find.text('Compatibility Advice');
      final anomalyFinder = find.text('Anomaly History');
      final dockFinder = find.byKey(const ValueKey('danio-bottom-dock'));
      expect(compatibilityFinder, findsOneWidget);
      expect(anomalyFinder, findsOneWidget);
      expect(dockFinder, findsOneWidget);

      final compatibilityRect = tester.getRect(compatibilityFinder);
      final anomalyRect = tester.getRect(anomalyFinder);
      final dockRect = tester.getRect(dockFinder);

      expect(compatibilityRect.bottom, lessThanOrEqualTo(dockRect.top - 12));
      expect(anomalyRect.bottom, lessThanOrEqualTo(dockRect.top - 12));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Learn retries first-path scroll when paths mount later', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrapWithDeferredLearnPaths(profile: _profile()));
      await _advance(tester);

      final context = tester.element(find.byType(TabNavigator));
      ProviderScope.containerOf(
            context,
          ).read(_deferredPathMetadataProvider.notifier).state =
          LessonProvider.allPathMetadata;
      await _advance(tester);

      final firstPathFinder = find.text('The Nitrogen Cycle').last;
      final dockFinder = find.byKey(const ValueKey('danio-bottom-dock'));
      expect(firstPathFinder, findsOneWidget);
      expect(dockFinder, findsOneWidget);

      final firstPathRect = tester.getRect(firstPathFinder);
      final dockRect = tester.getRect(dockFinder);

      expect(firstPathRect.bottom, lessThanOrEqualTo(dockRect.top - 12));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Learn first-run scroll is not blocked by guidance lookup', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        _wrap(profile: _profile(), learnGuidanceSeen: false),
      );
      await _advance(tester);

      final learningPathsFinder = find.text('Learning Paths');
      final firstPathFinder = find.text('The Nitrogen Cycle').last;
      final dockFinder = find.byKey(const ValueKey('danio-bottom-dock'));
      expect(learningPathsFinder, findsOneWidget);
      expect(firstPathFinder, findsOneWidget);
      expect(dockFinder, findsOneWidget);

      final learningPathsRect = tester.getRect(learningPathsFinder);
      final firstPathRect = tester.getRect(firstPathFinder);
      final dockRect = tester.getRect(dockFinder);

      expect(learningPathsRect.bottom, lessThanOrEqualTo(dockRect.top - 12));
      expect(firstPathRect.bottom, lessThanOrEqualTo(dockRect.top - 12));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Learn cards avoid raw icon and duplicate story semantics', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(_wrap(profile: _profile()));
        await _advance(tester);

        expect(
          find.bySemanticsLabel(RegExp(r'^0,\s*Continue learning')),
          findsNothing,
        );
        expect(find.bySemanticsLabel('0'), findsNothing);
        expect(
          find.bySemanticsLabel(RegExp(r'Continue learning[\s\S]*Today')),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(
            RegExp(r'^Interactive Stories\s+Interactive Stories'),
          ),
          findsNothing,
        );
        final storiesNode = tester.getSemantics(
          find.bySemanticsLabel(
            'Interactive Stories, Learn through choose-your-own-adventure scenarios',
          ),
        );
        expect(
          storiesNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
      } finally {
        semantics.dispose();
      }
    });

    testWidgets('tapping Practice tab switches selected item', (tester) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);
      await tester.tap(
        find.byKey(const ValueKey('danio-bottom-dock-item-practice')),
      );
      await _advance(tester);
      expect(
        find.byKey(const ValueKey('danio-bottom-dock-item-practice-selected')),
        findsOneWidget,
      );
    });

    testWidgets('Tank tab uses attached dock mode without extra bridge', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap());
      await _advance(tester);

      await tester.tap(
        find.byKey(const ValueKey('danio-bottom-dock-item-tank')),
      );
      await _advance(tester);

      expect(
        find.byKey(const ValueKey('danio-bottom-dock-attached')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('danio-bottom-dock-attached-bridge')),
        findsNothing,
      );
    });

    testWidgets('Practice tab preserves due-card badge', (tester) async {
      await tester.pumpWidget(_wrap(dueCards: 3));
      await _advance(tester);

      expect(
        find.byKey(const ValueKey('danio-bottom-dock-badge-practice')),
        findsOneWidget,
      );
    });
  });
}
