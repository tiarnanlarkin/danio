# 🚀 Quick Integration Guide - Gem Shop

## Step 1: Run Flutter Pub Get

```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"
/home/tiarnanlarkin/flutter/bin/flutter pub get
```

✅ **Already done** - confetti package installed!

---

## Step 2: Add Shop to Navigation

### Option A: Bottom Navigation Bar

```dart
// In your main screen with bottom nav
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
    BottomNavigationBarItem(icon: Icon(Icons.diamond), label: 'Shop'), // ← Add this
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
  onTap: (index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GemShopScreen()),
      );
    }
  },
)
```

### Option B: Drawer/Menu

```dart
// In your app drawer
import 'package:aquarium_app/screens/gem_shop_screen.dart';
import 'package:aquarium_app/providers/gems_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ...

Consumer(
  builder: (context, ref, _) {
    final gemBalance = ref.watch(gemBalanceProvider);
    return ListTile(
      leading: const Text('💎', style: TextStyle(fontSize: 24)),
      title: const Text('Gem Shop'),
      subtitle: Text('$gemBalance gems'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GemShopScreen()),
        );
      },
    );
  },
)
```

### Option C: Floating Action Button

```dart
// On your main screen
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GemShopScreen()),
    );
  },
  child: const Text('💎', style: TextStyle(fontSize: 24)),
)
```

---

## Step 3: Test Gem Earning

### Award Gems After Lesson:

```dart
// In your lesson completion handler
import 'package:aquarium_app/providers/gems_provider.dart';
import 'package:aquarium_app/models/gem_transaction.dart';

// ...

// After lesson completes successfully
await ref.read(gemsProvider.notifier).addGems(
  amount: 5,
  reason: GemEarnReason.lessonComplete,
);

// Show feedback to user
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('🎉 +5 gems earned!'),
    backgroundColor: Colors.green,
    duration: Duration(seconds: 2),
  ),
);
```

### Award Streak Bonuses:

```dart
// In your daily streak tracker
final streakDays = profile.currentStreak;
if (streakDays == 7 || streakDays == 30 || streakDays == 100) {
  final gems = GemRewards.getStreakMilestoneReward(streakDays);
  await ref.read(gemsProvider.notifier).addGems(
    amount: gems,
    reason: GemEarnReason.streakMilestone,
    customReason: '$streakDays day streak!',
  );
}
```

---

## Step 4: Display Gem Balance

### In AppBar:

```dart
AppBar(
  title: const Text('Aquarium App'),
  actions: [
    Consumer(
      builder: (context, ref, _) {
        final balance = ref.watch(gemBalanceProvider);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              '💎 $balance',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    ),
  ],
)
```

### In Profile Screen:

```dart
Consumer(
  builder: (context, ref, _) {
    final balance = ref.watch(gemBalanceProvider);
    final totalEarned = ref.read(gemsProvider.notifier).totalEarned;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('💎', style: TextStyle(fontSize: 48)),
            SizedBox(height: 8),
            Text(
              '$balance Gems',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              'Total earned: $totalEarned',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  },
)
```

---

## Step 5: Build & Test

```bash
# Build APK
/home/tiarnanlarkin/flutter/bin/flutter build apk --debug

# Install on device
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" install -r "C:\\Users\\larki\\Documents\\Aquarium App Dev\\repo\\apps\\aquarium_app\\build\\app\\outputs\\flutter-apk\\app-debug.apk"

# Launch app
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" shell monkey -p com.tiarnanlarkin.aquarium.aquarium_app -c android.intent.category.LAUNCHER 1
```

### Test Checklist:
- [ ] Navigate to shop screen
- [ ] Verify gem balance displays correctly
- [ ] Complete a lesson and see +5 gems
- [ ] Browse all 3 shop categories (Power-ups, Extras, Cosmetics)
- [ ] Tap an item and see purchase dialog
- [ ] Try buying with insufficient gems (should block)
- [ ] Buy an affordable item
- [ ] See confetti animation 🎉
- [ ] Verify gem balance decreased
- [ ] See "Owned" badge on purchased item
- [ ] Buy a consumable multiple times (quantity increases)
- [ ] Try buying non-consumable twice (should block)

---

## Optional: Admin Panel (for testing)

```dart
// Create a debug screen to grant gems
class DebugGemsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug: Grant Gems')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Grant 50 Gems'),
            trailing: Icon(Icons.add),
            onTap: () async {
              await ref.read(gemsProvider.notifier).grantGems(
                amount: 50,
                reason: 'Debug grant',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ 50 gems added!')),
              );
            },
          ),
          ListTile(
            title: Text('Grant 100 Gems'),
            trailing: Icon(Icons.add),
            onTap: () async {
              await ref.read(gemsProvider.notifier).grantGems(
                amount: 100,
                reason: 'Debug grant',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('✅ 100 gems added!')),
              );
            },
          ),
          ListTile(
            title: Text('Reset Gems'),
            trailing: Icon(Icons.refresh),
            onTap: () async {
              await ref.read(gemsProvider.notifier).reset();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('⚠️ Gems reset to 0')),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## Troubleshooting

### Import Errors:
```dart
// Make sure these are imported:
import 'package:aquarium_app/screens/gem_shop_screen.dart';
import 'package:aquarium_app/providers/gems_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

### Confetti Not Showing:
- Make sure `confetti: ^0.7.0` is in `pubspec.yaml`
- Run `flutter pub get`
- Rebuild the app

### Balance Not Updating:
- Ensure you're using `ConsumerWidget` or `Consumer` for reactive updates
- Check that `ref.watch(gemBalanceProvider)` is used (not `ref.read`)

---

## 🎉 You're Done!

Your gem shop is now integrated and ready to use! Users can:
- Earn gems through gameplay
- Browse beautiful shop categories
- Purchase power-ups, extras, and cosmetics
- Enjoy confetti celebrations

Happy coding! 💎✨
