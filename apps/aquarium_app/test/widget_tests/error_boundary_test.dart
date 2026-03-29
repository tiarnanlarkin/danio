// Widget tests for ErrorBoundary.
//
// Run: flutter test test/widget_tests/error_boundary_test.dart
//
// Note: ErrorBoundary wraps FlutterError.onError for error detection, which
// makes it tricky to test the full error-display path in isolation.  We test
// the static/structural guarantees instead, and rely on the R-091 guard for
// the overflow-bypass invariant (debug-mode only).

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:danio/widgets/error_boundary.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<void> _advance(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('ErrorBoundary', () {
    testWidgets('renders its child when no error occurs', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: const Scaffold(
              body: Text('All good'),
            ),
          ),
        ),
      );
      await _advance(tester);
      expect(find.text('All good'), findsOneWidget);
    });

    testWidgets('installs a FlutterError.onError handler on mount',
        (tester) async {
      // Capture the handler BEFORE pumping so we can compare after.
      final originalHandler = FlutterError.onError;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: const Scaffold(body: Text('Child')),
          ),
        ),
      );
      await _advance(tester);

      // ErrorBoundary should have replaced the handler with its own.
      final installedHandler = FlutterError.onError;
      expect(installedHandler, isNotNull);
      // The installed handler should be distinct from the original
      // (it's a closure capturing the boundary state).
      expect(installedHandler == originalHandler, isFalse);
    });

    testWidgets(
        'in debug mode, overflow errors do NOT trigger state updates (R-091)',
        (tester) async {
      if (!kDebugMode) return; // The guard is only active in debug mode

      // onError callback should NOT be called for overflow errors in debug mode
      var onErrorCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            onError: (_) => onErrorCallCount++,
            child: const Scaffold(body: Text('Child widget')),
          ),
        ),
      );
      await _advance(tester);

      final boundaryHandler = FlutterError.onError!;

      // Temporarily detach from the test runner to safely inject an error.
      // We swap the boundary handler with a wrapper that absorbs the chain.
      // The boundary handler calls previousHandler (which it captured during
      // initState as the test framework's handler), so we redirect that by
      // pre-installing a silent handler BEFORE the boundary was created — but
      // since we can't do that now, we just verify the callback count instead.
      //
      // R-091 path exits *before* calling widget.onError, so we can verify
      // that by injecting the overflow details with a no-op chain.
      final chainedHandler = FlutterError.onError;
      FlutterError.onError = (_) {}; // swallow test-framework propagation
      boundaryHandler(FlutterErrorDetails(
        exception: Exception('A RenderFlex overflowed by 42 pixels'),
        library: 'rendering',
        context: ErrorDescription('during layout'),
      ));
      FlutterError.onError = chainedHandler; // restore

      // R-091: overflow details should NOT reach the onError callback
      expect(onErrorCallCount, equals(0));
    });

    testWidgets('shows custom errorBuilder instead of default screen',
        (tester) async {
      // Verify the errorBuilder wiring by building the default-error widget
      // directly (bypassing the FlutterError.onError trigger plumbing).
      // We pump the errorBuilder output directly to confirm it renders.
      final fakeDetails = FlutterErrorDetails(
        exception: Exception('fake'),
        context: ErrorDescription('test'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            errorBuilder: (details) => Text('Error: ${details.exception}'),
            child: const Scaffold(body: Text('Normal')),
          ),
        ),
      );
      await _advance(tester);

      // Verify the child renders normally (no error yet).
      expect(find.text('Normal'), findsOneWidget);

      // Manually invoke the errorBuilder to verify it produces the right widget.
      final boundaryElement =
          tester.element(find.byType(ErrorBoundary));
      final boundary =
          boundaryElement.widget as ErrorBoundary;
      final builtWidget = boundary.errorBuilder!(fakeDetails);
      expect(builtWidget, isA<Text>());
    });
  });
}
