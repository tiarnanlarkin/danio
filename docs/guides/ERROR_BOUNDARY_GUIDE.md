# Error Boundary Implementation Guide

## Overview

The Aquarium App uses a comprehensive error boundary system to prevent crashes and provide friendly error messages to users. This guide covers how the error boundary works and how to test it.

## Architecture

### Components

1. **ErrorBoundary Widget** (`lib/widgets/error_boundary.dart`)
   - Catches errors in widget tree
   - Displays friendly fallback UI
   - Provides retry mechanism
   - Shows technical details in debug mode

2. **GlobalErrorHandler** (`lib/widgets/error_boundary.dart`)
   - Catches Flutter framework errors (`FlutterError.onError`)
   - Catches platform errors (`PlatformDispatcher.instance.onError`)
   - Sends to crash reporting in production (Firebase Crashlytics ready)
   - Logs to console in debug mode

3. **ErrorHandlerMixin** (`lib/widgets/error_boundary.dart`)
   - Reusable error handling for StatefulWidgets
   - Error banner display
   - Async operation error handling
   - Auto-dismiss errors after 5 seconds

## Integration

### App-Level Integration (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error handler
  GlobalErrorHandler.initialize(
    onError: (error, stack) {
      // In production, send to crash reporting service
      // e.g., FirebaseCrashlytics.instance.recordError(error, stack);
      
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Global error caught: $error\n$stack');
      }
    },
  );

  runApp(
    ErrorBoundary(
      child: const ProviderScope(child: AquariumApp()),
    ),
  );
}
```

### Widget-Level Error Handling

For screens that need inline error handling, use `ErrorHandlerMixin`:

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> with ErrorHandlerMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Screen')),
      body: Column(
        children: [
          // Show error banner if error exists
          buildErrorBanner(),
          
          // Your content
          ElevatedButton(
            onPressed: () async {
              await handleAsync(
                () async {
                  // Your async operation
                  await someAsyncFunction();
                },
                errorMessage: 'Failed to load data',
                onError: () {
                  // Optional: handle error
                },
              );
            },
            child: const Text('Do Something'),
          ),
        ],
      ),
    );
  }
}
```

## Error Screen Features

### User-Facing Features
- ✅ **Friendly icon and message** - No scary red screens
- ✅ **"Try Again" button** - Lets user retry the operation
- ✅ **Data safety assurance** - Tells user their data is safe
- ✅ **Support guidance** - Suggests contacting support if issue persists
- ✅ **Theme-aware** - Adapts to light/dark mode

### Debug Features
- ✅ **"Show Technical Details" button** - View full error stack trace
- ✅ **Console logging** - All errors logged to console in debug mode
- ✅ **Error dialog** - Detailed error info in a modal dialog

## Testing the Error Boundary

### Method 1: Settings Screen Test Button (Recommended)

The easiest way to test the error boundary is using the built-in test crash button:

1. **Open Settings Screen**
   - Launch the app
   - Navigate to Settings (tap gear icon on home screen)

2. **Scroll to Debug Section**
   - Only visible in debug mode
   - Located at the bottom of the settings screen

3. **Tap "Trigger Test Crash"**
   - This intentionally throws an error
   - Error boundary should catch it
   - You'll see the friendly error screen

4. **Verify Error Screen**
   - ✅ Friendly icon and message displayed
   - ✅ "Try Again" button visible
   - ✅ "Show Technical Details" button visible (debug mode)

5. **Test Retry**
   - Tap "Try Again"
   - App should recover and return to normal state

### Method 2: Manual Error Injection

For testing in specific screens, you can manually throw an error:

```dart
// In any screen's build method or event handler
throw Exception('Test error for error boundary');
```

### Method 3: Simulate Real Errors

Test with realistic error scenarios:

```dart
// Null pointer exception
final String? value = null;
print(value!.length); // Throws error

// Async error
Future.delayed(Duration.zero, () {
  throw Exception('Async error test');
});

// Invalid data parsing
final invalidJson = '{broken json';
jsonDecode(invalidJson); // Throws error
```

## Production Setup

### Firebase Crashlytics Integration

To enable crash reporting in production:

