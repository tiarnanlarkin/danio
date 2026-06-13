import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reduced_motion_provider.dart';

/// Applies Danio's in-app reduced-motion preference to widgets that rely on
/// [MediaQueryData.disableAnimations].
class ReducedMotionMediaQuery extends ConsumerWidget {
  final Widget child;

  const ReducedMotionMediaQuery({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reducedMotion = ref.watch(
      reducedMotionProvider.select((state) => state.isEnabled),
    );
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery == null) return child;

    return MediaQuery(
      data: mediaQuery.copyWith(
        disableAnimations: mediaQuery.disableAnimations || reducedMotion,
      ),
      child: child,
    );
  }
}
