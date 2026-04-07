import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'fish_motion.dart';
import 'fish_painter.dart';

/// Animated fish that swims with goal-seeking motion across the tank.
///
/// Wraps [SoftFish] in a RepaintBoundary to prevent full-tree repaints on
/// every animation tick.
class AnimatedSwimmingFish extends StatefulWidget {
  final double size;
  final Color color;
  final double swimSpeed;       // seconds to traverse the tank at top speed
  final double verticalBob;     // bob amplitude in px
  final double startOffset;     // 0-1, phase offset for de-syncing fish
  final double tankWidth;
  final double tankHeight;
  final double baseTop;         // base Y fraction of tank height (0-1)

  const AnimatedSwimmingFish({
    super.key,
    required this.size,
    required this.color,
    required this.tankWidth,
    required this.tankHeight,
    this.swimSpeed = 8.0,
    this.verticalBob = 15.0,
    this.startOffset = 0.0,
    this.baseTop = 0.3,
  });

  @override
  State<AnimatedSwimmingFish> createState() => _AnimatedSwimmingFishState();
}

class _AnimatedSwimmingFishState extends State<AnimatedSwimmingFish>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  late FishMotion _motion;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _motion = _buildMotion();
    _motion.seedInitialPosition(phaseOffset: widget.startOffset);
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ticker.muted = MediaQuery.of(context).disableAnimations;
  }

  @override
  void didUpdateWidget(covariant AnimatedSwimmingFish oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tankWidth != widget.tankWidth ||
        oldWidget.tankHeight != widget.tankHeight ||
        oldWidget.size != widget.size ||
        oldWidget.swimSpeed != widget.swimSpeed) {
      _motion = _buildMotion();
      _motion.seedInitialPosition(phaseOffset: widget.startOffset);
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
    final tw = widget.tankWidth > 0 ? widget.tankWidth : 1;
    final speed = widget.swimSpeed > 0 ? widget.swimSpeed : 8;
    return FishMotion(
      tankWidth: widget.tankWidth,
      tankHeight: widget.tankHeight,
      fishSize: widget.size,
      baseTopFraction: widget.baseTop,
      layerHalfHeightFraction: 0.18,
      maxSpeed: tw / speed,
      minSpeed: (tw / speed) * 0.25,
      bobAmplitude: widget.verticalBob,
      bobPeriodSeconds: speed * 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = _motion.position;
    // R-088 finite guard at the render boundary — engine does not guarantee
    // pos.isFinite for degenerate tanks (zero width/height), so we defend here.
    if (!pos.dx.isFinite || !pos.dy.isFinite) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: pos.dx - widget.size / 2,
      top: pos.dy - widget.size / 2,
      child: RepaintBoundary(
        child: Transform.scale(
          scaleX: _motion.facingRight ? 1 : -1,
          child: SoftFish(size: widget.size, color: widget.color),
        ),
      ),
    );
  }
}
