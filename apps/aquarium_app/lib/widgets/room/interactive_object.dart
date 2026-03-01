import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../theme/app_theme.dart';

/// Interactive tappable object for room scenes.
/// Features subtle "tap me" animations that are more prominent for new users.
class InteractiveObject extends StatefulWidget {
  /// Icon to display
  final IconData icon;

  /// Label text shown on hover/long-press
  final String label;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Size of the object
  final double size;

  /// Color of the icon
  final Color? iconColor;

  /// Background color (if any)
  final Color? backgroundColor;

  /// Whether to show the "new user" prominent animation
  final bool isNewUser;

  /// Whether to show the label by default (without hover)
  final bool showLabel;

  /// Custom child widget instead of icon
  final Widget? child;

  /// Glow color for the pulse animation
  final Color? glowColor;

  /// Animation style
  final InteractiveAnimationStyle animationStyle;

  const InteractiveObject({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.size = 48,
    this.iconColor,
    this.backgroundColor,
    this.isNewUser = false,
    this.showLabel = false,
    this.child,
    this.glowColor,
    this.animationStyle = InteractiveAnimationStyle.pulse,
  });

  @override
  State<InteractiveObject> createState() => _InteractiveObjectState();
}

/// Animation styles for interactive object "tap me" hints.
///
/// Defines different visual attention-getting behaviors for interactive elements.
enum InteractiveAnimationStyle {
  pulse,   // Gentle glow pulse
  bounce,  // Subtle bounce
  wobble,  // Slight rotation wobble
  shimmer, // Shimmering highlight
}

