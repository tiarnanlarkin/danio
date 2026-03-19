import 'dart:async';
import 'package:flutter/material.dart';

/// Prevents double-tap / tap-spam on navigation actions.
///
/// Uses a [_busyCount] to allow concurrent navigations from different parts
/// of the app (e.g. different tabs) while still blocking rapid re-taps on
/// the same element.
///
/// Usage:
/// ```dart
/// onTap: () => NavigationThrottle.push(context, MyScreen());
/// onTap: () => NavigationThrottle.push(context, MyScreen(), route: RoomSlideRoute(page: MyScreen()));
/// ```
class NavigationThrottle {
  /// Number of in-flight navigations. Replaces the old single bool flag
  /// so that navigation in one tab doesn't block another tab.
  static int _busyCount = 0;
  static Timer? _safetyTimer;

  /// Starts a 2-second safety-reset timer that clears all navigation locks
  /// in case an exception or hang prevents the finally block from running.
  static void _startSafetyTimer() {
    _safetyTimer?.cancel();
    _safetyTimer = Timer(const Duration(seconds: 2), () {
      _busyCount = 0;
    });
  }

  /// Cancels the safety timer (called when navigation completes normally).
  static void _cancelSafetyTimer() {
    _safetyTimer?.cancel();
    _safetyTimer = null;
  }

  /// Push a route with tap-spam protection.
  /// If [route] is provided, uses it directly. Otherwise wraps [page] in MaterialPageRoute.
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    Route<T>? route,
  }) async {
    if (_busyCount > 0) return null;
    _busyCount++;
    _startSafetyTimer();
    try {
      final result = await Navigator.push<T>(
        context,
        route ?? MaterialPageRoute<T>(builder: (_) => page),
      );
      return result;
    } finally {
      _cancelSafetyTimer();
      _busyCount = 0;
    }
  }

  /// Push a named route with tap-spam protection.
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (_busyCount > 0) return null;
    _busyCount++;
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
      _busyCount = 0;
    }
  }

  /// Reset the navigation lock (call in tests or edge cases).
  static void reset() {
    _safetyTimer?.cancel();
    _safetyTimer = null;
    _busyCount = 0;
  }

  /// Whether navigation is currently in progress.
  static bool get isNavigating => _busyCount > 0;
}
