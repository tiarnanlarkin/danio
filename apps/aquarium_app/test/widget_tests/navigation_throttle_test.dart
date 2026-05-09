import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/utils/navigation_throttle.dart';

void main() {
  setUp(NavigationThrottle.reset);

  testWidgets('rootNavigator push covers the tab bar for focused flows', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Center(
                child: TextButton(
                  onPressed: () {
                    NavigationThrottle.push(
                      context,
                      const Scaffold(body: Center(child: Text('Focused flow'))),
                      rootNavigator: true,
                    );
                  },
                  child: const Text('Open focused flow'),
                ),
              ),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            destinations: [
              NavigationDestination(icon: Icon(Icons.school), label: 'Learn'),
              NavigationDestination(
                icon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.text('Open focused flow'));
    await tester.pumpAndSettle();

    expect(find.text('Focused flow'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    Navigator.of(tester.element(find.text('Focused flow'))).pop();
    await tester.pumpAndSettle();
    NavigationThrottle.reset();
  });

  testWidgets(
    'nested route can navigate again after the tap debounce releases',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () {
                    NavigationThrottle.push(
                      context,
                      Scaffold(
                        body: Center(
                          child: Builder(
                            builder: (nestedContext) => TextButton(
                              onPressed: () {
                                NavigationThrottle.push(
                                  nestedContext,
                                  const Scaffold(
                                    body: Center(child: Text('Second route')),
                                  ),
                                );
                              },
                              child: const Text('Open second route'),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Open first route'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open first route'));
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Open second route'));
      await tester.pumpAndSettle();

      expect(find.text('Second route'), findsOneWidget);
      NavigationThrottle.reset();
    },
  );
}
