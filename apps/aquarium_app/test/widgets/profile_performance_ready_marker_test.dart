import 'package:danio/widgets/profile_performance_ready_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _channel = MethodChannel('danio/profile_performance');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  testWidgets('reports each ready Tank lifecycle frame exactly once', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    expect(calls, isEmpty);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePerformanceReadyMarker(
          enabled: true,
          child: Semantics(
            label: 'Tank Toolbox',
            button: true,
            onTap: () {},
            child: const SizedBox(width: 48, height: 48),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(calls.map((call) => call.method), ['markTankReady']);

    await tester.pump();
    expect(calls, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump();

    expect(calls.map((call) => call.method), [
      'markTankReady',
      'markTankReady',
    ]);
  });
}
