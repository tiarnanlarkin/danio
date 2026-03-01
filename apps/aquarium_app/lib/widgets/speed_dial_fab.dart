import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Speed dial FAB matching design reference:
/// - Pill-shaped action buttons with icon+label in one pill
/// - Diagonal staggered layout fanning up-left from bottom-right
/// - BackdropFilter blur scrim with warm orange vignette
/// - Two side-by-side FABs: orange + and orange ×
class SpeedDialFAB extends StatefulWidget {
  final List<SpeedDialAction> actions;

  const SpeedDialFAB({super.key, required this.actions});

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Stack(
          children: [
            // ── Blur scrim ──────────────────────────────────────────
            if (t > 0)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _close,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 8 * t,
                      sigmaY: 8 * t,
                    ),
                    child: Container(
                      color: Color.fromARGB(
                        (140 * t).round(), 20, 20, 30,
                      ),
                    ),
                  ),
                ),
              ),

            // ── Warm orange vignette from bottom-right ───────────────
            if (t > 0)
              Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: Container(
                    width: 350,
                    height: 350,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Color.fromARGB((100 * t).round(), 240, 120, 32),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Action pills ─────────────────────────────────────────
            ..._buildActionPills(t),

            // ── FAB pair ─────────────────────────────────────────────
            Positioned(
              bottom: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // + FAB (primary)
                  _OrangeFAB(
                    icon: Icons.add,
                    size: 64,
                    color: const Color(0xFFF07820),
                    onPressed: _toggle,
                    isOpen: _isOpen,
                    animation: _controller,
                  ),
                  if (t > 0) ...[
                    const SizedBox(width: 8),
                    // × FAB (close)
                    Transform.scale(
                      scale: t,
                      child: Opacity(
                        opacity: t,
                        child: _OrangeFAB(
                          icon: Icons.close,
                          size: 56,
                          color: const Color(0xFFE8631A),
                          onPressed: _close,
                          isOpen: true,
                          animation: _controller,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Diagonal staggered positions for 5 buttons.
  static const List<Offset> _positions = [
    Offset(110, 110),  // Stats
    Offset(16,  200),  // Water Change
    Offset(200, 280),  // Feed
    Offset(16,  360),  // Quick Test
    Offset(110, 440),  // Add Tank
  ];

  List<Widget> _buildActionPills(double t) {
    final pills = <Widget>[];
    final count = widget.actions.length;

    for (var i = 0; i < count && i < _positions.length; i++) {
      final action = widget.actions[i];
      final pos = _positions[i];

      final staggerStart = i / count * 0.5;
      final staggerEnd = staggerStart + 0.5;
      final staggerT = ((t - staggerStart) / (staggerEnd - staggerStart))
          .clamp(0.0, 1.0);
      final curve = Curves.easeOutBack.transform(staggerT);

      pills.add(
        Positioned(
          bottom: pos.dy,
          right: pos.dx,
          child: Transform.scale(
            scale: curve,
            alignment: Alignment.bottomRight,
            child: Opacity(
              opacity: staggerT.clamp(0.0, 1.0),
              child: _PillButton(
                action: action,
                onPressed: () {
                  _close();
                  action.onPressed?.call();
                },
              ),
            ),
          ),
        ),
      );
    }
    return pills;
  }
}

/// Full pill button: icon + label in one stadium-shaped container
class _PillButton extends StatelessWidget {
  final SpeedDialAction action;
  final VoidCallback onPressed;

  const _PillButton({required this.action, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bg = action.backgroundColor ?? Colors.white;
    final fg = action.foregroundColor ?? AppColors.textPrimary;
    final isColored = action.backgroundColor != null &&
        action.backgroundColor != Colors.white;

    return Semantics(
      button: true,
      label: action.label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.largeRadius,
            boxShadow: [
              BoxShadow(
                color: (isColored ? bg : Colors.black)
                    .withAlpha(isColored ? 80 : 40),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, color: fg, size: 26),
              const SizedBox(width: 10),
              Text(
                action.label,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Orange circular FAB (for + and × buttons)
class _OrangeFAB extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onPressed;
  final bool isOpen;
  final Animation<double> animation;

  const _OrangeFAB({
    required this.icon,
    required this.size,
    required this.color,
    required this.onPressed,
    required this.isOpen,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(100),
                blurRadius: 12 + (animation.value * 6),
                spreadRadius: animation.value * 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: size * 0.44),
        ),
      ),
    );
  }
}

/// Represents one action in the speed dial
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
