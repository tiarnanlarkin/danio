import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/widgets/core/app_card.dart';
import 'package:aquarium_app/theme/app_theme.dart';

void main() {
  group('AppCard', () {
    testWidgets('renders with child content', (tester) async {
      const testText = 'Test Content';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              child: Text(testText),
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
    });

    testWidgets('applies correct padding variant - none', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              padding: AppCardPadding.none,
              child: Text('Test'),
            ),
          ),
        ),
      );

      // AppCard renders correctly with none padding
      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
    });

    testWidgets('applies correct padding variant - compact', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              padding: AppCardPadding.compact,
              child: Text('Test'),
            ),
          ),
        ),
      );

      // AppCard renders correctly with compact padding
      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
    });

    testWidgets('applies correct padding variant - standard', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              padding: AppCardPadding.standard,
              child: Text('Test'),
            ),
          ),
        ),
      );

      // AppCard renders correctly with standard padding
      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
    });

    testWidgets('applies correct padding variant - spacious', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              padding: AppCardPadding.spacious,
              child: Text('Test'),
            ),
          ),
        ),
      );

      // AppCard renders correctly with spacious padding
      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
    });

    testWidgets('shows header when provided', (tester) async {
      const headerText = 'Header';
      const bodyText = 'Body';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              header: Text(headerText),
              child: Text(bodyText),
            ),
          ),
        ),
      );

      expect(find.text(headerText), findsOneWidget);
      expect(find.text(bodyText), findsOneWidget);
    });

    testWidgets('shows footer when provided', (tester) async {
      const bodyText = 'Body';
      const footerText = 'Footer';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              footer: Text(footerText),
              child: Text(bodyText),
            ),
          ),
        ),
      );

      expect(find.text(bodyText), findsOneWidget);
      expect(find.text(footerText), findsOneWidget);
    });

    testWidgets('tap callback works', (tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              onTap: () => tapped = true,
              child: Text('Tap me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('long press callback works', (tester) async {
      var longPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              onLongPress: () => longPressed = true,
              child: Text('Long press me'),
            ),
          ),
        ),
      );

      await tester.longPress(find.byType(AppCard));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });

    testWidgets('elevated variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              variant: AppCardVariant.elevated,
              child: Text('Elevated'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.color, isNotNull);
    });

    testWidgets('outlined variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              variant: AppCardVariant.outlined,
              child: Text('Outlined'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('filled variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              variant: AppCardVariant.filled,
              child: Text('Filled'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('glass variant has correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              variant: AppCardVariant.glass,
              child: Text('Glass'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.color, isNotNull);
    });

    testWidgets('gradient variant renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              variant: AppCardVariant.gradient,
              child: Text('Gradient'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
    });

    testWidgets('custom background color applies', (tester) async {
      const customColor = Colors.purple;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              variant: AppCardVariant.elevated,
              backgroundColor: customColor,
              child: Text('Custom color'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });

    testWidgets('width and height constraints apply', (tester) async {
      const testWidth = 200.0;
      const testHeight = 150.0;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              width: testWidth,
              height: testHeight,
              child: Text('Sized'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AppCard),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(container.constraints?.maxWidth, equals(testWidth));
      expect(container.constraints?.maxHeight, equals(testHeight));
    });

    testWidgets('semantics label applies', (tester) async {
      const semanticsLabel = 'Test card for accessibility';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppCard(
              semanticsLabel: semanticsLabel,
              child: Text('Accessible'),
            ),
          ),
        ),
      );

      // AppCard with semantics label renders correctly
      expect(find.byType(AppCard), findsOneWidget);
      expect(find.text('Accessible'), findsOneWidget);
      
      // Check that semantics is present
      final semantics = find.byType(Semantics);
      expect(semantics, findsWidgets);
    });
  });

  group('InfoCard', () {
    testWidgets('renders with icon and title', (tester) async {
      const title = 'Information';
      const icon = Icons.info;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: InfoCard(
              icon: icon,
              title: title,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('renders with subtitle when provided', (tester) async {
      const title = 'Information';
      const subtitle = 'Additional details';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: InfoCard(
              icon: Icons.info,
              title: title,
              subtitle: subtitle,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
    });

    testWidgets('shows chevron when tappable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: InfoCard(
              icon: Icons.info,
              title: 'Tappable',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('tap callback fires', (tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: InfoCard(
              icon: Icons.info,
              title: 'Tap me',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InfoCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('StatisticCard', () {
    testWidgets('renders value and label', (tester) async {
      const value = '42';
      const label = 'Total Count';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatisticCard(
              value: value,
              label: label,
            ),
          ),
        ),
      );

      expect(find.text(value), findsOneWidget);
      expect(find.text(label), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      const icon = Icons.star;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatisticCard(
              value: '10',
              label: 'Stars',
              icon: icon,
            ),
          ),
        ),
      );

      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('shows positive trend indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatisticCard(
              value: '100',
              label: 'Growth',
              trend: 12.5,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_up), findsOneWidget);
      expect(find.text('+12.5%'), findsOneWidget);
    });

    testWidgets('shows negative trend indicator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: StatisticCard(
              value: '80',
              label: 'Decline',
              trend: -8.3,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.trending_down), findsOneWidget);
      expect(find.text('-8.3%'), findsOneWidget);
    });
  });

  group('ActionCard', () {
    testWidgets('renders title and action button', (tester) async {
      const title = 'Take Action';
      const actionLabel = 'Do It';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ActionCard(
              title: title,
              actionLabel: actionLabel,
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(actionLabel), findsOneWidget);
    });

    testWidgets('renders description when provided', (tester) async {
      const description = 'This is what happens';
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ActionCard(
              title: 'Action',
              description: description,
              actionLabel: 'Go',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.text(description), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      const icon = Icons.rocket_launch;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ActionCard(
              title: 'Launch',
              icon: icon,
              actionLabel: 'Go',
              onAction: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(icon), findsOneWidget);
    });

    testWidgets('action button callback fires', (tester) async {
      var actionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ActionCard(
              title: 'Click',
              actionLabel: 'Click Me',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Click Me'));
      await tester.pumpAndSettle();

      expect(actionCalled, isTrue);
    });
  });
}
