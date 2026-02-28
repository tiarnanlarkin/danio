# Offline Mode Implementation Guide

## Overview

The app now supports full offline functionality with automatic syncing when connection is restored. All user actions (XP awards, gem purchases, profile updates, etc.) work seamlessly offline and sync automatically when internet returns.

## Key Components

### 1. Connectivity Monitoring

**File:** `lib/widgets/offline_indicator.dart`

Provides:
- `connectivityProvider` - Stream of connectivity changes
- `isOnlineProvider` - Simple boolean for online/offline status
- `OfflineIndicator` - Banner widget showing "You're offline" message
- `OfflineIndicatorCompact` - Compact version for app bars

**Usage:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/offline_indicator.dart';

// In your widget:
@override
Widget build(BuildContext context, WidgetRef ref) {
  final isOnline = ref.watch(isOnlineProvider);
  
  return Column(
    children: [
      const OfflineIndicator(), // Shows banner when offline
      // Your content here
    ],
  );
}
```

### 2. Sync Service

**File:** `lib/services/sync_service.dart`

Manages queued actions when offline:
- Automatically queues actions when device is offline
- Auto-syncs when connection returns
- Persists queue across app restarts
- Shows sync status and progress

**Action Types:**
- `xpAward` - XP rewards
- `gemPurchase` - Gem shop purchases
- `gemEarn` - Gem rewards
- `profileUpdate` - Profile changes
- `lessonComplete` - Lesson completions
- `achievementUnlock` - Achievement unlocks
- `streakUpdate` - Streak updates

**Providers:**
- `syncServiceProvider` - Main sync service state
- `needsSyncProvider` - Boolean indicating if sync is needed
- `syncStatusMessageProvider` - Human-readable sync status

**Usage:**
```dart
// Queue an action manually:
final syncService = ref.read(syncServiceProvider.notifier);
await syncService.queueAction(
  type: SyncActionType.xpAward,
  data: {'xp': 50, 'timestamp': DateTime.now().toIso8601String()},
);

// Trigger manual sync:
await syncService.syncNow();
```

### 3. Offline-Aware Service

**File:** `lib/services/offline_aware_service.dart`

Helper service that wraps user actions to automatically handle offline queueing:

**Usage:**
```dart
final offlineService = ref.read(offlineAwareServiceProvider);

// Award XP (works offline):
await offlineService.awardXp(
  amount: 50,
  localUpdate: () async {
    // Your existing XP update code here
    await ref.read(userProfileProvider.notifier).addXp(50);
  },
);

// Complete lesson (works offline):
await offlineService.completeLesson(
  lessonId: 'lesson_123',
  xpReward: 50,
  localUpdate: () async {
    await ref.read(userProfileProvider.notifier).completeLesson('lesson_123', 50);
  },
);

// Purchase with gems (works offline):
await offlineService.purchaseWithGems(
  itemId: 'item_123',
  itemName: 'Streak Freeze',
  cost: 100,
  localUpdate: () async {
    await ref.read(gemsProvider.notifier).spendGems(100, 'Streak Freeze');
  },
);
```

### 4. Sync Indicators

**File:** `lib/widgets/sync_indicator.dart`

Visual feedback for sync status:
- `SyncIndicator` - Full-width banner showing sync progress
- `SyncIndicatorCompact` - Small badge for app bars
- `SyncFloatingButton` - FAB-style button to trigger manual sync

**Usage:**
```dart
return Column(
  children: [
    const OfflineIndicator(),  // Shows when offline
    const SyncIndicator(),      // Shows when syncing/queued
    // Your content here
  ],
);
```

## Integration Examples

### Example 1: Add to Main Layout

```dart
// In lib/screens/house_navigator.dart or your main layout:
import '../widgets/offline_indicator.dart';
import '../widgets/sync_indicator.dart';

