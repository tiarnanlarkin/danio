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
  }) =>
      SwissArmyPanel(
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
  }) =>
      SwissArmyPanel(
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
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
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
          bottom: bottomPad,
          left: widget.isLeft ? 0 : null,
          right: widget.isLeft ? null : 0,
          width: panelWidth,
          child: Transform(
            alignment: widget.isLeft ? Alignment.centerLeft : Alignment.centerRight,
            transform: Matrix4.identity()
              ..translate(translateX, translateY)
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
                          : BorderSide(color: widget.theme.glassBorder, width: 1),
                      right: widget.isLeft
                          ? BorderSide(color: widget.theme.glassBorder, width: 1)
                          : BorderSide.none,
                    ),
                  ),
                  child: SafeArea(
                    left: false,
                    right: false,
                    child: widget.child,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ref.read(stageProvider.notifier).toggle(panel),
      child: Container(
        width: 14,
        height: 80,
        decoration: BoxDecoration(
          color: AppOverlays.black40,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? Radius.zero : const Radius.circular(8),
            right: isLeft ? const Radius.circular(8) : Radius.zero,
          ),
          image: const DecorationImage(
            image: AssetImage('assets/textures/slate-dark.png'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: Center(
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
