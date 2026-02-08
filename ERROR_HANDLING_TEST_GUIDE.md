# Error Handling Test Guide

## Quick Verification Tests

### 1. GemsProvider - Atomic Transaction Test

**Test:** Verify spendGems() rolls back on failure

**Steps:**
1. Open Gem Shop screen
2. Note current gem balance
3. Try to purchase an item
4. If purchase fails, verify:
   - ✅ Balance hasn't changed (rollback worked)
   - ✅ Error SnackBar appears
   - ✅ Retry button is visible
   - ✅ Clicking retry attempts purchase again

**Expected Result:** No partial transactions occur.

---

### 2. SpacedRepetitionProvider - Non-Breaking Test

**Test:** Verify review flow continues despite errors

**Steps:**
1. Start a review session
2. Answer a question
3. If card save fails, verify:
   - ✅ Error message appears (SnackBar + inline message)
   - ✅ Can still proceed to next card
   - ✅ Session doesn't crash
   - ✅ Retry button available

**Expected Result:** User can complete review session even if individual card saves fail.

---

### 3. AchievementProvider - No Silent Failures Test

**Test:** Verify all errors are logged and visible

**Steps:**
1. Complete a lesson or action that triggers achievement check
2. Monitor console/logs for any errors
3. Verify:
   - ✅ Any errors include "ACHIEVEMENT ERROR:" prefix
   - ✅ Error includes achievement ID
   - ✅ Stack trace is logged
   - ✅ Error surfaces to UI (not silently caught)

**Expected Result:** All achievement errors are visible in logs.

---

## Error Message Examples

### Good Error Messages (User-Friendly)
✅ "Failed to start session: Storage error"
✅ "Failed to record answer: Card not found"
✅ "Error: Insufficient gems for purchase"

### Bad Error Messages (Avoid)
❌ "Error: null"
❌ "Exception occurred"
❌ No message at all (silent failure)

---

## Retry Functionality

All error SnackBars include a **Retry** button:

```dart
SnackBar(
  content: Text('Error message'),
  action: SnackBarAction(
    label: 'Retry',
    onPressed: () => retryAction(),
  ),
)
```

**Test:** Click retry button and verify action is re-attempted.

---

## Error State Verification

### GemsProvider
Check state after error:
```dart
final gemsState = ref.watch(gemsProvider);
gemsState.when(
  loading: () => ...,
  error: (e, st) => ..., // Should show error
  data: (state) => ...,
);
```

### SpacedRepetitionProvider
Check error message:
```dart
final srState = ref.watch(spacedRepetitionProvider);
if (srState.errorMessage != null) {
  // Display error to user
}
```

---

## Simulating Errors for Testing

### Option 1: Modify Provider Temporarily
Add throw statement to simulate error:

```dart
Future<void> spendGems(...) async {
  // Temporary for testing
  throw Exception('Simulated storage error');
  
  // ... rest of code
}
```

### Option 2: Use Mock Storage
Create a mock SharedPreferences that fails on demand.

### Option 3: Network Conditions
Test on poor network to trigger real failures.

---

## Success Criteria

✅ **GemsProvider**
- [ ] spendGems() rolls back on failure
- [ ] Errors show in SnackBar with retry
- [ ] Balance never shows partial updates

✅ **SpacedRepetitionProvider**
- [ ] Review sessions continue despite errors
- [ ] Error messages are displayed
- [ ] Cards can still be reviewed after error

✅ **AchievementProvider**
- [ ] All errors are logged with full details
- [ ] No silent failures
- [ ] Errors include achievement ID + stack trace

✅ **UI Screens**
- [ ] Error SnackBars appear for all failures
- [ ] Retry buttons work correctly
- [ ] Error messages are user-friendly

---

## Regression Testing

After implementing error handling, verify:

1. **Normal Flow Still Works**
   - [ ] Can purchase items successfully
   - [ ] Can complete review sessions successfully
   - [ ] Achievements unlock successfully

2. **Error Recovery Works**
   - [ ] App doesn't crash on errors
   - [ ] User can retry failed operations
   - [ ] State remains consistent after errors

3. **Atomic Transactions**
   - [ ] No partial gem spends
   - [ ] Balance always matches transaction history

---

## Monitoring in Production

**Log Patterns to Monitor:**

1. GemsProvider errors:
   - Search logs for: "Failed to save gems data"
   - Search logs for: "Cannot spend gems"

2. SpacedRepetition errors:
   - Search logs for: "Failed to save review data"
   - Search logs for: "Card not found"

3. Achievement errors:
   - Search logs for: "ACHIEVEMENT ERROR"
   - Should include achievement ID + stack trace

**Action:** If these errors spike, investigate storage layer issues.

---

## Common Error Scenarios

### Scenario 1: Storage Full
- **Error:** "Failed to save gems data"
- **User Impact:** Purchases fail with rollback
- **Recovery:** Free up storage space

### Scenario 2: Corrupted Data
- **Error:** "Cannot load gems state"
- **User Impact:** Starts with empty state
- **Recovery:** Restore from backup

### Scenario 3: Concurrent Access
- **Error:** "Card not found in session"
- **User Impact:** That card is skipped
- **Recovery:** Continue with next card

---

## Developer Checklist

When adding new provider methods:

- [ ] Add try/catch block
- [ ] Set AsyncValue.error or errorMessage
- [ ] Rethrow exception for UI
- [ ] Add descriptive error messages
- [ ] Consider rollback for atomic operations
- [ ] Add retry logic in UI
- [ ] Test error path manually
- [ ] Log errors with context

**Follow the established pattern for consistency!**

---

## Questions?

If errors aren't being handled correctly:
1. Check provider has proper try/catch
2. Check UI screen has error handling
3. Check error is being rethrown (not swallowed)
4. Check SnackBar is showing (mounted check)

**All three providers now have comprehensive error handling! 🎉**
