import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'stage_provider.dart';

/// Wraps the LivingRoomScene to add colour pulse lighting effects
/// when panels open. Warm amber for temp, cool blue for water.
class LightingPulseWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const LightingPulseWrapper({super.key, required this.child});

  @override
  ConsumerState<LightingPulseWrapper> createState() =>
      _LightingPulseWrapperState();
}

class _LightingPulseWrapperState extends ConsumerState<LightingPulseWrapper>
    with TickerProviderStateMixin {
  late final AnimationController _warmPulse;
  late final AnimationController _coolPulse;
  bool _wasTemOpen = false;
  bool _wasWaterOpen = false;

  @override
  void initState() {
    super.initState();
    _warmPulse = AnimationController(
      vsync: this,
      duration: AppDurations.long3, // 800ms
    );
    _coolPulse = AnimationController(vsync: this, duration: AppDurations.long3);
  }

  @override
  void dispose() {
    _warmPulse.dispose();
    _coolPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) return widget.child;

    final openPanels = ref.watch(stageProvider.select((s) => s.openPanels));

    final tempOpen = openPanels.contains(StagePanel.temp);
    final waterOpen = openPanels.contains(StagePanel.waterQuality);

    // Trigger warm amber pulse when temp panel opens
    if (tempOpen && !_wasTemOpen) {
      _warmPulse.forward(from: 0).then((_) {
        if (mounted) _warmPulse.reverse();
      });
    }
    _wasTemOpen = tempOpen;

    // Trigger cool blue pulse when water panel opens
    if (waterOpen && !_wasWaterOpen) {
      _coolPulse.forward(from: 0).then((_) {
        if (mounted) _coolPulse.reverse();
      });
    }
    _wasWaterOpen = waterOpen;

    return ExcludeSemantics(
      child: Stack(
        children: [
          widget.child, // room scene — never repaints for the pulse
          IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_warmPulse, _coolPulse]),
              builder: (context, _) {
                final warmValue = Curves.easeInOutSine.transform(
                  _warmPulse.value,
                );
                final coolValue = Curves.easeInOutSine.transform(
                  _coolPulse.value,
                );

                if (warmValue < 0.001 && coolValue < 0.001) {
                  return const SizedBox.shrink();
                }

                // Blend warm amber and cool blue into a single overlay colour
                final warmAlpha = (warmValue * 20).round().clamp(0, 255);
                final coolAlpha = (coolValue * 15).round().clamp(0, 255);

                return Stack(
                  children: [
                    if (warmAlpha > 0)
                      Positioned.fill(
                        child: ColoredBox(
                          color: DanioMaterials.warmAmberPulse.withAlpha(
                            warmAlpha,
                          ),
                        ),
                      ),
                    if (coolAlpha > 0)
                      Positioned.fill(
                        child: ColoredBox(
                          color: DanioMaterials.coolBluePulse.withAlpha(
                            coolAlpha,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
