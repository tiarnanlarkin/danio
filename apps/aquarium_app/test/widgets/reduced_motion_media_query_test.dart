import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/widgets/reduced_motion_media_query.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.tiarnanlarkin.aquarium/accessibility'),
          (call) async => 1.0,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.tiarnanlarkin.aquarium/accessibility'),
          null,
        );
  });

  testWidgets('user override enables descendant MediaQuery reduced motion', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'reduced_motion_override': true});

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ReducedMotionMediaQuery(
            child: Builder(
              builder: (context) {
                return Text(
                  MediaQuery.of(context).disableAnimations
                      ? 'reduced'
                      : 'animated',
                );
              },
            ),
          ),
        ),
      ),
    );

    for (var i = 0; i < 10 && find.text('reduced').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.text('reduced'), findsOneWidget);
    expect(find.text('animated'), findsNothing);
  });
}
