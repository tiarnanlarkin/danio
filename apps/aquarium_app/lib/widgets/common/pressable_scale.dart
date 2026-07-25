import 'package:flutter/material.dart';
import 'package:danio/utils/haptic_feedback.dart';
import '../../theme/app_theme.dart';

/// A tactile spring scale wrapper that shrinks children smoothly on tap-down
/// (`0.97x` scale with [Curves.easeOutBack] physics) and triggers soft haptics.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHaptics;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enableHaptics = true,
    this.pressedScale = 0.97,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  bool get _isInteractive => widget.onTap != null || widget.onLongPress != null;

  void _handleTapDown(TapDownDetails details) {
    if (_isInteractive) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isInteractive) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (_isInteractive) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTap() {
    if (_isInteractive && widget.onTap != null) {
      if (widget.enableHaptics) AppHaptics.selection(context);
      widget.onTap!();
    }
  }

  void _handleLongPress() {
    if (_isInteractive && widget.onLongPress != null) {
      if (widget.enableHaptics) AppHaptics.medium(context);
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInteractive) return widget.child;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: AppDurations.medium1, // 150ms
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
