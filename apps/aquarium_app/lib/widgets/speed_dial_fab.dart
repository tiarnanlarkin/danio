import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// A beautiful radial speed dial FAB that expands to reveal action buttons
class SpeedDialFAB extends StatefulWidget {
  final List<SpeedDialAction> actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData closedIcon;
  final IconData openIcon;

  const SpeedDialFAB({
    super.key,
    required this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.closedIcon = Icons.apps_rounded,
    this.openIcon = Icons.close_rounded,
  });

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.medium3,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.standardDecelerate,
      reverseCurve: Curves.easeInBack,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
        _showOverlay();
      } else {
        _controller.reverse();
        _removeOverlay();
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() => _isOpen = false);
      _controller.reverse();
      _removeOverlay();
    }
  }

  /// Computes the centre of the main FAB in global screen coordinates.
  Offset _fabCenter() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    // The FAB widget is a 56x56 circle — its centre in local coords is (28, 28)
    return box.localToGlobal(const Offset(28, 28));
  }

  void _showOverlay() {
    final bgColor = widget.backgroundColor ?? AppColors.primary;
    final count = widget.actions.length;
    const startAngle = 180.0;
    const endAngle = 90.0;
    final angleStep = (startAngle - endAngle) / (count - 1).clamp(1, 10);

    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        final center = _fabCenter();
        return Stack(
          children: [
            // Full-screen scrim — closes the FAB on any outside tap
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                behavior: HitTestBehavior.opaque,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),

            // Radial action buttons rendered in the Overlay layer
            for (var i = 0; i < count; i++)
              _OverlayActionButton(
                action: widget.actions[i],
                fabCenter: center,
                angle: startAngle - (i * angleStep),
                index: i,
                total: count,
                animation: _expandAnimation,
                onPressed: () {
                  _close();
                  widget.actions[i].onPressed?.call();
                },
              ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.primary;
    final fgColor = widget.foregroundColor ?? Colors.white;

    // Only the main FAB button lives in the widget tree.
    // Action buttons are rendered in the Overlay when open.
    return _MainFAB(
      isOpen: _isOpen,
      animation: _expandAnimation,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      closedIcon: widget.closedIcon,
      openIcon: widget.openIcon,
      onPressed: _toggle,
    );
  }
}

/// Renders a single action button inside the Overlay at an absolute screen position.
class _OverlayActionButton extends StatelessWidget {
  final SpeedDialAction action;
  final Offset fabCenter;
  final double angle;
  final int index;
  final int total;
  final Animation<double> animation;
  final VoidCallback onPressed;

  const _OverlayActionButton({
    required this.action,
    required this.fabCenter,
    required this.angle,
    required this.index,
    required this.total,
    required this.animation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radians = angle * (math.pi / 180);
    const radius = 110.0;
    final dx = radius * math.cos(radians);
    final dy = radius * math.sin(radians); // positive y = downward in screen coords

    return AnimatedBuilder(
      animation: animation,
      builder: (ctx, child) {
        final progress = animation.value;
        final staggeredProgress = AppCurves.standardDecelerate.transform(
          ((progress * total) - index).clamp(0.0, 1.0),
        );

        // Button centre in screen coordinates (spread from FAB centre)
        final bx = fabCenter.dx + (dx * progress);
        final by = fabCenter.dy - (dy * progress); // subtract because screen y is inverted

        return Positioned(
          // Anchor to button centre (approximate: label+icon width ~180, height ~48)
          left: bx - 180,
          top: by - 24,
          child: IgnorePointer(
            ignoring: staggeredProgress < 0.5,
            child: Transform.scale(
              scale: staggeredProgress,
              child: Opacity(opacity: staggeredProgress, child: child),
            ),
          ),
        );
      },
      child: _ActionButton(action: action, onPressed: onPressed),
    );
  }
}

class _MainFAB extends StatelessWidget {
  final bool isOpen;
  final Animation<double> animation;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData closedIcon;
  final IconData openIcon;
  final VoidCallback onPressed;

  const _MainFAB({
    required this.isOpen,
    required this.animation,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.closedIcon,
    required this.openIcon,
    required this.onPressed,
  });

  void _handleTap() {
    HapticFeedback.mediumImpact();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isOpen ? 'Close quick actions menu' : 'Open quick actions menu',
      onTap: _handleTap,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [backgroundColor, backgroundColor.withAlpha(204)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withAlpha(102),
                    blurRadius: 12 + (animation.value * 8),
                    spreadRadius: animation.value * 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: AppDurations.medium2,
                child: Icon(
                  isOpen ? openIcon : closedIcon,
                  key: ValueKey(isOpen),
                  color: foregroundColor,
                  size: 26,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final SpeedDialAction action;
  final VoidCallback onPressed;

  const _ActionButton({required this.action, required this.onPressed});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: AppDurations.medium1,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: AppCurves.emphasized),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.action.label,
      onTap: _handleTap,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label
              ExcludeSemantics(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.mediumRadius,
                    boxShadow: [
                      BoxShadow(
                        color: AppOverlays.black15,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    widget.action.label,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Icon button - 48x48 for accessibility
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.action.backgroundColor ?? Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.action.backgroundColor ?? AppColors.primary)
                          .withAlpha(76),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  widget.action.icon,
                  color: widget.action.foregroundColor ?? AppColors.primary,
                  size: AppIconSizes.md,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Represents an action in the speed dial menu
class SpeedDialAction {
  final IconData icon;
  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onPressed;

  const SpeedDialAction({
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.onPressed,
  });
}
