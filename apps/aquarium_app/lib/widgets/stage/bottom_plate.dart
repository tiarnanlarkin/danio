import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// A bottom plate that peeks from the bottom edge and can be dragged up.
/// Two instances stack independently (progress in front, tanks behind).
class BottomPlate extends StatefulWidget {
  final double peekHeight;
  final double maxHeightFraction; // e.g. 0.65 or 0.75
  final String label;
  final String emoji;
  final Widget child;
  final Widget? backgroundPainter; // CustomPaint or similar for texture
  final Color? backgroundColor;
  final double bottomOffset;

  /// Optional colour for the peek-strip tab (the visible handle area).
  /// When set, the tab gets a coloured background with rounded top corners,
  /// creating a filing-cabinet tab effect.
  final Color? tabColor;

  const BottomPlate({
    super.key,
    required this.peekHeight,
    required this.maxHeightFraction,
    required this.label,
    required this.emoji,
    required this.child,
    this.backgroundPainter,
    this.backgroundColor,
    this.bottomOffset = 0,
    this.tabColor,
  });

  @override
  State<BottomPlate> createState() => BottomPlateState();
}

class BottomPlateState extends State<BottomPlate>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragExtent = 0; // 0 = peek, 1 = fully open
  bool _isDragging = false;

  bool get isOpen => _dragExtent > 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _animation = _controller.drive(Tween(begin: 0.0, end: 0.0));
    _controller.addListener(() {
      if (!_isDragging) {
        setState(() => _dragExtent = _animation.value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxDragDistance) {
    _isDragging = true;
    setState(() {
      _dragExtent = (_dragExtent - details.primaryDelta! / maxDragDistance)
          .clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;

    // Velocity threshold: 300px/s
    double target;
    if (velocity.abs() > 300) {
      target = velocity < 0 ? 1.0 : 0.0; // up = open, down = close
    } else {
      target = _dragExtent > 0.5 ? 1.0 : 0.0;
    }

    // Spring animation
    final spring = SpringDescription.withDampingRatio(
      mass: 1.0,
      stiffness: 300.0,
      ratio: 0.8,
    );
    final simulation = SpringSimulation(spring, _dragExtent, target, -velocity / 1000);
    _animation = _controller.drive(
      Tween(begin: _dragExtent, end: target),
    );
    _controller.animateWith(simulation);

    if (target == 1.0) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final maxDragDistance =
        screenHeight * widget.maxHeightFraction - widget.peekHeight;
    final currentHeight =
        widget.peekHeight + maxDragDistance * _dragExtent;

    return Positioned(
      bottom: widget.bottomOffset,
      left: 0,
      right: 0,
      height: currentHeight + bottomPad,
      child: Semantics(
        label: '${widget.label} panel, ${isOpen ? "expanded" : "collapsed"}. Drag to ${isOpen ? "collapse" : "expand"}',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (d) => _onDragUpdate(d, maxDragDistance),
          onVerticalDragEnd: _onDragEnd,
          child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: const [
              BoxShadow(
                color: AppOverlays.black15,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Texture background
              if (widget.backgroundPainter != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Opacity(
                      opacity: 0.08,
                      child: widget.backgroundPainter!,
                    ),
                  ),
                ),

              // Content
              Column(
                children: [
                  // Drag handle peek strip — always centred
                  SizedBox(
                    height: widget.peekHeight,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        decoration: widget.tabColor != null
                            ? BoxDecoration(
                                color: widget.tabColor,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              )
                            : null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pill handle
                            Container(
                              width: 20,
                              height: 3,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: widget.tabColor != null
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : AppOverlays.black20,
                                borderRadius: AppRadius.pillRadius,
                              ),
                            ),
                            Text(
                              '${widget.emoji} ${widget.label}',
                              style: AppTypography.labelMedium.copyWith(
                                color: widget.tabColor != null
                                    ? Colors.white
                                    : context.textSecondary,
                                fontWeight: widget.tabColor != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Expandable content
                  Expanded(
                    child: _dragExtent > 0.05
                        ? Opacity(
                            opacity: _dragExtent.clamp(0.0, 1.0),
                            child: widget.child,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
