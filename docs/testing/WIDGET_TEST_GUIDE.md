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

- **Target:** 20-30% initial coverage (from current 5.8%)
- **Priority:** Core widgets (AppCard, AppButton, etc.) and critical screens
- **Focus:** User-facing functionality, not internal implementation

## Examples

See comprehensive test examples in:
- `test/widgets/core/app_card_test.dart` - 29 tests covering all card variants
- `test/widgets/core/app_button_test.dart` - 28 tests covering all button variants
- `test/screens/home_screen_test.dart` - Screen-level integration tests

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Widget Testing Best Practices](https://flutter.dev/docs/cookbook/testing/widget)
- [Riverpod Testing Guide](https://riverpod.dev/docs/cookbooks/testing)
