import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PerformanceOverlay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/settings_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/spaced_repetition_provider.dart';
import 'screens/tab_navigator.dart';
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
import 'services/supabase_service.dart';
import 'services/hive_storage_service.dart';
import 'theme/app_theme.dart';
import 'utils/performance_monitor.dart';
import 'widgets/performance_overlay.dart';
import 'widgets/error_boundary.dart';

// Global navigator key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Performance monitoring toggle (enable in debug mode)
const bool _enablePerformanceMonitoring =
    kDebugMode && false; // Set to true to enable
const bool _showPerformanceOverlay = false; // Set to true to show FPS overlay

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ROADMAP: Configure Firebase for push notifications and analytics — see docs/FIREBASE_SETUP_GUIDE.md

  // Initialize global error handler
  GlobalErrorHandler.initialize(
    onError: (error, stack) {
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Global error caught: $error\n$stack');
      }
    },
  );

  // Initialize persistent storage (Hive)
  // CRITICAL: All user data (tanks, fish, logs, progress) is stored here.
  // App will NOT work properly if this fails.
  final storageInitialized = await HiveStorageService.initialize();
  if (!storageInitialized) {
    debugPrint('[CRITICAL] Storage initialization failed - app may lose data!');
    // Continue anyway to allow debugging, but warn user
  }

  // Initialize Supabase (safe to call - returns false if credentials are
  // placeholders, and the app continues in offline-only mode).
  await SupabaseService.initialize();

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
      scrollBehavior: const DanioScrollBehavior(),
      navigatorKey: navigatorKey,
      title: 'Danio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.flutterThemeMode,
      // navigatorObservers: [
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
      // Wait for profile provider to actually finish loading (not just a timeout!)
      final profileAsync = ref.read(userProfileProvider);
      
      // If still loading, wait for it to complete
      if (profileAsync is AsyncLoading) {
        // Wait up to 2 seconds for profile to load
        for (int i = 0; i < 20; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          final current = ref.read(userProfileProvider);
          if (current is! AsyncLoading) break;
        }
      }
      
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
                  'Danio',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
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
      return const TabNavigator();
    }
  }
}
