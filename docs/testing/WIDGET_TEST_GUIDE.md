# Widget Test Guide

## Overview

This guide explains how to write and run widget tests for the Aquarium App. Widget tests verify that UI components render correctly and respond to user interactions as expected.

## Test Infrastructure

### Test Helpers (`test/helpers/test_helpers.dart`)

The app provides several helper functions and mock data factories:

#### pumpWithProviders()
Wraps widgets with ProviderScope and MaterialApp for testing Riverpod providers:

```dart
import '../helpers/test_helpers.dart';

await pumpWithProviders(
  tester,
  const MyWidget(),
  overrides: [
    myProvider.overrideWith((ref) => mockValue),
  ],
);
```

#### MockData Factory

Create test data easily:

```dart
// Create a single mock tank
final tank = MockData.mockTank(
  id: 'test-1',
  name: 'My Test Tank',
  volumeLitres: 100.0,
);

// Create multiple tanks
final tanks = MockData.mockTankList(5); // Creates 5 tanks

// Create mock water test results
final waterTest = MockData.mockWaterTest(
  ph: 7.0,
  ammonia: 0.0,
  nitrite: 0.0,
  nitrate: 10.0,
);

// Create mock log entry
final log = MockData.mockLog(
  tankId: 'test-1',
  type: LogType.waterTest,
  waterTest: waterTest,
);
```

## Writing Widget Tests

### Basic Widget Test Structure

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/widgets/my_widget.dart';
import 'package:aquarium_app/theme/app_theme.dart';

void main() {
  group('MyWidget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MyWidget(),
          ),
        ),
      );

      expect(find.byType(MyWidget), findsOneWidget);
    });

    testWidgets('displays expected content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MyWidget(title: 'Test'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
```

### Testing with Riverpod Providers

```dart
import '../helpers/test_helpers.dart';
import 'package:aquarium_app/providers/tank_provider.dart';

testWidgets('shows tank data from provider', (tester) async {
  final mockTank = MockData.mockTank(name: 'Test Tank');

  await pumpWithProviders(
    tester,
    const MyWidget(),
    overrides: [
      tanksProvider.overrideWith((ref) => AsyncValue.data([mockTank])),
    ],
  );

  await tester.pumpAndSettle();
  expect(find.text('Test Tank'), findsOneWidget);
});
```

### Testing User Interactions

```dart
testWidgets('button tap fires callback', (tester) async {
  var wasTapped = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: AppButton(
          label: 'Click Me',
          onPressed: () => wasTapped = true,
        ),
      ),
    ),
  );

  await tester.tap(find.text('Click Me'));
  await tester.pump(); // Trigger a frame

  expect(wasTapped, isTrue);
});
```

### Testing Animations

When testing widgets with animations, avoid `pumpAndSettle()` for infinite animations (like `CircularProgressIndicator`):

```dart
testWidgets('loading state shows spinner', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppButton(
        label: 'Loading',
        isLoading: true,
        onPressed: () {},
      ),
    ),
  );

  // Use pump() instead of pumpAndSettle() for infinite animations
  await tester.pump();
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

### Testing Different Variants

```dart
testWidgets('primary variant renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppCard(
        variant: AppCardVariant.primary,
        child: Text('Content'),
      ),
    ),
  );

  expect(find.text('Content'), findsOneWidget);
  expect(find.byType(AppCard), findsOneWidget);
});

testWidgets('outlined variant renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppCard(
        variant: AppCardVariant.outlined,
        child: Text('Content'),
      ),
    ),
  );

  // Verify the widget renders with the variant
  expect(find.byType(AppCard), findsOneWidget);
});
```

### Testing Error States

```dart
testWidgets('handles error state gracefully', (tester) async {
  await pumpWithProviders(
    tester,
    const MyWidget(),
    overrides: [
      myProvider.overrideWith(
        (ref) => AsyncValue.error('Test error', StackTrace.current),
      ),
    ],
  );

  await tester.pumpAndSettle();
  expect(find.byType(ErrorState), findsOneWidget);
});
```

### Testing Loading States

```dart
testWidgets('shows loading indicator', (tester) async {
  await pumpWithProviders(
    tester,
    const MyWidget(),
    overrides: [
      myProvider.overrideWith((ref) => const AsyncValue.loading()),
    ],
  );

  // Check for loading indicators
  final hasLoading = find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
                     find.byWidgetPredicate(
                       (widget) => widget.runtimeType.toString().contains('Skeleton'),
                     ).evaluate().isNotEmpty;

  expect(hasLoading, isTrue);
});
```

## Running Tests

### Run All Tests

```bash
cd apps/aquarium_app
flutter test
```

### Run Specific Test File

```bash
flutter test test/widgets/core/app_card_test.dart
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### View Coverage Report

```bash
# Generate summary
lcov --summary coverage/lcov.info

# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
```

### Run Tests Matching Pattern

```bash
flutter test --name "AppCard"
flutter test --name "loading"
```

## Best Practices

### 1. **Test Behavior, Not Implementation**

✅ **Good:**
```dart
testWidgets('shows error message when validation fails', (tester) async {
  // ... setup ...
  await tester.tap(find.text('Submit'));
  expect(find.text('Invalid input'), findsOneWidget);
});
```

❌ **Bad:**
```dart
testWidgets('calls _validateInput when submit pressed', (tester) async {
  // Testing private methods/internal implementation
});
```

### 2. **Use Descriptive Test Names**

✅ **Good:**
```dart
testWidgets('loading state prevents user interaction', (tester) async {
testWidgets('shows empty state when no tanks exist', (tester) async {
```

❌ **Bad:**
```dart
testWidgets('test 1', (tester) async {
testWidgets('it works', (tester) async {
```

### 3. **Group Related Tests**

```dart
group('AppCard', () {
  group('variants', () {
    testWidgets('elevated variant renders correctly', (tester) async { ... });
    testWidgets('outlined variant renders correctly', (tester) async { ... });
  });

  group('interactions', () {
    testWidgets('tap callback fires', (tester) async { ... });
    testWidgets('long press callback fires', (tester) async { ... });
  });
});
```

### 4. **Initialize SharedPreferences for Tests**

Some widgets use SharedPreferences. Initialize mock values in setUp:

```dart
setUp(() {
  SharedPreferences.setMockInitialValues({
    'onboarding_completed': true,
    'theme_mode': 'light',
  });
});
```

### 5. **Clean Up After Tests**

```dart
tearDown(() {
  // Clean up resources, close streams, etc.
});
```

### 6. **Test Dark Mode**

```dart
testWidgets('renders correctly in dark mode', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark, // Use dark theme
      home: MyWidget(),
    ),
  );

  expect(find.byType(MyWidget), findsOneWidget);
});
```

### 7. **Avoid Over-Testing Internal Structure**

Focus on user-visible behavior rather than internal widget tree structure.

✅ **Good:**
```dart
expect(find.text('Welcome'), findsOneWidget);
expect(find.byIcon(Icons.settings), findsOneWidget);
```

❌ **Bad:**
```dart
expect(find.byType(Column), findsOneWidget); // Too implementation-specific
expect(find.byType(Padding).at(2).padding, equals(...)); // Fragile
```

## Common Patterns

### Testing Lists

```dart
testWidgets('displays list of tanks', (tester) async {
  final tanks = MockData.mockTankList(3);

  await pumpWithProviders(
    tester,
    const TankListWidget(),
    overrides: [
      tanksProvider.overrideWith((ref) => AsyncValue.data(tanks)),
    ],
  );

  await tester.pumpAndSettle();
  expect(find.byType(TankCard), findsNWidgets(3));
});
```

### Testing Forms

```dart
testWidgets('form validation works', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: MyForm()),
  );

  // Enter invalid data
  await tester.enterText(find.byKey(Key('email')), 'invalid');
  await tester.tap(find.text('Submit'));
  await tester.pump();

  expect(find.text('Invalid email'), findsOneWidget);
});
```

### Testing Navigation

```dart
testWidgets('navigates to detail screen on tap', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ListScreen(),
      routes: {
        '/detail': (context) => DetailScreen(),
      },
    ),
  );

  await tester.tap(find.text('View Details'));
  await tester.pumpAndSettle();

  expect(find.byType(DetailScreen), findsOneWidget);
});
```

## Troubleshooting

### "pumpAndSettle timed out"

**Cause:** Infinite animations (CircularProgressIndicator, etc.)  
**Solution:** Use `pump()` instead of `pumpAndSettle()`

### "No MaterialLocalizations found"

**Cause:** Missing MaterialApp wrapper  
**Solution:** Wrap your widget in MaterialApp

### "ProviderNotFoundException"

**Cause:** Missing ProviderScope  
**Solution:** Use `pumpWithProviders()` helper

### "Null check operator used on null value"

**Cause:** Async data not loaded yet  
**Solution:** Add `await tester.pump()` or `pumpAndSettle()` after async operations

## Coverage Goals

- **Target:** 30-40% overall app coverage ✅ **ACHIEVED**
- **Priority:** Core widgets (AppCard, AppButton, etc.) and critical screens
- **Focus:** User-facing functionality, not internal implementation

### Coverage Milestones

- **Wave 1 (Feb 8):** 5.8% → 73% widget coverage (AppCard, AppButton)
- **Wave 2 (Feb 15):** 73% → 30-40% app coverage (screen & flow tests)

## Advanced Test Patterns

### Complex Screen Testing

For screens with multiple data sources (like TankDetailScreen), override all required providers:

```dart
testWidgets('tank detail screen renders with all data', (tester) async {
  final mockTank = MockData.mockTank(id: 'test-tank-1');
  final mockLogs = [MockData.mockLog(tankId: 'test-tank-1')];
  final mockLivestock = [/* ... */];
  final mockEquipment = [/* ... */];
  final mockTasks = [/* ... */];

  await pumpWithProviders(
    tester,
    const TankDetailScreen(tankId: 'test-tank-1'),
    overrides: [
      tankProvider('test-tank-1').overrideWith((ref) async => mockTank),
      logsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
      allLogsProvider('test-tank-1').overrideWith((ref) async => mockLogs),
      livestockProvider('test-tank-1').overrideWith((ref) async => mockLivestock),
      equipmentProvider('test-tank-1').overrideWith((ref) async => mockEquipment),
      tasksProvider('test-tank-1').overrideWith((ref) async => mockTasks),
    ],
  );
  await tester.pumpAndSettle();

  expect(find.byType(TankDetailScreen), findsOneWidget);
  expect(find.text('Community Tank'), findsOneWidget);
});
```

### Integration/Flow Testing

Test complete user flows across multiple screens:

```dart
// test/flows/create_tank_flow_test.dart
testWidgets('complete create tank flow', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: const CreateTankScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Step 1: Enter tank name
  final nameField = find.byType(TextField).first;
  await tester.enterText(nameField, 'My New Tank');
  await tester.pumpAndSettle();

  // Step 2: Navigate to next step
  final nextButton = find.text('Next');
  await tester.tap(nextButton);
  await tester.pumpAndSettle();

  // Step 3: Enter tank size
  final sizeField = find.byType(TextField).first;
  await tester.enterText(sizeField, '200');
  await tester.pumpAndSettle();

  // Step 4: Save tank
  final saveButton = find.text('Save');
  await tester.tap(saveButton);
  await tester.pumpAndSettle();

  // Verify completion
  expect(find.text('Tank created'), findsOneWidget);
});
```

### Testing State Persistence

```dart
testWidgets('form data persists across navigation', (tester) async {
  // Navigate forward
  await tester.enterText(find.byType(TextField).first, 'Data');
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();

  // Navigate back
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();

  // Verify data persists
  expect(find.text('Data'), findsOneWidget);
});
```

### Testing Error Boundaries

```dart
testWidgets('handles provider errors gracefully', (tester) async {
  await pumpWithProviders(
    tester,
    const TankDetailScreen(tankId: 'error-tank'),
    overrides: [
      tankProvider('error-tank').overrideWith((ref) async {
        throw Exception('Database error');
      }),
    ],
  );
  await tester.pumpAndSettle();

  expect(find.text('Error'), findsOneWidget);
  expect(find.textContaining('Failed to load'), findsOneWidget);
});
```

### Testing Loading States

```dart
testWidgets('shows loading skeleton while fetching', (tester) async {
  await pumpWithProviders(
    tester,
    const TankDetailScreen(tankId: 'test-tank-1'),
    overrides: [
      tankProvider('test-tank-1').overrideWith((ref) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return mockTank;
      }),
    ],
  );

  // Should show loading indicator initially
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
  expect(find.text('Loading tank...'), findsOneWidget);

  await tester.pumpAndSettle();

  // Should show content after loading
  expect(find.byType(CircularProgressIndicator), findsNothing);
  expect(find.text('Community Tank'), findsOneWidget);
});
```

### Testing Empty States

```dart
testWidgets('shows empty state when no data', (tester) async {
  await pumpWithProviders(
    tester,
    const LivestockScreen(tankId: 'test-tank-1'),
    overrides: [
      livestockProvider('test-tank-1').overrideWith((ref) async => []),
    ],
  );
  await tester.pumpAndSettle();

  expect(find.textContaining('No livestock'), findsOneWidget);
  expect(find.textContaining('Add your first'), findsOneWidget);
});
```

### Soft Assertions for Flexible UI

When UI implementation details may vary:

```dart
testWidgets('has some form of navigation', (tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pumpAndSettle();

  // Flexible check - accept any navigation pattern
  final hasNav = find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
                 find.byType(NavigationBar).evaluate().isNotEmpty ||
                 find.byType(TabBar).evaluate().isNotEmpty ||
                 find.byType(Drawer).evaluate().isNotEmpty;

  expect(hasNav, isTrue);
});
```

## Examples

See comprehensive test examples in:

### Widget Tests (Core Components)
- `test/widgets/core/app_card_test.dart` - 29 tests covering all card variants
- `test/widgets/core/app_button_test.dart` - 28 tests covering all button variants

### Screen Tests (Complex UI)
- `test/screens/tank_detail_screen_test.dart` - 18 tests for tank detail screen
- `test/screens/learn_screen_test.dart` - 17 tests for learning screen
- `test/screens/settings_screen_test.dart` - 14 tests for settings screen

### Integration Tests (User Flows)
- `test/flows/onboarding_flow_test.dart` - 11 tests for onboarding flow
- `test/flows/create_tank_flow_test.dart` - 21 tests for tank creation flow

### Model & Service Tests
- `test/models/` - Model validation tests
- `test/services/` - Business logic tests

## Test Statistics

**Total Tests:** ~111 tests (57 widget + 54 screen/flow)
**Coverage:** 30-40% overall app coverage
**Lines Covered:** ~3,000+ lines of application code

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Widget Testing Best Practices](https://flutter.dev/docs/cookbook/testing/widget)
- [Riverpod Testing Guide](https://riverpod.dev/docs/cookbooks/testing)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)
