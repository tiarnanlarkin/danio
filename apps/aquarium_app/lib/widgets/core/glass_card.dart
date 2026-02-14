import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Glass card variant styles
enum GlassVariant {
  /// Standard frosted glass
  frosted,
  
  /// Soft puffy (cotton candy style)
  soft,
  
  /// Aurora gradient glass
  aurora,
  
  /// Cozy warm card
  cozy,
  
  /// Watercolor style (subtle gradient tint)
  watercolor,
}

/// A premium glassmorphism card with blur effects.
/// 
/// Inspired by high-end app designs with:
/// - Backdrop blur for true glass effect
/// - Subtle borders and glows
/// - Soft, premium shadows
/// - Optional gradient tints
class GlassCard extends StatefulWidget {
  final Widget child;
  final GlassVariant variant;
  final double blurAmount;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? tintColor;
  final double? width;
  final double? height;
  final bool enableHaptics;

  const GlassCard({
    super.key,
    required this.child,
    this.variant = GlassVariant.frosted,
    this.blurAmount = 10.0,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.onLongPress,
    this.tintColor,
    this.width,
    this.height,
    this.enableHaptics = true,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      if (widget.enableHaptics) HapticFeedback.lightImpact();
      widget.onTap!();
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      if (widget.enableHaptics) HapticFeedback.mediumImpact();
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = widget.borderRadius ?? BorderRadius.circular(24);
    
    Widget card = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.onTap != null ? _scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: widget.blurAmount,
              sigmaY: widget.blurAmount,
            ),
            child: Container(
              decoration: _buildDecoration(isDark, radius),
              padding: widget.padding ?? const EdgeInsets.all(16),
              child: widget.child,
            ),
          ),
        ),
      ),
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      card = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        onLongPress: _handleLongPress,
        child: card,
      );
    }

    return card;
  }

  BoxDecoration _buildDecoration(bool isDark, BorderRadius radius) {
    switch (widget.variant) {
      case GlassVariant.frosted:
        return _frostedDecoration(isDark, radius);
      case GlassVariant.soft:
        return _softDecoration(isDark, radius);
      case GlassVariant.aurora:
        return _auroraDecoration(isDark, radius);
      case GlassVariant.cozy:
        return _cozyDecoration(isDark, radius);
      case GlassVariant.watercolor:
        return _watercolorDecoration(isDark, radius);
    }
  }

  BoxDecoration _frostedDecoration(bool isDark, BorderRadius radius) {
    final tint = widget.tintColor;
    return BoxDecoration(
      color: tint != null
          ? tint.withOpacity(isDark ? 0.15 : 0.25)
          : (isDark ? AppColors.whiteAlpha08 : AppColors.whiteAlpha70),
      borderRadius: radius,
      border: Border.all(
        color: isDark 
            ? AppColors.whiteAlpha12 
            : AppColors.whiteAlpha50,
        width: 1.5,
      ),
      boxShadow: [
        // Subtle inner glow
        BoxShadow(
          color: isDark ? AppColors.whiteAlpha05 : AppColors.whiteAlpha20,
          blurRadius: 1,
          offset: const Offset(0, 1),
        ),
        // Main shadow
        BoxShadow(
          color: isDark ? AppColors.blackAlpha30 : AppColors.blackAlpha05,
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  BoxDecoration _softDecoration(bool isDark, BorderRadius radius) {
    return BoxDecoration(
      color: widget.tintColor?.withOpacity(0.9) ??
          (isDark ? const Color(0xFF2A2A3E) : Colors.white),
      borderRadius: radius,
      boxShadow: [
        // First layer - close soft shadow
        BoxShadow(
          color: isDark ? AppColors.blackAlpha20 : AppColors.blackAlpha05,
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 2),
        ),
        // Second layer - medium distance
        BoxShadow(
          color: isDark ? AppColors.blackAlpha15 : Color(0x08000000), // 0.03
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        // Third layer - far, very soft
        BoxShadow(
          color: isDark ? AppColors.blackAlpha10 : Color(0x05000000), // 0.02
          blurRadius: 40,
          spreadRadius: 0,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }

  BoxDecoration _auroraDecoration(bool isDark, BorderRadius radius) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF1A3A4A).withOpacity(0.85),
                const Color(0xFF0D2030).withOpacity(0.95),
              ]
            : [
                const Color(0xFFE8F4F8).withOpacity(0.9),
                const Color(0xFFF0F8FF).withOpacity(0.95),
              ],
      ),
      borderRadius: radius,
      border: Border.all(
        color: isDark
            ? const Color(0xFF5FBFB3).withOpacity(0.25)
            : const Color(0xFF5FBFB3).withOpacity(0.15),
        width: 1,
      ),
      boxShadow: [
        // Teal glow
        BoxShadow(
          color: isDark
              ? const Color(0xFF3D9F8B).withOpacity(0.2)
              : const Color(0xFF3D7068).withOpacity(0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  BoxDecoration _cozyDecoration(bool isDark, BorderRadius radius) {
    return BoxDecoration(
      color: isDark ? const Color(0xFF2D2B3A) : const Color(0xFFFFFBF5),
      borderRadius: radius,
      border: Border.all(
        color: isDark
            ? const Color(0xFFD4A574).withOpacity(0.2)
            : const Color(0xFFD4A574).withOpacity(0.12),
        width: 1,
      ),
      boxShadow: [
        // Warm gold tinted shadow
        BoxShadow(
          color: const Color(0xFFD4A574).withOpacity(isDark ? 0.15 : 0.1),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
        // Subtle dark shadow
        BoxShadow(
          color: isDark ? AppColors.blackAlpha15 : AppColors.blackAlpha05,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  BoxDecoration _watercolorDecoration(bool isDark, BorderRadius radius) {
    final tint = widget.tintColor ?? AppColors.primary;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          tint.withOpacity(isDark ? 0.12 : 0.08),
          (isDark ? Colors.black : Colors.white).withOpacity(isDark ? 0.3 : 0.8),
          tint.withOpacity(isDark ? 0.08 : 0.05),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      borderRadius: radius,
      border: Border.all(
        color: tint.withOpacity(isDark ? 0.15 : 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: tint.withOpacity(isDark ? 0.1 : 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

/// A simplified soft card without blur (better performance)
class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const SoftCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(24);

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? const Color(0xFF2A2A3E) : Colors.white),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.blackAlpha20 : AppColors.blackAlpha05,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: isDark ? AppColors.blackAlpha15 : const Color(0x08000000), // 0.03
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: isDark ? AppColors.blackAlpha10 : const Color(0x05000000), // 0.02
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        child: card,
      );
    }

    return card;
  }
}
