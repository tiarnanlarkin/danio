import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Fish tap interaction layer ────────────────────────────────────────────────
//
// Placed on top of the tank via a Stack in ThemedAquarium.
// Detects taps anywhere in the tank and shows:
//   1. A splash ripple at the tap point
//   2. A tooltip with a random encouraging message that fades after 2s
//
// The "excited wiggle" of the tapped fish is handled by the fish
// receiving an external wiggle signal via [FishWiggleBus].

/// A bus that notifies fish animations to wiggle for a brief period.
/// Call [trigger()] to start a 500ms excited wiggle on all fish.
class FishWiggleBus extends ChangeNotifier {
  DateTime? _wiggleUntil;

  bool get isWiggling {
    final until = _wiggleUntil;
    return until != null && DateTime.now().isBefore(until);
  }

  void trigger() {
    _wiggleUntil = DateTime.now().add(const Duration(milliseconds: 500));
    notifyListeners();
  }
}

// Shared instance (simple singleton — no need for Riverpod here)
final fishWiggleBus = FishWiggleBus();

// ── Tank tap overlay ──────────────────────────────────────────────────────────

/// Transparent tap-detection layer placed over the full tank area.
/// Shows splash + tooltip on tap.
class TankTapInteractionLayer extends StatefulWidget {
  final double tankWidth;
  final double tankHeight;
  final String speciesName; // name to show in tooltip (from species selected)

  const TankTapInteractionLayer({
    super.key,
    required this.tankWidth,
    required this.tankHeight,
    required this.speciesName,
  });

  @override
  State<TankTapInteractionLayer> createState() =>
      _TankTapInteractionLayerState();
}

class _TankTapInteractionLayerState extends State<TankTapInteractionLayer> {
  _TapEffect? _effect;

  void _handleTap(Offset localPos) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Trigger fish wiggle
    fishWiggleBus.trigger();

    // Haptic
    HapticFeedback.lightImpact();

    setState(() {
      _effect = _TapEffect(
        position: localPos,
        speciesName: widget.speciesName,
        reduceMotion: reduceMotion,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.tankWidth,
      height: widget.tankHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tap detector
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (d) => _handleTap(d.localPosition),
            child: const SizedBox.expand(),
          ),
          // Ripple + tooltip overlay
          if (_effect != null)
            _TapEffectWidget(
              key: ValueKey(_effect!.id),
              effect: _effect!,
              onDone: () {
                if (mounted) setState(() => _effect = null);
              },
            ),
        ],
      ),
    );
  }
}

// ── Tap effect data ───────────────────────────────────────────────────────────

class _TapEffect {
  final int id = DateTime.now().microsecondsSinceEpoch;
  final Offset position;
  final String speciesName;
  final bool reduceMotion;

  _TapEffect({
    required this.position,
    required this.speciesName,
    required this.reduceMotion,
  });
}

// ── Tap effect widget (ripple + tooltip) ──────────────────────────────────────

class _TapEffectWidget extends StatefulWidget {
  final _TapEffect effect;
  final VoidCallback onDone;

  const _TapEffectWidget({super.key, required this.effect, required this.onDone});

  @override
  State<_TapEffectWidget> createState() => _TapEffectWidgetState();
}

class _TapEffectWidgetState extends State<_TapEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _tooltipController;
  late Animation<double> _rippleScale;
  late Animation<double> _rippleFade;
  late Animation<double> _tooltipFade;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _rippleScale = Tween<double>(begin: 0.2, end: 2.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
    _rippleFade = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Tooltip: fade in (0-15%), hold (15-75%), fade out (75-100%)
    _tooltipFade = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 15,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 25,
      ),
    ]).animate(_tooltipController);

    if (!widget.effect.reduceMotion) {
      _rippleController.forward();
    }
    _tooltipController.forward().then((_) => widget.onDone());
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.effect.position;
    const rippleSize = 60.0;
    const tooltipOffset = -48.0;

    return Stack(
      children: [
        // Splash ripple
        if (!widget.effect.reduceMotion)
          Positioned(
            left: pos.dx - rippleSize / 2,
            top: pos.dy - rippleSize / 2,
            child: AnimatedBuilder(
              animation: _rippleController,
              builder: (context, _) {
                return Transform.scale(
                  scale: _rippleScale.value,
                  child: Opacity(
                    opacity: _rippleFade.value,
                    child: Container(
                      width: rippleSize,
                      height: rippleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF9ED8EC),
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Species tooltip
        Positioned(
          left: pos.dx - 60,
          top: pos.dy + tooltipOffset,
          child: AnimatedBuilder(
            animation: _tooltipFade,
            builder: (context, child) =>
                Opacity(opacity: _tooltipFade.value, child: child),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xDD2D3436),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatSpeciesName(widget.effect.speciesName),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatSpeciesName(String id) {
    return id
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

// ── Wiggle modifier for fish animations ──────────────────────────────────────

/// Computes an excited wiggle multiplier based on [FishWiggleBus] state.
/// Returns a value > 1.0 when a wiggle is active, 1.0 otherwise.
///
/// Usage in fish animation:
/// ```dart
/// final wiggleMult = FishWiggleHelper.amplitudeMultiplier();
/// final bobY = sin(phase) * widget.bobAmplitude * wiggleMult;
/// ```
class FishWiggleHelper {
  static double amplitudeMultiplier() {
    return fishWiggleBus.isWiggling ? 2.5 : 1.0;
  }
}
