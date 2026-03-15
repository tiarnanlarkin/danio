import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PerformanceOverlay;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/onboarding_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/spaced_repetition_provider.dart';
import 'screens/tab_navigator.dart';
import 'screens/onboarding_screen.dart';
import 'screens/onboarding/personalisation_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/spaced_repetition_practice_screen.dart';
import 'screens/achievements_screen.dart';
import 'services/onboarding_service.dart';
import 'services/notification_service.dart';
import 'services/hearts_service.dart';
import 'services/celebration_service.dart';
import 'services/xp_animation_service.dart';
import 'services/supabase_service.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // Disable runtime font fetching — use bundled/system fonts only
  GoogleFonts.config.allowRuntimeFetching = false;

  // ROADMAP: Configure Firebase for push notifications and analytics — see docs/FIREBASE_SETUP_GUIDE.md

  // Capture full Flutter framework errors to logcat for QA debugging.
  // Remove before release or restrict to kDebugMode.
  if (kDebugMode) {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('========== FLUTTER ERROR ==========');
      debugPrint('${details.exception}');
      debugPrint('${details.stack}');
      debugPrint('===================================');
      originalOnError?.call(details);
    };
  }

  // Initialize global error handler
  GlobalErrorHandler.initialize(
    onError: (error, stack) {
      // Log to console in debug mode
      if (kDebugMode) {
        debugPrint('Global error caught: $error\n$stack');
      }
    },
  );

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
      child: const ProviderScope(child: DanioApp()),
    ),
  );
}

class DanioApp extends ConsumerWidget {
  const DanioApp({super.key});

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
      builder: (context, child) => XpAnimationListener(
        child: CelebrationOverlayWrapper(
          child: AppPerformanceOverlay(
            showOverlay: _showPerformanceOverlay,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: const _AppRouter(),
    );
  }
}

/// Checks onboarding state, profile existence, and routes to the appropriate
/// screen.  All routing decisions are driven by Riverpod providers so that
/// mid-session state changes (e.g. onboarding completing) cause a single,
/// clean rebuild — preventing the duplicate-TabNavigator bug that occurred
/// when onboarding screens pushed their own TabNavigator instance.
class _AppRouter extends ConsumerStatefulWidget {
  const _AppRouter();

  @override
  ConsumerState<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends ConsumerState<_AppRouter>
    with WidgetsBindingObserver {
  bool _hasScheduledNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  Widget build(BuildContext context) {
    // ── 1. Onboarding state (reactive via provider) ──────────────────────
    final onboardingAsync = ref.watch(onboardingCompletedProvider);

    // While the provider is loading, show splash screen
    if (onboardingAsync is AsyncLoading || !onboardingAsync.hasValue) {
      return _buildSplash(context);
    }

    final onboardingCompleted = onboardingAsync.value ?? false;

    if (!onboardingCompleted) {
      return const OnboardingScreen();
    }

    // ── 2. Profile state (reactive via provider) ─────────────────────────
    final profileAsync = ref.watch(userProfileProvider);

    // Still loading profile — show splash to avoid flash
    if (profileAsync is AsyncLoading) {
      return _buildSplash(context);
    }

    final profileExists = profileAsync.value != null;

    if (!profileExists) {
      return const PersonalisationScreen();
    }

    // ── 3. Everything ready — show main app ──────────────────────────────
    // Schedule review notifications once after first build completes
    if (!_hasScheduledNotifications) {
      _hasScheduledNotifications = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scheduleReviewNotifications();
      });
    }

    return const TabNavigator();
  }

  Widget _buildSplash(BuildContext context) {
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
                color: Colors.white,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Danio',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
