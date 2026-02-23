import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/widgets/common/common_widgets.dart';
import 'package:aquarium_app/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget widget) {
  return MaterialApp(
    theme: AppTheme.light,
    darkTheme: AppTheme.dark,
    home: Scaffold(body: SingleChildScrollView(child: widget)),
  );
}

// ---------------------------------------------------------------------------
// CozyCard tests
// ---------------------------------------------------------------------------

void main() {
  group('CozyCard', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(_wrap(
        const CozyCard(
          child: Text('Hello card'),
        ),
      ));
      expect(find.text('Hello card'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        CozyCard(
          semanticsLabel: 'Test card',
          onTap: () => tapped = true,
          child: const Text('Tap me'),
        ),
      ));
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('renders in dark mode without error', (tester) async {
      await tester.pumpWidget(MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: AppTheme.dark,
        home: Scaffold(
          body: CozyCard(child: const Text('Dark card')),
        ),
      ));
      expect(find.text('Dark card'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // RoomHeader tests
  // -------------------------------------------------------------------------

  group('RoomHeader', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 400,
          child: RoomHeader(title: 'Living Room'),
        ),
      ));
      expect(find.text('Living Room'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(
          width: 400,
          child: RoomHeader(title: 'Study', subtitle: 'Tank: 30L'),
        ),
      ));
      expect(find.text('Study'), findsOneWidget);
      expect(find.text('Tank: 30L'), findsOneWidget);
    });

    testWidgets('back button calls onBack', (tester) async {
      bool backPressed = false;
      await tester.pumpWidget(_wrap(
        SizedBox(
          width: 400,
          child: RoomHeader(
            title: 'Room',
            onBack: () => backPressed = true,
          ),
        ),
      ));
      // Find and tap the back button via semantics
      final backFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Back',
        description: 'Back button',
      );
      await tester.tap(backFinder);
      await tester.pump();
      expect(backPressed, isTrue);
    });

    testWidgets('no back button when onBack is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const SizedBox(width: 400, child: RoomHeader(title: 'Room')),
      ));
      final backFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Back',
      );
      expect(backFinder, findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // PrimaryActionTile tests
  // -------------------------------------------------------------------------

  group('PrimaryActionTile', () {
    testWidgets('displays title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        const PrimaryActionTile(
          icon: Icons.water_drop,
          title: 'Water Change',
          subtitle: 'Last: 7 days ago',
        ),
      ));
      expect(find.text('Water Change'), findsOneWidget);
      expect(find.text('Last: 7 days ago'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(
        PrimaryActionTile(
          icon: Icons.water_drop,
          title: 'Tap me',
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('badge is shown when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        const PrimaryActionTile(
          icon: Icons.alarm,
          title: 'Reminders',
          badge: '3',
        ),
      ));
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('has Semantics button role when interactive', (tester) async {
      await tester.pumpWidget(_wrap(
        PrimaryActionTile(
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {},
        ),
      ));
      final semantics = tester.getSemantics(find.byType(PrimaryActionTile));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // DrawerListItem tests
  // -------------------------------------------------------------------------

  group('DrawerListItem', () {
    testWidgets('displays label', (tester) async {
      await tester.pumpWidget(_wrap(
        DrawerListItem(
          icon: Icons.home,
          label: 'Home',
          onTap: () {},
        ),
      ));
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('selected state is communicated via semantics', (tester) async {
      await tester.pumpWidget(_wrap(
        DrawerListItem(
          icon: Icons.home,
          label: 'Home',
          isSelected: true,
          onTap: () {},
        ),
      ));
      final semantics = tester.getSemantics(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Home',
        ).first,
      );
      expect(semantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('badge is hidden when 0', (tester) async {
      await tester.pumpWidget(_wrap(
        DrawerListItem(
          icon: Icons.notifications,
          label: 'Alerts',
          badge: 0,
          onTap: () {},
        ),
      ));
      // Badge container should not be visible for count = 0
      expect(find.text('0'), findsNothing);
    });

    testWidgets('badge shows 99+ for counts over 99', (tester) async {
      await tester.pumpWidget(_wrap(
        DrawerListItem(
          icon: Icons.notifications,
          label: 'Alerts',
          badge: 150,
          onTap: () {},
        ),
      ));
      expect(find.text('99+'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // EmptyState tests
  // -------------------------------------------------------------------------

  group('EmptyState', () {
    testWidgets('displays title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyState(
          icon: Icons.inbox,
          title: 'No items',
          subtitle: 'Add your first item.',
        ),
      ));
      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Add your first item.'), findsOneWidget);
    });

    testWidgets('action button is shown when provided', (tester) async {
      bool actionCalled = false;
      await tester.pumpWidget(_wrap(
        EmptyState(
          icon: Icons.add_circle,
          title: 'Empty',
          actionLabel: 'Add Item',
          onAction: () => actionCalled = true,
        ),
      ));
      expect(find.text('Add Item'), findsOneWidget);
      await tester.tap(find.text('Add Item'));
      await tester.pump();
      expect(actionCalled, isTrue);
    });

    testWidgets('no action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const EmptyState(
          icon: Icons.inbox,
          title: 'Empty',
        ),
      ));
      expect(find.byType(ElevatedButton), findsNothing);
    });
  });

  // -------------------------------------------------------------------------
  // StandardInput tests
  // -------------------------------------------------------------------------

  group('StandardInput', () {
    testWidgets('renders with label and hint', (tester) async {
      await tester.pumpWidget(_wrap(
        const StandardInput(
          label: 'Tank Name',
          hint: 'e.g. Living Room 60L',
        ),
      ));
      expect(find.text('Tank Name'), findsOneWidget);
    });

    testWidgets('error text is shown', (tester) async {
      await tester.pumpWidget(_wrap(
        const StandardInput(
          label: 'Volume',
          errorText: 'Must be a positive number',
        ),
      ));
      expect(find.text('Must be a positive number'), findsOneWidget);
    });

    testWidgets('onChanged is called on input', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(
        StandardInput(
          label: 'Name',
          onChanged: (v) => changed = v,
        ),
      ));
      await tester.enterText(find.byType(TextField), 'Nemo');
      expect(changed, equals('Nemo'));
    });
  });

  // -------------------------------------------------------------------------
  // PrimaryButton & SecondaryButton tests
  // -------------------------------------------------------------------------

  group('PrimaryButton', () {
    testWidgets('renders label and calls onPressed', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(_wrap(
        PrimaryButton(
          label: 'Save',
          onPressed: () => pressed = true,
        ),
      ));
      expect(find.text('Save'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(_wrap(
        const PrimaryButton(label: 'Disabled'),
      ));
      // Semantics should communicate disabled state
      final semantics = tester.getSemantics(find.byType(PrimaryButton));
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
    });
  });

  group('SecondaryButton', () {
    testWidgets('renders label and calls onPressed', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(_wrap(
        SecondaryButton(
          label: 'Cancel',
          onPressed: () => pressed = true,
        ),
      ));
      expect(find.text('Cancel'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // Design tokens smoke test
  // -------------------------------------------------------------------------

  group('AppSpacing extended tokens', () {
    test('scale values are correct', () {
      expect(AppSpacing.s4, equals(4.0));
      expect(AppSpacing.s8, equals(8.0));
      expect(AppSpacing.s12, equals(12.0));
      expect(AppSpacing.s16, equals(16.0));
      expect(AppSpacing.s20, equals(20.0));
      expect(AppSpacing.s24, equals(24.0));
      expect(AppSpacing.s32, equals(32.0));
      expect(AppSpacing.s40, equals(40.0));
      expect(AppSpacing.s48, equals(48.0));
      expect(AppSpacing.s64, equals(64.0));
    });
  });

  group('AppRadius extended tokens', () {
    test('scale values are correct', () {
      expect(AppRadius.r4, equals(4.0));
      expect(AppRadius.r8, equals(8.0));
      expect(AppRadius.r12, equals(12.0));
      expect(AppRadius.r16, equals(16.0));
      expect(AppRadius.r24, equals(24.0));
      expect(AppRadius.r32, equals(32.0));
    });
  });

  group('AppElevation tokens', () {
    test('elevation values are correct', () {
      expect(AppElevation.none, equals(0.0));
      expect(AppElevation.low, equals(1.0));
      expect(AppElevation.subtle, equals(2.0));
      expect(AppElevation.raised, equals(4.0));
      expect(AppElevation.high, equals(8.0));
      expect(AppElevation.overlay, equals(16.0));
    });
  });

  group('AppColors semantic on-colours', () {
    test('onPrimary is white', () {
      expect(AppColors.onPrimary, equals(const Color(0xFFFFFFFF)));
    });
    test('onError is white', () {
      expect(AppColors.onError, equals(const Color(0xFFFFFFFF)));
    });
    test('onWarning is dark (WCAG contrast)', () {
      // Warning (#C99524) is light, so onWarning must be dark
      expect(AppColors.onWarning, equals(const Color(0xFF2D3436)));
    });
  });

  group('AppTypography new aliases', () {
    test('display style has correct font size', () {
      expect(AppTypography.display.fontSize, equals(40.0));
    });
    test('caption style has correct font size', () {
      expect(AppTypography.caption.fontSize, equals(12.0));
    });
    test('overline style has correct letter spacing', () {
      expect(AppTypography.overline.letterSpacing, equals(1.2));
    });
  });
}
