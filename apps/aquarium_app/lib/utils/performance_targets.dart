/// Complete-local performance scenarios that Danio must measure before the app
/// is considered polished on Android phone and tablet.
enum DanioPerformanceScenario {
  /// Cold launch until the Tank tab is visible and interactive.
  coldStartTank,

  /// Resume from background until the current surface is interactive.
  warmResume,

  /// Switch between bottom tabs until content settles.
  tabSwitch,

  /// Animated Tank surface during normal idle movement and care feedback.
  tankAnimation,

  /// Scrolling main content lists such as learning, species, logs, and tasks.
  mainScrolling,

  /// First visible paint of local image-heavy surfaces after navigation.
  imageLoading,
}

/// A measurable performance budget for one Danio scenario.
class PerformanceBudget {
  /// Creates a performance budget.
  const PerformanceBudget({
    required this.scenario,
    required this.label,
    this.maxLatency,
    this.maxAverageFrameTime,
    this.maxDroppedFramePercentage,
    this.maxBlankImageTime,
  });

  /// The scenario this budget applies to.
  final DanioPerformanceScenario scenario;

  /// Human-readable scenario label for reports and QA notes.
  final String label;

  /// Maximum acceptable interaction or startup latency.
  final Duration? maxLatency;

  /// Maximum acceptable average frame time during the measured interaction.
  final Duration? maxAverageFrameTime;

  /// Maximum acceptable dropped-frame percentage during the measured window.
  final double? maxDroppedFramePercentage;

  /// Maximum acceptable blank/placeholder time before local imagery appears.
  final Duration? maxBlankImageTime;
}

/// Shared performance targets for local Android QA.
class PerformanceTargets {
  const PerformanceTargets._();

  /// 60 FPS frame budget.
  static const frameBudget60Fps = Duration(microseconds: 16667);

  /// Slightly looser scrolling budget for long, image-rich app lists.
  static const scrollingFrameBudget = Duration(milliseconds: 20);

  /// Cold launch target in profile/release mode on a mid-range Android device.
  static const coldStartToTankVisible = Duration(milliseconds: 2500);

  /// Warm resume target after returning from the background.
  static const warmResumeToInteractive = Duration(milliseconds: 1200);

  /// Bottom-tab switch target after the destination surface has cached once.
  static const tabSwitchToSettled = Duration(milliseconds: 300);

  /// Maximum time before local imagery paints after opening an image-heavy view.
  static const imageFirstPaint = Duration(milliseconds: 500);

  /// Default dropped-frame ceiling for short interactions and tank animation.
  static const maxDroppedFramePercentage = 5.0;

  /// Dropped-frame ceiling for long scrolling surfaces.
  static const maxScrollingDroppedFramePercentage = 8.0;

  /// Budget table used by docs, tests, and future measurement scripts.
  static const scenarioBudgets = <PerformanceBudget>[
    PerformanceBudget(
      scenario: DanioPerformanceScenario.coldStartTank,
      label: 'Cold start to visible Tank',
      maxLatency: coldStartToTankVisible,
    ),
    PerformanceBudget(
      scenario: DanioPerformanceScenario.warmResume,
      label: 'Warm resume to interactive',
      maxLatency: warmResumeToInteractive,
    ),
    PerformanceBudget(
      scenario: DanioPerformanceScenario.tabSwitch,
      label: 'Bottom-tab switch to settled content',
      maxLatency: tabSwitchToSettled,
      maxAverageFrameTime: frameBudget60Fps,
      maxDroppedFramePercentage: maxDroppedFramePercentage,
    ),
    PerformanceBudget(
      scenario: DanioPerformanceScenario.tankAnimation,
      label: 'Tank animation and care feedback',
      maxAverageFrameTime: frameBudget60Fps,
      maxDroppedFramePercentage: maxDroppedFramePercentage,
    ),
    PerformanceBudget(
      scenario: DanioPerformanceScenario.mainScrolling,
      label: 'Main content scrolling',
      maxAverageFrameTime: scrollingFrameBudget,
      maxDroppedFramePercentage: maxScrollingDroppedFramePercentage,
    ),
    PerformanceBudget(
      scenario: DanioPerformanceScenario.imageLoading,
      label: 'Local image first paint',
      maxBlankImageTime: imageFirstPaint,
    ),
  ];

  /// Returns the budget for a required scenario.
  static PerformanceBudget budgetFor(DanioPerformanceScenario scenario) {
    return scenarioBudgets.singleWhere(
      (budget) => budget.scenario == scenario,
    );
  }
}
