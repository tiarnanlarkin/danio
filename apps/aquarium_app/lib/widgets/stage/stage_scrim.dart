import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import 'stage_provider.dart';

/// Animated backdrop scrim that darkens + blurs when panels are open.
/// Tap to close all panels.
class StageScrim extends ConsumerStatefulWidget {
  const StageScrim({super.key});

  @override
  ConsumerState<StageScrim> createState() => _StageScrimState();
}

class _StageScrimState extends ConsumerState<StageScrim>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.long1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    _controller.duration = disableMotion ? Duration.zero : AppDurations.long1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intensity = ref.watch(stageProvider.select((s) => s.scrimIntensity));
    final hasOpenPanels = ref.watch(
      stageProvider.select((s) => s.openPanels.isNotEmpty),
    );

    // Drive animation controller towards target
    if (hasOpenPanels) {
      _controller.animateTo(
        intensity.clamp(0.0, 1.0),
        duration: AppDurations.long1,
        curve: Curves.easeOutCubic,
      );
    } else {
      _controller.animateTo(
        0.0,
        duration: AppDurations.long1,
        curve: Curves.easeOutCubic,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final value = _controller.value;
        if (value < 0.001) return const SizedBox.shrink();

        return Semantics(
          label: 'Close panel',
          button: true,
          child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => ref.read(stageProvider.notifier).closeAll(),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: value * 6, sigmaY: value * 6),
              child: Container(color: Color.fromRGBO(0, 0, 0, value * 0.25)),
            ),
          ),
        ),
        );
      },
    );
  }
}