@override
Widget build(BuildContext context, WidgetRef ref) {
  return Column(
    children: [
      const OfflineIndicator(),   // Shows when offline
      const SyncIndicator(),       // Shows sync status
      Expanded(
        child: // Your existing content
      ),
    ],
  );
}
```

### Example 2: Offline-Aware Action

```dart
// Wrap any user action that should work offline:
Future<void> completeMyLesson(String lessonId) async {
  final offlineService = ref.read(offlineAwareServiceProvider);
  
  await offlineService.completeLesson(
    lessonId: lessonId,
    xpReward: 50,
    localUpdate: () async {
      // This code runs immediately (even offline)
      // It updates local storage
      final profile = ref.read(userProfileProvider.notifier);
      await profile.completeLesson(lessonId, 50);
      
      // The action is also queued for backend sync when online
    },
  );
}
```

### Example 3: Manual Sync Button

```dart
// Add a sync button to settings or profile screen:
ElevatedButton(
  onPressed: () {
    ref.read(syncServiceProvider.notifier).syncNow();
  },
  child: Consumer(
    builder: (context, ref, child) {
      final syncState = ref.watch(syncServiceProvider);
      return Text(
        syncState.isSyncing 
          ? 'Syncing...' 
          : 'Sync Now (${syncState.queuedCount})'
      );
    },
  ),
)
```

## How It Works

### Local-First Architecture

The app uses a **local-first** approach:

1. **All data is stored locally** using `SharedPreferences`
2. **User actions execute immediately** on local data (no waiting for network)
3. **Actions are queued** for backend sync when offline
4. **Auto-sync happens** when connection returns
5. **App works fully offline** - no functionality is blocked

### Sync Flow

```
User Action (e.g., complete lesson)
  ↓
Check connectivity
  ↓
[ONLINE]                    [OFFLINE]
  ↓                           ↓
Execute locally          Execute locally
  ↓                           ↓
Done!                    Queue for sync
                              ↓
                         (Wait for connection)
                              ↓
                         Auto-sync when online
                              ↓
                         Clear queue
```

### Data Persistence

- **Sync queue** is persisted in `SharedPreferences` under key `sync_queue`
- **Last sync time** is stored under key `last_sync_time`
- **Queue survives** app restarts and device reboots
- **Actions are timestamped** to maintain order

## Testing Offline Mode

### Test Scenarios

1. **Turn off WiFi/data** before completing a lesson
   - ✅ Lesson should complete normally
   - ✅ Offline banner should appear
   - ✅ Sync indicator shows "1 action queued"

2. **Complete multiple actions while offline**
   - ✅ All actions execute locally
   - ✅ Queue count increases
   - ✅ No errors or blocking

3. **Turn WiFi/data back on**
   - ✅ Auto-sync triggers
   - ✅ "Syncing..." indicator appears
   - ✅ Queue clears after sync
   - ✅ Offline banner disappears

4. **Close app with queued actions**
   - ✅ Restart app
   - ✅ Queue is still present
   - ✅ Sync triggers when online

### Manual Testing Commands

```bash
# Enable airplane mode in emulator:
adb shell cmd connectivity airplane-mode enable

# Disable airplane mode:
adb shell cmd connectivity airplane-mode disable

# Check current connectivity:
adb shell dumpsys connectivity | grep "NetworkAgentInfo"
```

## Current Status

✅ **Completed:**
- Connectivity monitoring with `connectivity_plus`
- Offline indicator widget
- Sync service with queue management
- Offline-aware service wrapper
- Sync indicator widgets
- Auto-sync on connection restore
- Queue persistence across restarts

📝 **Not Yet Implemented (Future Backend Integration):**
- Actual backend API calls (app is currently local-only)
- Conflict resolution for synced data
- Server-side validation of queued actions

## Future Enhancements

When backend API is added:

1. **API Integration:**
   - Replace `syncNow()` simulation with real API calls
   - Add retry logic for failed syncs
   - Handle network timeouts gracefully

2. **Conflict Resolution:**
   - Timestamp-based conflict resolution
   - Server-side validation of actions
   - Merge strategies for concurrent edits

3. **Advanced Queueing:**
   - Priority queue for urgent actions
   - Batch syncing for efficiency
   - Exponential backoff for retries

4. **Sync Settings:**
   - Manual vs automatic sync toggle
   - WiFi-only sync option
   - Sync frequency settings

## Notes

- **Lessons are already offline-ready** - They're static Dart data in `lib/data/lesson_content.dart`, not API calls
- **All user progress** is stored locally in `SharedPreferences`
- **No external dependencies** are currently required (app is fully local)
- **Sync service is future-proof** - Ready for backend integration when needed

## Questions?

If you need help integrating offline mode into a specific screen or feature, check the examples above or refer to:
- `lib/providers/user_profile_provider.dart` - User action examples
- `lib/services/sync_service.dart` - Queue management
- `lib/widgets/offline_indicator.dart` - UI components
