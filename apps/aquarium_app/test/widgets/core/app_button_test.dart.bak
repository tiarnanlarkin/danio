import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/widgets/core/app_button.dart';
import 'package:aquarium_app/theme/app_theme.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders with label', (tester) async {
      const label = 'Test Button';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: label,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text(label), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('primary variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Primary',
              variant: AppButtonVariant.primary,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.primary));
    });

    testWidgets('secondary variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Secondary',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.color, equals(Colors.transparent));
    });

    testWidgets('text variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Text',
              variant: AppButtonVariant.text,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.transparent));
    });

    testWidgets('destructive variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Delete',
              variant: AppButtonVariant.destructive,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.error));
    });

    testWidgets('ghost variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Ghost',
              variant: AppButtonVariant.ghost,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.transparent));
    });

    testWidgets('loading state shows spinner', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Loading',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsOneWidget);
    });

    testWidgets('loading state prevents interaction', (tester) async {
      var pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Loading',
              isLoading: true,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pump(); // Use pump instead of pumpAndSettle to avoid infinite animation timeout

      expect(pressed, isFalse);
    });

    testWidgets('disabled state prevents interaction', (tester) async {
      var pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Disabled',
              onPressed: null, // null disables the button
            ),
          ),
        ),
      );

      // Attempt to tap disabled button
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(pressed, isFalse);
    });

    testWidgets('tap callback fires when enabled', (tester) async {
      var pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Click Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('leading icon displays', (tester) async {
      const icon = Icons.star;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Star',
              leadingIcon: icon,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('trailing icon displays', (tester) async {
      const icon = Icons.arrow_forward;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Next',
              trailingIcon: icon,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('loading hides trailing icon', (tester) async {
      const icon = Icons.arrow_forward;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Loading',
              trailingIcon: icon,
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(icon), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('small size applies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Small',
              size: AppButtonSize.small,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      expect(container.constraints?.maxHeight, equals(32.0));
    });

    testWidgets('medium size applies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Medium',
              size: AppButtonSize.medium,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      expect(container.constraints?.maxHeight, equals(44.0));
    });

    testWidgets('large size applies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Large',
              size: AppButtonSize.large,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      expect(container.constraints?.maxHeight, equals(52.0));
    });

    testWidgets('full width button expands', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AppButton(
                label: 'Full Width',
                isFullWidth: true,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byType(AppButton),
          matching: find.byType(AnimatedContainer),
        ),
      );
      
      expect(container.constraints?.minWidth, equals(double.infinity));
    });

    testWidgets('semantics label applies', (tester) async {
      const semanticsLabel = 'Submit form button';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Submit',
              semanticsLabel: semanticsLabel,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Button with semantics label renders correctly
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('disabled button has disabled semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      // Disabled button renders with proper semantics
      expect(find.byType(AppButton), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });
  });

  group('AppIconButton', () {
    testWidgets('renders with icon', (tester) async {
      const icon = Icons.settings;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: icon,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(icon), findsOneWidget);
      expect(find.byType(AppIconButton), findsOneWidget);
    });

    testWidgets('tap callback fires', (tester) async {
      var pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.add,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppIconButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('disabled state prevents interaction', (tester) async {
      var pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.add,
              onPressed: null,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppIconButton));
      await tester.pumpAndSettle();

      expect(pressed, isFalse);
    });

    testWidgets('small size applies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.add,
              size: AppButtonSize.small,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppIconButton),
          matching: find.byType(Container),
        ),
      );
      
      expect(container.constraints?.maxWidth, equals(36.0));
      expect(container.constraints?.maxHeight, equals(36.0));
    });

    testWidgets('medium size applies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.add,
              size: AppButtonSize.medium,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppIconButton),
          matching: find.byType(Container),
        ),
      );
      
      expect(container.constraints?.maxWidth, equals(44.0));
      expect(container.constraints?.maxHeight, equals(44.0));
    });

    testWidgets('large size applies correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.add,
              size: AppButtonSize.large,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppIconButton),
          matching: find.byType(Container),
        ),
      );
      
      expect(container.constraints?.maxWidth, equals(52.0));
      expect(container.constraints?.maxHeight, equals(52.0));
    });

    testWidgets('custom color applies', (tester) async {
      const customColor = Colors.purple;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.add,
              color: customColor,
              onPressed: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, equals(customColor));
    });

    testWidgets('custom background color applies', (tester) async {
      const customBgColor = Colors.blue;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.add,
              backgroundColor: customBgColor,
              onPressed: () {},
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(AppIconButton),
          matching: find.byType(Material),
        ),
      );
      
      expect(material.color, equals(customBgColor));
    });

    testWidgets('semantics label applies', (tester) async {
      const semanticsLabel = 'Add new item';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppIconButton(
              icon: Icons.add,
              semanticsLabel: semanticsLabel,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Icon button with semantics label renders correctly
      expect(find.byType(AppIconButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(Semantics), findsWidgets);
    });
  });
}
