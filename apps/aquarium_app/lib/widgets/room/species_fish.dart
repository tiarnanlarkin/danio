import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'fish_tap_interaction.dart';

/// A single fish rendered using its species sprite from assets/images/fish/.
///
/// ## Animation
/// The fish swims procedurally:
/// - Horizontal: constant-speed swim that bounces at the tank boundaries,
///   with a brief pause (200 ms) before reversing direction.
/// - Vertical: sine-wave bobbing with configurable amplitude and period.
/// - Speed jitter: a small random modifier changes every few seconds to
///   prevent all fish moving in perfect lockstep.
///
/// ## Depth layering
/// [depth] (0.0 = front, 1.0 = back) affects:
/// - Scale — background fish appear smaller.
/// - Opacity — background fish are slightly faded.
/// - Speed — background fish move more slowly.
///
/// The widget is wrapped in [RepaintBoundary] to isolate repaints.
class SpeciesFish extends StatefulWidget {
  /// Species asset ID, e.g. `neon_tetra`.  The asset is loaded from
  /// `assets/images/fish/<speciesId>.png`.
  final String speciesId;

  /// Depth layer: 0.0 = closest/front, 1.0 = furthest/back.
  final double depth;

  /// Width of the tank area in logical pixels.
  final double tankWidth;

  /// Height of the tank area in logical pixels.
  final double tankHeight;

  /// Base horizontal speed in px/second (before depth scaling).
  final double baseSpeed;

  /// Sine-wave vertical oscillation amplitude in px.
  final double bobAmplitude;

  /// Sine-wave oscillation period in seconds.
  final double bobPeriod;

  /// Fractional Y position (0-1 of tankHeight) around which the fish bobs.
  final double baseTop;

  /// Phase offset (0-1) so fish don't start in sync.
  final double phaseOffset;

  const SpeciesFish({
    super.key,
    required this.speciesId,
    required this.tankWidth,
    required this.tankHeight,
    this.depth = 0.5,
    this.baseSpeed = 30.0,
    this.bobAmplitude = 10.0,
    this.bobPeriod = 4.0,
    this.baseTop = 0.4,
    this.phaseOffset = 0.0,
  });

  @override
  State<SpeciesFish> createState() => _SpeciesFishState();
}

class _SpeciesFishState extends State<SpeciesFish>
    with SingleTickerProviderStateMixin {
  // ── Animation controller — runs 0→1 continuously ───────────────────────
  late AnimationController _ticker;

  // ── Fish state ──────────────────────────────────────────────────────────
  double _x = 0.0; // current x position (left edge)
  double _speedX = 1.0; // +1 = right, -1 = left
  bool _facingRight = true;
  bool _paused = false; // brief pause at boundary reversal
  double _lastElapsed = 0.0; // seconds at last frame
  double _speedJitter = 1.0; // random speed modifier
  double _nextJitterAt = 0.0; // elapsed seconds when jitter changes
  final _rng = math.Random();

  // ── Sprite size (after depth scaling) ──────────────────────────────────
  double get _scale => math.max(0.5, 1.0 - widget.depth * 0.4);
  double get _opacity => math.max(0.7, 1.0 - widget.depth * 0.2);
  double get _effectiveSpeed =>
      widget.baseSpeed * _speedJitter * (1.0 - widget.depth * 0.4);

  // Sprite drawn at 15% of tank height, scaled by depth
  double get _spriteSize => widget.tankHeight * 0.15 * _scale;

  @override
  void initState() {
    super.initState();

    // Stagger start X using phase offset
    _x = widget.phaseOffset * widget.tankWidth;
    _speedX = _x < widget.tankWidth / 2 ? 1.0 : -1.0;
    _facingRight = _speedX > 0;

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // effectively infinite
    )..addListener(_onTick)..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;

    // Compute elapsed seconds since last frame
    final elapsed = _ticker.lastElapsedDuration?.inMicroseconds ?? 0;
    final elapsedSeconds = elapsed / 1e6;
    final dt = (elapsedSeconds - _lastElapsed).clamp(0.0, 0.05); // cap at 50ms
    _lastElapsed = elapsedSeconds;

    if (_paused) return;

    // Speed jitter: update every 3–6 seconds
    if (elapsedSeconds >= _nextJitterAt) {
      _speedJitter = 0.7 + _rng.nextDouble() * 0.6; // 0.7 – 1.3
      _nextJitterAt = elapsedSeconds + 3.0 + _rng.nextDouble() * 3.0;
    }

    // Move horizontally
    final newX = _x + _speedX * _effectiveSpeed * dt;
    final maxX = widget.tankWidth - _spriteSize;
    const minX = 0.0;

    if (newX >= maxX || newX <= minX) {
      // Hit a wall — reverse after a short pause
      _x = newX.clamp(minX, maxX);
      _speedX = -_speedX;
      _facingRight = _speedX > 0;
      _paused = true;
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _paused = false);
        }
      });
    } else {
      _x = newX;
    }

    // Trigger repaint
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Guard: tank dimensions not yet measured — don't render (avoids
    // Transform.scale with invalid matrix and clamp(min > max) errors).
    if (_spriteSize <= 0) return const SizedBox.shrink();

    final disableMotion = MediaQuery.of(context).disableAnimations;

    // Vertical bob — amplitude increases during an excited wiggle
    final wiggleMult = FishWiggleHelper.amplitudeMultiplier();
    final phase =
        2 * math.pi * ((_lastElapsed / widget.bobPeriod) + widget.phaseOffset);
    final bobY = disableMotion
        ? 0.0
        : math.sin(phase) * widget.bobAmplitude * wiggleMult;

    final rawTop = widget.baseTop * widget.tankHeight + bobY;
    final clampedTop = rawTop.clamp(
      4.0,
      widget.tankHeight * 0.78 - _spriteSize,
    );

    return Positioned(
      left: _x,
      top: clampedTop,
      child: RepaintBoundary(
        child: Opacity(
          opacity: _opacity,
          child: Transform.scale(
            scaleX: _facingRight ? 1.0 : -1.0,
            child: SizedBox(
              width: _spriteSize,
              height: _spriteSize,
              child: Image.asset(
                'assets/images/fish/${widget.speciesId}.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _FallbackFish(size: _spriteSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Simple coloured circle fallback if the sprite asset is missing.
class _FallbackFish extends StatelessWidget {
  final double size;
  const _FallbackFish({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: const Color(0xFF6BBDD8).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
    );
  }
}
