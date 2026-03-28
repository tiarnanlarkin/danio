/// DanioSnackBar — a semantic, consistently-styled snack bar helper.
///
/// Wraps [AppFeedback] to provide a clean, discoverable API from the widgets
/// layer. Prefer [DanioSnackBar.show] for new code; Hephaestus will migrate
/// the remaining 100+ raw [SnackBar] call sites.
///
/// Usage:
/// ```dart
/// DanioSnackBar.show(context, 'Tank saved!');
/// DanioSnackBar.show(context, 'Something went wrong', type: SnackType.error);
/// DanioSnackBar.show(context, 'Did you know?', type: SnackType.info);
/// ```
library;

import 'package:flutter/material.dart';
import '../utils/app_feedback.dart';

/// The semantic type of a [DanioSnackBar] message.
enum SnackType {
  /// Green background — operation succeeded.
  success,

  /// Red background — something went wrong.
  error,

  /// Blue background — neutral information.
  info,

  /// Amber background — non-critical warning.
  warning,

  /// Default neutral style.
  neutral,
}

/// Consistent, styled snack bars for the Danio Aquarium app.
///
/// Delegates to [AppFeedback] for implementation so styling is always in sync.
abstract class DanioSnackBar {
  DanioSnackBar._();

  /// Show a snack bar with [message] styled according to [type].
  ///
  /// * [type] defaults to [SnackType.neutral].
  /// * Pass [onRetry] to add a Retry action (only used with [SnackType.error]).
  static void show(
    BuildContext context,
    String message, {
    SnackType type = SnackType.neutral,
    VoidCallback? onRetry,
  }) {
    switch (type) {
      case SnackType.success:
        AppFeedback.showSuccess(context, message);
      case SnackType.error:
        AppFeedback.showError(context, message, onRetry: onRetry);
      case SnackType.info:
        AppFeedback.showInfo(context, message);
      case SnackType.warning:
        AppFeedback.showWarning(context, message);
      case SnackType.neutral:
        AppFeedback.show(context, message);
    }
  }

  /// Convenience: show a success snack bar.
  static void success(BuildContext context, String message) =>
      AppFeedback.showSuccess(context, message);

  /// Convenience: show an error snack bar.
  static void error(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) => AppFeedback.showError(context, message, onRetry: onRetry);

  /// Convenience: show an info snack bar.
  static void info(BuildContext context, String message) =>
      AppFeedback.showInfo(context, message);

  /// Convenience: show a warning snack bar.
  static void warning(BuildContext context, String message) =>
      AppFeedback.showWarning(context, message);

  /// Dismiss the currently-visible snack bar (if any).
  static void dismiss(BuildContext context) => AppFeedback.dismiss(context);
}
