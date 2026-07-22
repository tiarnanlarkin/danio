import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/settings_provider.dart';
import 'package:danio/utils/app_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('success feedback respects disabled haptic preference', (
    tester,
  ) async {
    final hapticCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call);
          }
          return null;
        });

    final context = await _pumpHarness(tester, hapticsEnabled: false);

    AppFeedback.showSuccess(context, 'Saved');
    await tester.pump(const Duration(milliseconds: 150));

    expect(hapticCalls, isEmpty);
  });

  testWidgets('success feedback keeps haptics when preference is enabled', (
    tester,
  ) async {
    final hapticCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call);
          }
          return null;
        });

    final context = await _pumpHarness(tester, hapticsEnabled: true);

    AppFeedback.showSuccess(context, 'Saved');
    await tester.pump(const Duration(milliseconds: 150));

    expect(hapticCalls.map((call) => call.arguments), [
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.lightImpact',
    ]);
  });

  testWidgets('messenger success feedback respects disabled haptics', (
    tester,
  ) async {
    final hapticCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call);
          }
          return null;
        });

    final context = await _pumpHarness(tester, hapticsEnabled: false);

    AppFeedback.showSuccessViaMessenger(
      ScaffoldMessenger.of(context),
      'Saved',
    );
    await tester.pump(const Duration(milliseconds: 150));

    expect(hapticCalls, isEmpty);
  });

  testWidgets('messenger success feedback emits one intended sequence', (
    tester,
  ) async {
    final hapticCalls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticCalls.add(call);
          }
          return null;
        });

    final context = await _pumpHarness(tester, hapticsEnabled: true);

    AppFeedback.showSuccessViaMessenger(
      ScaffoldMessenger.of(context),
      'Saved',
    );
    await tester.pump(const Duration(milliseconds: 150));

    expect(hapticCalls.map((call) => call.arguments), [
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.lightImpact',
    ]);
  });
}

Future<BuildContext> _pumpHarness(
  WidgetTester tester, {
  required bool hapticsEnabled,
}) async {
  SharedPreferences.setMockInitialValues({
    'haptic_feedback_enabled': hapticsEnabled,
  });

  late BuildContext capturedContext;

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    ),
  );

  final container = ProviderScope.containerOf(capturedContext, listen: false);
  container.read(settingsProvider);
  for (var i = 0; i < 10; i += 1) {
    await tester.pump(const Duration(milliseconds: 10));
    if (container.read(settingsProvider).hapticFeedbackEnabled ==
        hapticsEnabled) {
      break;
    }
  }

  expect(
    container.read(settingsProvider).hapticFeedbackEnabled,
    hapticsEnabled,
  );

  return capturedContext;
}
