import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _profilePerformanceHarnessEnabled = bool.fromEnvironment(
  'DANIO_PROFILE_PERFORMANCE',
);
const _profilePerformanceChannel = MethodChannel(
  'danio/profile_performance',
);

/// Reports the first rendered Tank frame for each foreground lifecycle.
///
/// The marker is inert in ordinary builds. The local profile harness enables it
/// with `--dart-define=DANIO_PROFILE_PERFORMANCE=true` so Android can measure
/// readiness on the device clock without including host-side ADB latency.
class ProfilePerformanceReadyMarker extends StatefulWidget {
  const ProfilePerformanceReadyMarker({
    super.key,
    required this.child,
    this.enabled = _profilePerformanceHarnessEnabled,
  });

  final Widget child;
  final bool enabled;

  @override
  State<ProfilePerformanceReadyMarker> createState() =>
      _ProfilePerformanceReadyMarkerState();
}

class _ProfilePerformanceReadyMarkerState
    extends State<ProfilePerformanceReadyMarker>
    with WidgetsBindingObserver {
  bool _reportedForLifecycle = false;
  bool _reportScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleReadyReport();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleReadyReport();
  }

  @override
  void didUpdateWidget(ProfilePerformanceReadyMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      _reportedForLifecycle = false;
      _scheduleReadyReport();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !widget.enabled) {
      return;
    }
    _reportedForLifecycle = false;
    _scheduleReadyReport();
  }

  void _scheduleReadyReport() {
    if (!widget.enabled || _reportedForLifecycle || _reportScheduled) {
      return;
    }
    _reportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportScheduled = false;
      if (!mounted ||
          !widget.enabled ||
          _reportedForLifecycle ||
          !TickerMode.valuesOf(context).enabled) {
        return;
      }
      _reportedForLifecycle = true;
      unawaited(_reportReady());
    });
  }

  Future<void> _reportReady() async {
    try {
      await _profilePerformanceChannel.invokeMethod<void>('markTankReady');
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Danio profile performance harness',
          context: ErrorDescription('while reporting the rendered Tank frame'),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
