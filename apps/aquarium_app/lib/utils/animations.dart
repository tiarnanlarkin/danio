import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/reduced_motion_provider.dart';

/// Stagger animation utilities for list animations
class StaggerHelper {
  /// Calculate delay for item at index in a list
  static Duration delayForIndex(int index, {Duration? baseDelay}) {
    return (baseDelay ?? const Duration(milliseconds: 50)) * index;
  }
  
  /// Max duration for a staggered list animation
  static Duration totalDuration(
    int itemCount, {
    Duration? baseDelay,
    Duration? itemDuration,
  }) {
    final delay = baseDelay ?? const Duration(milliseconds: 50);
    final duration = itemDuration ?? AppDurations.medium2;
    return delay * (itemCount - 1) + duration;
  }
}

/// Page transition builders for consistent navigation animations
class AppPageTransitions {
  /// Fade + slide up transition (modern feel)
  /// With reduced motion: fade only
  static PageRouteBuilder<T> fadeSlideUp<T>(
    Widget page, {
    RouteSettings? settings,
    ReducedMotionState? reducedMotion,
  }) {
    final useReducedMotion = reducedMotion?.isEnabled ?? false;
    
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: useReducedMotion 
          ? AppDurations.medium2 * 0.3 
          : AppDurations.medium4,
      reverseTransitionDuration: useReducedMotion
          ? AppDurations.short
          : AppDurations.medium2,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (useReducedMotion) {
          // Reduced motion: fade only
          return FadeTransition(opacity: animation, child: child);
        }
        
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.emphasizedDecelerate,
          reverseCurve: AppCurves.emphasizedAccelerate,
        );
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Shared axis horizontal (left/right navigation)
  /// With reduced motion: fade only
  static PageRouteBuilder<T> sharedAxisX<T>(
    Widget page, {
    bool forward = true,
    RouteSettings? settings,
    ReducedMotionState? reducedMotion,
  }) {
    final useReducedMotion = reducedMotion?.isEnabled ?? false;
    
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: useReducedMotion
          ? AppDurations.medium2 * 0.3
          : AppDurations.medium4,
      reverseTransitionDuration: useReducedMotion
          ? AppDurations.short
          : AppDurations.medium2,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (useReducedMotion) {
          // Reduced motion: fade only
          return FadeTransition(opacity: animation, child: child);
        }
        
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.standard,
        );
        
        final beginOffset = forward 
            ? const Offset(0.3, 0) 
            : const Offset(-0.3, 0);
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Scale + fade transition (for detail views)
  /// With reduced motion: fade only (no scale)
  static PageRouteBuilder<T> scaleFade<T>(
    Widget page, {
    RouteSettings? settings,
    ReducedMotionState? reducedMotion,
  }) {
    final useReducedMotion = reducedMotion?.isEnabled ?? false;
    
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: useReducedMotion
          ? AppDurations.medium2 * 0.3
          : AppDurations.medium4,
      reverseTransitionDuration: useReducedMotion
          ? AppDurations.short
          : AppDurations.medium2,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (useReducedMotion) {
          // Reduced motion: fade only
          return FadeTransition(opacity: animation, child: child);
        }
        
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.emphasized,
        );
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
  
  /// Simple fade transition
  static PageRouteBuilder<T> fade<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppDurations.medium2,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
  
  /// Container transform (for card-to-detail transitions)
  /// Use with Hero widget for full effect
  static PageRouteBuilder<T> containerTransform<T>(Widget page, {RouteSettings? settings}) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: AppDurations.long1,
      reverseTransitionDuration: AppDurations.medium4,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.emphasized,
        );
        
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
    );
  }
}

/// Extension for easier navigation with custom transitions
extension NavigatorExtensions on NavigatorState {
  /// Push with fade + slide up transition
  Future<T?> pushFadeSlideUp<T>(Widget page) {
    return push(AppPageTransitions.fadeSlideUp<T>(page));
  }
  
  /// Push with scale + fade transition
  Future<T?> pushScaleFade<T>(Widget page) {
    return push(AppPageTransitions.scaleFade<T>(page));
  }
  
  /// Push with shared axis X transition
  Future<T?> pushSharedAxisX<T>(Widget page, {bool forward = true}) {
    return push(AppPageTransitions.sharedAxisX<T>(page, forward: forward));
  }
}

