import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/providers/settings_provider.dart';
import 'package:danio/utils/haptic_feedback.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets(
    'persisted disabled preference suppresses every platform haptic before settings hydrate',
    (tester) async {
      final hapticCalls = _captureHapticCalls();
      final context = await _pumpHarness(tester, hapticsEnabled: false);

      await AppHaptics.light(context);
      await AppHaptics.medium(context);
      await AppHaptics.heavy(context);
      await AppHaptics.selection(context);
      await AppHaptics.success(context);
      await AppHaptics.error(context);
      await AppHaptics.vibrate(context);

      expect(hapticCalls, isEmpty);
    },
  );

  testWidgets('enabled actions emit only their intended platform haptics', (
    tester,
  ) async {
    final hapticCalls = _captureHapticCalls();
    final context = await _pumpHarness(tester, hapticsEnabled: true);

    await AppHaptics.light(context);
    expect(_arguments(hapticCalls), ['HapticFeedbackType.lightImpact']);
    hapticCalls.clear();

    await AppHaptics.medium(context);
    expect(_arguments(hapticCalls), ['HapticFeedbackType.mediumImpact']);
    hapticCalls.clear();

    await AppHaptics.heavy(context);
    expect(_arguments(hapticCalls), ['HapticFeedbackType.heavyImpact']);
    hapticCalls.clear();

    await AppHaptics.selection(context);
    expect(_arguments(hapticCalls), ['HapticFeedbackType.selectionClick']);
    hapticCalls.clear();

    final success = AppHaptics.success(context);
    await tester.pump(const Duration(milliseconds: 100));
    await success;
    expect(_arguments(hapticCalls), [
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.lightImpact',
    ]);
    hapticCalls.clear();

    final error = AppHaptics.error(context);
    await tester.pump(const Duration(milliseconds: 100));
    await error;
    expect(_arguments(hapticCalls), [
      'HapticFeedbackType.heavyImpact',
      'HapticFeedbackType.mediumImpact',
    ]);
    hapticCalls.clear();

    await AppHaptics.vibrate(context);
    expect(_arguments(hapticCalls), [null]);

    final preferences = await SharedPreferences.getInstance();
    expect(
      await preferences.setBool(hapticFeedbackPreferenceKey, false),
      isTrue,
    );
    hapticCalls.clear();

    await AppHaptics.light(context);
    expect(hapticCalls, isEmpty);
  });
}

List<MethodCall> _captureHapticCalls() {
  final hapticCalls = <MethodCall>[];
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          hapticCalls.add(call);
        }
        return null;
      });
  return hapticCalls;
}

List<Object?> _arguments(List<MethodCall> calls) {
  return calls.map((call) => call.arguments).toList();
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

  return capturedContext;
}
