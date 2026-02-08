// Debouncer utility for input fields and frequent operations
// Prevents excessive function calls and improves performance

import 'dart:async';
import 'package:flutter/material.dart';

/// Simple debouncer that delays function execution
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Call the provided function after the delay
  /// If called again before delay expires, previous call is cancelled
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending execution
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer
  void dispose() {
    _timer?.cancel();
  }
}

/// Debouncer specifically for text input
class TextDebouncer {
  final Duration delay;
  final void Function(String value) onChanged;
  Timer? _timer;

  TextDebouncer({
    required this.onChanged,
    this.delay = const Duration(milliseconds: 300),
  });

  /// Update the value - debounced callback will be called after delay
  void update(String value) {
    _timer?.cancel();
    _timer = Timer(delay, () => onChanged(value));
  }

  /// Cancel any pending callback
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of resources
  void dispose() {
    _timer?.cancel();
  }
}

/// Throttler - ensures function is called at most once per period
class Throttler {
  final Duration period;
  DateTime? _lastExecution;

  Throttler({this.period = const Duration(milliseconds: 500)});

  /// Execute function if enough time has passed since last execution
  void run(VoidCallback action) {
    final now = DateTime.now();
    
    if (_lastExecution == null || 
        now.difference(_lastExecution!) >= period) {
      _lastExecution = now;
      action();
    }
  }

  /// Reset the throttler
  void reset() {
    _lastExecution = null;
  }
}

/// Mixin for debouncing in widgets
mixin DebounceMixin<T extends StatefulWidget> on State<T> {
  final Map<String, Debouncer> _debouncers = {};

  /// Get or create a debouncer with given key and delay
  Debouncer debouncer(String key, {Duration delay = const Duration(milliseconds: 300)}) {
    return _debouncers.putIfAbsent(key, () => Debouncer(delay: delay));
  }

  @override
  void dispose() {
    for (final debouncer in _debouncers.values) {
      debouncer.dispose();
    }
    _debouncers.clear();
    super.dispose();
  }
}
