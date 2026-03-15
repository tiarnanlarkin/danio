import 'package:flutter/material.dart';

/// Prevents double-tap / tap-spam on navigation actions.
///
/// Usage:
/// ```dart
/// onTap: () => NavigationThrottle.push(context, MyScreen());
/// onTap: () => NavigationThrottle.push(context, MyScreen(), route: RoomSlideRoute(page: MyScreen()));
/// ```
class NavigationThrottle {
  static bool _isNavigating = false;
  static Future<void>? _safetyTimer;

  /// Starts a 5-second safety-reset timer that clears the navigation lock
  /// in case an exception or hang prevents the finally block from running.
  /// Returns the Future so it can be cancelled on normal completion.
  static Future<void> _startSafetyTimer() {
    final timer = Future.delayed(const Duration(seconds: 5), () {
      _isNavigating = false;
    });
    _safetyTimer = timer;
    return timer;
  }

  /// Cancels the safety timer (called when navigation completes normally).
  static void _cancelSafetyTimer() {
    _safetyTimer = null;
    // Future.delayed cannot be cancelled directly, but setting _safetyTimer
    // to null and resetting _isNavigating in finally means the delayed
    // callback's write is harmless (it just sets false again).
  }

  /// Push a route with tap-spam protection.
  /// If [route] is provided, uses it directly. Otherwise wraps [page] in MaterialPageRoute.
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    Route<T>? route,
  }) async {
    if (_isNavigating) return null;
    _isNavigating = true;
    _startSafetyTimer();
    try {
      final result = await Navigator.push<T>(
        context,
        route ?? MaterialPageRoute<T>(builder: (_) => page),
      );
      return result;
    } finally {
      _cancelSafetyTimer();
      _isNavigating = false;
    }
  }

  /// Push a named route with tap-spam protection.
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (_isNavigating) return null;
    _isNavigating = true;
    _startSafetyTimer();
    try {
      final result = await Navigator.pushNamed<T>(
        context,
        routeName,
        arguments: arguments,
      );
      return result;
    } finally {
      _cancelSafetyTimer();
      _isNavigating = false;
    }
  }

  /// Reset the navigation lock (call in tests or edge cases).
  static void reset() {
    _isNavigating = false;
  }

  /// Whether navigation is currently in progress.
  static bool get isNavigating => _isNavigating;
}
