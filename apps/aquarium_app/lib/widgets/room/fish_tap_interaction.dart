import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/fish_facts.dart';
import '../../providers/species_unlock_provider.dart';
import '../core/app_dialog.dart';

// ── Fish tap interaction layer ────────────────────────────────────────────────
//
// Placed on top of the tank via a Stack in ThemedAquarium.
// Detects taps anywhere in the tank and shows:
//   1. A splash ripple at the tap point
//   2. A tooltip with a random encouraging message that fades after 2s
//   3. A fish facts dialog (DNL-001) — shows a fun fact about the species.
//      Dialog stacking is prevented by a _isDialogOpen flag (fix from Phase 1).
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
///
/// ## Fish Facts Dialog (DNL-001)
/// After the ripple/tooltip, a fish facts dialog is shown with a fun fact about
/// a random unlocked species.  The species list is read from
/// [speciesUnlockProvider] so no threading through parent widgets is needed.
/// Dialog stacking is prevented by the [_isDialogOpen] flag — tapping while a
/// dialog is open is a no-op (fix from Phase 1 anti-stacking work).
class TankTapInteractionLayer extends ConsumerStatefulWidget {
  final double tankWidth;
  final double tankHeight;

  /// Fallback label shown in the tooltip when no species are unlocked yet.
  final String speciesName;

  const TankTapInteractionLayer({
    super.key,
    required this.tankWidth,
    required this.tankHeight,
    required this.speciesName,
  });

  @override
  ConsumerState<TankTapInteractionLayer> createState() =>
      _TankTapInteractionLayerState();
}

class _TankTapInteractionLayerState
    extends ConsumerState<TankTapInteractionLayer> {
  _TapEffect? _effect;

  /// Prevents dialog stacking — set true while a fish facts dialog is open.
  bool _isDialogOpen = false;

  /// Pick a random unlocked species, falling back to [widget.speciesName].
  String _pickSpecies() {
    final unlocked = ref.read(speciesUnlockProvider).toList();
    if (unlocked.isEmpty) return widget.speciesName;
    final idx = math.Random().nextInt(unlocked.length);
    return unlocked[idx];
  }

  void _handleTap(Offset localPos) {
    // Guard: don't stack dialogs
    if (_isDialogOpen) return;

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final species = _pickSpecies();

    // Trigger fish wiggle
    fishWiggleBus.trigger();

    // Haptic
    HapticFeedback.lightImpact();

    setState(() {
      _effect = _TapEffect(
        position: localPos,
        speciesName: species,
        reduceMotion: reduceMotion,
      );
    });

    // Show fish facts dialog after a brief delay so the ripple is visible first
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _showFishFactDialog(species);
    });
  }

  /// Shows a fun-fact dialog for [speciesId].
  /// The [_isDialogOpen] flag is set true before showing and cleared on dismiss,
  /// preventing recursive/stacked dialog calls (DNL-001 anti-stack fix).
  void _showFishFactDialog(String speciesId) {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    final fact = getRandomFishFact(speciesId);
    final displayName = speciesDisplayName(speciesId);

    showAppDialog<void>(
      context: context,
      title: '🐟 $displayName',
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF4A9DB5),
      child: Text(fact),
      actions: [
        _DismissButton(onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }),
      ],
    ).then((_) {
      _isDialogOpen = false;
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

// ── Dismiss button for fish facts dialog ─────────────────────────────────────

/// Simple 'Got it!' dismiss button used in the fish facts dialog.
class _DismissButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _DismissButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4A9DB5),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Text('Got it!'),
      ),
    );
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
