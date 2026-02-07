# Hearts/Lives System - Quick Start Guide

**Duolingo-style mistake limiting for the Aquarium App learning system**

---

## 📚 Documentation Suite

This hearts system implementation comes with comprehensive documentation:

1. **HEARTS_SYSTEM_IMPLEMENTATION.md** (48 KB) - **START HERE**
   - Complete code implementation for all components
   - Copy-paste ready code snippets
   - Detailed explanations for each file
   - Testing guidelines

2. **HEARTS_SYSTEM_CHECKLIST.md** (5.6 KB)
   - Phase-by-phase implementation tracker
   - Checkbox format for tracking progress
   - Quick reference for all files and methods

3. **HEARTS_SYSTEM_FLOW.md** (16 KB)
   - Visual flow diagrams
   - User journey maps
   - State diagrams
   - Component interaction charts
   - Behavioral design principles

---

## 🎯 What Is This?

The hearts system adds a **Duolingo-style lives mechanic** to quizzes:

- Start with **5 hearts** ❤️❤️❤️❤️❤️
- Lose **1 heart** per wrong answer
- When hearts = 0, **practice mode** required to earn hearts back
- Hearts **auto-refill** (1 heart / 5 hours)
- **Practice mode**: Unlimited attempts, earn hearts, reduced XP
- **Settings toggle**: Disable hearts for unrestricted learning

---

## 🚀 Quick Implementation Path

### Step 1: Read the Documentation (5 minutes)
```
1. HEARTS_SYSTEM_IMPLEMENTATION.md → Full implementation guide
2. HEARTS_SYSTEM_FLOW.md → Understand the user flow
3. HEARTS_SYSTEM_CHECKLIST.md → Track your progress
```

### Step 2: Implement Data Layer (30 minutes)
```
✓ Update UserProfile model (3 new fields)
✓ Add extension methods (heart helpers)
✓ Update JSON serialization
```

### Step 3: Implement Provider Logic (20 minutes)
```
✓ Add loseHeart() method
✓ Add refillHearts() method
✓ Add earnHeartFromPractice() method
✓ Add toggleUnlimitedHearts() method
```

### Step 4: Create UI Components (1 hour)
```
✓ Create HeartsDisplay widget
✓ Create PracticeRequiredScreen
✓ Create PracticeModeScreen
```

### Step 5: Integrate with Quizzes (30 minutes)
```
✓ Update LessonScreen
  - Add hearts check before quiz
  - Deduct hearts on wrong answers
  - Handle mid-quiz depletion
```

### Step 6: Settings Integration (10 minutes)
```
✓ Add "Unlimited Hearts" toggle to SettingsScreen
```

### Step 7: Testing (1 hour)
```
✓ Write unit tests
✓ Run integration tests
✓ Manual testing checklist
```

**Total Time: ~3-4 hours** for full implementation

---

## 📂 Files You'll Create/Modify

### New Files (Create These):
```
lib/widgets/hearts_display.dart              (~150 lines)
lib/screens/practice_required_screen.dart    (~200 lines)
lib/screens/practice_mode_screen.dart        (~350 lines)
test/hearts_system_test.dart                 (~150 lines)
```

### Modified Files (Update These):
```
lib/models/user_profile.dart                 (+~150 lines)
lib/providers/user_profile_provider.dart     (+~80 lines)
lib/screens/lesson_screen.dart               (+~40 lines)
lib/screens/settings_screen.dart             (+~30 lines)
```

**Total: ~1150 lines of code** (including tests)

---

## 🎨 Key Features

### 1. Hearts Display Widget
- Shows current hearts (5 filled/empty icons)
- Color-coded status (green → yellow → red)
- Optional timer display
- Tap for info dialog
- Auto-refills based on elapsed time

### 2. Practice Mode
- Green-themed UI (distinct from regular quizzes)
- Unlimited attempts
- No heart loss
- Reduced XP (5 instead of 10)
- Earn 1 heart per completion

### 3. Smart Refill System
- 1 heart per 5 hours
- Works across app restarts
- Visual countdown timer
- Caps at max 5 hearts

### 4. Flexible Settings
- "Unlimited Hearts" toggle
- Useful for power users or accessibility
- Immediately disables heart system

### 5. Gamification Balance
```
Regular Quiz:
  ✓ Higher XP (10)
  ✗ Risk hearts
  → For confident learners

Practice Mode:
  ✓ Safe (no heart loss)
  ✓ Earn hearts
  ✗ Lower XP (5)
  → For careful learning
```

---

## 🧪 Testing Strategy

### Unit Tests
- UserProfile model helpers
- Provider methods (lose/refill/earn)
- Time calculations
- Edge cases (0 hearts, max hearts, etc.)

### Integration Tests
- Quiz → heart loss flow
- Practice mode → heart earning
- Settings toggle
- Refill timer accuracy