class _InteractiveObjectState extends State<InteractiveObject>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  bool _showTooltip = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation (continuous subtle animation)
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isNewUser ? 1200 : 2000),
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: AppCurves.standard,
    ));

    // Press animation (on tap)
    _pressController = AnimationController(
      vsync: this,
      duration: AppDurations.short,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: AppCurves.standardDecelerate,
    ));

    // Start pulsing for new users, or with subtle animation for others
    if (widget.isNewUser) {
      _pulseController.repeat(reverse: true);
    } else {
      // Subtle occasional pulse for existing users
      _startSubtlePulse();
    }
  }

  void _startSubtlePulse() {
    Future.delayed(Duration(milliseconds: 500 + math.Random().nextInt(2000)), () {
      if (mounted) {
        _pulseController.forward().then((_) {
          if (mounted) {
            _pulseController.reverse().then((_) {
              if (mounted) _startSubtlePulse();
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    setState(() => _showTooltip = true);

    // Hide tooltip after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _showTooltip = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: _handleLongPress,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Main object
              Transform.scale(
                scale: _scaleAnimation.value * _getScaleForStyle(),
                child: _buildObjectWithAnimation(),
              ),

              // Tooltip label
              if (_showTooltip || widget.showLabel)
                Positioned(
                  bottom: -28,
                  left: -20,
                  right: -20,
                  child: _buildTooltip(),
                ),
            ],
          );
        },
      ),
    );
  }

  double _getScaleForStyle() {
    switch (widget.animationStyle) {
      case InteractiveAnimationStyle.bounce:
        return 1.0 + (_pulseAnimation.value * 0.05);
      default:
        return 1.0;
    }
  }

  Widget _buildObjectWithAnimation() {
    final glowColor = widget.glowColor ?? 
        widget.iconColor?.withAlpha(128) ?? 
        AppOverlays.white30;

    final glowIntensity = widget.isNewUser ? 0.6 : 0.3;
    final glowRadius = widget.isNewUser ? 20.0 : 12.0;

    Widget content = widget.child ?? Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          // Glow effect
          if (widget.animationStyle == InteractiveAnimationStyle.pulse)
            BoxShadow(
              color: glowColor.withAlpha((_pulseAnimation.value * glowIntensity * 255).round()),
              blurRadius: glowRadius + (_pulseAnimation.value * 10),
              spreadRadius: _pulseAnimation.value * 4,
            ),
        ],
      ),
      child: Center(
        child: Icon(
          widget.icon,
          size: widget.size * 0.6,
          color: widget.iconColor ?? Colors.white,
        ),
      ),
    );

    // Apply animation style
    switch (widget.animationStyle) {
      case InteractiveAnimationStyle.wobble:
        return Transform.rotate(
          angle: math.sin(_pulseAnimation.value * math.pi * 2) * 0.05,
          child: content,
        );
      case InteractiveAnimationStyle.shimmer:
        return _ShimmerWrapper(
          animation: _pulseAnimation,
          child: content,
        );
      default:
        return content;
    }
  }

  Widget _buildTooltip() {
    return AnimatedOpacity(
      duration: AppDurations.medium2,
      opacity: _showTooltip || widget.showLabel ? 1.0 : 0.0,
      child: ClipRRect(
        borderRadius: AppRadius.smallRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppOverlays.black50,
              borderRadius: AppRadius.smallRadius,
              border: Border.all(color: AppOverlays.white20),
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer effect wrapper
class _ShimmerWrapper extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _ShimmerWrapper({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Colors.white,
            Colors.white54,
            Colors.white,
          ],
          stops: [
            0.0,
            animation.value,
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcATop,
      child: child,
    );
  }
}

/// Positioned interactive object with built-in positioning
class PositionedInteractiveObject extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final InteractiveObject object;

  const PositionedInteractiveObject({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.object,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: object,
    );
  }
}

/// Collection of themed interactive objects for living room
class LivingRoomObjects {
  static InteractiveObject journal({
    required VoidCallback onTap,
    bool isNewUser = false,
  }) {
    return InteractiveObject(
      icon: Icons.book_outlined,
      label: 'Journal',
      onTap: onTap,
      size: 56,
      iconColor: const Color(0xFFD4A574),
      glowColor: const Color(0xFFD4A574),
      isNewUser: isNewUser,
      animationStyle: InteractiveAnimationStyle.pulse,
    );
  }

  static InteractiveObject calendar({
    required VoidCallback onTap,
    bool isNewUser = false,
  }) {
    return InteractiveObject(
      icon: Icons.calendar_month_outlined,
      label: 'Schedule',
      onTap: onTap,
      size: 56,
      iconColor: AppColors.primary,
      glowColor: AppColors.primary,
      isNewUser: isNewUser,
      animationStyle: InteractiveAnimationStyle.pulse,
    );
  }
}

/// Collection of themed interactive objects for study room
class StudyRoomObjects {
  static InteractiveObject bookshelf({
    required VoidCallback onTap,
    bool isNewUser = false,
    String label = 'Lessons',
  }) {
    return InteractiveObject(
      icon: Icons.auto_stories,
      label: label,
      onTap: onTap,
      size: 42,
      iconColor: const Color(0xFFD4A574),
      glowColor: const Color(0xFFD4A574),
      isNewUser: isNewUser,
      animationStyle: InteractiveAnimationStyle.wobble,
    );
  }

  static InteractiveObject microscope({
    required VoidCallback onTap,
    bool isNewUser = false,
  }) {
    return InteractiveObject(
      icon: Icons.biotech,
      label: 'Water Chemistry',
      onTap: onTap,
      size: 40,
      iconColor: const Color(0xFF90CAF9),
      glowColor: const Color(0xFF64B5F6),
      isNewUser: isNewUser,
      animationStyle: InteractiveAnimationStyle.shimmer,
    );
  }

  static InteractiveObject globe({
    required VoidCallback onTap,
    bool isNewUser = false,
  }) {
    return InteractiveObject(
      icon: Icons.public,
      label: 'Fish Facts',
      onTap: onTap,
      size: 38,
      iconColor: const Color(0xFF4FC3F7),
      glowColor: const Color(0xFF29B6F6),
      isNewUser: isNewUser,
      animationStyle: InteractiveAnimationStyle.bounce,
    );
  }
}

/// Collection of themed interactive objects for workshop
class WorkshopObjects {
  static InteractiveObject toolRack({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    bool isNewUser = false,
  }) {
    return InteractiveObject(
      icon: icon,
      label: label,
      onTap: onTap,
      size: 40,
      iconColor: const Color(0xFFA0AEC0),
      glowColor: const Color(0xFFA0AEC0),
      isNewUser: isNewUser,
      animationStyle: InteractiveAnimationStyle.pulse,
    );
  }

  static InteractiveObject workbench({
    required VoidCallback onTap,
    bool isNewUser = false,
  }) {
    return InteractiveObject(
      icon: Icons.handyman,
      label: 'DIY Projects',
      onTap: onTap,
      size: 44,
      iconColor: const Color(0xFFD4A574),
      glowColor: const Color(0xFFD4A574),
      isNewUser: isNewUser,
      animationStyle: InteractiveAnimationStyle.wobble,
    );
  }
}
