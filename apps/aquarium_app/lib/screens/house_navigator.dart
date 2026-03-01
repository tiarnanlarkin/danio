import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/spaced_repetition_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/sync_indicator.dart';
import '../widgets/celebrations/level_up_listener.dart';
import 'home/home_screen.dart';
import 'learn_screen.dart';
import 'workshop_screen.dart';
import 'shop_street_screen.dart';
import 'leaderboard_screen.dart';
import 'friends_screen.dart';

/// Provider for current room index
final currentRoomProvider = StateProvider<int>(
  (ref) => 1,
); // Start at Living Room

/// The main app shell - horizontal swipe navigation between rooms
class HouseNavigator extends ConsumerStatefulWidget {
  const HouseNavigator({super.key});

  @override
  ConsumerState<HouseNavigator> createState() => _HouseNavigatorState();
}

class _HouseNavigatorState extends ConsumerState<HouseNavigator> {
  late PageController _pageController;

  // Tutorial target keys
  final GlobalKey _studyRoomKey = GlobalKey();
  final GlobalKey _livingRoomKey = GlobalKey();
  final GlobalKey _friendsRoomKey = GlobalKey();
  final GlobalKey _workshopRoomKey = GlobalKey();
  bool _tutorialShown = false;

  // Room definitions
  static const List<RoomInfo> _rooms = [
    RoomInfo(
      name: 'Study',
      icon: Icons.auto_stories,
      emoji: '📚',
      color: AppColors.secondaryDark, // Deep blue
    ),
    RoomInfo(
      name: 'Living Room',
      icon: Icons.weekend,
      emoji: '🛋️',
      color: AppColors.primary, // Brand amber
    ),
    RoomInfo(
      name: 'Friends',
      icon: Icons.people,
      emoji: '👥',
      color: DanioColors.amethyst, // Purple
    ),
    RoomInfo(
      name: 'Leaderboard',
      icon: Icons.leaderboard,
      emoji: '🏆',
      color: DanioColors.topaz, // Gold
    ),
    RoomInfo(
      name: 'Workshop',
      icon: Icons.build,
      emoji: '🔧',
      color: Color(0xFF5D4E37), // Brown
    ),
    RoomInfo(
      name: 'Shop Street',
      icon: Icons.storefront,
      emoji: '🏪',
      color: DanioColors.emeraldGreen, // Green
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1, // Start at Living Room
      viewportFraction: 1.0,
    );

    // Check if tutorial should be shown after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
      // Listen to room provider changes and sync PageController
      ref.listenManual(currentRoomProvider, (previous, next) {
        if (_pageController.hasClients && _pageController.page?.round() != next) {
          _goToRoom(next);
        }
      });
    });
  }

  Future<void> _checkAndShowTutorial() async {
    if (_tutorialShown) return;

    final profile = ref.read(userProfileProvider).value;
    if (profile == null || profile.hasSeenTutorial) return;

    _tutorialShown = true;

    // Wait a bit for UI to settle
    await Future.delayed(AppDurations.long2);

    if (!mounted) return;

    showTutorialOverlay(
      context,
      steps: [
        TutorialStep(
          title: 'Welcome to Your House! 🏠',
          description:
              'Swipe left and right to explore different rooms. Each room has different features to help you learn and track your aquarium.',
          targetKey: _livingRoomKey,
        ),
        TutorialStep(
          title: 'Study Room 📚',
          description:
              'Start your aquarium journey here! Learn through interactive lessons and practice with spaced repetition.',
          targetKey: _studyRoomKey,
        ),
        TutorialStep(
          title: 'Living Room 🛋️',
          description:
              'Your home base! Track your tanks, log parameters, manage fish and equipment, and stay on top of maintenance.',
          targetKey: _livingRoomKey,
        ),
        TutorialStep(
          title: 'Friends & Community 👥',
          description:
              'Connect with other aquarium enthusiasts, share tips, and learn together!',
          targetKey: _friendsRoomKey,
        ),
        TutorialStep(
          title: 'Workshop 🔧',
          description:
              'Access powerful calculators and tools to help you make the right decisions for your aquarium.',
          targetKey: _workshopRoomKey,
        ),
      ],
      onComplete: () {
        // Tutorial completion is handled by the overlay itself
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(currentRoomProvider.notifier).state = index;
    // Haptic feedback on room change
    HapticFeedback.selectionClick();
  }

  void _goToRoom(int index) {
    _pageController.animateToPage(
      index,
      duration: AppDurations.long1,
      curve: AppCurves.emphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoom = ref.watch(currentRoomProvider);

    return LevelUpListener(
      child: Scaffold(
        body: Stack(
        children: [
          // === Main PageView ===
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const BouncingScrollPhysics(),
            children: const [
              // Room 0: Study (Learning)
              LearnScreen(),

              // Room 1: Living Room (Home/Tanks)
              _LivingRoomWrapper(),

              // Room 2: Friends (Social)
              FriendsScreen(),

              // Room 3: Leaderboard (Competition)
              LeaderboardScreen(),

              // Room 4: Workshop (Tools)
              WorkshopScreen(),

              // Room 5: Shop Street
              ShopStreetScreen(),
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
                children: const [OfflineIndicator(), SyncIndicator()],
              ),
            ),
          ),

          // === Swipe Zones for Room Navigation ===
          // These wider zones allow horizontal swipes to navigate between rooms
          // They're positioned to avoid the Android back gesture zones (< 24px from edge)
          // Left side - swipe right to go to previous room
          Positioned(
            left: 24, // Start after Android's back gesture zone
            top: 120,
            bottom: 200,
            width: 60,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! > 400) {
                  // Swipe right - go to previous room
                  if (currentRoom > 0) {
                    _goToRoom(currentRoom - 1);
                  }
                }
              },
            ),
          ),
          // Right side - swipe left to go to next room
          Positioned(
            right: 24, // End before Android's back gesture zone
            top: 120,
            bottom: 200,
            width: 60,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null && details.primaryVelocity! < -400) {
                  // Swipe left - go to next room
                  if (currentRoom < _rooms.length - 1) {
                    _goToRoom(currentRoom + 1);
                  }
                }
              },
            ),
          ),

          // === Room Indicator Bar ===
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _RoomIndicatorBar(
              rooms: _rooms,
              currentIndex: currentRoom,
              onRoomTap: _goToRoom,
              roomKeys: {
                0: _studyRoomKey,
                1: _livingRoomKey,
                2: _friendsRoomKey,
                4: _workshopRoomKey,
              },
            ),
          ),
        ],
      ),
      ), // Close Scaffold
    ); // Close LevelUpListener
  }
}

