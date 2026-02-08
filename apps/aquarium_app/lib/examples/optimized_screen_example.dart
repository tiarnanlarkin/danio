/// Optimized Screen Example - Provider Rebuild Optimization
/// Shows before/after examples of provider optimization techniques
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// BEFORE: Full widget rebuilds when ANY provider changes
// ============================================================================

class UnoptimizedScreen extends ConsumerWidget {
  const UnoptimizedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ BAD: Watches all fields, rebuilds entire widget
    final user = ref.watch(userProfileProvider);
    // ignore: unused_local_variable
    final settings = ref.watch(settingsProvider);
    final tanks = ref.watch(tanksProvider);

    // Entire widget rebuilds when user.name, user.email, settings.theme,
    // settings.notifications, tanks list, etc. change

    return Scaffold(
      appBar: AppBar(
        title: Text(user.name), // Only needs user.name
      ),
      body: Column(
        children: [
          // Only needs tanks
          Expanded(child: TankList(tanks: tanks)),
          // Only needs user XP
          BottomBar(xp: user.xp),
        ],
      ),
    );
  }
}

// ============================================================================
// AFTER: Isolated rebuilds using Consumer and select()
// ============================================================================

class OptimizedScreen extends ConsumerWidget {
  const OptimizedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This build method only runs when tanks list changes
    final tanks = ref.watch(tanksProvider);

    return Scaffold(
      appBar: AppBar(
        // ✅ GOOD: Only rebuilds AppBar when user.name changes
        title: Consumer(
          builder: (context, ref, child) {
            final userName = ref.watch(
              userProfileProvider.select((u) => u.name),
            );
            return Text(userName);
          },
        ),
      ),
      body: Column(
        children: [
          // Tanks list rebuilds when tanks change (already happening)
          Expanded(child: TankList(tanks: tanks)),
          
          // ✅ GOOD: Only rebuilds BottomBar when user.xp changes
          Consumer(
            builder: (context, ref, child) {
              final xp = ref.watch(
                userProfileProvider.select((u) => u.xp),
              );
              return BottomBar(xp: xp);
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Using select() for granular subscriptions
// ============================================================================

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ GOOD: Only rebuilds when name changes, not email/xp/level/etc.
    final name = ref.watch(
      userProfileProvider.select((profile) => profile.name),
    );

    return Card(
      child: Text('Hello, $name!'),
    );
  }
}

// ============================================================================
// Combining multiple selects
// ============================================================================

class UserStatsCard extends ConsumerWidget {
  const UserStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ GOOD: Only rebuilds when XP or level changes
    final xp = ref.watch(
      userProfileProvider.select((p) => p.xp),
    );
    final level = ref.watch(
      userProfileProvider.select((p) => p.level),
    );

    return Card(
      child: Column(
        children: [
          Text('Level $level'),
          Text('$xp XP'),
        ],
      ),
    );
  }
}

// ============================================================================
// List optimization with RepaintBoundary
// ============================================================================

class TankList extends StatelessWidget {
  final List tanks;

  const TankList({super.key, required this.tanks});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tanks.length,
      itemBuilder: (context, index) {
        // ✅ GOOD: Each list item isolated from others
        return RepaintBoundary(
          child: TankListItem(tank: tanks[index]),
        );
      },
    );
  }
}

// ============================================================================
// Const constructors for static widgets
// ============================================================================

class StaticWidgetExample extends StatelessWidget {
  const StaticWidgetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ✅ GOOD: const prevents rebuilds
        const SizedBox(height: 16),
        const Divider(),
        const Icon(Icons.star),
        const Text('Static text'),
        
        // ❌ BAD: Will rebuild unnecessarily
        SizedBox(height: 16),
        Divider(),
        Icon(Icons.star),
        Text('Dynamic text'),
      ],
    );
  }
}

// ============================================================================
// Performance tracking mixin usage
// ============================================================================

class TrackedWidget extends StatefulWidget {
  const TrackedWidget({super.key});

  @override
  State<TrackedWidget> createState() => _TrackedWidgetState();
}

class _TrackedWidgetState extends State<TrackedWidget> {
  // ✅ GOOD: Track rebuilds in debug mode
  @override
  void didUpdateWidget(TrackedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This gets logged automatically by PerformanceMonitor
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// ============================================================================
// Key Optimization Principles
// ============================================================================

/// 1. Use select() to subscribe to specific fields:
///    ref.watch(provider.select((s) => s.specificField))
///
/// 2. Use Consumer for isolated rebuilds:
///    Consumer(builder: (context, ref, child) => ...)
///
/// 3. Use RepaintBoundary in lists:
///    ListView.builder(..., itemBuilder: (_, i) => RepaintBoundary(child: ...))
///
/// 4. Use const constructors everywhere possible:
///    const SizedBox(), const Text(), const Icon()
///
/// 5. Split large providers:
///    Instead of one giant UserProvider, split into UserProfileProvider,
///    UserSettingsProvider, UserStatsProvider
///
/// 6. Optimize images:
///    Use OptimizedNetworkImage/OptimizedAssetImage instead of Image.network/Image.asset
///
/// 7. Lazy load lists:
///    Always use .builder constructors: ListView.builder, GridView.builder
///
/// 8. Profile in profile mode:
///    flutter run --profile
///    Use DevTools to identify actual bottlenecks

// Placeholder provider implementations (replace with actual providers)
final userProfileProvider = StateProvider((ref) => UserProfile());
final settingsProvider = StateProvider((ref) => Settings());
final tanksProvider = StateProvider((ref) => <Tank>[]);

class UserProfile {
  final String name = 'User';
  final String email = 'user@example.com';
  final int xp = 1000;
  final int level = 5;
}

class Settings {
  final String theme = 'light';
  final bool notifications = true;
}

class Tank {
  final String id = '1';
  final String name = 'Tank';
}

class TankListItem extends StatelessWidget {
  final Tank tank;
  const TankListItem({super.key, required this.tank});

  @override
  Widget build(BuildContext context) => ListTile(title: Text(tank.name));
}

class BottomBar extends StatelessWidget {
  final int xp;
  const BottomBar({super.key, required this.xp});

  @override
  Widget build(BuildContext context) => Text('$xp XP');
}
