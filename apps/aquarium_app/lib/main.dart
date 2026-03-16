import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide PerformanceOverlay;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/onboarding_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/spaced_repetition_provider.dart';
import 'screens/tab_navigator.dart';
import 'screens/onboarding_screen.dart';
import 'screens/onboarding/consent_screen.dart';
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

  // Allow runtime font fetching — Fredoka & Nunito are not bundled as .ttf
  // assets, so GoogleFonts must fetch them on first use. They are cached by
  // the package for subsequent launches.
  GoogleFonts.config.allowRuntimeFetching = true;

  // Lock orientation to portrait (lightweight, keeps first frame fast)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── Error handling: set up BEFORE runApp so first-frame errors are captured ──
  // In debug mode, log to console. In release mode, install a preliminary
  // handler that captures errors; we upgrade to Crashlytics once Firebase
  // initialises in the post-frame callback.
  if (kReleaseMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Platform error (pre-Firebase): $error\n$stack');
      return true;
    };
  } else {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('========== FLUTTER ERROR ==========');
      debugPrint('${details.exception}');
      debugPrint('${details.stack}');
      debugPrint('===================================');
      originalOnError?.call(details);
    };

    GlobalErrorHandler.initialize(
      onError: (error, stack) {
        if (kDebugMode) {
          debugPrint('Global error caught: $error\n$stack');
        }
      },
    );
  }

  // ── Defer heavy init to after the first frame ─────────────────────────
  // Firebase, Supabase, and Notifications are moved to a post-frame
  // callback so the splash/loading screen renders instantly.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Initialize Firebase — graceful fallback if google-services.json is missing
    bool firebaseInitialized = false;
    try {
      await Firebase.initializeApp();
      firebaseInitialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Firebase init failed (app will run without it): $e');
    }

    // ── Apply persisted GDPR analytics consent ──
    if (firebaseInitialized) {
      final prefs = await SharedPreferences.getInstance();
      final consent = prefs.getBool(kGdprAnalyticsConsentKey);
      // null means user hasn't decided yet — keep collection disabled
      // (AndroidManifest defaults are already false).
      await applyAnalyticsConsent(consent == true);
    }

    // ── Upgrade error handlers to Crashlytics now that Firebase is ready ──
    if (kReleaseMode && firebaseInitialized) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
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
        if (payload == 'learn') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const LearnScreen()),
          );
        } else if (payload == 'review') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => const SpacedRepetitionPracticeScreen(),
            ),
          );
        } else if (payload == 'achievements') {
          navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
          );
        }
      },
    );
  });

  runApp(ErrorBoundary(child: const ProviderScope(child: DanioApp())));
}

class DanioApp extends ConsumerWidget {
  const DanioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      settingsProvider.select((s) => s.flutterThemeMode),
    );

    return MaterialApp(
      scrollBehavior: const DanioScrollBehavior(),
      navigatorKey: navigatorKey,
      title: 'Danio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
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

  /// `null` means "still loading", `true`/`false` means decided.
  bool? _gdprConsentDecided;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkGdprConsent();
  }

  Future<void> _checkGdprConsent() async {
    final prefs = await SharedPreferences.getInstance();
    final consent = prefs.getBool(kGdprAnalyticsConsentKey);
    if (mounted) {
      setState(() {
        // consent is null when user hasn't decided → show consent screen
        _gdprConsentDecided = consent != null;
      });
    }
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
      // Refresh streak nudge notifications based on today's progress
      _scheduleStreakNotifications();
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

  /// Schedule streak nudge notifications based on current profile.
  /// Cancels existing streak notifications before re-scheduling to
  /// avoid duplicates. Silently skips if permission was not granted.
  Future<void> _scheduleStreakNotifications() async {
    try {
      final profile = ref.read(userProfileProvider).value;
      if (profile == null) return;

      final notificationService = NotificationService();
      final now = DateTime.now();
      final todayKey =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final todayXp = profile.dailyXpHistory[todayKey] ?? 0;

      await notificationService.scheduleAllStreakNotifications(
        currentStreak: profile.currentStreak,
        dailyXpGoal: profile.dailyXpGoal,
        todayXp: todayXp,
      );
    } catch (e) {
      debugPrint('Failed to schedule streak notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── 0. GDPR consent gate ────────────────────────────────────────────
    if (_gdprConsentDecided == null) {
      return _buildSplash(context);
    }
    if (_gdprConsentDecided == false) {
      return ConsentScreen(
        key: const ValueKey('consent'),
        onConsentGiven: () {
          if (mounted) setState(() => _gdprConsentDecided = true);
        },
      );
    }

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
      // New onboarding flow always creates a profile before completing.
      // This fallback handles legacy cases where onboarding was marked
      // complete without a profile — restart onboarding to collect data.
      return const OnboardingScreen();
    }

    // ── 3. Everything ready — show main app ──────────────────────────────
    // Schedule review notifications once after first build completes
    if (!_hasScheduledNotifications) {
      _hasScheduledNotifications = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scheduleReviewNotifications();
          _scheduleStreakNotifications();
        }
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
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.water_drop,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
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
