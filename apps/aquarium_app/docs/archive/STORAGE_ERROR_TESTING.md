# Storage Error Handling - Manual Testing Guide

## Overview
This guide helps you manually test the storage error handling and recovery mechanisms.

## Prerequisites
- Android emulator or device running
- ADB access
- Aquarium app installed

## Test Scenarios

### Scenario 1: JSON Syntax Error
**Goal:** Verify the service handles malformed JSON gracefully

1. **Create a corrupted data file:**
   ```bash
   # Connect to device
   adb shell
   
   # Navigate to app data directory
   cd /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/
   
   # Create corrupted JSON (missing comma)
   cat > aquarium_data.json << 'EOF'
   {
     "version": 1
     "tanks": {}
   }
   EOF
   
   exit
   ```

2. **Launch the app and observe:**
   - ✅ App should not crash
   - ✅ Error should be logged in console: "❌ STORAGE ERROR: JSON Parsing Failed"
   - ✅ Service state should be `corrupted`
   - ✅ Backup file created: `aquarium_data.json.corrupted.[timestamp]`

3. **Verify recovery via logcat:**
   ```bash
   adb logcat | grep -E "STORAGE|Flutter"
   ```

4. **Test recovery:**
   - Use the app's UI to "Start Fresh" (if available)
   - OR manually delete the file and restart:
     ```bash
     adb shell rm /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/aquarium_data.json
     ```

---

### Scenario 2: Invalid Entity Structure
**Goal:** Verify partial corruption recovery

1. **Create file with some valid, some invalid entities:**
   ```bash
   adb shell
   cd /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/
   
   cat > aquarium_data.json << 'EOF'
   {
     "version": 1,
     "tanks": {
       "good-tank": {
         "id": "good-tank",
         "name": "Valid Tank",
         "type": "freshwater",
         "volumeLitres": 100.0,
         "startDate": "2024-01-01T00:00:00.000Z",
         "targets": {
           "tempMin": 22.0,
           "tempMax": 26.0
         },
         "createdAt": "2024-01-01T00:00:00.000Z",
         "updatedAt": "2024-01-01T00:00:00.000Z"
       },
       "bad-tank": {
         "id": "bad-tank",
         "name": "Missing Required Fields"
       }
     },
     "livestock": {
       "good-fish": {
         "id": "good-fish",
         "tankId": "good-tank",
         "commonName": "Valid Fish",
         "count": 1,
         "dateAdded": "2024-01-01T00:00:00.000Z",
         "createdAt": "2024-01-01T00:00:00.000Z",
         "updatedAt": "2024-01-01T00:00:00.000Z"
       },
       "bad-fish": {
         "id": "bad-fish"
       }
     }
   }
   EOF
   
   exit
   ```

2. **Launch app and verify:**
   - ✅ App loads with 1 tank (good-tank)
   - ✅ App loads with 1 fish (good-fish)
   - ✅ Console shows: "⚠️ Skipping corrupted tank: bad-tank"
   - ✅ Console shows: "⚠️ Skipping corrupted livestock: bad-fish"
   - ✅ Service state: `loaded` (not corrupted!)
   - ✅ Message: "⚠️ Loaded with 2 corrupted entities skipped"

---

### Scenario 3: Empty File
**Goal:** Verify graceful handling of empty data

1. **Create empty file:**
   ```bash
   adb shell
   cd /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/
   echo "" > aquarium_data.json
   exit
   ```

2. **Launch app and verify:**
   - ✅ App starts successfully
   - ✅ No tanks or livestock shown
   - ✅ Console: "📦 Storage: Empty data file, starting fresh"
   - ✅ Service state: `loaded`
   - ✅ No error state

---

### Scenario 4: Missing File
**Goal:** Verify fresh install behavior

1. **Delete data file:**
   ```bash
   adb shell rm /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/aquarium_data.json
   ```

2. **Launch app and verify:**
   - ✅ App starts successfully
   - ✅ No data shown
   - ✅ Console: "📦 Storage: No data file found, starting fresh"
   - ✅ Service state: `loaded`

---

### Scenario 5: Mass Corruption (Should Fail)
**Goal:** Verify service fails when too many entities are corrupted

1. **Create file with >10 corrupted entities:**
   ```bash
   adb shell
   cd /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/
   
   cat > aquarium_data.json << 'EOF'
   {
     "version": 1,
     "tanks": {
       "bad-1": {"id": "bad-1"},
       "bad-2": {"id": "bad-2"},
       "bad-3": {"id": "bad-3"},
       "bad-4": {"id": "bad-4"},
       "bad-5": {"id": "bad-5"},
       "bad-6": {"id": "bad-6"},
       "bad-7": {"id": "bad-7"},
       "bad-8": {"id": "bad-8"},
       "bad-9": {"id": "bad-9"},
       "bad-10": {"id": "bad-10"},
       "bad-11": {"id": "bad-11"}
     }
   }
   EOF
   
   exit
   ```

