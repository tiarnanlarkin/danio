import 'package:danio/utils/performance_targets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceTargets', () {
    test('records the complete-local mid-range Android budgets', () {
      expect(
        PerformanceTargets.coldStartToTankVisible,
        const Duration(milliseconds: 2500),
      );
      expect(
        PerformanceTargets.warmResumeToInteractive,
        const Duration(milliseconds: 1200),
      );
      expect(
        PerformanceTargets.tabSwitchToSettled,
        const Duration(milliseconds: 300),
      );
      expect(
        PerformanceTargets.imageFirstPaint,
        const Duration(milliseconds: 500),
      );
      expect(
        PerformanceTargets.frameBudget60Fps,
        const Duration(microseconds: 16667),
      );
      expect(PerformanceTargets.maxDroppedFramePercentage, 5);
      expect(PerformanceTargets.maxScrollingDroppedFramePercentage, 8);
    });

    test('lists every required whole-app performance scenario', () {
      final scenarios = PerformanceTargets.scenarioBudgets
          .map((budget) => budget.scenario)
          .toSet();

      expect(
        scenarios,
        containsAll(<DanioPerformanceScenario>{
          DanioPerformanceScenario.coldStartTank,
          DanioPerformanceScenario.warmResume,
          DanioPerformanceScenario.tabSwitch,
          DanioPerformanceScenario.tankAnimation,
          DanioPerformanceScenario.mainScrolling,
          DanioPerformanceScenario.imageLoading,
        }),
      );
    });

    test('gives animation and scrolling explicit frame budgets', () {
      final tankAnimation = PerformanceTargets.budgetFor(
        DanioPerformanceScenario.tankAnimation,
      );
      final mainScrolling = PerformanceTargets.budgetFor(
        DanioPerformanceScenario.mainScrolling,
      );

      expect(tankAnimation.maxAverageFrameTime, isNotNull);
      expect(tankAnimation.maxDroppedFramePercentage, 5);
      expect(mainScrolling.maxAverageFrameTime, isNotNull);
      expect(mainScrolling.maxDroppedFramePercentage, 8);
    });
  });
}
