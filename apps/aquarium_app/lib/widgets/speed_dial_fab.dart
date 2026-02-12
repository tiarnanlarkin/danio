import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInBack,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() => _isOpen = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.primary;
    final fgColor = widget.foregroundColor ?? Colors.white;

    return SizedBox(
      width: 280,
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          // Scrim/backdrop when open
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _close,
                child: Container(color: Colors.transparent),
              ),
            ),

          // Action buttons in radial pattern
          ..._buildActionButtons(bgColor),

          // Main FAB
          Positioned(
            bottom: 0,
            right: 0,
            child: _MainFAB(
              isOpen: _isOpen,
              animation: _expandAnimation,
              backgroundColor: bgColor,
              foregroundColor: fgColor,
              closedIcon: widget.closedIcon,
              openIcon: widget.openIcon,
              onPressed: _toggle,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(Color primaryColor) {
    final count = widget.actions.length;
    final buttons = <Widget>[];

    // Fan angle: spread actions in an arc from bottom-right
    // Start at 180° (left), end at 90° (up)
    const startAngle = 180.0;
    const endAngle = 90.0;
    final angleStep = (startAngle - endAngle) / (count - 1).clamp(1, 10);

    for (var i = 0; i < count; i++) {
      final action = widget.actions[i];
      final angle = startAngle - (i * angleStep);
      final radians = angle * (math.pi / 180);

      // Distance from center
      const radius = 110.0;
      final x = radius * math.cos(radians);
      final y = radius * math.sin(radians);

      buttons.add(
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            final progress = _expandAnimation.value;
            // Stagger the animation slightly for each button
            final staggeredProgress = Curves.easeOut.transform(
              ((progress * count) - i).clamp(0.0, 1.0),
            );

            return Positioned(
              bottom: 8 + (-y * progress),
              right: 8 + (-x * progress),
              child: Transform.scale(
                scale: staggeredProgress,
                child: Opacity(opacity: staggeredProgress, child: child),
              ),
            );
          },
          child: _ActionButton(
            action: action,
            onPressed: () {
              _close();
              action.onPressed?.call();
            },
          ),
        ),
      );
    }

    return buttons;
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isOpen ? 'Close quick actions menu' : 'Open quick actions menu',
      child: GestureDetector(
        onTap: onPressed,
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
                  colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.4),
                    blurRadius: 12 + (animation.value * 8),
                    spreadRadius: animation.value * 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
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

class _ActionButton extends StatelessWidget {
  final SpeedDialAction action;
  final VoidCallback onPressed;

  const _ActionButton({required this.action, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: action.label,
      child: GestureDetector(
        onTap: onPressed,
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
                  action.label,
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
                color: action.backgroundColor ?? Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (action.backgroundColor ?? AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                action.icon,
                color: action.foregroundColor ?? AppColors.primary,
                size: 24,
              ),
            ),
          ],
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
