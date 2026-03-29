import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'core/app_button.dart';
import 'core/app_dialog.dart';
import '../utils/logger.dart';

/// Error boundary widget that catches errors and displays a friendly fallback UI
///
/// Usage:
/// ```dart
/// ErrorBoundary(
///   child: YourApp(),
/// )
/// ```
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;
  final void Function(FlutterErrorDetails)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();

    // Capture errors in this widget's subtree — chain with previous handler
    final previousHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      // R-091: In debug mode, RenderFlex overflow ("overflowed by") is a
      // non-fatal layout diagnostic — Flutter draws the overflow indicator
      // and continues. Showing the error screen for this makes the app
      // unusable. Just log it and return. In release mode we keep the
      // "catch everything" behaviour (better safe than crashed).
      if (kDebugMode &&
          details.exception.toString().contains('overflowed by')) {
        FlutterError.presentError(details);
        return;
      }

      widget.onError?.call(details);

      // Always log — critical for diagnosing production errors
      FlutterError.presentError(details);
      appLog('🚨 ErrorBoundary caught: ${details.exception}\n${details.stack}', tag: 'ErrorBoundary');

      // Defer setState to avoid calling it during a build phase
      // (FlutterError.onError can fire mid-build, and setState during
      // build triggers its own framework assertion)
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _error = details;
            });
          }
        });
      }

      // Chain to previous handler so other error reporting (e.g. Crashlytics) still works
      previousHandler?.call(details);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          _DefaultErrorScreen(
            error: _error!,
            onRetry: () {
              setState(() {
                _error = null;
              });
            },
          );
    }

    return widget.child;
  }
}

/// Default friendly error screen
class _DefaultErrorScreen extends StatefulWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const _DefaultErrorScreen({required this.error, required this.onRetry});

  @override
  State<_DefaultErrorScreen> createState() => _DefaultErrorScreenState();
}

class _DefaultErrorScreenState extends State<_DefaultErrorScreen> {
  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    final onRetry = widget.onRetry;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F1EB),
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ).copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A2634),
      ),
      themeMode: ThemeMode.system,
      home: Builder(builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: isDark
              ? const Color(0xFF1A2634)
              : const Color(0xFFF5F1EB),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.errorAlpha10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: AppIconSizes.xxl,
                      color: AppColors.error,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  Text(
                    'Oops! Something went wrong',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Message
                  Text(
                    'Don\'t worry, your data is safe. Try restarting the app or contact support if this keeps happening.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: context.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Retry button
                  AppButton(
                    onPressed: onRetry,
                    label: 'Try Again',
                    isFullWidth: true,
                    size: AppButtonSize.large,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Show error details in debug mode
                  if (kDebugMode) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Show Technical Details',
                      onPressed: () {
                        showAppDialog(
                          context: context,
                          title: 'Error Details',
                          child: SingleChildScrollView(
                            child: Text(
                              error.toString(),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(fontFamily: 'monospace'),
                            ),
                          ),
                          actions: [
                            AppButton(
                              label: 'Close',
                              onPressed: () => Navigator.maybePop(context),
                              variant: AppButtonVariant.text,
                              isFullWidth: true,
                            ),
                          ],
                        );
                      },
                      variant: AppButtonVariant.secondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Global error handler for uncaught errors
class GlobalErrorHandler {
  static void initialize({
    void Function(Object error, StackTrace stack)? onError,
  }) {
    // Catch Flutter framework errors
    FlutterError.onError = (details) {
      onError?.call(details.exception, details.stack ?? StackTrace.current);

      // Log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }

      // In production, you would send to crash reporting service
    };

    // Catch errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      onError?.call(error, stack);

      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Uncaught error: $error\n$stack');
      }

      // In production, send to crash reporting

      return true; // Mark as handled
    };
  }
}

/// Mixin for widgets that need error handling
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  String? _errorMessage;

  /// Show error message to user
  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    // Auto-dismiss after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  /// Clear error message
  void clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  /// Execute async operation with error handling
  Future<void> handleAsync(
    Future<void> Function() operation, {
    String? errorMessage,
    VoidCallback? onError,
  }) async {
    try {
      clearError();
      await operation();
    } catch (e, st) {
      logError('ErrorBoundary: guarded operation failed: $e', stackTrace: st, tag: 'ErrorBoundary');
      showError(errorMessage ?? 'Oops! We hit a snag. Give it another try.');
      onError?.call();
    }
  }

  /// Build error banner if error exists
  Widget buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      color: AppColors.error,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.onError),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.onError),
            ),
          ),
          Semantics(
            label: 'Close error message',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.onError),
              onPressed: clearError,
              tooltip: 'Close error message',
            ),
          ),
        ],
      ),
    );
  }
}
