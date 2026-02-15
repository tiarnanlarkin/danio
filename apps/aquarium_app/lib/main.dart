import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PerformanceOverlay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/settings_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/spaced_repetition_provider.dart';
import 'screens/house_navigator.dart';
import 'screens/onboarding_screen.dart';
import 'screens/onboarding/profile_creation_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/spaced_repetition_practice_screen.dart';
import 'screens/achievements_screen.dart';
import 'services/onboarding_service.dart';
import 'services/notification_service.dart';
import 'services/hearts_service.dart';
import 'services/celebration_service.dart';
import 'services/xp_animation_service.dart';
// import 'services/firebase_analytics_service.dart';
import 'theme/app_theme.dart';
import 'utils/performance_monitor.dart';
import 'widgets/performance_overlay.dart';
import 'widgets/error_boundary.dart';

// Firebase imports (uncomment when Firebase is configured)
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'dart:async';

// Global navigator key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Performance monitoring toggle (enable in debug mode)
const bool _enablePerformanceMonitoring =
    kDebugMode && false; // Set to true to enable
const bool _showPerformanceOverlay = false; // Set to true to show FPS overlay

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (uncomment when configured - see docs/setup/FIREBASE_SETUP_GUIDE.md)
  // await Firebase.initializeApp();

  // Initialize Firebase Crashlytics (uncomment when Firebase is configured)
  // FlutterError.onError = (errorDetails) {
  //   FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  // };
  // 
  // // Pass all uncaught asynchronous errors to Crashlytics
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };

  // Initialize global error handler
  GlobalErrorHandler.initialize(
    onError: (error, stack) {
      // Send to Firebase Crashlytics when enabled
      // FirebaseCrashlytics.instance.recordError(error, stack);
      
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Global error caught: $error\n$stack');
      }
    },
  );

  // Initialize Firebase Analytics (uncomment when Firebase is configured)
  // await FirebaseAnalyticsService().initialize();

  // Start performance monitoring in debug mode if enabled
  if (_enablePerformanceMonitoring) {
    performanceMonitor.startMonitoring();
  }

  // Initialize notifications with navigation callback
  final notificationService = NotificationService();
  await notificationService.initialize(
    onSelectNotification: (payload) {
      // Navigate based on notification payload
      if (payload == 'learn') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const LearnScreen()),
        );
      } else if (payload == 'review') {
        // Navigate to review/practice screen
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => const SpacedRepetitionPracticeScreen(),
          ),
        );
      } else if (payload == 'achievements') {
        // Navigate to achievements screen
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const AchievementsScreen()),
        );
      }
    },
  );

  runApp(
    ErrorBoundary(
      child: const ProviderScope(child: AquariumApp()),
    ),
  );
}

class AquariumApp extends ConsumerWidget {
  const AquariumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Aquarium',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.flutterThemeMode,
      // Add Firebase Analytics observer when configured
      // navigatorObservers: [
      //   FirebaseAnalyticsService().observer,
      // ],
      home: XpAnimationListener(
        child: CelebrationOverlayWrapper(
          child: AppPerformanceOverlay(
            showOverlay: _showPerformanceOverlay,
            child: const _AppRouter(),
          ),
        ),
      ),
    );
  }
}

/// Checks onboarding state, profile existence, and routes to the appropriate screen.
class _AppRouter extends ConsumerStatefulWidget {
  const _AppRouter();

  @override
  ConsumerState<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<_AppRouter>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  bool _showOnboarding = false;
  bool _needsProfile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkOnboardingAndProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check and apply heart auto-refill when app resumes
      final heartsService = ref.read(heartsServiceProvider);
      heartsService.checkAndApplyAutoRefill();

      // Schedule review notifications if cards are due
      _scheduleReviewNotifications();
    }
  }

  /// Schedule review reminder notifications based on due cards
  Future<void> _scheduleReviewNotifications() async {
    try {
      final srState = ref.read(spacedRepetitionProvider);
      final dueCount = srState.stats.dueCards;

      // Schedule notification if cards are due
      final notificationService = NotificationService();
      await notificationService.scheduleReviewReminder(
        dueCardsCount: dueCount,
        time: const TimeOfDay(hour: 9, minute: 0), // Default 9 AM
      );
    } catch (e) {
      // Silently fail - don't break app flow
      debugPrint('Failed to schedule review notifications: $e');
    }
  }

  Future<void> _checkOnboardingAndProfile() async {
    // Check onboarding status
    final onboardingService = await OnboardingService.getInstance();
    final onboardingCompleted = onboardingService.isOnboardingCompleted;

    // Check profile status
    bool profileExists = false;
    if (onboardingCompleted) {
      // Wait for profile provider to load
      await Future.delayed(const Duration(milliseconds: 100));
      final profile = ref.read(userProfileProvider).value;
      profileExists = profile != null;
    }

    setState(() {
      _showOnboarding = !onboardingCompleted;
      _needsProfile = onboardingCompleted && !profileExists;
      _isLoading = false;
    });

    // Schedule review notifications after initialization
    if (onboardingCompleted && profileExists) {
      _scheduleReviewNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Splash screen while checking onboarding state and profile
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [AppColors.primaryDark, AppColors.backgroundDark]
                  : [AppColors.primary, AppColors.secondary],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 80,
                  color: isDark ? Colors.black : Colors.white,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Aquarium',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Route to appropriate screen based on state
    if (_showOnboarding) {
      return const OnboardingScreen();
    } else if (_needsProfile) {
      return const ProfileCreationScreen();
    } else {
      return const HouseNavigator();
    }
  }
}