### Manual Testing
- Complete quiz without mistakes
- Deplete all hearts
- Complete practice session
- Verify heart refill
- Test unlimited hearts mode

---

## 💡 Design Principles

### 1. **Scarcity Creates Value**
Limited hearts → users read lessons more carefully

### 2. **Positive Reinforcement**
Practice mode lets users learn without penalty

### 3. **Multiple Recovery Paths**
Practice OR wait → users never feel blocked

### 4. **Transparency**
Hearts always visible, refill timer clear

### 5. **User Control**
Settings toggle for those who want unrestricted access

---

## 📊 Expected User Behavior

### Beginner Users:
- May deplete hearts quickly
- Use practice mode to learn safely
- Build confidence before attempting quizzes

### Intermediate Users:
- Balance between regular quizzes and practice
- Use hearts as a pacing mechanism
- Occasional practice when hearts low

### Advanced Users:
- Rarely lose hearts
- May enable unlimited hearts setting
- Focus on XP optimization

---

## 🎯 Success Metrics (Optional)

Track these to measure effectiveness:

1. **Heart Depletion Rate**
   - How many users hit 0 hearts per day?
   - Average hearts remaining after quiz

2. **Practice Mode Engagement**
   - % of users who complete practice
   - Practice sessions per week

3. **Unlimited Hearts Adoption**
   - % of users who toggle unlimited mode
   - Correlation with experience level

4. **Quiz Performance**
   - Accuracy rate before vs. after hearts
   - Lesson completion rates

---

## 🔮 Future Enhancements

### Short-term:
- [ ] Animations for heart loss/gain
- [ ] Achievement: "Perfect Quiz" (no hearts lost)
- [ ] Daily bonus hearts (e.g., +1 for streak)

### Medium-term:
- [ ] Heart power-ups or items
- [ ] Social features (gift hearts to friends)
- [ ] Adaptive difficulty (adjust based on hearts)

### Long-term:
- [ ] Premium subscription with unlimited hearts
- [ ] Heart currency for unlocking content
- [ ] Leaderboards with heart preservation bonus

---

## 🐛 Known Edge Cases (Handled)

✅ Hearts depleted mid-quiz → Navigate to practice screen  
✅ Unlimited mode enabled → Hearts hidden, no deductions  
✅ App closed during refill → Refills on next open  
✅ Practice with full hearts → No heart awarded (at max)  
✅ Time-based refill calculations → Accurate across days  

---

## 🚨 Common Pitfalls to Avoid

### 1. **Don't Block Permanently**
Always provide a path to recover hearts (practice + time)

### 2. **Don't Hide the System**
Hearts should be visible and understandable

### 3. **Don't Punish Learning**
Practice mode must feel safe and encouraging

### 4. **Don't Ignore Accessibility**
Provide unlimited hearts option for users who need it

### 5. **Don't Forget Persistence**
Heart state must survive app restarts

---

## 📞 Support & Questions

If you encounter issues during implementation:

1. Check HEARTS_SYSTEM_IMPLEMENTATION.md for code details
2. Reference HEARTS_SYSTEM_FLOW.md for logic flow
3. Use HEARTS_SYSTEM_CHECKLIST.md to track progress
4. Look for edge cases in this README

---

## ✅ Pre-Implementation Checklist

Before you start coding:

- [ ] Read all 4 documentation files
- [ ] Understand the user flow (see FLOW.md)
- [ ] Review UserProfile model structure
- [ ] Check UserProfileProvider methods
- [ ] Identify where lesson/quiz screens are located
- [ ] Verify settings screen structure
- [ ] Set up test environment

---

## 🎓 Learning Resources

**Inspiration:**
- Duolingo (hearts/lives system)
- Khan Academy (practice mode)
- Memrise (adaptive difficulty)

**Flutter Concepts Used:**
- Riverpod state management
- Provider patterns
- DateTime calculations
- SharedPreferences persistence
- Custom widgets
- Navigation flows

---

## 📈 Implementation Timeline

### Week 1: Core Implementation
- Days 1-2: Model + Provider
- Days 3-4: UI Components
- Day 5: Quiz Integration

### Week 2: Testing & Polish
- Days 1-2: Unit + Integration Tests
- Days 3-4: Manual Testing + Bug Fixes
- Day 5: Documentation + Review

### Week 3: Deployment
- Days 1-2: User Acceptance Testing
- Days 3-4: Analytics Setup
- Day 5: Release

---

## 🎉 Ready to Start?

1. Open `HEARTS_SYSTEM_IMPLEMENTATION.md`
2. Follow Section 1: UserProfile Model Extensions
3. Use `HEARTS_SYSTEM_CHECKLIST.md` to track progress
4. Reference `HEARTS_SYSTEM_FLOW.md` when confused about logic

**Happy coding!** 🚀

---

**Last Updated:** February 7, 2025  
**Version:** 1.0  
**Status:** Ready for Implementation
