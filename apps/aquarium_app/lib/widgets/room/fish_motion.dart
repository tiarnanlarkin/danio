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

  Offset get position => _position;
  bool get facingRight => _lastFacingRight;
  bool get isHovering => _pauseRemaining > 0;

  @visibleForTesting
  Offset get debugTarget => _target;

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

    // Constant speed for now (Task 7 adds the speed model)
    final direction = Offset(toTarget.dx / distance, toTarget.dy / distance);
    _position = Offset(
      _position.dx + direction.dx * maxSpeed * clampedDt,
      _position.dy + direction.dy * maxSpeed * clampedDt,
    );
  }

  void _pickNewTarget() {
    final minX = glassMargin + fishSize;
    final maxX = tankWidth - glassMargin - fishSize;

    final layerCenter = baseTopFraction * tankHeight;
    final layerHalf = layerHalfHeightFraction * tankHeight;
    final minY = (glassMargin + fishSize).clamp(0.0, double.infinity).toDouble();
    final maxY = (tankHeight * sandFraction - fishSize).clamp(0.0, tankHeight);
    final boundedMinY = (layerCenter - layerHalf < minY) ? minY : layerCenter - layerHalf;
    final boundedMaxY = (layerCenter + layerHalf > maxY) ? maxY : layerCenter + layerHalf;

    // Uniform random within bounds (edge bias added in Task 8)
    final tx = minX + (maxX - minX) * _rng.nextDouble();
    final ty = boundedMinY + (boundedMaxY - boundedMinY) * _rng.nextDouble();
    _target = Offset(tx, ty);
  }
}
