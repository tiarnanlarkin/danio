# Widget Test Guide

## Goal
Build a comprehensive widget test suite to catch regressions and enable confident rapid iteration.

## Current Coverage
**5.8%** - Very low, needs significant improvement  
**Target:** 30-40% coverage

## Priority Screens for Testing

### Tier 1: Core Flows (MUST HAVE)
1. **home_screen_test.dart** - Tank list, navigation hub
2. **tank_detail_test.dart** - Complex screen, many widgets
3. **learn_screen_test.dart** - Learning paths, lesson navigation
4. **add_log_test.dart** - Critical data entry
5. **settings_screen_test.dart** - Settings, preferences

### Tier 2: High-Traffic Screens
6. livestock_screen_test.dart
7. equipment_screen_test.dart
8. achievements_screen_test.dart
9. charts_screen_test.dart
10. tasks_screen_test.dart

### Tier 3: Components
11. app_card_test.dart
12. app_button_test.dart
13. empty_state_test.dart

## Test Structure Pattern

### Basic Screen Test Template
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/screens/home_screen.dart';

void main() {
  group('HomeScreen', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('displays tank list when tanks exist', (tester) async {
      // TODO: Mock tank provider with test data
      await tester.pumpWidget(/* ... */);
      
      expect(find.text('My Tank'), findsOneWidget);
    });

    testWidgets('navigates to tank detail on tap', (tester) async {
      await tester.pumpWidget(/* ... */);
      
      await tester.tap(find.text('My Tank'));
      await tester.pumpAndSettle();
      
      expect(find.byType(TankDetailScreen), findsOneWidget);
    });
  });
}
```

### Testing with Riverpod Providers

**Mock Provider Pattern:**
```dart
testWidgets('test description', (tester) async {
  final container = ProviderContainer(
    overrides: [
      tankProvider.overrideWith((ref) {
        return AsyncValue.data(mockTank);
      }),
    ],
  );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    ),
  );

  // Test assertions...
});
```

### Testing Async Loading States

```dart
testWidgets('shows loading indicator', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tankProvider.overrideWith((ref) {
          return const AsyncValue.loading();
        }),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Testing Error States

```dart
testWidgets('shows error message', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        tankProvider.overrideWith((ref) {
          return AsyncValue.error('Test error', StackTrace.empty);
        }),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );

  expect(find.text('Test error'), findsOneWidget);
});
```

## Test Helpers

### Create `test/helpers/test_helpers.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pump widget with ProviderScope
Future<void> pumpWithProviders(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: widget,
      ),
    ),
  );
}

/// Mock data factories
class MockData {
  static Tank mockTank({String? id, String? name}) {
    return Tank(
      id: id ?? 'test-tank-1',
      name: name ?? 'Test Tank',
      volumeLitres: 100,
      type: TankType.freshwater,
      startDate: DateTime.now(),
      targets: WaterTargets.freshwaterTropical(),
    );
  }

  static LogEntry mockLog({String? tankId}) {
    return LogEntry(
      id: 'test-log-1',
      tankId: tankId ?? 'test-tank-1',
      timestamp: DateTime.now(),
      type: LogType.waterTest,
      waterTest: WaterTest(
        ph: 7.0,
        ammonia: 0.0,
        nitrite: 0.0,
        nitrate: 10.0,
      ),
    );
  }
}
```

## What to Test

### For Each Screen:
- ✅ Renders without crashing
- ✅ Loading state shows correctly
- ✅ Error state displays error message
- ✅ Data state shows content
- ✅ Empty state displays when no data
- ✅ Navigation works (taps lead to correct screens)
- ✅ Forms validate inputs
- ✅ Buttons trigger correct actions

### For Each Widget:
- ✅ Renders with required props
- ✅ Responds to taps/gestures
- ✅ Displays correct content based on props
- ✅ Handles edge cases (null, empty, very long text)

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/screens/home_screen_test.dart

# Run with coverage
flutter test --coverage

# View coverage HTML
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Success Criteria

- ✅ All tests pass
- ✅ 30-40% code coverage achieved
- ✅ Core user flows tested
- ✅ CI/CD integration ready
- ✅ Tests run in <2 minutes total

## Implementation Strategy

### Parallel Sub-Agents (4-5 agents)
**Agent 1:** home_screen_test.dart + test_helpers.dart setup  
**Agent 2:** tank_detail_test.dart  
**Agent 3:** learn_screen_test.dart  
**Agent 4:** add_log_test.dart  
**Agent 5:** Widget component tests (app_card, app_button, empty_state)

Each agent: 2-4 hours, clear test file structure

### Proof of Concept First (Recommended)
Start with just 2 screens:
- home_screen_test.dart (proves pattern)
- tank_detail_test.dart (proves complex screen testing)

If successful, continue with remaining screens.

## Common Pitfalls

**DON'T:**
- ❌ Test implementation details (internal state)
- ❌ Over-mock (test real widget interactions when possible)
- ❌ Write flaky tests (use `pumpAndSettle`, not arbitrary delays)
- ❌ Forget to dispose controllers in tests

**DO:**
- ✅ Test from user perspective (what they see/do)
- ✅ Use `find.byType`, `find.text`, `find.byKey`
- ✅ Mock external dependencies (API, storage)
- ✅ Test accessibility (semantic labels)

## Files to Create

```
test/
├── helpers/
│   ├── test_helpers.dart
│   └── mock_data.dart
├── screens/
│   ├── home_screen_test.dart
│   ├── tank_detail_test.dart
│   ├── learn_screen_test.dart
│   ├── add_log_test.dart
│   └── settings_screen_test.dart
└── widgets/
    ├── app_card_test.dart
    ├── app_button_test.dart
    └── empty_state_test.dart
```

## Commit Messages

```
test: add widget tests for home screen
test: add comprehensive tank detail screen tests
test: add test helpers and mock data factories
test: achieve 35% widget test coverage
```
