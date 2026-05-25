import 'package:danio/services/celebration_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _CelebrationHarness extends ConsumerWidget {
  const _CelebrationHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              ref
                  .read(celebrationProvider.notifier)
                  .milestone('Test milestone');
            },
            child: const Text('Trigger milestone'),
          ),
          TextButton(
            onPressed: () {
              ref.read(celebrationProvider.notifier).dismiss();
            },
            child: const Text('Dismiss celebration'),
          ),
        ],
      ),
    );
  }
}

Widget _wrap() {
  return const ProviderScope(
    child: MaterialApp(
      builder: _celebrationBuilder,
      home: _CelebrationHarness(),
    ),
  );
}

Widget _celebrationBuilder(BuildContext context, Widget? child) {
  return CelebrationOverlayWrapper(child: child ?? const SizedBox.shrink());
}

void main() {
  testWidgets('dismissing active celebration does not use disposed confetti', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());

    await tester.tap(find.text('Trigger milestone'));
    await tester.pump();
    expect(find.text('Test milestone'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Test milestone'), findsNothing);
  });
}
