import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Debounce utility for search/input
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttle utility for scroll/resize events
class Throttler {
  final Duration delay;
  Timer? _timer;
  bool _isThrottled = false;

  Throttler({this.delay = const Duration(milliseconds: 100)});

  void run(VoidCallback action) {
    if (_isThrottled) return;
    
    action();
    _isThrottled = true;
    _timer = Timer(delay, () {
      _isThrottled = false;
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Simple memoization cache
class MemoCache<K, V> {
  final int maxSize;
  final Map<K, V> _cache = {};
  final List<K> _keys = [];

  MemoCache({this.maxSize = 100});

  V? get(K key) => _cache[key];

  void set(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache[key] = value;
      return;
    }

    if (_keys.length >= maxSize) {
      final oldKey = _keys.removeAt(0);
      _cache.remove(oldKey);
    }

    _cache[key] = value;
    _keys.add(key);
  }

  V getOrCompute(K key, V Function() compute) {
    if (_cache.containsKey(key)) {
      return _cache[key] as V;
    }
    final value = compute();
    set(key, value);
    return value;
  }

  void clear() {
    _cache.clear();
    _keys.clear();
  }

  int get length => _cache.length;
}

/// Lazy initialization helper
class Lazy<T> {
  T? _value;
  final T Function() _factory;
  bool _isInitialized = false;

  Lazy(this._factory);

  T get value {
    if (!_isInitialized) {
      _value = _factory();
      _isInitialized = true;
    }
    return _value as T;
  }

  bool get isInitialized => _isInitialized;

  void reset() {
    _value = null;
    _isInitialized = false;
  }
}

/// Widget that only rebuilds when visible on screen
class VisibilityAwareBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isVisible) builder;
  final Widget? placeholder;

  const VisibilityAwareBuilder({
    super.key,
    required this.builder,
    this.placeholder,
  });

  @override
  State<VisibilityAwareBuilder> createState() => _VisibilityAwareBuilderState();
}

class _VisibilityAwareBuilderState extends State<VisibilityAwareBuilder> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      onVisibilityChanged: (visible) {
        if (visible != _isVisible) {
          setState(() => _isVisible = visible);
        }
      },
      child: _isVisible 
          ? widget.builder(context, true)
          : (widget.placeholder ?? widget.builder(context, false)),
    );
  }
}

/// Simple visibility detector
class VisibilityDetector extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> onVisibilityChanged;

  const VisibilityDetector({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> 
    with WidgetsBindingObserver {
  final GlobalKey _key = GlobalKey();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SchedulerBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted) return;
    
    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null) return;

    try {
      final viewport = RenderAbstractViewport.of(renderObject);
      final offset = viewport.getOffsetToReveal(renderObject, 0.0);
      final isVisible = offset.offset >= 0;
      _updateVisibility(isVisible);
    } catch (_) {
      // Not in a scrollable - assume visible
      _updateVisibility(true);
    }
  }

  void _updateVisibility(bool isVisible) {
    if (isVisible != _isVisible) {
      _isVisible = isVisible;
      widget.onVisibilityChanged(isVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: KeyedSubtree(
        key: _key,
        child: widget.child,
      ),
    );
  }
}

/// RepaintBoundary wrapper for complex widgets
class IsolatedRepaint extends StatelessWidget {
  final Widget child;

  const IsolatedRepaint({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: child);
  }
}

/// Optimized image with caching and placeholder
class OptimizedImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      frameBuilder: placeholder != null
          ? (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return placeholder!;
            }
          : null,
      errorBuilder: errorWidget != null
          ? (context, error, stackTrace) => errorWidget!
          : null,
    );
  }
}

/// Keep alive wrapper for tab views
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

/// Frame callback scheduler for smooth animations
class FrameScheduler {
  static final FrameScheduler _instance = FrameScheduler._internal();
  factory FrameScheduler() => _instance;
  FrameScheduler._internal();

  final Set<VoidCallback> _callbacks = {};
  bool _isScheduled = false;

  void scheduleFrame(VoidCallback callback) {
    _callbacks.add(callback);
    _scheduleIfNeeded();
  }

  void _scheduleIfNeeded() {
    if (_isScheduled) return;
    _isScheduled = true;
    
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _isScheduled = false;
      final callbacks = Set<VoidCallback>.from(_callbacks);
      _callbacks.clear();
      for (final callback in callbacks) {
        callback();
      }
    });
  }
}

/// Performance monitoring mixin
mixin PerformanceMonitor<T extends StatefulWidget> on State<T> {
  Stopwatch? _buildStopwatch;
  int _buildCount = 0;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      _buildStopwatch = Stopwatch();
    }
  }

  void startBuildTimer() {
    if (kDebugMode) {
      _buildStopwatch?.reset();
      _buildStopwatch?.start();
    }
  }

  void endBuildTimer([String? widgetName]) {
    if (kDebugMode && _buildStopwatch != null) {
      _buildStopwatch!.stop();
      _buildCount++;
      final elapsed = _buildStopwatch!.elapsedMicroseconds;
      
      // Warn if build takes too long
      if (elapsed > 16000) { // > 16ms = frame drop
        debugPrint(
          '⚠️ Slow build: ${widgetName ?? widget.runtimeType} '
          'took ${elapsed / 1000}ms (build #$_buildCount)',
        );
      }
    }
  }
}

/// Extension for build context performance helpers
extension PerformanceContext on BuildContext {
  /// Run callback after current frame
  void postFrame(VoidCallback callback) {
    SchedulerBinding.instance.addPostFrameCallback((_) => callback());
  }

  /// Run callback on next idle
  void onIdle(VoidCallback callback) {
    SchedulerBinding.instance.scheduleTask(callback, Priority.idle);
  }
}

/// List view optimization helper
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? itemExtent;
  final double? cacheExtent;
  final bool addRepaintBoundaries;
  final bool addAutomaticKeepAlives;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.itemExtent,
    this.cacheExtent,
    this.addRepaintBoundaries = true,
    this.addAutomaticKeepAlives = true,
  });

  @override
  Widget build(BuildContext context) {
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        cacheExtent: cacheExtent,
        addRepaintBoundaries: addRepaintBoundaries,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder!,
      );
    }

    if (itemExtent != null) {
      return ListView.builder(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics,
        itemExtent: itemExtent,
        cacheExtent: cacheExtent,
        addRepaintBoundaries: addRepaintBoundaries,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      cacheExtent: cacheExtent,
      addRepaintBoundaries: addRepaintBoundaries,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
