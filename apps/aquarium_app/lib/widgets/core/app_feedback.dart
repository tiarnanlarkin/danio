import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Snackbar variants for different message types
enum AppSnackbarVariant {
  /// Default informational message
  info,
  
  /// Success message
  success,
  
  /// Warning message
  warning,
  
  /// Error message
  error,
}

/// A helper class for showing consistent snackbars across the app.
/// 
/// Example:
/// ```dart
/// AppSnackbar.show(
///   context,
///   message: 'Settings saved',
///   variant: AppSnackbarVariant.success,
/// );
/// ```
class AppSnackbar {
  AppSnackbar._();

  /// Show a snackbar with the given message and variant.
  static void show(
    BuildContext context, {
    required String message,
    AppSnackbarVariant variant = AppSnackbarVariant.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool floating = true,
  }) {
    final snackBar = SnackBar(
      content: _SnackbarContent(
        message: message,
        variant: variant,
      ),
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: _getActionColor(variant),
              onPressed: onAction ?? () {},
            )
          : null,
      duration: duration,
      behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      backgroundColor: _getBackgroundColor(variant),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.smallRadius),
      margin: floating ? EdgeInsets.all(AppSpacing.md) : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Show a success snackbar.
  static void success(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message: message, variant: AppSnackbarVariant.success, actionLabel: actionLabel, onAction: onAction);
  }

  /// Show an error snackbar.
  static void error(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message: message, variant: AppSnackbarVariant.error, actionLabel: actionLabel, onAction: onAction);
  }

  /// Show a warning snackbar.
  static void warning(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message: message, variant: AppSnackbarVariant.warning, actionLabel: actionLabel, onAction: onAction);
  }

  /// Show an info snackbar.
  static void info(BuildContext context, String message, {String? actionLabel, VoidCallback? onAction}) {
    show(context, message: message, variant: AppSnackbarVariant.info, actionLabel: actionLabel, onAction: onAction);
  }

  static Color _getBackgroundColor(AppSnackbarVariant variant) {
    switch (variant) {
      case AppSnackbarVariant.success:
        return AppColors.success;
      case AppSnackbarVariant.error:
        return AppColors.error;
      case AppSnackbarVariant.warning:
        return AppColors.warning;
      case AppSnackbarVariant.info:
        return AppColors.textPrimary;
    }
  }

  static Color _getActionColor(AppSnackbarVariant variant) {
    switch (variant) {
      case AppSnackbarVariant.success:
      case AppSnackbarVariant.error:
      case AppSnackbarVariant.warning:
        return Colors.white;
      case AppSnackbarVariant.info:
        return AppColors.primary;
    }
  }
}

class _SnackbarContent extends StatelessWidget {
  final String message;
  final AppSnackbarVariant variant;

  const _SnackbarContent({
    required this.message,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          _getIcon(),
          color: Colors.white,
          size: AppIconSizes.md,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }

  IconData _getIcon() {
    switch (variant) {
      case AppSnackbarVariant.success:
        return Icons.check_circle;
      case AppSnackbarVariant.error:
        return Icons.error;
      case AppSnackbarVariant.warning:
        return Icons.warning;
      case AppSnackbarVariant.info:
        return Icons.info;
    }
  }
}

/// Dialog variants
enum AppDialogVariant {
  /// Standard dialog
  standard,
  
  /// Alert/warning dialog
  alert,
  
  /// Confirmation dialog (destructive action)
  confirmation,
}

/// A helper class for showing consistent dialogs across the app.
/// 
/// Example:
/// ```dart
/// final result = await AppDialog.confirm(
///   context,
///   title: 'Delete Tank?',
///   message: 'This action cannot be undone.',
/// );
/// if (result == true) deleteTank();
/// ```
class AppDialog {
  AppDialog._();

  /// Show a dialog with title and message.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    AppDialogVariant variant = AppDialogVariant.standard,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => _AppDialogWidget(
        title: title,
        message: message,
        content: content,
        actions: actions,
        variant: variant,
      ),
    );
  }

  /// Show a confirmation dialog. Returns true if confirmed, false otherwise.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await show<bool>(
      context,
      title: title,
      message: message,
      variant: isDestructive ? AppDialogVariant.confirmation : AppDialogVariant.standard,
      barrierDismissible: false,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? TextButton.styleFrom(foregroundColor: AppColors.error)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
    return result ?? false;
  }

  /// Show an alert dialog with a single OK button.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String buttonLabel = 'OK',
  }) async {
    await show(
      context,
      title: title,
      message: message,
      variant: AppDialogVariant.alert,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonLabel),
        ),
      ],
    );
  }

  /// Show an input dialog. Returns the entered text or null if cancelled.
  static Future<String?> input(
    BuildContext context, {
    required String title,
    String? message,
    String? initialValue,
    String? hint,
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancel',
    int? maxLength,
    TextInputType? keyboardType,
  }) async {
    final controller = TextEditingController(text: initialValue);
    
    final result = await show<String>(
      context,
      title: title,
      message: message,
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(borderRadius: AppRadius.smallRadius),
        ),
        maxLength: maxLength,
        keyboardType: keyboardType,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(confirmLabel),
        ),
      ],
    );
    
    controller.dispose();
    return result;
  }
}

class _AppDialogWidget extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final AppDialogVariant variant;

  const _AppDialogWidget({
    required this.title,
    this.message,
    this.content,
    this.actions,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      icon: _buildIcon(),
      title: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
      content: content ?? (message != null
          ? Text(
              message!,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
          : null),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      actions: actions,
    );
  }

  Widget? _buildIcon() {
    switch (variant) {
      case AppDialogVariant.alert:
        return Icon(
          Icons.warning_rounded,
          color: AppColors.warning,
          size: AppIconSizes.xl,
        );
      case AppDialogVariant.confirmation:
        return Icon(
          Icons.help_outline_rounded,
          color: AppColors.error,
          size: AppIconSizes.xl,
        );
      case AppDialogVariant.standard:
        return null;
    }
  }
}

/// Bottom sheet helper
class AppBottomSheet {
  AppBottomSheet._();

  /// Show a bottom sheet with the given content.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext) builder,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
    double? maxHeight,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight)
          : null,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 32,
            height: 4,
            margin: EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppOverlays.white30 : AppOverlays.black30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(child: builder(context)),
        ],
      ),
    );
  }

  /// Show a menu bottom sheet with a list of options.
  static Future<T?> menu<T>(
    BuildContext context, {
    String? title,
    required List<AppBottomSheetOption<T>> options,
  }) {
    return show<T>(
      context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  title,
                  style: AppTypography.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(height: 1),
            ],
            ...options.map((option) => ListTile(
              leading: option.icon != null ? Icon(option.icon, color: option.isDestructive ? AppColors.error : null) : null,
              title: Text(
                option.label,
                style: TextStyle(
                  color: option.isDestructive ? AppColors.error : null,
                ),
              ),
              onTap: () => Navigator.of(context).pop(option.value),
            )),
            SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

/// An option for AppBottomSheet.menu
class AppBottomSheetOption<T> {
  final String label;
  final T value;
  final IconData? icon;
  final bool isDestructive;

  const AppBottomSheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.isDestructive = false,
  });
}
