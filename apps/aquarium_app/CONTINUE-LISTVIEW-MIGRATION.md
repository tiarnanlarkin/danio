# How to Continue ListView.builder Migration

**Current Status:** 1 of 5 settings screens completed  
**Remaining:** 4 settings screens + 22 guide screens  
**Pattern Established:** ✅ See settings_hub_screen.dart for reference

---

## Step 1: Fix Build Environment (if needed)

### From Windows PowerShell:
```powershell
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"
.\fix_gradle_locks.ps1
```

### Or manually:
```powershell
.\android\gradlew.bat --stop
flutter clean
Remove-Item -Recurse -Force android\.gradle
flutter build apk --debug
```

**Expected:** Build should succeed in ~80-90 seconds

---

## Step 2: Convert Remaining Settings Screens

### Priority Order:

1. **tank_settings_screen.dart** (medium, ~448 lines)
2. **backup_restore_screen.dart** (large, ~860 lines)  
3. **settings_screen.dart** (very large, ~1500 lines)

### Conversion Pattern:

**Before:**
```dart
body: ListView(
  children: [
    Widget1(),
    Widget2(),
    Widget3(),
  ],
)
```

**After:**
```dart
body: ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => items[index],
)

// Add helper method:
List<Widget> _buildListItems(...) {
  return [
    Widget1(),
    Widget2(),
    Widget3(),
  ];
}
```

### For Each File:

1. **Convert** ListView to ListView.builder
2. **Build** test: `flutter build apk --debug`
3. **Verify** build succeeds (no errors)
4. **Commit** with descriptive message:
   ```bash
   git add lib/screens/[filename].dart
   git commit -m "refactor: Convert [screen_name] to ListView.builder

   - Migrated from static ListView to ListView.builder
   - Extracted children list into helper method
   - Part of Phase 1.3c: ListView.builder migration
   - Build verified: ✓"
   ```

---

## Step 3: Decide on Guide Screens (22 files)

### Option A: Skip (Recommended for now)
- Most have static lists < 15 items
- ListView.builder provides minimal performance benefit
- Focus on more impactful work

### Option B: Batch Convert
- Consistency across codebase
- Future-proofing
- Estimated time: ~2 hours

### Files (if converting):
```
lib/screens/acclimation_guide_screen.dart
lib/screens/breeding_guide_screen.dart
lib/screens/co2_calculator_screen.dart
lib/screens/compatibility_checker_screen.dart
lib/screens/emergency_guide_screen.dart
lib/screens/enhanced_quiz_screen.dart
lib/screens/equipment_guide_screen.dart
lib/screens/faq_screen.dart
lib/screens/feeding_guide_screen.dart
lib/screens/hardscape_guide_screen.dart
lib/screens/lighting_schedule_screen.dart
lib/screens/parameter_guide_screen.dart
lib/screens/practice_hub_screen.dart
lib/screens/quarantine_guide_screen.dart
lib/screens/quick_start_guide_screen.dart
lib/screens/spaced_repetition_practice_screen.dart
lib/screens/substrate_guide_screen.dart
lib/screens/tank_comparison_screen.dart
lib/screens/troubleshooting_screen.dart
lib/screens/vacation_guide_screen.dart
lib/screens/water_change_calculator_screen.dart
```

**Tip:** Use search & replace for batch conversions, then test build once at the end.

---

## Step 4: Final Report

When complete, update:
```
docs/completed/Phase-1.3c-ListView-Migration-Report.md
```

Add:
- Files converted
- Build verification results
- Final count of remaining non-builder ListViews in entire app

---

## Quick Reference: Completed Example

**File:** `lib/screens/settings_hub_screen.dart`  
**Commit:** `0a7aae5`  
**Pattern:** Extract children to `_buildListItems()` method

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final profile = ref.watch(userProfileProvider).value;
  final items = _buildListItems(context, profile);

  return Scaffold(
    appBar: AppBar(
      title: const Text('⚙️ Settings & More'),
    ),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    ),
  );
}

List<Widget> _buildListItems(BuildContext context, profile) {
  return [
    _buildProfileCard(context, profile),
    const SizedBox(height: 24),
    _buildSectionHeader('Community'),
    // ... more widgets
  ];
}
```

---

## Troubleshooting

### Build Fails with Gradle Lock Error
→ Run `fix_gradle_locks.ps1` from PowerShell

### Build Hangs During Flutter Clean
→ Kill process, skip flutter clean, just remove `android/.gradle/`

### CMake Errors
→ Usually transient, try again. Not related to Dart code changes.

### "Could not create service... FileHasher already locked"
→ Multiple Gradle daemons running. Kill all:
```powershell
Get-Process | Where-Object {$_.ProcessName -like "*java*" -and $_.CommandLine -like "*gradle*"} | Stop-Process -Force
```

---

## Estimated Time

- Fix build environment: 5-10 minutes
- Convert 3 settings screens: 45 minutes
- Guide screens (optional): 2 hours
- **Total:** 1-3 hours depending on scope

---

## Success Criteria

- [ ] Build passes after each file conversion
- [ ] All settings screens use ListView.builder  
- [ ] Commits pushed to master
- [ ] Report updated with final results
- [ ] Count of remaining non-builder ListViews documented

---

**Last Updated:** 2025-02-15  
**Next Agent:** Can pick up from Step 1
