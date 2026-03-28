import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standardised bottom sheet helper for the app.
///
/// Three variants:
/// - [showAppBottomSheet] — card-style sheet with margin/padding (Pattern A)
/// - [showAppDragSheet] — Material 3 drag-handle sheet (Pattern B)
/// - [showAppScrollableSheet] — DraggableScrollableSheet wrapper (Pattern C)
///
/// Usage:
/// ```dart
/// showAppBottomSheet(
///   context: context,
///   child: MySheetContent(),
/// );
/// ```

/// Pattern A: card-style with rounded corners, margin, and padding.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(AppSpacing.lg2),
  EdgeInsets margin = const EdgeInsets.all(AppSpacing.md),
  bool isScrollControlled = true,
  double? maxHeightFraction,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    builder: (ctx) => SafeArea(
      child: Container(
        margin: margin,
        padding: padding,
        constraints: maxHeightFraction != null
            ? BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * maxHeightFraction,
              )
            : null,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: AppRadius.largeRadius,
          boxShadow: [
            BoxShadow(
              color: AppOverlays.black12,
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

/// Pattern B: Material 3 native sheet with drag handle.
Future<T?> showAppDragSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool isScrollControlled = true,
  bool useSafeArea = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    showDragHandle: true,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
    ),
    builder: builder,
  );
}

/// Pattern C: scrollable content sheet.
Future<T?> showAppScrollableSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext, ScrollController) builder,
  double initialSize = 0.5,
  double minSize = 0.25,
  double maxSize = 0.9,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      expand: false,
      builder: (ctx, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
        child: builder(ctx, scrollController),
      ),
    ),
  );
}
