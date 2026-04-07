import 'dart:math';
import 'dart:ui';

/// Pure-Dart goal-seeking motion engine for fish widgets.
///
/// See `docs/plans/2026-04-07-fish-motion-rewrite-design.md` for the full
/// algorithm specification.
class FishMotion {
  FishMotion({
    required this.tankWidth,
    required this.tankHeight,
    required this.fishSize,
    this.baseTopFraction = 0.5,
    this.layerHalfHeightFraction = 0.18,
    this.maxSpeed = 35.0,
    this.minSpeed = 8.0,
    this.bobAmplitude = 6.0,
    this.bobPeriodSeconds = 3.5,
    this.glassMargin = 4.0,
    this.sandFraction = 0.78,
    Random? rng,
  }) : _rng = rng ?? Random();

  final double tankWidth;
  final double tankHeight;
  final double fishSize;
  final double baseTopFraction;
  final double layerHalfHeightFraction;
  final double maxSpeed;
  final double minSpeed;
  final double bobAmplitude;
  final double bobPeriodSeconds;
  final double glassMargin;
  final double sandFraction;

  final Random _rng;

  // Mutable state — populated by seedInitialPosition / tick
  Offset _position = Offset.zero;
  Offset _target = Offset.zero;
  double _speed = 0;
  double _pauseRemaining = 0;
  double _bobPhase = 0;
  bool _lastFacingRight = true;

  Offset get position => _position;
  bool get facingRight => _lastFacingRight;
  bool get isHovering => _pauseRemaining > 0;

  void seedInitialPosition({double phaseOffset = 0}) {
    final clampedPhase = phaseOffset.clamp(0.0, 1.0);
    final minX = glassMargin + fishSize / 2;
    final maxX = tankWidth - glassMargin - fishSize / 2;
    _position = Offset(
      minX + (maxX - minX) * clampedPhase,
      baseTopFraction * tankHeight,
    );
    _target = _position;
    _pauseRemaining = clampedPhase * 0.5;  // staggered start so fish don't sync
  }

  void tick(double dt) {
    if (dt <= 0) return;
    final clampedDt = dt > 0.1 ? 0.1 : dt;
    _bobPhase += clampedDt * 2 * pi / bobPeriodSeconds;
    // Movement logic comes in later tasks.
  }
}
