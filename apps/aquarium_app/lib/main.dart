import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/settings_provider.dart';
import 'screens/house_navigator.dart';
import 'screens/onboarding_screen.dart';
import 'screens/learn_screen.dart';
import 'services/onboarding_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

// Global navigator key for notification navigation
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications with navigation callback
  final notificationService = NotificationService();
  await notificationService.initialize(
    onSelectNotification: (payload) {
      // Navigate to learn screen when notification is tapped
      if (payload == 'learn') {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const LearnScreen()),
        );
      }
    },
  );

  runApp(
    const ProviderScope(
      child: AquariumApp(),
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
      home: const _AppRouter(),
    );
  }
}

/// Checks onboarding state and routes to the appropriate screen.
class _AppRouter extends StatefulWidget {
  const _AppRouter();

  @override
  State<_AppRouter> createState() => _AppRouterState();
}

class _AppRouterState extends State<_AppRouter> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final service = await OnboardingService.getInstance();
    setState(() {
      _showOnboarding = !service.isOnboardingCompleted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Splash screen while checking onboarding state
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
                Icon(Icons.water_drop, size: 80, color: isDark ? Colors.black : Colors.white),
                const SizedBox(height: 16),
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

    return _showOnboarding ? const OnboardingScreen() : const HouseNavigator();
  }
}
