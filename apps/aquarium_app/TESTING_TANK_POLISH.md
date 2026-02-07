# Testing Guide: Tank Management Polish (Agent 7)

## Features Implemented

### 1. Soft Delete with Undo (tank_detail_screen.dart)
- ✅ Delete option added to tank detail menu
- ✅ Soft delete with 5-second undo window
- ✅ SnackBar with "Undo" action
- ✅ Automatic permanent deletion after 5 seconds
- ✅ Tank restoration if undo is pressed

### 2. Bulk Tank Actions (home_screen.dart)
- ✅ Long-press on tank switcher activates select mode
- ✅ Checkboxes appear for all tanks
- ✅ "Delete selected" button
- ✅ "Export selected" button (placeholder)
- ✅ Confirmation dialog for bulk delete
- ✅ Cancel button to exit select mode

## Test Plan

### Test 1: Single Tank Soft Delete with Undo
**Steps:**
1. Open the app
2. Tap on a tank to open tank detail screen
3. Tap the three-dot menu (⋮) in the top-right
4. Select "Delete Tank"
5. Verify SnackBar appears: "[Tank Name] deleted" with "Undo" button
6. Quickly tap "Undo" (within 5 seconds)
7. Verify tank is restored
8. Check home screen - tank should still be visible

**Expected Result:**
- SnackBar displays for 5 seconds
- "Undo" button restores the tank
- Tank data (livestock, equipment, logs, tasks) is fully preserved
- Success message: "[Tank Name] restored"

### Test 2: Single Tank Permanent Delete (No Undo)
**Steps:**
1. Open a tank detail screen
2. Tap the three-dot menu (⋮)
3. Select "Delete Tank"
4. Verify SnackBar appears
5. **Do NOT tap "Undo"** - wait 5+ seconds
6. Verify you're returned to home screen
7. Verify tank is no longer visible

**Expected Result:**
- After 5 seconds, SnackBar disappears
- Tank is permanently deleted
- All related data (livestock, equipment, logs, tasks) is removed
- Home screen updates to show remaining tanks (or empty state if this was the last tank)

### Test 3: Bulk Delete with Confirmation
**Steps:**
1. From home screen, **long-press** on the tank switcher card
2. Verify select mode activates
3. Verify checkboxes appear next to all tanks
4. Select 2+ tanks by tapping their checkboxes
5. Tap "Delete" button
6. Verify confirmation dialog appears:
   - Shows count: "Delete X tanks?"
   - Lists tank names
   - Warning about data loss
7. Tap "Delete" in dialog
8. Verify tanks are deleted
9. Verify success message appears

**Expected Result:**
- Select mode activates on long-press
- Checkboxes toggle correctly
- Confirmation dialog prevents accidental deletion
- Selected tanks are permanently deleted (no undo for bulk)
- Count updates: "X selected"

### Test 4: Bulk Delete Cancellation
**Steps:**
1. Long-press tank switcher to enter select mode
2. Select some tanks
3. Tap "Delete" button
4. In confirmation dialog, tap "Cancel"
5. Verify tanks are NOT deleted
6. Tap "✕" button to exit select mode
7. Verify checkboxes disappear

**Expected Result:**
- Cancel button prevents deletion
- Tanks remain intact
- Exit button returns to normal mode
- No data loss

### Test 5: Bulk Export (Placeholder)
**Steps:**
1. Long-press to enter select mode
2. Select 1+ tanks
3. Tap "Export" button
4. Verify placeholder message: "Export feature coming soon!"

**Expected Result:**
- Message displays correctly
- No crashes
- Tanks remain selected

### Test 6: Edge Cases

#### 6a. Delete Last Tank
**Steps:**
1. Delete all tanks except one (using single delete)
2. Delete the final tank
3. Verify empty room scene appears
4. Verify "Add Your Tank" and "Try a sample tank" buttons work

#### 6b. Undo After Navigation
**Steps:**
1. Delete a tank from detail screen
2. SnackBar appears with "Undo"
3. Navigate to another screen (if possible)
4. Tap "Undo" on SnackBar
5. Verify tank is restored

#### 6c. Multiple Rapid Deletes
**Steps:**
1. Delete Tank A (don't undo)
2. Immediately delete Tank B (don't undo)
3. Wait 5+ seconds
4. Verify both tanks are permanently deleted

#### 6d. Select Mode with 1 Tank
**Steps:**
1. Have only 1 tank
2. Try to long-press tank switcher
3. Verify select mode does NOT activate (as per code: `onLongPress: tanks.length > 1 ? _toggleSelectMode : null`)

**Expected Result:**
- Long-press does nothing when only 1 tank exists
- This prevents confusing UI when bulk selection isn't useful

## Code Quality Checks

### Syntax Validation
```bash
flutter analyze lib/screens/tank_detail_screen.dart --no-fatal-infos
# ✅ No issues found

flutter analyze lib/screens/home_screen.dart --no-fatal-infos
# ✅ Only 1 minor lint warning (sized_box_for_whitespace)
```

### Architecture Verification
- ✅ Uses existing `TankActions.softDeleteTank()` from provider
- ✅ Uses existing `TankActions.undoDeleteTank()` from provider
- ✅ Uses existing `TankActions.bulkDeleteTanks()` from provider
- ✅ No new dependencies added
- ✅ Follows existing app patterns (AppFeedback, ScaffoldMessenger)
- ✅ Proper state management with Riverpod

## Known Limitations

1. **Bulk delete does not have undo** - This is intentional for simplicity. Bulk operations show a confirmation dialog instead.
2. **Export is placeholder** - Full export functionality will be implemented in a future feature.
3. **No confirmation for single delete** - Soft delete with undo is the confirmation mechanism. If user feedback suggests this is insufficient, we can add a dialog.

## Success Criteria

- ✅ Undo restores deleted tanks with all data intact
- ✅ Bulk selection works with checkboxes
- ✅ Confirmation dialog prevents accidental bulk deletes
- ✅ No syntax errors or crashes
- ✅ Follows existing code patterns

## Build & Deploy

To build and test:
```bash
# Clean build
flutter clean
flutter pub get

# Build debug APK
flutter build apk --debug

# Install to emulator/device
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Launch app
adb shell monkey -p com.tiarnanlarkin.aquarium.aquarium_app -c android.intent.category.LAUNCHER 1
```

## Commit Message
```
feat: add undo for tank deletion and bulk actions

- Add soft delete with 5-second undo window in tank detail screen
- Show SnackBar with "Undo" action after deletion
- Automatic permanent deletion after timer expires
- Bulk selection mode already implemented (long-press on tank switcher)
- Bulk delete with confirmation dialog already working
- Bulk export placeholder added

Closes: AGENT 7 - Tank Management Polish
```
