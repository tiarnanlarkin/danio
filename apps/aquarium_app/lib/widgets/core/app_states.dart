import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_constants.dart';
import 'bubble_loader.dart';

/// Empty state variants for different contexts
enum EmptyStateVariant {
  /// No data/items
  noData,

  /// Search returned no results
  noResults,

  /// No network connection
  offline,

  /// Feature not available
  unavailable,

  /// First-time/onboarding state
  getStarted,
}

/// A polished empty state widget with illustration placeholder and action button.
///
/// Use when there's no content to display. Provides visual interest and
/// guides users toward taking action.
///
/// Example:
/// ```dart
/// AppEmptyState(
///   icon: Icons.pets,
///   title: 'No fish yet',
///   message: 'Add your first fish to get started!',
///   actionLabel: 'Add Fish',
///   onAction: () => addFish(),
/// )
/// ```
class AppEmptyState extends StatelessWidget {
  /// Main icon (will be styled as illustration)
  final IconData icon;

  /// Title text
  final String title;

  /// Description/message
  final String? message;

  /// Primary action button label
  final String? actionLabel;

  /// Primary action callback
  final VoidCallback? onAction;

  /// Secondary action label
  final String? secondaryActionLabel;

  /// Secondary action callback
  final VoidCallback? onSecondaryAction;

  /// Icon color (defaults to primary)
  final Color? iconColor;

  /// Background color for icon container
  final Color? iconBackgroundColor;

  /// Whether to use compact layout
  final bool compact;

