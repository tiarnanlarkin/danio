import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

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

  Offset get position {
    final bobOffset = sin(_bobPhase) * bobAmplitude;
    return Offset(_position.dx, _position.dy + bobOffset);
  }

  /// Cached facing direction. Updated inside [tick] from horizontal
  /// velocity sign with a small hysteresis band — the getter itself is
  /// pure so multiple reads per frame are safe.
  bool get facingRight => _lastFacingRight;

  bool get isHovering => _pauseRemaining > 0;

  /// Current bob phase in radians, used by widgets that want to layer
  /// additional bob effects (e.g. tap-feedback wiggle) in phase with
  /// the engine's sine bob.
  double get bobPhase => _bobPhase;

  @visibleForTesting
  Offset get debugTarget => _target;

  @visibleForTesting
  Offset get debugPosition => _position;

  @visibleForTesting
  set debugPosition(Offset value) => _position = value;

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

    if (_pauseRemaining > 0) {
      _pauseRemaining -= clampedDt;
      if (_pauseRemaining <= 0) {
        _pickNewTarget();
      }
      return;
    }

    final toTarget = _target - _position;
    final distance = toTarget.distance;

    if (distance < fishSize * 0.25) {
      // Arrived — enter hover phase with random pause 0.3-0.8s
      _pauseRemaining = 0.3 + _rng.nextDouble() * 0.5;
      _speed = 0;
      return;
    }

    // Wall proximity factor — 0 at any wall, 1 mid-tank
    final comfortDistance = fishSize * 2;
    final xMargin = min(
      _position.dx - glassMargin,
      tankWidth - glassMargin - _position.dx,
    );
    final yMargin = min(
      _position.dy - glassMargin,
      tankHeight * sandFraction - _position.dy,
    );
    final xFactor = (xMargin / comfortDistance).clamp(0.0, 1.0);
    final yFactor = (yMargin / comfortDistance).clamp(0.0, 1.0);
    final edgeFactor = min(xFactor, yFactor);

    // Approach factor — 0 right at target, 1 outside deceleration radius
    final decelDistance = tankWidth * 0.18;
    final approachFactor = (distance / decelDistance).clamp(0.0, 1.0);

    // Target speed with exponential ease-in (time constant ≈ 0.25s; clamps
    // to snap on large dt).
    final targetSpeed = minSpeed + (maxSpeed - minSpeed) * approachFactor * edgeFactor;
    _speed += (targetSpeed - _speed) * min(clampedDt * 4, 1.0);

    final direction = Offset(toTarget.dx / distance, toTarget.dy / distance);
    _position = Offset(
      _position.dx + direction.dx * _speed * clampedDt,
      _position.dy + direction.dy * _speed * clampedDt,
    );

    // Wander: small perpendicular noise
    final perpendicular = Offset(-direction.dy, direction.dx);
    final wanderAmount = (_rng.nextDouble() - 0.5) * 0.5 * clampedDt * _speed;
    _position = Offset(
      _position.dx + perpendicular.dx * wanderAmount,
      _position.dy + perpendicular.dy * wanderAmount,
    );

    // BUG-08 hard clamp — last line of defense against any code path that
    // leaves _position outside the glass bounds. The min/max swap defends
    // against degenerate `tankWidth ≤ 2 * glassMargin + fishSize` cases where
    // the inversion would otherwise cause clamp() to throw.
    final minXC = glassMargin + fishSize / 2;
    final maxXC = tankWidth - glassMargin - fishSize / 2;
    final minYC = glassMargin + fishSize / 2;
    final maxYC = tankHeight * sandFraction - fishSize / 2;
    final clampedX = _position.dx.clamp(
      minXC < maxXC ? minXC : maxXC,
      minXC < maxXC ? maxXC : minXC,
    );
    final clampedY = _position.dy.clamp(
      minYC < maxYC ? minYC : maxYC,
      minYC < maxYC ? maxYC : minYC,
    );
    _position = Offset(clampedX, clampedY);

    // Update cached facing direction from horizontal velocity sign with
    // hysteresis. Runs only on movement ticks (pause/arrival branches early
    // return), so _lastFacingRight stays stable while the fish is hovering.
    final facingDx = _target.dx - _position.dx;
    if (facingDx.abs() >= 0.01) {
      _lastFacingRight = facingDx > 0;
    }
  }

  ({double start, double end}) _biasAwayFromCurrentEdge(
    double current,
    double min,
    double max,
  ) {
    final total = max - min;
    if (total <= 0) return (start: min, end: max);
    final fraction = (current - min) / total;
    if (fraction < 0.33) {
      return (start: min + total * 0.40, end: max);
    }
    if (fraction > 0.67) {
      return (start: min, end: min + total * 0.60);
    }
    return (start: min, end: max);
  }

  void _pickNewTarget() {
    // Target bounds use full `fishSize` (not `fishSize / 2`) so picked targets
    // sit at least one body length inside the glass. The tick() BUG-08 clamp
    // uses `fishSize / 2` — the extra margin here gives the fish room to
    // decelerate before the hard clamp kicks in.
    final minX = glassMargin + fishSize;
    final maxX = tankWidth - glassMargin - fishSize;

    final layerCenter = baseTopFraction * tankHeight;
    final layerHalf = layerHalfHeightFraction * tankHeight;
    final minYBound = (glassMargin + fishSize).toDouble();
    final maxYBound = (tankHeight * sandFraction - fishSize).clamp(0.0, tankHeight);
    final minY = layerCenter - layerHalf < minYBound ? minYBound : layerCenter - layerHalf;
    final maxY = layerCenter + layerHalf > maxYBound ? maxYBound : layerCenter + layerHalf;

    final xRange = _biasAwayFromCurrentEdge(_position.dx, minX, maxX);
    final yRange = _biasAwayFromCurrentEdge(_position.dy, minY, maxY);

    // Try up to 5 samples for minTravelDistance
    final minTravel = tankWidth * 0.25;
    Offset candidate = _position;
    for (int i = 0; i < 5; i++) {
      candidate = Offset(
        xRange.start + (xRange.end - xRange.start) * _rng.nextDouble(),
        yRange.start + (yRange.end - yRange.start) * _rng.nextDouble(),
      );
      if ((candidate - _position).distance >= minTravel) break;
    }
    _target = candidate;
  }
}
