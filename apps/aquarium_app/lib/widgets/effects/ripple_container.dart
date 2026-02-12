import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'water_ripple.dart';

/// A container that handles tap detection and spawns water ripple effects
/// Wrap around any widget to add interactive ripple animations
class RippleContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enableHaptics;

  const RippleContainer({
    super.key,
    required this.child,
    this.onTap,
    this.enableHaptics = true,
  });

  @override
  State<RippleContainer> createState() => _RippleContainerState();
}

class _RippleContainerState extends State<RippleContainer> {
  final List<_RippleData> _ripples = [];
  int _rippleIdCounter = 0;

  void _addRipple(Offset position) {
    // Haptic feedback for water touch feel
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }

    final id = _rippleIdCounter++;
    setState(() {
      _ripples.add(_RippleData(id: id, position: position));
    });

    // Also trigger the optional onTap callback
    widget.onTap?.call();
  }

  void _removeRipple(int id) {
    setState(() {
      _ripples.removeWhere((r) => r.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _addRipple(details.localPosition),
      child: Stack(
        children: [
          // The wrapped child widget
          widget.child,

          // Overlay for ripple effects
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: _ripples
                    .map(
                      (ripple) => WaterRipple(
                        key: ValueKey(ripple.id),
                        position: ripple.position,
                        onComplete: () => _removeRipple(ripple.id),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal data class to track individual ripples
class _RippleData {
  final int id;
  final Offset position;

  _RippleData({required this.id, required this.position});
}
