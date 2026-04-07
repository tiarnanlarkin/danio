import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'fish_motion.dart';
import 'fish_tap_interaction.dart';

/// A single fish rendered using its species sprite from assets/images/fish/.
///
/// ## Animation
/// The fish swims procedurally using the shared [FishMotion] engine:
/// - Horizontal + vertical: goal-seeking motion with ease-out speed and a
///   brief hover on arrival at each target.
/// - Vertical bob: sine-wave bobbing layered on top of the engine position,
///   with amplitude increased during an excited wiggle (tap feedback).
/// - Wall avoidance: edge-biased target picking plus a hard clamp on position.
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
  // ── Motion engine ──────────────────────────────────────────────────────
  late Ticker _ticker;
  late FishMotion _motion;
  Duration _lastElapsed = Duration.zero;

  // ── Depth-derived render values ────────────────────────────────────────
  double get _scale => math.max(0.5, 1.0 - widget.depth * 0.4);
  double get _opacity => math.max(0.7, 1.0 - widget.depth * 0.2);

  // Sprite drawn at 15% of tank height, scaled by depth
  double get _spriteSize => widget.tankHeight * 0.15 * _scale;

  @override
  void initState() {
    super.initState();
    _motion = _buildMotion();
    _motion.seedInitialPosition(phaseOffset: widget.phaseOffset);
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticker.muted = MediaQuery.of(context).disableAnimations;
  }

  @override
  void didUpdateWidget(covariant SpeciesFish oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tankWidth != widget.tankWidth ||
        oldWidget.tankHeight != widget.tankHeight ||
        oldWidget.depth != widget.depth ||
        oldWidget.baseSpeed != widget.baseSpeed ||
        oldWidget.bobAmplitude != widget.bobAmplitude ||
        oldWidget.bobPeriod != widget.bobPeriod ||
        oldWidget.baseTop != widget.baseTop ||
        oldWidget.phaseOffset != widget.phaseOffset) {
      _motion = _buildMotion();
      _motion.seedInitialPosition(phaseOffset: widget.phaseOffset);
      _lastElapsed = Duration.zero;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final dtMicros = (elapsed - _lastElapsed).inMicroseconds;
    _lastElapsed = elapsed;
    final dt = dtMicros / 1e6;
    if (dt <= 0) return;
    _motion.tick(dt);
    if (mounted) setState(() {});
  }

  FishMotion _buildMotion() {
    // Depth scaling: background fish smaller + slower. Reuse the `_scale`
    // and `_spriteSize` getters so the engine and renderer always agree on
    // size if the depth math is ever tuned.
    final depthScale = _scale;
    final effectiveSize = _spriteSize;
    final effectiveMaxSpeed = widget.baseSpeed * depthScale;
    final effectiveMinSpeed = effectiveMaxSpeed * 0.25;
    return FishMotion(
      tankWidth: widget.tankWidth,
      tankHeight: widget.tankHeight,
      fishSize: effectiveSize,
      baseTopFraction: widget.baseTop,
      layerHalfHeightFraction: 0.20,
      maxSpeed: effectiveMaxSpeed,
      minSpeed: effectiveMinSpeed,
      bobAmplitude: widget.bobAmplitude,
      bobPeriodSeconds: widget.bobPeriod,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Guard: tank dimensions not yet measured — don't render (avoids
    // Transform.scale with invalid matrix and clamp(min > max) errors).
    if (_spriteSize <= 0) return const SizedBox.shrink();

    final pos = _motion.position;
    // R-088 finite guard at the render boundary — engine does not guarantee
    // pos.isFinite for degenerate tanks (zero width/height), so we defend here.
    if (!pos.dx.isFinite || !pos.dy.isFinite) {
      return const SizedBox.shrink();
    }

    // Extra wiggle amplitude during tap feedback. The base bob is applied by
    // the engine inside _motion.position; this multiplier adds "excited" bob
    // on top by reading the engine's live `bobPhase` directly so the extra sin
    // term stays perfectly in phase with the underlying motion — producing a
    // clean amplitude scale-up instead of a sum of two out-of-phase sinusoids.
    //
    // Accessibility: under reduced motion the ticker is muted, so
    // _motion.bobPhase is frozen. If we still applied extraBob on a tap, the
    // fish would jump by a fixed offset for 500ms and snap back. Gate the
    // whole wiggle on !disableMotion so reduced motion is truly motion-free.
    final disableMotion = MediaQuery.of(context).disableAnimations;
    final wiggleMult = FishWiggleHelper.amplitudeMultiplier();
    final extraBob = (wiggleMult > 1.0 && !disableMotion)
        ? math.sin(_motion.bobPhase) *
            widget.bobAmplitude *
            (wiggleMult - 1.0)
        : 0.0;

    final left = pos.dx - _spriteSize / 2;
    final top = pos.dy - _spriteSize / 2 + extraBob;

    return Positioned(
      left: left,
      top: top,
      child: RepaintBoundary(
        child: Opacity(
          opacity: _opacity,
          child: Transform.scale(
            scaleX: _motion.facingRight ? 1.0 : -1.0,
            child: SizedBox(
              width: _spriteSize,
              height: _spriteSize,
              child: ExcludeSemantics(
                child: Image.asset(
                  'assets/images/fish/${widget.speciesId}.webp',
                  fit: BoxFit.contain,
                  cacheWidth: 128,
                  cacheHeight: 128,
                  errorBuilder: (_, __, ___) => _FallbackFish(size: _spriteSize),
                ),
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
