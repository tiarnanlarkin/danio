# Gem Shop Implementation - Quick Start Guide

## 📦 What's Been Delivered

### Core Documentation
- **LINGOTS_SHOP_IMPLEMENTATION.md** - Comprehensive 60-page implementation guide

### Data Models (Ready to Use)
- `lib/models/gem_transaction.dart` - Transaction tracking
- `lib/models/shop_item.dart` - Shop items and inventory
- `lib/models/purchase_result.dart` - Purchase flow helper
- `lib/models/gem_economy.dart` - Gem reward configuration
- `lib/data/shop_catalog.dart` - 13 shop items catalog

---

## 🚀 Quick Implementation Path

### Phase 1: Data Layer (Day 1)
1. **Add new fields to UserProfile**
   ```dart
   // In lib/models/user_profile.dart
   final int gems;
   final List<GemTransaction> gemTransactions;
   final Map<String, InventoryItem> inventory;
   final List<String> activeEffects;
   ```

2. **Update serialization**
   - Add fields to `copyWith`, `toJson`, `fromJson`
   - Import new models: `gem_transaction.dart`, `shop_item.dart`

3. **Test data persistence**
   ```bash
   flutter test test/models/
   ```

### Phase 2: Provider Methods (Day 2)
1. **Add gem methods to UserProfileNotifier**
   ```dart
   Future<void> awardGems({required int amount, required GemEarnReason reason})
   Future<PurchaseResult> purchaseItem(ShopItem item)
   Future<bool> activateItem(String itemId)
   bool hasActiveEffect(ShopItemType effectType)
   ```

2. **Integrate with existing actions**
   - `completeLesson` → award gems
   - `recordActivity` → streak milestone gems
   - `unlockAchievement` → achievement tier gems

### Phase 3: UI (Day 3-4)
1. **Create GemShopScreen**
   - Copy from implementation guide
   - Add to navigation

2. **Add GemBalanceWidget to HomeScreen**
   ```dart
   // Top of home screen
   GemBalanceWidget(showShopButton: true)
   ```

3. **Test purchase flow**
   - Buy consumable item
   - Buy permanent item
   - Test insufficient gems

---

## 🎮 How It Works

### Earning Gems
```dart
// Lesson completion
await notifier.completeLesson('nitrogen_basics', 50);
// → Awards 5 gems automatically

// Daily goal met
await notifier.recordActivity(xp: 60);
// → Awards 5 gems if goal reached

// Streak milestone (7 days)
// → Awards 10 gems automatically
```

### Spending Gems
```dart
// User taps shop item
final item = ShopCatalog.getById('xp_boost_1h')!;
final result = await notifier.purchaseItem(item);

if (result.success) {
  // Item now in inventory
  // Balance reduced by gemCost
}
```

### Using Items
```dart
// Activate XP boost
await notifier.activateItem('xp_boost_1h');

// Check if active
if (notifier.hasActiveEffect(ShopItemType.xpBoost)) {
  // Double XP for next lesson
}
```

---

## 📊 Shop Catalog Preview

### Power-Ups (15-25 gems)
- ⚡ **2x XP Boost** (25 gems) - 1 hour double XP
- 💡 **Lesson Helper** (15 gems) - Hints in next lesson
- 🎯 **Quiz Second Chance** (20 gems) - Retry quiz mistakes

### Extras (30-40 gems)
- 🧊 **Streak Freeze** (30 gems) - Protect your streak
- 🏖️ **Weekend Pass** (40 gems) - Reduce weekend goal
- 🛡️ **Goal Shield** (35 gems) - Auto-complete daily goal

### Cosmetics (50-150 gems)
- 🐦 **Early Bird Badge** (50 gems) - Profile badge
- 🎉 **Confetti Effect** (75 gems) - Celebration animation
- 🌊 **Ocean Theme** (150 gems) - Profile background

---

## 🎯 Earning Rates (Balanced)

| Action | Gems | Frequency |
|--------|------|-----------|
| Complete lesson | 5 | ~1-3/day |
| Perfect quiz | 5 | ~1/day |
| Daily goal met | 5 | 1/day |
| 7-day streak | 10 | 1/week |
| 30-day streak | 25 | 1/month |
| Level up | 10-200 | Varies |
| Achievement | 5-50 | Varies |

**Daily earning potential**: 20-30 gems (active user)

---

## ✅ Testing Checklist

### Unit Tests
- [x] GemTransaction serialization
- [x] ShopItem serialization
- [x] ShopCatalog validation
- [ ] UserProfile with gems fields

### Integration Tests
- [ ] Award gems increases balance
- [ ] Purchase deducts gems + adds to inventory
- [ ] Insufficient gems prevents purchase
- [ ] Active effects expire correctly

### UI Tests
- [ ] Shop screen displays items
- [ ] Purchase flow works end-to-end
- [ ] Gem balance updates in real-time
- [ ] Confetti shows on purchase

---

## 🔧 Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  confetti: ^0.7.0  # For purchase celebrations

dev_dependencies:
  flutter_test:
    sdk: flutter
```

---

## 🐛 Troubleshooting

### Gems not saving
**Solution**: Ensure `UserProfile.toJson` includes gem fields

### Purchase succeeds but no inventory
**Solution**: Check `inventory` map serialization in `fromJson`

### Active effects not working
**Solution**: Call `cleanupExpiredEffects()` on app launch

### Shop screen crashes
**Solution**: Import all required models in shop screen file

---

## 📈 Next Steps

1. **Week 1**: Implement data models + provider methods
2. **Week 2**: Build shop UI + purchase flow
3. **Week 3**: Integration + gem reward hooks
4. **Week 4**: Polish + testing + balance tuning

**Target launch**: 4 weeks from start

---

## 📚 Key Files

| File | Purpose |
|------|---------|
| `LINGOTS_SHOP_IMPLEMENTATION.md` | Full technical guide |
| `lib/models/gem_transaction.dart` | Transaction model |
| `lib/models/shop_item.dart` | Shop items + inventory |
| `lib/models/purchase_result.dart` | Purchase validation |
| `lib/models/gem_economy.dart` | Reward configuration |
| `lib/data/shop_catalog.dart` | Item catalog |
| `lib/providers/user_profile_provider.dart` | **Needs updates** |
| `lib/screens/gem_shop_screen.dart` | **Create this** |
| `lib/widgets/shop_item_card.dart` | **Create this** |

---

## 💡 Pro Tips

1. **Start simple**: Implement earning gems first, then shop UI
2. **Balance later**: Use default gem values, tune after testing
3. **Visual feedback**: Animations make it feel rewarding
4. **Track metrics**: Log purchases to understand what users like
5. **Iterate**: Ship MVP, gather feedback, improve

---

## 🆘 Need Help?

- **Full guide**: See `LINGOTS_SHOP_IMPLEMENTATION.md`
- **Code examples**: Check implementation guide sections
- **Testing**: Run `flutter test` after each phase
- **Design questions**: Reference Duolingo's Lingots system

---

**Happy implementing! 💎**
