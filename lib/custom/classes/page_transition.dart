import 'package:flutter/material.dart';

class SlideUpTransitionRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  SlideUpTransitionRoute({required this.child})
    : super(
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Apply an easing curve to the core animation
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );

          // Configure the slide path (from offscreen right to center)
          final slideTween = Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).animate(curvedAnimation);

          // Combine a SlideTransition and a FadeTransition
          return SlideTransition(
            position: slideTween,
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          );
        },
      );
}

class CustomDirectionalTransitionRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final bool ltr;

  CustomDirectionalTransitionRoute({required this.child, this.ltr = false})
    : super(
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Apply an easing curve to the core animation
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          final curvedOpacityAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          // Configure the slide path (from offscreen right to center)
          final slideTween = Tween<Offset>(
            begin: ltr ? const Offset(-0.2, 0.0) : const Offset(0.2, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation);

          // Combine a SlideTransition and a FadeTransition
          return SlideTransition(
            position: slideTween,
            child: FadeTransition(
              opacity: curvedOpacityAnimation,
              child: child,
            ),
          );
        },
      );
}
