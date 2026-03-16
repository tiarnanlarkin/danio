/// XP Animation Service
/// Provides a centralized way to show XP gain animations throughout the app.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/xp_award_animation.dart';

/// Event data for XP animation
class XpAnimationEvent {
  final int amount;
  final String? label;
  final bool withGlow;

  const XpAnimationEvent({
    required this.amount,
    this.label,
    this.withGlow = true,
  });
}

/// Service to trigger XP animations from anywhere in the app
class XpAnimationService {
  final _controller = StreamController<XpAnimationEvent>.broadcast();

  Stream<XpAnimationEvent> get events => _controller.stream;

  /// Trigger an XP animation
  void showXpGain(int amount, {String? label}) {
    if (amount > 0) {
      _controller.add(XpAnimationEvent(amount: amount, label: label));
    }
  }

  void dispose() {
    _controller.close();
  }
}

/// Provider for XP animation service
final xpAnimationServiceProvider = Provider<XpAnimationService>((ref) {
  final service = XpAnimationService();
  ref.onDispose(service.dispose);
  return service;
});

/// Widget that listens for XP animation events and shows them
/// Wrap your main content with this at a high level (e.g., in MaterialApp's builder)
class XpAnimationListener extends ConsumerStatefulWidget {
  final Widget child;

  const XpAnimationListener({super.key, required this.child});

  @override
  ConsumerState<XpAnimationListener> createState() =>
      _XpAnimationListenerState();
}

class _XpAnimationListenerState extends ConsumerState<XpAnimationListener> {
  late StreamSubscription<XpAnimationEvent> _subscription;
  OverlayEntry? _currentOverlay;

  @override
  void initState() {
    super.initState();
    final service = ref.read(xpAnimationServiceProvider);
    _subscription = service.events.listen(_showAnimation);
  }

  @override
  void dispose() {
    _subscription.cancel();
    _currentOverlay?.remove();
    super.dispose();
  }

  void _showAnimation(XpAnimationEvent event) {
    // Guard: widget may have been deactivated before the stream event fired
    if (!mounted) return;

    // Remove any existing overlay
    _currentOverlay?.remove();
    _currentOverlay = null;

    // Defer to post-frame so the Overlay is guaranteed to exist.
    // XpAnimationListener lives in MaterialApp's builder (above Navigator),
    // so Overlay.of(context) may fail during navigation transitions if called
    // synchronously. Post-frame ensures the frame has settled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final overlayState = Overlay.maybeOf(context, rootOverlay: true);
      if (overlayState == null) {
        return; // Overlay not yet available — skip silently
      }

      _currentOverlay = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).size.height * 0.35,
          left: 0,
          right: 0,
          child: Center(
            child: XpAwardAnimation(
              xpAmount: event.amount,
              onComplete: () {
                _currentOverlay?.remove();
                _currentOverlay = null;
              },
            ),
          ),
        ),
      );

      overlayState.insert(_currentOverlay!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension to easily show XP animation from any WidgetRef
extension XpAnimationExtension on WidgetRef {
  /// Show an XP gain animation
  void showXpAnimation(int amount, {String? label}) {
    read(xpAnimationServiceProvider).showXpGain(amount, label: label);
  }
}

/// Helper function to show XP animation directly with BuildContext
/// Use this when you don't have access to WidgetRef (e.g., in callbacks)
void showXpAwardAnimation(BuildContext context, int amount) {
  if (amount > 0) {
    XpAwardOverlay.show(context, xpAmount: amount);
  }
}
