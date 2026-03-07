import 'package:flutter/material.dart';

/// Slide transition for navigating between rooms
class RoomSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final bool slideFromRight;
  
  RoomSlideRoute({
    required this.page, 
    this.slideFromRight = true,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = Offset(slideFromRight ? 1.0 : -1.0, 0);
      final tween = Tween(begin: begin, end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));
      
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

/// Fade + scale for modal-style screens
class ModalScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  ModalScaleRoute({required this.page}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic))
            .animate(animation),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

/// Hero-enabled route for tank detail navigation
class TankDetailRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  
  TankDetailRoute({required this.page}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ),
        child: child, // Hero animations will handle the rest
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 220),
  );
}
