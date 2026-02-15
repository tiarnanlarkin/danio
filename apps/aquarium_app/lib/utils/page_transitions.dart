import 'package:flutter/material.dart';

/// Smooth, consistent page transitions for the app
/// All transitions respect reduced motion when enabled
class AppPageRoute {
  /// Slide transition from right (default push)
  /// With reduced motion: fade only
  static PageRoute slide(Widget page, {bool reducedMotion = false}) {
    if (reducedMotion) {
      return fade(page);
    }
    
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Fade transition (used for all transitions when reduced motion is enabled)
  static PageRoute fade(Widget page, {bool reducedMotion = false}) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: reducedMotion 
          ? const Duration(milliseconds: 100)
          : const Duration(milliseconds: 250),
    );
  }

  /// Scale transition (good for modals)
  /// With reduced motion: fade only (no scale)
  static PageRoute scale(Widget page, {bool reducedMotion = false}) {
    if (reducedMotion) {
      return fade(page, reducedMotion: true);
    }
    
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOutCubic;

        var scaleTween = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        var fadeTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: curve));

        return ScaleTransition(
          scale: animation.drive(scaleTween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide up transition (good for bottom sheets converted to full screen)
  /// With reduced motion: fade only
  static PageRoute slideUp(Widget page, {bool reducedMotion = false}) {
    if (reducedMotion) {
      return fade(page, reducedMotion: true);
    }
    
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }

  /// No transition (instant)
  static PageRoute instant(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
    );
  }
}
