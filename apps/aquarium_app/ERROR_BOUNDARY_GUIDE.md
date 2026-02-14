# Error Boundary Implementation Guide

## Goal
Wrap the app with error boundaries to catch and handle crashes gracefully, preventing the red error screen and showing users a friendly recovery UI.

## What We're Building

### 1. ErrorBoundary Widget
A wrapper widget that catches Flutter errors and displays a friendly error screen instead of the red debug screen.

**Features:**
- Catches widget build errors
- Shows friendly error UI
- Provides "Restart App" button
- Logs errors for debugging
- Optional: Send to crash reporting (Crashlytics/Sentry)

### 2. Friendly Error Screen
User-facing error UI that:
- Explains something went wrong (without technical details)
- Offers a restart button
- Shows a friendly mascot or illustration
- Maintains app branding

### 3. Integration Points
Wrap critical parts of the app:
- Main app navigator
- Individual complex screens (optional)
- Bottom sheets with complex logic

## Implementation

### File: `lib/widgets/core/error_boundary.dart`

```dart
import 'package:flutter/material.dart';

/// Catches errors in the widget tree and displays a friendly error screen
/// instead of the red debug error screen.
/// 
/// Wrap your app or individual screens with this to provide graceful error handling:
/// ```dart
/// ErrorBoundary(
///   child: MyApp(),
/// )
/// ```
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorBuilder;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _error;

  @override
  void initState() {
    super.initState();
    
    // Set up error handler
    FlutterError.onError = (details) {
      if (mounted) {
        setState(() {
          _error = details;
        });
      }
      // Also log to console
      FlutterError.presentError(details);
    };
  }

  void _reset() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ?? 
             _DefaultErrorScreen(
               error: _error!,
               onReset: _reset,
             );
    }
    
    return widget.child;
  }
}

class _DefaultErrorScreen extends StatelessWidget {
  final FlutterErrorDetails error;
  final VoidCallback onReset;
  
  const _DefaultErrorScreen({
    required this.error,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Friendly icon
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                
                // User-friendly message
                Text(
                  'Oops! Something went wrong',
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Don\'t worry, your data is safe. Try restarting the app.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Restart button
                AppButton(
                  label: 'Restart App',
                  onPressed: onReset,
                  variant: AppButtonVariant.primary,
                ),
                
                const SizedBox(height: 16),
                
                // Debug info (only in debug mode)
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  Text(
                    'Error: ${error.exception}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
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
```

### File: `lib/main.dart` Integration

```dart
// In main.dart, wrap MaterialApp with ErrorBoundary:

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global error handlers
  FlutterError.onError = (details) {
    // Log error
    debugPrint('Flutter Error: ${details.exception}');
    // Send to crash reporting (if configured)
    // FirebaseCrashlytics.instance.recordFlutterError(details);
  };
  
  runApp(
    ErrorBoundary(
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}
```

### Optional: Crashlytics Integration

```dart
// Add to main.dart for production error logging

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kReleaseMode) {
    // Initialize Firebase Crashlytics
    await Firebase.initializeApp();
    
    FlutterError.onError = (details) {
      FirebaseCrashlytics.instance.recordFlutterError(details);
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }
  
  runApp(
    ErrorBoundary(
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}
```

## Testing

### Test Error Boundary Works:

1. **Add test error trigger:**
```dart
// In any screen, add a button to test:
ElevatedButton(
  onPressed: () {
    throw Exception('Test error boundary');
  },
  child: Text('Test Error'),
)
```

2. **Expected behavior:**
   - Tap button
   - App shows friendly error screen (NOT red debug screen)
   - Tap "Restart App"
   - App returns to normal state

3. **Remove test code after verification**

## Success Criteria

- ✅ App wrapped with ErrorBoundary
- ✅ Test crash shows friendly error screen
- ✅ Restart button works
- ✅ No red debug screens in production
- ✅ Errors logged (console or Crashlytics)
- ✅ User data remains safe

## Notes

- This catches **widget build errors**, not all errors
- For async errors, use try-catch in async functions
- For network errors, use proper error handling in services
- ErrorBoundary is a last resort - fix bugs when found
- Consider adding analytics tracking for error frequency

## Commit Message

```
feat: add error boundary for graceful error handling

- Created ErrorBoundary widget to catch Flutter errors
- Shows friendly error screen instead of red debug screen
- Provides restart functionality
- Logs errors for debugging
- Prevents app crashes from showing raw stack traces to users
```