/// Room metadata
class RoomInfo {
  final String name;
  final IconData icon;
  final String emoji;
  final Color color;

  const RoomInfo({
    required this.name,
    required this.icon,
    required this.emoji,
    required this.color,
  });
}

/// Bottom navigation bar showing room indicators
class _RoomIndicatorBar extends ConsumerWidget {
  final List<RoomInfo> rooms;
  final int currentIndex;
  final ValueChanged<int> onRoomTap;
  final Map<int, GlobalKey>? roomKeys;

  const _RoomIndicatorBar({
    required this.rooms,
    required this.currentIndex,
    required this.onRoomTap,
    this.roomKeys,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Watch spaced repetition state for badge count
    final srState = ref.watch(spacedRepetitionProvider);
    final dueCardsCount = srState.stats.dueCards;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: bottomPadding + 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppOverlays.black30,
            AppOverlays.black50,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(rooms.length, (index) {
          final room = rooms[index];
          final isSelected = index == currentIndex;
          final roomKey = roomKeys?[index];

          return Semantics(
            label: '${room.name}${isSelected ? ', selected' : ''}',
            button: true,
            selected: isSelected,
            child: GestureDetector(
              key: roomKey,
              onTap: () => onRoomTap(index),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: AppDurations.medium2,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? 16 : 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? room.color.withAlpha(230)
                          : AppOverlays.white10,
                      borderRadius: AppRadius.largeRadius,
                      border: Border.all(
                        color: isSelected
                            ? AppOverlays.white30
                            : Colors.transparent,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          room.emoji,
                          style: TextStyle(fontSize: isSelected ? 18 : 16),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Text(
                            room.name,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Badge for Study room (index 0) when cards are due
                  if (index == 0 && dueCardsCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: AppRadius.smallRadius,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            dueCardsCount > 99 ? '99+' : '$dueCardsCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Wrapper for Living Room to handle its own state
class _LivingRoomWrapper extends ConsumerWidget {
  const _LivingRoomWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The HomeScreen but without its own scaffold
    // We'll need to refactor HomeScreen slightly
    return const HomeScreen();
  }
}
