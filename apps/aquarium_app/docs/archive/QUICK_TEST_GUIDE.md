# Quick Test Guide - XP Animations

## 🚀 Quick Start

### Option 1: Use Demo Screen (Recommended for quick testing)
```dart
// Add to your routing/navigation:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => XpAnimationsDemoScreen(),
  ),
);
```

**What you'll see**:
- Current level and XP stats
- Buttons to trigger XP animations (10, 25, 50, 100 XP)
- Button to preview level-up dialog
- Buttons to add XP to test real level-ups

### Option 2: Test via Quiz
1. Open app and navigate to any lesson
2. Complete the quiz
3. **See XP animation** float up and fade on results screen
4. If you level up, **see confetti celebration** dialog

---

## 📱 Build and Install

```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"

# Debug build
/home/tiarnanlarkin/flutter/bin/flutter build apk --debug

# Install to emulator
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" install -r \
  "C:\\Users\\larki\\Documents\\Aquarium App Dev\\repo\\apps\\aquarium_app\\build\\app\\outputs\\flutter-apk\\app-debug.apk"

# Launch app
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" shell monkey \
  -p com.tiarnanlarkin.aquarium.aquarium_app -c android.intent.category.LAUNCHER 1
```

---

## ✅ What to Look For

### XP Animation (1.5 seconds)
- ✨ Gold badge with "+X XP" text and star icon
- 📈 Floats upward smoothly
- 🌫️ Fades out in second half
- 🎯 Positioned near top-center of screen
- ⚡ Slight bounce/scale effect at start

### Level-Up Dialog
- 🎊 Confetti particles falling (30 colorful pieces)
- ⭐ Glowing star icon
- 🏆 "Level Up!" text
- 📊 New level badge with title
- 💬 Optional unlock message (levels 2-7)
- 🔘 "Continue" button to dismiss

### Integration
- 🔄 XP animation plays FIRST
- 🎉 Level-up dialog appears AFTER (if level up occurred)
- ✅ Only happens once per quiz completion
- 🎮 Works in both normal and practice modes

---

## 🐛 Known Issues / Notes

- ⚠️ Pre-existing warning: `unused_field` for `_heartLost` (not related to new code)
- ℹ️ XP animation won't show if quiz awards 0 XP
- ℹ️ Level-up only triggers if level actually increases
- ℹ️ Demo screen is for testing only (can be removed in production)

---

## 📂 Files Modified/Created

**New Files**:
- `lib/widgets/xp_award_animation.dart` (197 lines)
- `lib/widgets/level_up_dialog.dart` (324 lines)
- `lib/screens/xp_animations_demo_screen.dart` (332 lines)

**Modified**:
- `lib/screens/enhanced_quiz_screen.dart` (added imports + 3 methods + state vars)

**Documentation**:
- `PHASE2_XP_ANIMATIONS_COMPLETE.md` (detailed specs)
- `PHASE2_IMPLEMENTATION_SUMMARY.md` (implementation details)
- `QUICK_TEST_GUIDE.md` (this file)

---

## 🎯 Testing Checklist

Quick checklist for QA:

### Basic Functionality
- [ ] XP animation shows after completing quiz
- [ ] Animation floats upward and fades
- [ ] Gold/amber color matches theme
- [ ] Star icon visible
- [ ] Correct XP amount displayed

### Level-Up
- [ ] Dialog appears after XP animation
- [ ] Confetti animates smoothly
- [ ] All text fields populate correctly
- [ ] "Continue" button dismisses dialog
- [ ] Unlock messages show for levels 2-7

### Edge Cases
- [ ] Works in practice mode
- [ ] Doesn't show for 0 XP
- [ ] Multiple quizzes work correctly
- [ ] No animation replays on results screen refresh

### Demo Screen (if included)
- [ ] All XP amounts trigger animation
- [ ] "Add XP" updates profile correctly
- [ ] Level-up preview shows confetti
- [ ] Stats update after adding XP

---

## 🔧 Troubleshooting

**Animation doesn't show**:
- Check if quiz awards > 0 XP
- Ensure `onQuizComplete` callback is being called
- Verify user profile provider is loaded

**Level-up doesn't trigger**:
- Check if level actually increased
- Verify `_levelBeforeQuiz` was captured in initState
- Ensure profile provider updates before check

**Confetti looks choppy**:
- May be device performance issue
- Try reducing particle count (30 → 20) in level_up_dialog.dart line 125

**Build errors**:
- Run `flutter pub get`
- Run `flutter clean && flutter pub get`
- Check Flutter version compatibility

---

## 💡 Tips

1. **Use demo screen first** - Easier to test animations without completing quizzes
2. **Add XP incrementally** - Test level-up by adding small amounts until next level
3. **Check logs** - Look for any errors in Flutter console
4. **Test on device** - Animations look better on real device than emulator
5. **Video record** - Useful for reviewing animation timing and smoothness

---

## 📧 Questions?

All implementation details in `PHASE2_IMPLEMENTATION_SUMMARY.md`
Technical specs in `PHASE2_XP_ANIMATIONS_COMPLETE.md`
