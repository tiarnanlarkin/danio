import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/learn_screen.dart';
import '../screens/workshop_screen.dart';
import '../screens/shop_street_screen.dart';
import '../utils/navigation_throttle.dart';

/// Room navigation widget - can be placed in settings or as an overlay
class RoomNavigation extends StatelessWidget {
  final String? tankId;
  final String? tankName;

  const RoomNavigation({super.key, this.tankId, this.tankName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explore the House', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Each room has different tools and features',
            style: AppTypography.bodySmall.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _RoomCard(
                  emoji: '📚',
                  name: 'Study',
                  description: 'Learn & guides',
                  color: const Color(0xFF1A237E),
                  onTap: () =>
                      NavigationThrottle.push(context, const LearnScreen()),
                ),
              ),
              const SizedBox(width: AppSpacing.sm2),
              Expanded(
                child: _RoomCard(
                  emoji: '🔧',
                  name: 'Workshop',
                  description: 'Tools & calculators',
                  color: const Color(0xFF5D4037),
                  onTap: () =>
                      NavigationThrottle.push(context, const WorkshopScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm2),
          _RoomCard(
            emoji: '🏪',
            name: 'Shop Street',
            description: 'Wishlist & costs',
            color: const Color(0xFF2E7D32),
            onTap: () =>
                NavigationThrottle.push(context, const ShopStreetScreen()),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const _RoomCard({
    required this.emoji,
    required this.name,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mediumRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withAlpha(178)],
          ),
          borderRadius: AppRadius.mediumRadius,
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(76),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              emoji,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              style: AppTypography.labelLarge.copyWith(color: Colors.white),
            ),
            Text(
              description,
              style: AppTypography.bodySmall.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet to show room navigation
void showRoomNavigationSheet(
  BuildContext context, {
  String? tankId,
  String? tankName,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          RoomNavigation(tankId: tankId, tankName: tankName),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
  );
}
