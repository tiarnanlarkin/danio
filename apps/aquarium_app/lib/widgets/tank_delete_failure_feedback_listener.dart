import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tank_provider.dart';
import '../utils/app_feedback.dart';

class TankDeleteFailureFeedbackListener extends ConsumerWidget {
  final Widget child;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  const TankDeleteFailureFeedbackListener({
    super.key,
    required this.child,
    this.scaffoldMessengerKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<TankDeleteFailureFeedback?>(tankDeleteFailureFeedbackProvider, (
      previous,
      failure,
    ) {
      if (failure == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final messenger =
            scaffoldMessengerKey?.currentState ??
            ScaffoldMessenger.maybeOf(context);
        if (messenger == null) return;
        messenger.removeCurrentSnackBar();
        AppFeedback.showErrorViaMessenger(messenger, failure.message);
        ref.read(tankDeleteFailureFeedbackProvider.notifier).state = null;
      });
    });

    return child;
  }
}
