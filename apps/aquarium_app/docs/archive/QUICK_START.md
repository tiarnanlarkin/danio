# 💎 Gem Shop - Quick Start

## TL;DR - Get the Shop Working in 5 Minutes

### 1. Import & Navigate (2 min)

Add this wherever you want to link to the shop:

```dart
import 'package:aquarium_app/screens/gem_shop_screen.dart';

// Then navigate:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const GemShopScreen()),
);
```

### 2. Award Gems (1 min)

After lesson completion:

```dart
import 'package:aquarium_app/providers/gems_provider.dart';
import 'package:aquarium_app/models/gem_transaction.dart';

await ref.read(gemsProvider.notifier).addGems(
  amount: 5,
  reason: GemEarnReason.lessonComplete,
);
```

### 3. Display Balance (1 min)

In your AppBar:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aquarium_app/providers/gems_provider.dart';

Consumer(
  builder: (context, ref, _) {
    final balance = ref.watch(gemBalanceProvider);
    return Text('💎 $balance');
  },
)
```

### 4. Build & Test (1 min)

```bash
flutter build apk --debug
# Install and test!
```

## Done! 🎉

Your gem shop is now live. Users can:
- Earn gems through lessons & streaks
- Browse 18 beautiful shop items
- Purchase power-ups, extras, & cosmetics
- Enjoy confetti celebrations 🎊

---

## Full Documentation

- **LINGOTS_SHOP_IMPLEMENTATION.md** - Complete technical docs
- **SHOP_INTEGRATION_GUIDE.md** - Detailed integration examples
- **DELIVERY_SUMMARY.md** - What was delivered

---

## Quick Examples

### Grant Gems (For Testing)

```dart
await ref.read(gemsProvider.notifier).grantGems(
  amount: 100,
  reason: 'Testing',
);
```

### Check If User Owns Item

```dart
final hasFreeze = ref.watch(ownsItemProvider('streak_freeze'));
if (hasFreeze) {
  // User owns streak freeze - apply protection
}
```

### Get Item Quantity

```dart
final freezeCount = ref.watch(itemQuantityProvider('streak_freeze'));
// How many streak freezes user has
```

---

## Shop Items Cheat Sheet

| Item | Cost | Type |
|------|------|------|
| Timer Boost | 5 💎 | Consumable |
| Streak Freeze | 10 💎 | Consumable |
| Early Bird Badge | 10 💎 | Permanent |
| Lesson Helper | 15 💎 | Consumable |
| Bonus Skill | 15 💎 | Permanent |
| Quiz Second Chance | 20 💎 | Consumable |
| Weekend Amulet | 20 💎 | Time-based |
| 2x XP Boost | 25 💎 | Time-based |
| Hearts Refill | 30 💎 | Consumable |
| Confetti Effect | 30 💎 | Permanent |
| Goal Shield | 35 💎 | Consumable |
| Progress Protector | 40 💎 | Consumable |
| Zen Theme | 40 💎 | Permanent |
| Rainbow Theme | 45 💎 | Permanent |
| Fireworks Effect | 50 💎 | Permanent |
| Ocean Theme | 50 💎 | Permanent |
| Coral Theme | 50 💎 | Permanent |
| Night Mode Theme | 50 💎 | Permanent |

---

## Earn Gems Through

- Lesson completion: **5 gems**
- Quiz pass: **3 gems**
- Perfect quiz: **5 gems**
- Daily goal met: **5 gems**
- 7-day streak: **10 gems**
- 30-day streak: **25 gems**
- 100-day streak: **100 gems**
- Level up: **10-200 gems**
- Achievements: **5-50 gems**

---

That's it! Happy coding! 💎✨