1. **Add Firebase Crashlytics dependency**
   ```yaml
   dependencies:
     firebase_crashlytics: ^3.4.0
   ```

2. **Initialize in main.dart**
   ```dart
   import 'package:firebase_crashlytics/firebase_crashlytics.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     
     // Enable Crashlytics
     FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
     
     GlobalErrorHandler.initialize(
       onError: (error, stack) {
         FirebaseCrashlytics.instance.recordError(error, stack);
       },
     );
     
     runApp(ErrorBoundary(child: const ProviderScope(child: AquariumApp())));
   }
   ```

3. **Test Crashlytics**
   ```dart
   FirebaseCrashlytics.instance.crash(); // Force crash for testing
   ```

### Other Crash Reporting Services

The error boundary is compatible with any crash reporting service:

- **Sentry**: `Sentry.captureException(error, stackTrace: stack)`
- **Bugsnag**: `Bugsnag.notify(error, stackTrace: stack)`
- **Custom API**: Send error to your own backend

## Best Practices

### DO ✅
- Wrap entire app in `ErrorBoundary` (already done in main.dart)
- Use `ErrorHandlerMixin` for screens with complex async operations
- Show user-friendly error messages (not technical jargon)
- Log errors to crash reporting service in production
- Test error boundary regularly with test crash button
- Include context in error messages (what operation failed)

### DON'T ❌
- Don't catch errors silently without logging
- Don't show technical stack traces to end users (only in debug mode)
- Don't use error boundary for expected validation errors (use form validation instead)
- Don't wrap every tiny widget in ErrorBoundary (one app-level is enough)
- Don't forget to test error boundary before shipping

## Error Categories

### Critical Errors (Show Error Screen)
- Uncaught exceptions
- Widget build errors
- Navigation errors
- State management errors

### Recoverable Errors (Show Error Banner)
- Network errors (use ErrorHandlerMixin)
- Validation errors (use form validation)
- User input errors (show inline messages)
- Permission denied (show inline messages)

## Troubleshooting

### Error Boundary Not Catching Errors

**Problem**: Errors not caught, red screen still showing

**Solutions**:
1. Verify `ErrorBoundary` wraps entire app in `main.dart`
2. Check that `GlobalErrorHandler.initialize()` is called before `runApp()`
3. Ensure error occurs inside widget tree (not in main() or outside widgets)

### Retry Button Not Working

**Problem**: "Try Again" button doesn't recover app state

**Solutions**:
1. Check that error is in widget build method (not in initState)
2. Verify state is properly reset when retry is triggered
3. Consider using ErrorHandlerMixin for better recovery control

### Test Crash Button Not Visible

**Problem**: Can't find test crash button in settings

**Solutions**:
1. Ensure app is running in debug mode (`flutter run` not `flutter run --release`)
2. Check `kDebugMode` constant is true
3. Restart app if debug mode was recently changed

## Future Enhancements

Potential improvements for the error boundary system:

- [ ] **Error analytics** - Track which errors occur most frequently
- [ ] **User feedback** - Allow users to submit error reports
- [ ] **Offline error queue** - Queue errors when offline, send when back online
- [ ] **Error recovery strategies** - Different recovery actions for different error types
- [ ] **A/B testing** - Test different error message variations
- [ ] **Localization** - Translate error messages to user's language

## Related Documentation

- [Performance Monitoring Guide](../performance/PERFORMANCE_GUIDE.md)
- [Testing Guide](../testing/TESTING_GUIDE.md)
- [Flutter Error Handling Best Practices](https://docs.flutter.dev/testing/errors)
- [Firebase Crashlytics Docs](https://firebase.google.com/docs/crashlytics)

## Summary

The Aquarium App has a **production-ready error boundary system** that:
- ✅ Catches all uncaught errors
- ✅ Shows friendly error screens (not red screens)
- ✅ Provides retry mechanism
- ✅ Logs to console in debug mode
- ✅ Ready for crash reporting integration (Firebase Crashlytics)
- ✅ Includes test crash button for easy testing

**To test it right now:**
1. Open Settings screen
2. Scroll to bottom (debug section)
3. Tap "Trigger Test Crash"
4. Verify friendly error screen appears
5. Tap "Try Again" to recover

**Status**: ✅ Fully implemented and tested
