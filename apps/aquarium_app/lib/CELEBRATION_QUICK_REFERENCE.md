# Celebration System Quick Reference 🎉

One-page cheat sheet for using the celebration system.

---

## Setup (One-Time)

```bash
# 1. Install dependencies
flutter pub get

# 2. Add audio files to assets/audio/celebrations/
# See AUDIO_README.md for sources

# 3. Wrap your app
# In main.dart:
return MaterialApp(
  home: EnhancedCelebrationOverlayWrapper(
    child: YourHome(),
  ),
);
```

---

## Usage

### Import

```dart
import 'services/enhanced_celebration_service.dart';
```

### Lesson Complete

```dart
ref.celebrateLessonComplete(
  xpEarned: 50,
  isPerfect: true,
  lessonTitle: 'The Nitrogen Cycle',
);
```

### Streak Milestone

```dart
ref.celebrateStreak(
  streakDays: 7,
  isNewRecord: true,
);
```

### Achievement Unlock

```dart
ref.celebrateAchievement(
  name: 'First Steps',
  icon: '🐣',
  description: 'Complete your first lesson',
  isRare: false,
);
```

### Level Up

```dart
ref.celebrateLevelUp(
  newLevel: 5,
  levelTitle: 'Aquarium Apprentice',
  context: context,  // For full overlay
);
```

### Share

```dart
await ref.shareCelebration();
```

---

## Celebration Levels

| Level | When | Sound | Haptic | Particles | Share |
|-------|------|-------|--------|-----------|-------|
| Standard | Small wins | Whoosh | Light | 20 | No |
| Achievement | Unlock badges | Chime | Success | 30 | Yes |
| Level Up | User levels up | Fireworks | Epic | 35 | Yes* |
| Milestone | 30-day streak | Applause | Epic | 40 | Yes |
| Epic | 365-day streak | Fireworks | Epic++ | 50 | Yes |

*Every 5 levels

---

## Streak Milestones

Auto-celebrate at:
- 3, 7, 14 days (early)
- 30, 60, 100 days (major)
- 365 days (epic)
- Every 100 days after 100

---

## Achievement Rarity

```dart
isRare: achievement.rarity >= AchievementRarity.gold
```

- Bronze/Silver → `isRare: false` → Achievement level
- Gold/Platinum → `isRare: true` → Milestone/Epic level

---

## Audio Files Needed

Place in `assets/audio/celebrations/`:

1. **whoosh.mp3** (0.5-1s) - Quick wins
2. **chime.mp3** (1-2s) - Achievements
3. **fanfare.mp3** (2-3s) - Lesson complete
4. **applause.mp3** (2-4s) - Streaks
5. **fireworks.mp3** (3-5s) - Epic celebrations

Download from: [Pixabay](https://pixabay.com/sound-effects/) (free, no attribution)

---

## Settings Integration

```dart
// In SettingsProvider:
final bool? reduceAnimations;  // Disables animations + haptics
final bool? soundEffects;      // Disables sounds
```

---

## Common Patterns

### Queue Multiple Celebrations

```dart
// Lesson complete
ref.celebrateLessonComplete(...);

// Wait before next celebration
await Future.delayed(Duration(seconds: 4));

// Then level up
ref.celebrateLevelUp(...);
```

### Conditional Celebrations

```dart
// Only celebrate milestones
if (streakDays % 7 == 0) {
  ref.celebrateStreak(streakDays: streakDays);
}
```

### Time-Based

```dart
final hour = DateTime.now().hour;

if (hour < 8) {
  ref.celebrateAchievement(
    name: 'Early Bird',
    icon: '🌅',
    description: 'Lesson before 8 AM',
  );
}
```

---

## Troubleshooting

### Sounds don't play
- Check files exist in `assets/audio/celebrations/`
- Run `flutter pub get`
- Check device volume
- Verify `soundEffects: true` in settings

### Haptics don't work
- Test on physical device (not simulator)
- Check `reduceAnimations: false` in settings
- Verify device supports vibration

### Celebrations overlap
- Add delays between celebrations
- Use `await Future.delayed(Duration(seconds: 4))`

---

## Testing

```dart
// Quick test button
ElevatedButton(
  onPressed: () {
    ref.celebrateLessonComplete(
      xpEarned: 50,
      isPerfect: true,
      lessonTitle: 'Test',
    );
  },
  child: Text('Test Celebration'),
)
```

---

## Examples

See `lib/CELEBRATION_EXAMPLES.dart` for:
- Lesson completion
- Streak handling
- Achievement batching
- Level up with context
- Celebration queueing
- Time-based triggers
- Settings integration
- Manual sharing
- Conditional logic

---

## Documentation

- **Setup:** `CELEBRATION_INTEGRATION_GUIDE.md`
- **Examples:** `CELEBRATION_EXAMPLES.dart`
- **Audio:** `assets/audio/celebrations/AUDIO_README.md`
- **Completion Report:** `docs/completed/PHASE_2.2_CELEBRATION_SYSTEM_COMPLETE.md`

---

## Pro Tips

✅ **DO:**
- Celebrate major achievements (first lesson, 7-day streak)
- Add delays between multiple celebrations
- Respect accessibility settings
- Share celebrations for engagement

❌ **DON'T:**
- Celebrate every small action (causes fatigue)
- Overlap celebrations (use queueing)
- Ignore reduced motion settings
- Play sounds without user control

---

**Quick start:** Copy code from `CELEBRATION_EXAMPLES.dart` → Paste → Customize → Ship! 🚀
