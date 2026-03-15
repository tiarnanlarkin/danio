import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'haptic_feedback.dart';

/// Standardized user feedback (snackbars, toasts, haptics)
///
/// Usage:
/// ```dart
/// AppFeedback.showSuccess(context, 'Task completed!');
/// AppFeedback.showError(context, 'Failed to save');
/// ```
class AppFeedback {
  /// Show success message with green background + haptic
  static void showSuccess(BuildContext context, String message) {
    AppHaptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.onSuccess, size: 20),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSuccess),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// Show error message with red background + haptic
  static void showError(
    BuildContext context,
    String message, {
    VoidCallback? onRetry,
  }) {
    AppHaptics.error();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.onError, size: 20),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onError),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        margin: const EdgeInsets.all(AppSpacing.md),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: AppColors.onError,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Show warning message with amber background + haptic
  static void showWarning(BuildContext context, String message) {
    AppHaptics.medium();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber, color: AppColors.onWarning, size: 20),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onWarning),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// Show info message with blue background
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.onSecondary, size: 20),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onSecondary),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// Show generic message (neutral)
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodyMedium),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// Show loading indicator (use with caution - prefer CircularProgressIndicator)
  static void showLoading(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.onPrimary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm2),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.onPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(
          days: 365,
        ), // "Forever" - must be dismissed manually
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  /// Dismiss any currently showing snackbar
  static void dismiss(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
