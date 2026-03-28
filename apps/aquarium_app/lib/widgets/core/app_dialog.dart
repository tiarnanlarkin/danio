import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'app_button.dart';

/// A standardised dialog widget following the app's visual system.
///
/// Use the helper functions for common patterns:
/// - [showAppDialog] — basic dialog with title, content and actions
/// - [showAppConfirmDialog] — confirm/cancel pattern
/// - [showAppDestructiveDialog] — destructive action (red button)
///
/// Example:
/// ```dart
/// await showAppConfirmDialog(
///   context,
///   title: 'Delete Tank?',
///   message: 'This cannot be undone.',
///   confirmLabel: 'Delete',
///   onConfirm: () => _deleteTank(),
/// );
/// ```
class AppDialog extends StatelessWidget {
  /// Dialog title text
  final String? title;

  /// Optional icon displayed above the title
  final IconData? icon;

  /// Optional icon color
  final Color? iconColor;

  /// Dialog body content
  final Widget? child;

  /// Action buttons rendered at the bottom
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    this.title,
    this.icon,
    this.iconColor,
    this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? AppColors.surfaceDark : AppColors.surface;

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 40,
                color: iconColor ?? AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (child != null) ...[
              DefaultTextStyle(
                style: AppTypography.body.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
                child: child!,
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows a basic app dialog.
///
/// Returns whatever value is popped from the dialog route.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  String? title,
  IconData? icon,
  Color? iconColor,
  Widget? child,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AppDialog(
      title: title,
      icon: icon,
      iconColor: iconColor,
      child: child,
      actions: actions,
    ),
  );
}

/// Shows a confirm/cancel dialog.
///
/// Calls [onConfirm] if the user taps the confirm button.
/// Returns `true` if confirmed, `false`/`null` otherwise.
Future<bool?> showAppConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  VoidCallback? onConfirm,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AppDialog(
      title: title,
      child: Text(message),
      actions: [
        AppButton(
          label: cancelLabel,
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, false);
          },
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: confirmLabel,
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, true);
            onConfirm?.call();
          },
          variant: AppButtonVariant.primary,
          isFullWidth: true,
        ),
      ],
    ),
  );
}

/// Shows a dialog with a destructive (red) confirm action.
///
/// Calls [onConfirm] if the user taps the destructive button.
/// Returns `true` if confirmed, `false`/`null` otherwise.
Future<bool?> showAppDestructiveDialog({
  required BuildContext context,
  required String title,
  required String message,
  String destructiveLabel = 'Delete',
  String cancelLabel = 'Cancel',
  VoidCallback? onConfirm,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AppDialog(
      title: title,
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.error,
      child: Text(message),
      actions: [
        AppButton(
          label: cancelLabel,
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, false);
          },
          variant: AppButtonVariant.text,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppButton(
          label: destructiveLabel,
          onPressed: () {
            if (Navigator.canPop(ctx)) Navigator.pop(ctx, true);
            onConfirm?.call();
          },
          variant: AppButtonVariant.destructive,
          isFullWidth: true,
        ),
      ],
    ),
  );
}
