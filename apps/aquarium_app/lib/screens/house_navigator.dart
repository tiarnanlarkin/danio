import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'workshop_screen.dart';
import 'shop_street_screen.dart';
import 'leaderboard_screen.dart';

/// Provider for current room index
final currentRoomProvider = StateProvider<int>((ref) => 1); // Start at Living Room

/// The main app shell - horizontal swipe navigation between rooms
class HouseNavigator extends ConsumerStatefulWidget {
  const HouseNavigator({super.key});

  @override
  ConsumerState<HouseNavigator> createState() => _HouseNavigatorState();
}

class _HouseNavigatorState extends ConsumerState<HouseNavigator> {
  late PageController _pageController;

  // Room definitions
  static const List<RoomInfo> _rooms = [
    RoomInfo(
      name: 'Study',
      icon: Icons.auto_stories,
      emoji: '📚',
      color: Color(0xFF2D3A4F), // Deep blue
    ),
    RoomInfo(
      name: 'Living Room',
      icon: Icons.weekend,
      emoji: '🛋️',
      color: Color(0xFF5B9A8B), // Teal
    ),
    RoomInfo(
      name: 'Leaderboard',
      icon: Icons.leaderboard,
      emoji: '🏆',
      color: Color(0xFFFFD700), // Gold
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
      color: Color(0xFF4A7C59), // Green
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1, // Start at Living Room
      viewportFraction: 1.0,
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
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRoom = ref.watch(currentRoomProvider);

    return Scaffold(
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
              
              // Room 2: Leaderboard (Competition)
              LeaderboardScreen(),
              
              // Room 3: Workshop (Tools)
              WorkshopScreen(),
              
              // Room 4: Shop Street
              ShopStreetScreen(),
            ],
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
            ),
          ),
        ],
      ),
    );
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
class _RoomIndicatorBar extends StatelessWidget {
  final List<RoomInfo> rooms;
  final int currentIndex;
  final ValueChanged<int> onRoomTap;

  const _RoomIndicatorBar({
    required this.rooms,
    required this.currentIndex,
    required this.onRoomTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(rooms.length, (index) {
          final room = rooms[index];
          final isSelected = index == currentIndex;

          return Semantics(
            label: '${room.name}${isSelected ? ', selected' : ''}',
            button: true,
            selected: isSelected,
            child: GestureDetector(
              onTap: () => onRoomTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 12,
                  vertical: 8,
                ),
              decoration: BoxDecoration(
                color: isSelected
                    ? room.color.withOpacity(0.9)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    room.emoji,
                    style: TextStyle(
                      fontSize: isSelected ? 18 : 16,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      room.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
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
