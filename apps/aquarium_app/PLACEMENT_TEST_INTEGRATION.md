# Placement Test - Integration Checklist

## Quick Start Integration

This is your step-by-step guide to wire the placement test into your app's onboarding flow.

---

## ✅ Pre-Integration Checklist

### 1. Verify Files Exist
```bash
# Run this to verify all files are in place
ls -la lib/models/placement_test.dart
ls -la lib/data/placement_test_content.dart
ls -la lib/screens/placement_test_screen.dart
ls -la lib/screens/placement_result_screen.dart
```

### 2. Check Dependencies
The implementation uses only existing dependencies:
- ✅ `flutter_riverpod` (already in project)
- ✅ `shared_preferences` (already in project)
- ✅ No new packages needed!

---

## 🔌 Integration Steps

### Step 1: Find Your Onboarding Screen

Locate where users complete the initial profile setup. Common locations:
- `lib/screens/onboarding_screen.dart`
- `lib/screens/welcome_screen.dart`
- `lib/screens/setup_wizard.dart`

### Step 2: Add Import

At the top of your onboarding screen file:

```dart
import 'package:aquarium_app/screens/placement_test_screen.dart';
```

### Step 3: Update Onboarding Complete Function

Find the function that runs after the user completes onboarding (usually after selecting experience level, tank type, and goals).

**BEFORE:**
```dart
void _completeOnboarding() async {
  // Create profile
  await ref.read(userProfileProvider.notifier).createProfile(
    name: nameController.text,
    experienceLevel: selectedExperience,
    primaryTankType: selectedTankType,
    goals: selectedGoals,
  );
  
  // Navigate to main app
  if (mounted) {
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
```

**AFTER:**
```dart
void _completeOnboarding() async {
  // Create profile
  await ref.read(userProfileProvider.notifier).createProfile(
    name: nameController.text,
    experienceLevel: selectedExperience,
    primaryTankType: selectedTankType,
    goals: selectedGoals,
  );
  
  if (!mounted) return;
  
  // Offer placement test
  final shouldTakeTest = await _showPlacementTestDialog();
  
  if (!mounted) return;
  
  if (shouldTakeTest) {
    // Go to placement test
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const PlacementTestScreen(),
      ),
    );
  } else {
    // Skip to main app
    Navigator.of(context).pushReplacementNamed('/home');
  }
}
```

### Step 4: Add Dialog Method

Add this method to your onboarding screen class:

```dart
Future<bool> _showPlacementTestDialog() async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false, // Must choose an option
    builder: (context) => AlertDialog(
      title: Row(
        children: const [
          Text('🎯 '),
          Expanded(child: Text('Quick Knowledge Check')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Want to take a 5-minute quiz to skip lessons you already know?',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            '✨ Earn XP for what you know\n'
            '⏭️ Skip straight to advanced topics\n'
            '📚 Or start from the basics',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Skip - I\'m New'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Take Quiz'),
        ),
      ],
    ),
  ) ?? false; // Default to false if dialog dismissed
}
```

---

## 🎨 Alternative: Add as Onboarding Step

If you prefer to integrate it as a step in a multi-page onboarding wizard:

```dart
class OnboardingWizard extends StatefulWidget {
  // ... existing code ...
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  int _currentStep = 0;
  
  final List<Widget> _steps = [
    WelcomeStep(),           // Step 0: Welcome
    ExperienceStep(),        // Step 1: Select experience level
    TankTypeStep(),          // Step 2: Select tank type
    GoalsStep(),             // Step 3: Select goals
    PlacementTestOfferStep(), // Step 4: Offer placement test (NEW)
  ];
  
  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _completeOnboarding();
    }
  }
  
  // ... rest of wizard code ...
}

// New step widget
class PlacementTestOfferStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '🎯',
          style: TextStyle(fontSize: 64),
        ),
        const SizedBox(height: 24),
        const Text(
          'Ready to show what you know?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'Take a quick 5-minute quiz to skip lessons you\'ve already mastered.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const PlacementTestScreen(),
              ),
            );
          },
          icon: const Icon(Icons.quiz),
          label: const Text('Take Placement Test'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
          child: const Text('Skip - Start from Basics'),
        ),
      ],
    );
  }
}
```

---

## 🧪 Testing the Integration

### Manual Test Flow

1. **Start Fresh:**
   ```bash
   # Clear app data to simulate new user
   /mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe shell pm clear com.tiarnanlarkin.aquarium.aquarium_app
   ```

2. **Complete Onboarding:**
   - Open app
   - Go through onboarding steps
   - Select experience level, tank type, goals
   - Verify placement test dialog appears

