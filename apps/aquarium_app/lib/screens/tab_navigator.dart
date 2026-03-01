import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/spaced_repetition_provider.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/sync_indicator.dart';
import '../widgets/celebrations/level_up_listener.dart';
import 'home/home_screen.dart';
import 'learn_screen.dart';
import 'practice_hub_screen.dart';
import 'settings_hub_screen.dart';
import 'smart_screen.dart';

/// Provider for current tab index
final currentTabProvider = StateProvider<int>((ref) => 0); // Start at Learn tab

/// The main app navigation - 5-tab bottom navigation
/// Main tab-based navigation pattern with smooth cross-fade transitions
class TabNavigator extends ConsumerStatefulWidget {
  const TabNavigator({super.key});

  @override
  ConsumerState<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends ConsumerState<TabNavigator>
    with SingleTickerProviderStateMixin {
  // Track last back button press for double-tap-to-exit
  DateTime? _lastBackPress;

  // Animation for tab cross-fade
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // Keys for each tab's navigator to preserve state
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Learn
    GlobalKey<NavigatorState>(), // Quiz
    GlobalKey<NavigatorState>(), // Tank
    GlobalKey<NavigatorState>(), // Smart
    GlobalKey<NavigatorState>(), // Settings
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0, // Start fully visible
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabChanged(int newIndex, int oldIndex) {
    if (newIndex == oldIndex) return;
    // Quick fade out then in for smooth tab transition
    _fadeController.value = 0.0;
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final srState = ref.watch(spacedRepetitionProvider);
    final dueCardsCount = srState.stats.dueCards;

    return LevelUpListener(
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) return;

          // Check if current tab has screens in its stack
          final currentNavigator = _navigatorKeys[currentTab].currentState;
          if (currentNavigator != null && currentNavigator.canPop()) {
            // Pop within the current tab's navigation stack
            currentNavigator.pop();
            return;
          }

          // At tab root - implement double-back-to-exit
          final now = DateTime.now();
          if (_lastBackPress == null ||
              now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
            // First back press - show toast
            _lastBackPress = now;
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tap back once more to leave'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }

          // Second back press within 2 seconds - exit app
          SystemNavigator.pop();
        },
        child: Scaffold(
          body: Stack(
            children: [
              // === Main Tab Content ===
              // Each tab has its own Navigator to preserve state
              // Wrapped in FadeTransition for smooth tab switching
              FadeTransition(
                opacity: _fadeAnimation,
                child: IndexedStack(
                  index: currentTab,
                  children: [
                    // Tab 0: Learn
                    Navigator(
                      key: _navigatorKeys[0],
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (context) => const LearnScreen(),
                          settings: settings,
                        );
                      },
                    ),
                    // Tab 1: Quiz/Practice
                    Navigator(
                      key: _navigatorKeys[1],
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (context) => const PracticeHubScreen(),
                          settings: settings,
                        );
                      },
                    ),
                    // Tab 2: Tank
                    Navigator(
                      key: _navigatorKeys[2],
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                          settings: settings,
                        );
                      },
                    ),
                    // Tab 3: Smart
                    Navigator(
                      key: _navigatorKeys[3],
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (context) => const SmartScreen(),
                          settings: settings,
                        );
                      },
                    ),
                    // Tab 4: Settings
                    Navigator(
                      key: _navigatorKeys[4],
                      onGenerateRoute: (settings) {
                        return MaterialPageRoute(
                          builder: (context) => const SettingsHubScreen(),
                          settings: settings,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // === Offline/Sync Indicators at Top ===
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      OfflineIndicator(),
                      SyncIndicator(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // === Bottom Navigation Bar ===
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentTab,
            onDestinationSelected: (index) {
              if (index == currentTab) {
                // Tapped current tab - scroll to top if possible
                final navigator = _navigatorKeys[index].currentState;
                if (navigator != null && navigator.canPop()) {
                  // Pop to root of this tab
                  navigator.popUntil((route) => route.isFirst);
                }
              } else {
                // Animate tab transition
                _onTabChanged(index, currentTab);
              }
              // Switch tabs
              ref.read(currentTabProvider.notifier).state = index;
              // Haptic feedback
              HapticFeedback.selectionClick();
            },
            destinations: [
              // Learn tab
              const NavigationDestination(
                icon: Icon(Icons.auto_stories_outlined),
                selectedIcon: Icon(Icons.auto_stories),
                label: 'Learn',
              ),
              // Quiz tab with badge for due cards
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: dueCardsCount > 0,
                  label: Text(dueCardsCount > 99 ? '99+' : '$dueCardsCount'),
                  child: const Icon(Icons.quiz_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: dueCardsCount > 0,
                  label: Text(dueCardsCount > 99 ? '99+' : '$dueCardsCount'),
                  child: const Icon(Icons.quiz),
                ),
                label: 'Practice',
              ),
              // Tank tab
              const NavigationDestination(
                icon: Icon(Icons.water_outlined),
                selectedIcon: Icon(Icons.water),
                label: 'Tank',
              ),
              // Smart tab
              const NavigationDestination(
                icon: Icon(Icons.psychology_outlined),
                selectedIcon: Icon(Icons.psychology),
                label: 'Smart',
              ),
              // Toolbox tab
              const NavigationDestination(
                icon: Icon(Icons.construction_outlined),
                selectedIcon: Icon(Icons.construction),
                label: 'Toolbox',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
