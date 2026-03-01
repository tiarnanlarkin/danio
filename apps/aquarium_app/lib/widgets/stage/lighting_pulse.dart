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
      duration: const Duration(milliseconds: 800), // 800ms
    );
    _coolPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _warmPulse.dispose();
    _coolPulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return AnimatedBuilder(
      animation: Listenable.merge([_warmPulse, _coolPulse]),
      builder: (context, _) {
        final warmValue = Curves.easeInOutSine.transform(_warmPulse.value);
        final coolValue = Curves.easeInOutSine.transform(_coolPulse.value);

        Widget child = widget.child;

        if (warmValue > 0.001) {
          child = ColorFiltered(
            colorFilter: ColorFilter.mode(
              DanioMaterials.warmAmberPulse.withAlpha(
                (warmValue * 20).round().clamp(0, 255),
              ),
              BlendMode.srcOver,
            ),
            child: child,
          );
        }

        if (coolValue > 0.001) {
          child = ColorFiltered(
            colorFilter: ColorFilter.mode(
              DanioMaterials.coolBluePulse.withAlpha(
                (coolValue * 15).round().clamp(0, 255),
              ),
              BlendMode.srcOver,
            ),
            child: child,
          );
        }

        return child;
      },
    );
  }
}