  /// Custom illustration widget (replaces icon)
  final Widget? illustration;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconColor,
    this.iconBackgroundColor,
    this.compact = false,
    this.illustration,
  });

  /// Create an empty state for "no items" scenarios
  factory AppEmptyState.noItems({
    Key? key,
    required String itemName,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return AppEmptyState(
      key: key,
      icon: Icons.inbox_outlined,
      title: 'No $itemName yet',
      message: 'Add your first $itemName to get started.',
      actionLabel: actionLabel ?? 'Add $itemName',
      onAction: onAction,
    );
  }

  /// Create an empty state for "no search results"
  factory AppEmptyState.noResults({
    Key? key,
    String? query,
    VoidCallback? onClearSearch,
  }) {
    return AppEmptyState(
      key: key,
      icon: Icons.search_off,
      title: 'No results found',
      message: query != null
          ? 'No matches for "$query"'
          : 'Try adjusting your search or filters.',
      actionLabel: onClearSearch != null ? 'Clear Search' : null,
      onAction: onClearSearch,
    );
  }

  /// Create an empty state for offline scenarios
  factory AppEmptyState.offline({Key? key, VoidCallback? onRetry}) {
    return AppEmptyState(
      key: key,
      icon: Icons.wifi_off,
      title: 'You\'re offline',
      message: 'Check your internet connection and try again.',
      actionLabel: 'Retry',
      onAction: onRetry,
      iconColor: AppColors.warning,
    );
  }

  /// Create an empty state for errors
  factory AppEmptyState.error({
    Key? key,
    String? message,
    VoidCallback? onRetry,
  }) {
    return AppEmptyState(
      key: key,
      icon: Icons.error_outline,
      title: 'Oops! Something went wrong',
      message:
          message ?? 'That was not supposed to happen. Give it another try!',
      actionLabel: 'Try Again',
      onAction: onRetry,
      iconColor: AppColors.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            illustration ??
                Container(
                  width: compact ? 80 : 120,
                  height: compact ? 80 : 120,
                  decoration: BoxDecoration(
                    color:
                        iconBackgroundColor ?? effectiveIconColor.withAlpha(26),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: compact ? 40 : 56,
                    color: effectiveIconColor,
                  ),
                ),

            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),

            // Title
            Text(
              title,
              style:
                  (compact
                          ? AppTypography.titleSmall
                          : AppTypography.titleMedium)
                      .copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),

            // Message
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Actions
            if (actionLabel != null) ...[
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.smallRadius,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],

            if (secondaryActionLabel != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state indicator variants
enum LoadingIndicatorVariant {
  /// Circular spinner
  circular,

  /// Linear progress bar
  linear,

  /// Pulsing dots
  dots,

  /// Custom (use child)
  custom,
}

/// A polished loading state widget with optional message.
class AppLoadingState extends StatelessWidget {
  /// Loading indicator variant
  final LoadingIndicatorVariant variant;

  /// Optional message to display
  final String? message;

  /// Whether to use compact layout
  final bool compact;

  /// Custom loading widget (for variant.custom)
  final Widget? child;

  /// Progress value (0.0 - 1.0) for determinate progress
  final double? progress;

  /// Whether to center in available space
  final bool center;

  const AppLoadingState({
    super.key,
    this.variant = LoadingIndicatorVariant.circular,
    this.message,
    this.compact = false,
    this.child,
    this.progress,
    this.center = true,
  });

  /// Simple centered spinner
  const AppLoadingState.spinner({Key? key, String? message})
    : this(
        key: key,
        variant: LoadingIndicatorVariant.circular,
        message: message,
      );

  /// Linear progress bar
  const AppLoadingState.linear({Key? key, String? message, double? progress})
    : this(
        key: key,
        variant: LoadingIndicatorVariant.linear,
        message: message,
        progress: progress,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget indicator;

    switch (variant) {
      case LoadingIndicatorVariant.circular:
        // Use themed bubble loader instead of standard spinner
        indicator = progress != null
            ? SizedBox(
                width: compact ? 24 : 40,
                height: compact ? 24 : 40,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: compact ? 2 : 3,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
            : BubbleLoader(
                size: compact ? 32 : 60,
                bubbleCount: compact ? 3 : 5,
              );
        break;

      case LoadingIndicatorVariant.linear:
        indicator = SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? AppOverlays.white10 : AppOverlays.black10,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        );
        break;

      case LoadingIndicatorVariant.dots:
        indicator = _LoadingDots();
        break;

      case LoadingIndicatorVariant.custom:
        indicator = child ?? SizedBox.shrink();
        break;
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        if (message != null) ...[
          SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          Text(
            message!,
            style: AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (center) {
      content = Center(child: content);
    }

    return Padding(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      child: content,
    );
  }
}

/// Animated loading dots
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _disableMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: kQuizRevealDelay, vsync: this)
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newValue = MediaQuery.of(context).disableAnimations;
    if (newValue != _disableMotion) {
      _disableMotion = newValue;
      _controller.duration = _disableMotion ? Duration.zero : kQuizRevealDelay;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = ((_controller.value + delay) % 1.0);
            final scale = 0.5 + (value < 0.5 ? value : 1 - value);

            return Transform.scale(
              scale: scale,
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// An error state widget with retry option.
class AppErrorState extends StatelessWidget {
  /// Error icon
  final IconData icon;

  /// Error title
  final String title;

  /// Error message/details
  final String? message;

  /// Retry button label
  final String retryLabel;

  /// Retry callback
  final VoidCallback? onRetry;

  /// Whether to show "Report Issue" link
  final bool showReportLink;

  /// Report issue callback
  final VoidCallback? onReport;

  /// Whether to use compact layout
  final bool compact;

  const AppErrorState({
    super.key,
    this.icon = Icons.error_outline,
    this.title = 'Oops! Something went wrong',
    this.message,
    this.retryLabel = 'Try Again',
    this.onRetry,
    this.showReportLink = false,
    this.onReport,
    this.compact = false,
  });

  /// Network error state
  factory AppErrorState.network({Key? key, VoidCallback? onRetry}) {
    return AppErrorState(
      key: key,
      icon: Icons.wifi_off,
      title: 'No Connection',
      message:
          'Looks like you are offline. Check your connection and we will try again!',
      onRetry: onRetry,
    );
  }

  /// Server error state
  factory AppErrorState.server({
    Key? key,
    VoidCallback? onRetry,
    VoidCallback? onReport,
  }) {
    return AppErrorState(
      key: key,
      icon: Icons.cloud_off,
      title: 'Server Error',
      message: 'Our servers are taking a quick break. Try again in a moment!',
      onRetry: onRetry,
      showReportLink: onReport != null,
      onReport: onReport,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 64 : 96,
              height: compact ? 64 : 96,
              decoration: BoxDecoration(
                color: AppOverlays.error10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: compact ? 32 : 48,
                color: AppColors.error,
              ),
            ),

            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),

            Text(
              title,
              style:
                  (compact
                          ? AppTypography.titleSmall
                          : AppTypography.titleMedium)
                      .copyWith(color: context.textPrimary),
              textAlign: TextAlign.center,
            ),

            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (onRetry != null) ...[
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, size: 18),
                label: Text(retryLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],

            if (showReportLink && onReport != null) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: onReport, child: Text('Report Issue')),
            ],
          ],
        ),
      ),
    );
  }
}

/// Async content builder that handles loading/error/data states.
class AsyncContentBuilder<T> extends StatelessWidget {
  /// Future or stream to watch
  final AsyncSnapshot<T> snapshot;

  /// Builder for success state
  final Widget Function(BuildContext context, T data) builder;

  /// Custom loading widget
  final Widget? loading;

  /// Custom error widget builder
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  /// Loading message
  final String? loadingMessage;

  /// Retry callback for errors
  final VoidCallback? onRetry;

  const AsyncContentBuilder({
    super.key,
    required this.snapshot,
    required this.builder,
    this.loading,
    this.errorBuilder,
    this.loadingMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      if (errorBuilder != null) {
        return errorBuilder!(context, snapshot.error);
      }
      return AppErrorState(
        message: snapshot.error?.toString(),
        onRetry: onRetry,
      );
    }

    if (!snapshot.hasData) {
      return loading ?? AppLoadingState(message: loadingMessage);
    }

    return builder(context, snapshot.data as T);
  }
}
