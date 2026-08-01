import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import 'brass_gauge_painter.dart';

/// Animated gauge wrapper around [BrassGaugePainter].
///
/// Drives `tempFraction` from 0 → actual on panel entry (900ms ease-out-cubic)
/// and stacks a center temperature label on top of the dial.
///
/// Respects [MediaQueryData.disableAnimations] for reduced-motion users: the
/// entry animation snaps to its end state instantly.
class BrassGauge extends StatefulWidget {
  final double? temp;
  final double gaugeMin;
  final double gaugeMax;
  final double? optimalMin;
  final double? optimalMax;
  final bool showCenterLabel;

  const BrassGauge({
    super.key,
    required this.temp,
    required this.gaugeMin,
    required this.gaugeMax,
    required this.optimalMin,
    required this.optimalMax,
    this.showCenterLabel = true,
  });

  @override
  State<BrassGauge> createState() => _BrassGaugeState();
}

class _BrassGaugeState extends State<BrassGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _anim.duration = Duration.zero;
      if (!_anim.isCompleted) _anim.value = 1.0;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  double? _targetFraction() {
    final t = widget.temp;
    if (t == null) return null;
    return ((t - widget.gaugeMin) / (widget.gaugeMax - widget.gaugeMin)).clamp(
      0.0,
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final target = _targetFraction();
    final optMin = widget.optimalMin == null
        ? null
        : (widget.optimalMin! - widget.gaugeMin) /
              (widget.gaugeMax - widget.gaugeMin);
    final optMax = widget.optimalMax == null
        ? null
        : (widget.optimalMax! - widget.gaugeMin) /
              (widget.gaugeMax - widget.gaugeMin);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final ease = Curves.easeOutCubic.transform(_anim.value);
        final frac = target != null ? target * ease : null;
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: BrassGaugePainter(
                tempFraction: frac,
                optFracMin: optMin,
                optFracMax: optMax,
                gaugeMin: widget.gaugeMin,
                gaugeMax: widget.gaugeMax,
              ),
            ),
            if (widget.showCenterLabel)
              FractionallySizedBox(
                widthFactor: 0.42,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.temp != null
                        ? '${widget.temp!.toStringAsFixed(1)}\u00b0C'
                        : '--\u00b0C',
                    style: AppTypography.titleMedium.copyWith(
                      color: const Color(0xFF202425),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