2. **Launch app and verify:**
   - ✅ Service throws `StorageCorruptionException`
   - ✅ Console: "Too many entity parsing errors (11). Data may be severely corrupted."
   - ✅ Service state: `corrupted`
   - ✅ Backup file created

---

## Testing Recovery Methods

### Test `clearAllData()`
```dart
// In your app code or debug console:
final storage = LocalJsonStorageService();
await storage.clearAllData();

// Verify:
// - state == StorageState.loaded
// - lastError == null
// - data file deleted
```

### Test `retryLoad()`
```dart
// After fixing a corrupted file externally:
final storage = LocalJsonStorageService();
await storage.retryLoad();

// Verify:
// - Data reloaded from disk
// - state updated accordingly
```

### Test `recoverFromCorruption()`
```dart
// After corruption detected:
final storage = LocalJsonStorageService();
await storage.recoverFromCorruption();

// Verify:
// - Corrupted file deleted
// - state == StorageState.loaded
// - lastError == null
// - Can save new data
```

---

## Verifying Backup Files

After any corruption scenario:

```bash
adb shell ls -la /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/
```

You should see:
- `aquarium_data.json` (current file, may be empty after recovery)
- `aquarium_data.json.corrupted.[timestamp]` (backup of corrupted data)

To inspect a backup:
```bash
adb shell cat /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/aquarium_data.json.corrupted.1234567890
```

---

## Expected Console Logs

### Successful Load:
```
📦 Storage loaded successfully: 2 tanks, 5 livestock, 3 equipment
```

### JSON Corruption:
```
❌ STORAGE ERROR: JSON Parsing Failed
   Error: FormatException: ...
   File: /data/.../aquarium_data.json
   Backup: /data/.../aquarium_data.json.corrupted.1234567890
   Timestamp: 2024-01-15T10:30:00.000Z
```

### Partial Corruption:
```
⚠️  Skipping corrupted tank: bad-tank - ...
⚠️  Skipping corrupted livestock: bad-fish - ...
⚠️  Loaded with 2 corrupted entities skipped
✅ Storage loaded successfully: 1 tanks, 1 livestock
```

### Recovery:
```
🔧 Recovering from storage corruption...
🗑️  Deleted corrupted data file
🗑️  All storage data cleared, service reset to healthy state
✅ Recovery complete - starting with fresh data
```

---

## Accessing Service State in UI

Add this to your UI for debugging:

```dart
Widget _buildStorageStatus() {
  final storage = LocalJsonStorageService();
  
  return Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Storage Status: ${storage.state}'),
          if (storage.hasError) ...[
            SizedBox(height: 8),
            Text(
              'Error: ${storage.lastError?.message}',
              style: TextStyle(color: Colors.red),
            ),
            if (storage.lastError?.corruptedFilePath != null)
              Text('Backup: ${storage.lastError!.corruptedFilePath}'),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await storage.recoverFromCorruption();
                setState(() {});
              },
              child: Text('Recover from Corruption'),
            ),
          ],
        ],
      ),
    ),
  );
}
```

---

## Quick Reference: ADB Commands

**View logs:**
```bash
adb logcat | grep -E "STORAGE|Flutter"
```

**Clear app data (nuclear option):**
```bash
adb shell pm clear com.tiarnanlarkin.aquarium.aquarium_app
```

**Pull data file for inspection:**
```bash
adb pull /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/aquarium_data.json ./backup.json
```

**Push test file to device:**
```bash
adb push ./test_data.json /data/data/com.tiarnanlarkin.aquarium.aquarium_app/app_flutter/aquarium_data.json
```

---

## Success Criteria

All scenarios pass if:

1. ✅ **No app crashes** - Even with corrupted data
2. ✅ **Proper error logging** - All errors visible in console
3. ✅ **State tracking works** - Service state reflects reality
4. ✅ **Backups created** - Corrupted files preserved
5. ✅ **Recovery works** - Can recover from all error states
6. ✅ **Partial recovery** - Good data loaded even when some is bad
7. ✅ **User feedback** - UI can access error state and offer recovery

---

## Troubleshooting

**Can't access app data directory:**
- Make sure device is rooted OR using debug build OR emulator

**ADB shell permission denied:**
```bash
adb root
adb shell
```

**File doesn't persist after creation:**
- Make sure app is closed when editing files
- Verify path is correct for your package name

**Changes not taking effect:**
- Clear app cache: `adb shell pm clear <package>`
- Restart app completely
- Check file was actually modified: `adb shell cat <path>`
