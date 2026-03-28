import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standardised bottom sheet helpers for the Danio app.
///
/// Three variants cover the common patterns:
/// - [showAppBottomSheet] — Pattern A: card-style sheet floating above the scaffold.
/// - [showAppDragSheet] — Pattern B: Material 3 sheet with a native drag handle.
/// - [showAppScrollableSheet] — Pattern C: [DraggableScrollableSheet] for tall content.
///
/// ## Choosing a pattern
/// | Pattern | When to use |
/// |---------|-------------|
/// | A — [showAppBottomSheet] | Confirmations, quick-add forms, filter panels |
/// | B — [showAppDragSheet] | Resizable settings or detail sheets |
/// | C — [showAppScrollableSheet] | Long scrollable lists (fish picker, history) |
///
/// ## Basic usage
/// ```dart
/// showAppBottomSheet(
///   context: context,
///   child: MySheetContent(),
/// );
/// ```

/// Pattern A — card-style sheet with rounded corners, side margin, and inner padding.
///
/// The sheet floats above the scaffold edges (via [margin]) and has a themed
/// background matching the scaffold colour. Suitable for most bottom sheet needs.
///
/// - [child] — content to display inside the sheet.
/// - [padding] — inner padding; defaults to [AppSpacing.lg2] on all sides.
/// - [margin] — outer margin from screen edges; defaults to [AppSpacing.md] on all sides.
/// - [isScrollControlled] — when `true` (default) the sheet can grow to fill the screen.
/// - [maxHeightFraction] — optional cap as a fraction of screen height (e.g. `0.85`).
///
/// Returns a `Future` that resolves to the value passed to `Navigator.pop`.
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

/// Pattern B — Material 3 native sheet with a built-in drag handle.
///
/// The handle allows users to resize the sheet by dragging. Sheet shape uses
/// [AppRadius.lg] top corners.
///
/// - [builder] — receives a [BuildContext] and returns the sheet content.
/// - [isScrollControlled] — when `true` (default) the sheet can fill the screen.
/// - [useSafeArea] — when `true` (default) the sheet respects safe-area insets.
///
/// Returns a `Future` that resolves to the value passed to `Navigator.pop`.
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

/// Pattern C — scrollable content sheet backed by [DraggableScrollableSheet].
///
/// Use when the sheet content is a long scrollable list (fish picker, parameter history).
/// The [builder] receives both a [BuildContext] and a [ScrollController] — pass the
/// controller to your [ListView] or [CustomScrollView] to enable seamless scrolling.
///
/// - [initialSize] — initial height as a fraction of screen height (default `0.5`).
/// - [minSize] — minimum fraction the sheet can be dragged to (default `0.25`).
/// - [maxSize] — maximum fraction the sheet can expand to (default `0.9`).
///
/// ```dart
/// showAppScrollableSheet(
///   context: context,
///   builder: (ctx, scrollController) => ListView(
///     controller: scrollController,
///     children: fishList.map((f) => FishTile(fish: f)).toList(),
///   ),
/// );
/// ```
///
/// Returns a `Future` that resolves to the value passed to `Navigator.pop`.
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
