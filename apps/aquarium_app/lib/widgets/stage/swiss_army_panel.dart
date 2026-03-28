import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/room_themes.dart';
import 'stage_provider.dart';

/// Side panel that hinges in from left or right with a blade-curve animation.
class SwissArmyPanel extends ConsumerStatefulWidget {
  final StagePanel panel;
  final bool isLeft;
  final RoomTheme theme;
  final Widget child;

  const SwissArmyPanel({
    super.key,
    required this.panel,
    required this.isLeft,
    required this.theme,
    required this.child,
  });

  /// Convenience constructors
  factory SwissArmyPanel.left({
    Key? key,
    required RoomTheme theme,
    required Widget child,
  }) => SwissArmyPanel(
    key: key,
    panel: StagePanel.temp,
    isLeft: true,
    theme: theme,
    child: child,
  );

  factory SwissArmyPanel.right({
    Key? key,
    required RoomTheme theme,
    required Widget child,
  }) => SwissArmyPanel(
    key: key,
    panel: StagePanel.waterQuality,
    isLeft: false,
    theme: theme,
    child: child,
  );

  @override
  ConsumerState<SwissArmyPanel> createState() => _SwissArmyPanelState();
}

class _SwissArmyPanelState extends ConsumerState<SwissArmyPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    final disableMotion = MediaQuery.of(context).disableAnimations;
    _anim = AnimationController(
      vsync: this,
      duration: disableMotion ? Duration.zero : AppDurations.medium4,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  bool _wasOpen = false;

  @override
  Widget build(BuildContext context) {
    final isOpen = ref.watch(
      stageProvider.select((s) => s.openPanels.contains(widget.panel)),
    );

    // Drive animation + haptics only on state change
    if (isOpen && !_wasOpen) {
      _anim.forward();
      HapticFeedback.lightImpact();
    } else if (!isOpen && _wasOpen) {
      _anim.reverse();
      HapticFeedback.selectionClick();
    }
    _wasOpen = isOpen;

    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 0.72;
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    // Account for bottom nav bar so panel content stays visible above tabs.
    const tabBarHeight = 64.0;
    final effectiveBottom = bottomPad + tabBarHeight;
    final sign = widget.isLeft ? -1.0 : 1.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(_anim.value);

        // Slide + subtle rotation + tiny vertical arc
        final translateX = sign * (1 - t) * panelWidth;
        final rotateZ = sign * (1 - t) * 0.035;
        final translateY = (1 - t) * 6;

        if (t < 0.001) return const SizedBox.shrink();

        return Positioned(
          top: topPad,
          bottom: effectiveBottom,
          left: widget.isLeft ? 0 : null,
          right: widget.isLeft ? null : 0,
          width: panelWidth,
          child: Transform(
            alignment: widget.isLeft
                ? Alignment.centerLeft
                : Alignment.centerRight,
            transform: Matrix4.identity()
              ..translateByDouble(translateX, translateY, 0.0, 1.0)
              ..rotateZ(rotateZ),
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(
                left: widget.isLeft ? Radius.zero : const Radius.circular(16),
                right: widget.isLeft ? const Radius.circular(16) : Radius.zero,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.theme.glassCard,
                    border: Border(
                      left: widget.isLeft
                          ? BorderSide.none
                          : BorderSide(
                              color: widget.theme.glassBorder,
                              width: 1,
                            ),
                      right: widget.isLeft
                          ? BorderSide(
                              color: widget.theme.glassBorder,
                              width: 1,
                            )
                          : BorderSide.none,
                    ),
                  ),
                  child: SafeArea(
                    left: false,
                    right: false,
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: context.textHint,
                              borderRadius: AppRadius.xxsRadius,
                            ),
                          ),
                        ),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String _panelLabel(StagePanel panel) {
  switch (panel) {
    case StagePanel.temp:
      return 'Temperature panel';
    case StagePanel.waterQuality:
      return 'Water quality panel';
    case StagePanel.progress:
      return 'Progress panel';
    case StagePanel.tanks:
      return 'Tanks panel';
  }
}

/// Always-visible handle strip at screen edge, used to trigger panel open/close.
class StageHandleStrip extends ConsumerWidget {
  final StagePanel panel;
  final bool isLeft;
  final IconData icon;

  const StageHandleStrip({
    super.key,
    required this.panel,
    required this.isLeft,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Semantics(
      label: 'Drag to resize panel: ${_panelLabel(panel)}',
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref.read(stageProvider.notifier).toggle(panel),
        // Horizontal drag: swipe toward centre to open, swipe to edge to close.
        // Left panel: rightward drag (positive dx) = open.
        // Right panel: leftward drag (negative dx) = open.
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          final openVelocity = isLeft ? velocity > 100 : velocity < -100;
          final closeVelocity = isLeft ? velocity < -100 : velocity > 100;
          final notifier = ref.read(stageProvider.notifier);
          final isOpen = ref.read(stageProvider).openPanels.contains(panel);
          if (openVelocity && !isOpen) {
            notifier.toggle(panel);
          } else if (closeVelocity && isOpen) {
            notifier.toggle(panel);
          }
        },
        // SizedBox ensures a ≥48dp touch target (Material a11y minimum) while
        // the inner Container stays visually narrow at 20dp.
        child: SizedBox(
          width: 48,
          height: 80,
          child: Align(
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 20,
              height: 80,
              decoration: BoxDecoration(
                color: AppOverlays.black60,
                borderRadius: BorderRadius.horizontal(
                  left: isLeft ? Radius.zero : const Radius.circular(8),
                  right: isLeft ? const Radius.circular(8) : Radius.zero,
                ),
                image: const DecorationImage(
                  image: AssetImage('assets/textures/slate-dark.webp'),
                  fit: BoxFit.cover,
                  opacity: 0.6,
                ),
              ),
              child: Center(
                child: Icon(
                  isLeft ? Icons.chevron_right : Icons.chevron_left,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
