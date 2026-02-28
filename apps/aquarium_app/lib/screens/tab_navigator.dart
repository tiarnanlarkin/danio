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

/// The main app navigation - 4-tab bottom navigation
/// Replaces the old HouseNavigator's 6-room swipe pattern
class TabNavigator extends ConsumerStatefulWidget {
  const TabNavigator({super.key});

  @override
  ConsumerState<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends ConsumerState<TabNavigator> {
  // Keys for each tab's navigator to preserve state
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Learn
    GlobalKey<NavigatorState>(), // Quiz
    GlobalKey<NavigatorState>(), // Tank
    GlobalKey<NavigatorState>(), // Smart
    GlobalKey<NavigatorState>(), // Settings
  ];

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

          // At tab root - show exit confirmation dialog
          if (!context.mounted) return;
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Exit app?'),
              content: const Text('Are you sure you want to leave?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Exit'),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          body: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // === Main Tab Content ===
              // Each tab has its own Navigator to preserve state
              IndexedStack(
                clipBehavior: Clip.hardEdge,
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
                label: 'Quiz',
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
              // Settings tab
              const NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