/// A widget that animates its child in with a stagger delay
class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? delay;
  final Duration? duration;
  final Curve? curve;
  final Offset? slideOffset;
  final bool fadeIn;
  final bool slideIn;
  final bool scaleIn;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay,
    this.duration,
    this.curve,
    this.slideOffset,
    this.fadeIn = true,
    this.slideIn = true,
    this.scaleIn = false,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppDurations.medium2,
      vsync: this,
    );

    final curve = widget.curve ?? AppCurves.emphasized;
    final curvedAnimation = CurvedAnimation(parent: _controller, curve: curve);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);
    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset ?? const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(curvedAnimation);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation);

    // Start animation after stagger delay
    Future.delayed(
      StaggerHelper.delayForIndex(widget.index, baseDelay: widget.delay),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.scaleIn) {
      child = ScaleTransition(scale: _scaleAnimation, child: child);
    }
    if (widget.slideIn) {
      child = SlideTransition(position: _slideAnimation, child: child);
    }
    if (widget.fadeIn) {
      child = FadeTransition(opacity: _fadeAnimation, child: child);
    }

    return child;
  }
}

/// A builder for creating staggered list animations
class StaggeredListBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Duration? staggerDelay;
  final Duration? itemDuration;
  final Curve? curve;
  final bool fadeIn;
  final bool slideIn;
  final bool scaleIn;
  final Offset? slideOffset;

  const StaggeredListBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelay,
    this.itemDuration,
    this.curve,
    this.fadeIn = true,
    this.slideIn = true,
    this.scaleIn = false,
    this.slideOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return StaggeredListItem(
          index: index,
          delay: staggerDelay,
          duration: itemDuration,
          curve: curve,
          fadeIn: fadeIn,
          slideIn: slideIn,
          scaleIn: scaleIn,
          slideOffset: slideOffset,
          child: itemBuilder(context, index),
        );
      }),
    );
  }
}

/// Animated press feedback wrapper
/// Automatically respects reduced motion settings
class PressableScale extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double pressedScale;
  final Duration duration;
  final Curve curve;
  final bool enableHaptic;

  const PressableScale({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.pressedScale = 0.96,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.easeOutCubic,
    this.enableHaptic = false,
  });

  @override
  ConsumerState<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends ConsumerState<PressableScale> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    final reducedMotion = ref.read(reducedMotionProvider);
    if (!reducedMotion.isEnabled) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    final reducedMotion = ref.read(reducedMotionProvider);
    if (!reducedMotion.isEnabled) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    final reducedMotion = ref.read(reducedMotionProvider);
    if (!reducedMotion.isEnabled) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    // Add haptic feedback if enabled
    if (widget.enableHaptic) {
      // Import and use HapticFeedback from services/flutter
      // HapticFeedback.lightImpact();
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = ref.watch(reducedMotionProvider);
    
    // If reduced motion is enabled, skip the animation wrapper
    if (reducedMotion.isEnabled) {
      return GestureDetector(
        onTap: _handleTap,
        onLongPress: widget.onLongPress,
        child: widget.child,
      );
    }
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Shake animation for error feedback
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;
  final double offset;
  final int shakeCount;
  final Duration duration;
  final VoidCallback? onShakeComplete;

  const ShakeWidget({
    super.key,
    required this.child,
    this.shake = false,
    this.offset = 10.0,
    this.shakeCount = 3,
    this.duration = const Duration(milliseconds: 400),
    this.onShakeComplete,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        widget.onShakeComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sineValue = _animation.value * widget.shakeCount * 2 * 3.14159;
        final offset = widget.offset * _animation.value * 
            (1 - _animation.value) * 4 * 
            (sineValue - sineValue.truncate() < 0.5 ? 1 : -1);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Animated entrance wrapper using flutter_animate style API
class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final Duration? delay;
  final Duration? duration;
  final Curve? curve;
  final double fadeBegin;
  final Offset? slideBegin;
  final double? scaleBegin;
  final VoidCallback? onComplete;

  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delay,
    this.duration,
    this.curve,
    this.fadeBegin = 0.0,
    this.slideBegin,
    this.scaleBegin,
    this.onComplete,
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppDurations.medium2,
      vsync: this,
    );

    final curve = widget.curve ?? AppCurves.emphasized;
    final curvedAnimation = CurvedAnimation(parent: _controller, curve: curve);

    _fadeAnimation = Tween<double>(
      begin: widget.fadeBegin,
      end: 1.0,
    ).animate(curvedAnimation);

    if (widget.slideBegin != null) {
      _slideAnimation = Tween<Offset>(
        begin: widget.slideBegin,
        end: Offset.zero,
      ).animate(curvedAnimation);
    }

    if (widget.scaleBegin != null) {
      _scaleAnimation = Tween<double>(
        begin: widget.scaleBegin,
        end: 1.0,
      ).animate(curvedAnimation);
    }

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (_scaleAnimation != null) {
      child = ScaleTransition(scale: _scaleAnimation!, child: child);
    }
    if (_slideAnimation != null) {
      child = SlideTransition(position: _slideAnimation!, child: child);
    }
    
    return FadeTransition(opacity: _fadeAnimation, child: child);
  }
}
