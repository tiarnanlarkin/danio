import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/reduced_motion_provider.dart';
import '../providers/spaced_repetition_provider.dart';
import 'package:flutter/foundation.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/sync_indicator.dart';
import '../widgets/celebrations/level_up_listener.dart';
import '../widgets/celebrations/streak_milestone_listener.dart';
import 'home/home_screen.dart';
import 'learn_screen.dart';
import 'practice_hub_screen.dart';
import 'settings_hub_screen.dart';
import 'smart_screen.dart';
import '../widgets/danio_snack_bar.dart';

/// Provider for current tab index
final currentTabProvider = StateProvider<int>((ref) => 0); // Start at Learn tab

/// Holds the list of per-tab nested navigator keys.
/// Initialized once by [TabNavigator] so that external callers (notification
/// deep-link handler) can push routes within a specific tab's navigator.
final tabNavigatorKeysProvider = StateProvider<List<GlobalKey<NavigatorState>>>(
  (ref) => List.generate(5, (_) => GlobalKey<NavigatorState>()),
);

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
    final disableMotion = ref.read(reducedMotionProvider).disableDecorativeAnimations;
    _fadeController = AnimationController(
      vsync: this,
      duration: disableMotion ? Duration.zero : AppDurations.medium2, // 200ms – crisp tab cross-fade
      value: 1.0, // Start fully visible
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AppCurves.standardDecelerate, // easeOut
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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
    final dueCardsCount = ref.watch(
      spacedRepetitionProvider.select((s) => s.stats.dueCards),
    );

    // Expose tab navigator keys so external code (notifications) can push
    // routes within a specific tab's navigator.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tabNavigatorKeysProvider.notifier).state = _navigatorKeys;
    });

    return StreakMilestoneListener(
      child: LevelUpListener(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, _) async {
            if (didPop) return;

            // Check if current tab has screens in its stack
            final currentNavigator = _navigatorKeys[currentTab].currentState;
            if (currentNavigator != null && currentNavigator.canPop()) {
              // Defer pop to next frame to avoid accessing a deactivating element's
              // ancestor during NavigatorState._cancelActivePointers (lifecycle assertion)
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (currentNavigator.canPop()) {
                  currentNavigator.pop();
                }
              });
              return;
            }

            // At tab root - implement double-back-to-exit
            final now = DateTime.now();
            if (_lastBackPress == null ||
                now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
              // First back press - show toast
              _lastBackPress = now;
              DanioSnackBar.info(context, 'Tap back once more to leave');
              return;
            }

            // Second back press within 2 seconds - exit app
            SystemNavigator.pop();
          },
          child: Scaffold(
            extendBody: true,
            body: Stack(
              children: [
                // === Main Tab Content ===
                // Each tab has its own Navigator to preserve state
                // Wrapped in FadeTransition for smooth tab switching
                // Bottom padding ensures content doesn't hide behind NavigationBar.
                // With extendBody:true, MediaQuery.padding.bottom already includes
                // the NavigationBar height — no extra offset needed.
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: IndexedStack(
                    index: currentTab,
                    children: [
                      // Tab 0: Learn
                      TickerMode(
                        enabled: currentTab == 0,
                        child: Navigator(
                          key: _navigatorKeys[0],
                          onGenerateRoute: (settings) {
                            return MaterialPageRoute(
                              builder: (context) => const LearnScreen(),
                              settings: settings,
                            );
                          },
                        ),
                      ),
                      // Tab 1: Quiz/Practice
                      TickerMode(
                        enabled: currentTab == 1,
                        child: Navigator(
                          key: _navigatorKeys[1],
                          onGenerateRoute: (settings) {
                            return MaterialPageRoute(
                              builder: (context) => const PracticeHubScreen(),
                              settings: settings,
                            );
                          },
                        ),
                      ),
                      // Tab 2: Tank
                      TickerMode(
                        enabled: currentTab == 2,
                        child: Navigator(
                          key: _navigatorKeys[2],
                          onGenerateRoute: (settings) {
                            return MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                              settings: settings,
                            );
                          },
                        ),
                      ),
                      // Tab 3: Smart
                      TickerMode(
                        enabled: currentTab == 3,
                        child: Navigator(
                          key: _navigatorKeys[3],
                          onGenerateRoute: (settings) {
                            return MaterialPageRoute(
                              builder: (context) => const SmartScreen(),
                              settings: settings,
                            );
                          },
                        ),
                      ),
                      // Tab 4: Settings
                      TickerMode(
                        enabled: currentTab == 4,
                        child: Navigator(
                          key: _navigatorKeys[4],
                          onGenerateRoute: (settings) {
                            return MaterialPageRoute(
                              builder: (context) => const SettingsHubScreen(),
                              settings: settings,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
                      children: [const OfflineIndicator(), if (kDebugMode) const SyncIndicator()],
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
                  tooltip: 'Learn tab',
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
                  tooltip: 'Practice tab',
                ),
                // Tank tab
                const NavigationDestination(
                  icon: Icon(Icons.water_outlined),
                  selectedIcon: Icon(Icons.water),
                  label: 'Tank',
                  tooltip: 'Tank tab',
                ),
                // Smart tab
                const NavigationDestination(
                  icon: Icon(Icons.psychology_outlined),
                  selectedIcon: Icon(Icons.psychology),
                  label: 'Smart',
                  tooltip: 'Smart tab',
                ),
                // More tab (profile, shop, tools, settings, about)
                const NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view),
                  label: 'More',
                  tooltip: 'More tab',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
