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

  /// Push a route with tap-spam protection.
  /// If [route] is provided, uses it directly. Otherwise wraps [page] in MaterialPageRoute.
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    Route<T>? route,
  }) async {
    if (_isNavigating) return null;
    _isNavigating = true;
    try {
      final result = await Navigator.push<T>(
        context,
        route ?? MaterialPageRoute<T>(builder: (_) => page),
      );
      return result;
    } finally {
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
    try {
      final result = await Navigator.pushNamed<T>(
        context,
        routeName,
        arguments: arguments,
      );
      return result;
    } finally {
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
