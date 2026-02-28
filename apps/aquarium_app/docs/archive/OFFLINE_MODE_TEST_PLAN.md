# Offline Mode Test Plan

## ✅ Implementation Checklist

### 1. Offline Indicator Widget
- [x] Created `lib/widgets/offline_indicator.dart`
- [x] Shows banner when offline: "You're offline - some features may not work"
- [x] Auto-hides when connection restored
- [x] Integrated into HouseNavigator (main app screen)

### 2. Sync Service
- [x] Created `lib/services/sync_service.dart`
- [x] Queues actions when offline:
  - XP awards
  - Gem purchases/earnings
  - Lesson completions
  - Achievement unlocks
  - Profile updates
  - Streak updates
- [x] Persists queue to SharedPreferences (survives app restart)
- [x] Auto-syncs when connection restored
- [x] Shows sync status in UI

### 3. Sync Indicator Widget
- [x] Created `lib/widgets/sync_indicator.dart`
- [x] Shows "Syncing..." during sync
- [x] Shows queued action count when offline
- [x] Integrated into HouseNavigator

### 4. Offline-Aware Service
- [x] Created `lib/services/offline_aware_service.dart`
- [x] Wrapper for user actions
- [x] Executes locally first (app works offline)
- [x] Queues for sync automatically

### 5. Lessons Verified Offline-Ready
- [x] Lessons are static Dart data in `lib/data/lesson_content.dart`
- [x] No API calls required
- [x] All content embedded in app

## 📱 Test Scenarios

### Test 1: App Works Offline
**Steps:**
1. Build and install app
2. Enable airplane mode
3. Open app
4. Navigate to Study room
5. Start a lesson
6. Complete lesson and quiz

**Expected:**
- ✅ Offline banner appears at top
- ✅ Lesson loads normally
- ✅ Quiz works
- ✅ XP awarded locally
- ✅ No crashes or errors
- ✅ Sync indicator shows "1 action queued"

### Test 2: Multiple Offline Actions
**Steps:**
1. With airplane mode ON:
2. Complete 2-3 lessons
3. Check sync indicator

**Expected:**
- ✅ All lessons work
- ✅ XP accumulates
- ✅ Sync indicator shows "3 actions queued" (or however many)
- ✅ All local state updates immediately

### Test 3: Auto-Sync on Reconnect
**Steps:**
1. Complete 2-3 actions while offline
2. Turn airplane mode OFF
3. Observe sync indicator

**Expected:**
- ✅ Offline banner disappears
- ✅ Sync indicator shows "Syncing..."
- ✅ After ~1 second, sync completes
- ✅ Queue cleared
- ✅ Sync indicator hides

### Test 4: Queue Persists Across Restart
**Steps:**
1. Enable airplane mode
2. Complete 2 lessons
3. Force-close app
4. Reopen app (still in airplane mode)
5. Check sync indicator

**Expected:**
- ✅ Sync indicator still shows "2 actions queued"
- ✅ Queue survived restart
- ✅ When online, those actions will sync

### Test 5: Online Behavior (No Queue)
**Steps:**
1. Disable airplane mode
2. Complete lessons normally

**Expected:**
- ✅ No offline banner
- ✅ No sync indicator
- ✅ Everything works as before

## 🔧 ADB Commands for Testing

### Enable Airplane Mode
```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" shell cmd connectivity airplane-mode enable
```

### Disable Airplane Mode
```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" shell cmd connectivity airplane-mode disable
```

### Check Connectivity Status
```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" shell dumpsys connectivity | grep "NetworkAgentInfo"
```

### Install APK
```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" install -r "C:\\Users\\larki\\Documents\\Aquarium App Dev\\repo\\apps\\aquarium_app\\build\\app\\outputs\\flutter-apk\\app-debug.apk"
```

### Launch App
```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" shell monkey -p com.tiarnanlarkin.aquarium.aquarium_app -c android.intent.category.LAUNCHER 1
```

### Take Screenshot
```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" exec-out screencap -p > /tmp/offline_test_screenshot.png
```

### View Logs
```bash
"/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe" logcat -s flutter
```

## ✅ Success Criteria

All of these must be true:

1. **Offline Banner Visible**
   - Shows when offline
   - Hides when online
   - Uses orange color scheme

2. **Lessons Work Offline**
   - All lessons load
   - Quizzes work
   - XP awarded locally
   - No network errors

3. **Sync Queue Works**
   - Actions queued when offline
   - Queue persists across restart
   - Sync indicator shows count

4. **Auto-Sync Works**
   - Detects connection restore
   - Automatically syncs queue
   - Shows "Syncing..." during sync
   - Clears queue on success

5. **No Crashes**
   - App stable in airplane mode
   - No errors in logs
   - All features accessible

## 📊 Integration Status

### Files Modified
- `lib/screens/house_navigator.dart` - Added offline/sync indicators

### Files Already Created (from previous work)
- `lib/widgets/offline_indicator.dart` - Offline banner widget
- `lib/widgets/sync_indicator.dart` - Sync status widget
- `lib/services/sync_service.dart` - Queue management
- `lib/services/offline_aware_service.dart` - Action wrapper

### Dependencies (Already in pubspec.yaml)
- `connectivity_plus: ^6.1.2` - Network monitoring
- `shared_preferences: ^2.3.3` - Queue persistence

## 🎯 Next Steps (Future Enhancements)

When backend API is added:

1. **Replace Mock Sync**
   - Update `SyncService.syncNow()` to call real API
   - Add retry logic for failed syncs
   - Handle network timeouts

2. **Conflict Resolution**
   - Timestamp-based merging
   - Server validation
   - Handle concurrent edits

3. **Advanced Features**
   - Manual sync toggle in settings
   - WiFi-only sync option
   - Sync frequency preferences
   - Priority queue for urgent actions

4. **Analytics**
   - Track offline usage patterns
   - Monitor sync success rates
   - Detect common failures

## 📝 Notes

- App is currently **fully local** - no backend exists yet
- Sync service is **future-proof** and ready for backend integration
- All user data stored in **SharedPreferences**
- Lessons are **static Dart data** - inherently offline-ready
- No external API calls currently made