3. **Choose "Take Quiz":**
   - Should navigate to PlacementTestScreen
   - See question 1/20
   - Progress bar at 0%

4. **Answer Questions:**
   - Select an answer
   - Click "Submit Answer"
   - See explanation (green if correct)
   - Click "Next Question"
   - Progress bar updates

5. **Complete Test:**
   - After question 20, click "See Results"
   - Should navigate to PlacementResultScreen
   - See overall score
   - See per-path recommendations
   - See XP earned

6. **Click "Start Learning!":**
   - Should navigate to main app
   - Skipped lessons should show as completed

### Verify Data Persistence

```dart
// Add this debug code temporarily to verify placement test was saved
void _debugCheckPlacementTest() async {
  final profile = ref.read(userProfileProvider).value;
  if (profile != null) {
    print('Has completed placement test: ${profile.hasCompletedPlacementTest}');
    print('Placement result ID: ${profile.placementResultId}');
    print('Placement test date: ${profile.placementTestDate}');
    print('Total completed lessons: ${profile.completedLessons.length}');
    print('Total XP: ${profile.totalXp}');
  }
}
```

---

## 🐛 Troubleshooting

### Issue: Dialog doesn't appear

**Fix:** Check that you're calling `_showPlacementTestDialog()` after profile creation:

```dart
// ✅ CORRECT
await createProfile(...);
if (mounted) {
  final shouldTest = await _showPlacementTestDialog();
}

// ❌ WRONG
final shouldTest = await _showPlacementTestDialog();
await createProfile(...);
```

### Issue: Navigation doesn't work

**Fix:** Always check `mounted` before navigating:

```dart
if (mounted) {
  Navigator.of(context).pushReplacement(...);
}
```

### Issue: Results don't save

**Fix:** Verify you're using the updated `userProfileProvider`:

```dart
await ref.read(userProfileProvider.notifier).completePlacementTest(
  resultId: result.id,
  lessonsToSkip: result.lessonsToSkip,
  xpToAward: result.calculateSkipXp(LessonContent.allPaths),
);
```

### Issue: Skipped lessons don't show as completed

**Fix:** Check that your lesson list respects `completedLessons`:

```dart
// In your learning screen
final profile = ref.watch(userProfileProvider).value;
final completedLessons = profile?.completedLessons ?? [];

// When displaying lessons
for (final lesson in path.lessons) {
  final isCompleted = completedLessons.contains(lesson.id);
  // Show checkmark or "Completed" badge if isCompleted
}
```

---

## 📱 UI Customization

### Match Your App's Theme

The placement test screens use your app's theme automatically, but you can customize:

**Colors:**
```dart
// In placement_test_screen.dart
// Change this:
backgroundColor: AppColors.accent.withOpacity(0.1),

// To your brand color:
backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
```

**Fonts:**
```dart
// In placement_result_screen.dart
// The screens use theme text styles:
style: theme.textTheme.headlineSmall // Automatically uses your theme
```

**Spacing:**
```dart
// Adjust padding/margins as needed
padding: const EdgeInsets.all(16), // Change to 20, 24, etc.
```

---

## 🎯 Success Criteria

After integration, you should have:

- ✅ Placement test offered after onboarding
- ✅ Users can take or skip the test
- ✅ Test displays all 20 questions correctly
- ✅ Results show accurate scores and recommendations
- ✅ Lessons are marked as completed in profile
- ✅ XP is awarded correctly
- ✅ Navigation flows smoothly throughout
- ✅ Data persists after app restart

---

## 🚀 Going Live

### Pre-Launch Checklist

- [ ] Test with real users (5-10 people)
- [ ] Verify question accuracy (no typos/wrong answers)
- [ ] Check all explanations are helpful
- [ ] Test on multiple screen sizes
- [ ] Verify dark mode support (if applicable)
- [ ] Test skip flows work correctly
- [ ] Confirm XP calculations are correct
- [ ] Check performance (should be instant)

### Launch Monitoring

Track these metrics:
- **Opt-in rate**: % of users who take the test
- **Completion rate**: % who finish all 20 questions
- **Average score**: Overall performance
- **Drop-off points**: Where users quit
- **Time to complete**: Average duration

### Iteration Ideas

Based on metrics:
- If opt-in is low → Improve messaging in dialog
- If completion is low → Consider fewer questions or skip option
- If scores are too high/low → Adjust question difficulty
- If time is too long → Reduce to 15 questions

---

## 📞 Support

If you need help:
1. Read `PLACEMENT_TEST_IMPLEMENTATION.md` for detailed architecture
2. Check code examples in that doc
3. Review this integration guide
4. Test on a clean install

---

**Ready to integrate? Start with Step 1 above! 🎉**
