import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
    
    // Capture errors in this widget's subtree
    FlutterError.onError = (details) {
      widget.onError?.call(details);
      
      // Log to console in debug mode
      if (kDebugMode) {
        FlutterError.presentError(details);
      }
      
      // Show error UI
      if (mounted) {
        setState(() {
          _error = details;
        });
      }
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
class _DefaultErrorScreen extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onRetry;

  const _DefaultErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A2634) : const Color(0xFFF5F1EB),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'Oops! Something went wrong',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Message
                Text(
                  'Don\'t worry, your data is safe. Try restarting the app or contact support if this keeps happening.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Retry button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Show error details in debug mode
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error Details'),
                          content: SingleChildScrollView(
                            child: Text(
                              error.toString(),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Show Technical Details'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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
      // e.g., FirebaseCrashlytics.instance.recordFlutterError(details);
    };
    
    // Catch errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      onError?.call(error, stack);
      
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Uncaught error: $error\n$stack');
      }
      
      // In production, send to crash reporting
      // e.g., FirebaseCrashlytics.instance.recordError(error, stack);
      
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
    } catch (e) {
      showError(errorMessage ?? 'Something went wrong: ${e.toString()}');
      onError?.call();
    }
  }
  
  /// Build error banner if error exists
  Widget buildErrorBanner() {
    if (_errorMessage == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.error,
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: clearError,
          ),
        ],
      ),
    );
  }
}
