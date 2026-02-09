import 'package:flutter_test/flutter_test.dart';
import 'package:aquarium_app/utils/performance_monitor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PerformanceMonitor Resource Cleanup', () {
    test('dispose() cleans up all resources', () {
      final monitor = PerformanceMonitor();

      // Start monitoring
      monitor.startMonitoring();
      expect(monitor.isMonitoring, true);
      expect(monitor.isDisposed, false);

      // Simulate some activity
      monitor.trackRebuild('TestWidget');
      expect(monitor.getRebuilds('TestWidget'), 1);

      // Dispose
      monitor.dispose();

      // Verify disposal state
      expect(monitor.isDisposed, true);
      expect(monitor.isMonitoring, false);

      // Verify data cleared
      expect(monitor.getRebuilds('TestWidget'), 0);
      expect(monitor.currentFPS, 60.0); // Default when no data
      expect(monitor.currentMemoryMB, 0.0);
    });

    test('cannot start monitoring after disposal', () {
      final monitor = PerformanceMonitor();

      monitor.dispose();

      // Should throw StateError
      expect(
        () => monitor.startMonitoring(),
        throwsStateError,
      );
    });

    test('stopMonitoring() allows restart, dispose() does not', () {
      final monitor = PerformanceMonitor();

      // Start and stop
      monitor.startMonitoring();
      expect(monitor.isMonitoring, true);

      monitor.stopMonitoring();
      expect(monitor.isMonitoring, false);
      expect(monitor.isDisposed, false);

      // Can restart after stop
      monitor.startMonitoring();
      expect(monitor.isMonitoring, true);

      // Now dispose
      monitor.dispose();
      expect(monitor.isDisposed, true);

      // Cannot restart after dispose
      expect(() => monitor.startMonitoring(), throwsStateError);
    });

    test('trackRebuild() is bounded to prevent memory leak', () {
      final monitor = PerformanceMonitor();

      // Track more than _maxRebuildEntries (100)
      for (int i = 0; i < 150; i++) {
        monitor.trackRebuild('Widget_$i');
      }

      // Should not exceed max entries
      expect(monitor.allRebuilds.length, lessThanOrEqualTo(100));

      monitor.dispose();
    });

    test('trackRebuild() ignores calls after disposal', () {
      final monitor = PerformanceMonitor();

      monitor.dispose();

      // Should not throw, just ignore
      monitor.trackRebuild('TestWidget');
      expect(monitor.getRebuilds('TestWidget'), 0);
    });

    test('reset() does not work on disposed monitor', () {
      final monitor = PerformanceMonitor();

      monitor.trackRebuild('TestWidget');
      expect(monitor.getRebuilds('TestWidget'), 1);

      monitor.dispose();

      // Reset should be ignored
      monitor.reset();
      expect(monitor.isDisposed, true);
    });

    test('multiple dispose() calls are safe', () {
      final monitor = PerformanceMonitor();

      monitor.startMonitoring();
      monitor.dispose();
      monitor.dispose(); // Should not throw
      monitor.dispose(); // Should not throw

      expect(monitor.isDisposed, true);
    });

    test('stopMonitoring cleans up timer and callback', () {
      final monitor = PerformanceMonitor();

      monitor.startMonitoring();
      expect(monitor.isMonitoring, true);

      // Stop should clean up resources
      monitor.stopMonitoring();
      expect(monitor.isMonitoring, false);

      // Can safely dispose after stop
      monitor.dispose();
      expect(monitor.isDisposed, true);
    });
  });

  group('PerformanceMonitor Lifecycle', () {
    test('start -> stop -> start -> dispose works correctly', () {
      final monitor = PerformanceMonitor();

      // Cycle 1
      monitor.startMonitoring();
      monitor.trackRebuild('Widget1');
      monitor.stopMonitoring();

      // Data preserved after stop
      expect(monitor.getRebuilds('Widget1'), 1);

      // Cycle 2
      monitor.startMonitoring();
      monitor.trackRebuild('Widget2');
      monitor.stopMonitoring();

      // Both tracked
      expect(monitor.getRebuilds('Widget1'), 1);
      expect(monitor.getRebuilds('Widget2'), 1);

      // Final disposal
      monitor.dispose();
      expect(monitor.isDisposed, true);
      expect(monitor.getRebuilds('Widget1'), 0);
      expect(monitor.getRebuilds('Widget2'), 0);
    });

    test('reset() clears data but allows continued use', () {
      final monitor = PerformanceMonitor();

      monitor.startMonitoring();
      monitor.trackRebuild('Widget1');
      expect(monitor.getRebuilds('Widget1'), 1);

      monitor.reset();

      // Data cleared
      expect(monitor.getRebuilds('Widget1'), 0);

      // Still usable
      expect(monitor.isDisposed, false);
      monitor.trackRebuild('Widget2');
      expect(monitor.getRebuilds('Widget2'), 1);

      monitor.dispose();
    });
  });
}
