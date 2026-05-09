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

  /// Starts a safety-reset timer that clears all navigation locks in case an
  /// exception or hang prevents the normal short debounce from running.
  static void _startSafetyTimer() {
    _safetyTimer?.cancel();
    _safetyTimer = Timer(const Duration(seconds: 5), () {
      _busyCount = 0;
    });
  }

  /// Cancels the safety timer.
  static void _cancelSafetyTimer() {
    _safetyTimer?.cancel();
    _safetyTimer = null;
  }

  static void _releaseLock() {
    if (_busyCount > 0) {
      _busyCount--;
    }
    if (_busyCount == 0) {
      _cancelSafetyTimer();
    }
  }

  static void _scheduleShortRelease() {
    Timer(const Duration(milliseconds: 450), _releaseLock);
  }

  /// Push a route with tap-spam protection.
  /// If [route] is provided, uses it directly. Otherwise wraps [page] in MaterialPageRoute.
  static Future<T?> push<T>(
    BuildContext context,
    Widget page, {
    Route<T>? route,
    bool rootNavigator = false,
    bool fullscreenDialog = false,
  }) async {
    if (_busyCount > 0) return null;
    // R-090: Guard against stale context — widget may have been unmounted
    // between the tap event and this call (e.g. during a loading state).
    if (!context.mounted) return null;
    _busyCount++;
    _startSafetyTimer();
    try {
      final navigator = Navigator.of(context, rootNavigator: rootNavigator);
      final result = navigator.push<T>(
        route ??
            MaterialPageRoute<T>(
              builder: (_) => page,
              fullscreenDialog: fullscreenDialog,
            ),
      );
      _scheduleShortRelease();
      return result;
    } catch (e) {
      _releaseLock();
      // Absorb Navigator-not-ready errors (null check / lookup failure)
      // that can occur if the widget tree is torn down mid-navigation.
      debugPrint('[NavigationThrottle] push failed: $e');
      return null;
    }
  }

  /// Push a named route with tap-spam protection.
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    if (_busyCount > 0) return null;
    // R-090: Guard against stale context.
    if (!context.mounted) return null;
    _busyCount++;
    _startSafetyTimer();
    try {
      final result = Navigator.pushNamed<T>(
        context,
        routeName,
        arguments: arguments,
      );
      _scheduleShortRelease();
      return result;
    } catch (e) {
      _releaseLock();
      debugPrint('[NavigationThrottle] pushNamed failed: $e');
      return null;
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
