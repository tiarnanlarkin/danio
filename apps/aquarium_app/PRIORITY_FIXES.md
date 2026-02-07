# 🚨 PRIORITY FIXES - Aquarium App

## ⚠️ STOP THE PRESSES - FIX IMMEDIATELY

### 1. Storage Not Persisting (P0-5)
**File:** `lib/providers/storage_provider.dart`

**Current code (likely):**
```dart
final storageServiceProvider = Provider<StorageService>((ref) {
  return InMemoryStorageService();  // ❌ DATA LOST ON APP CLOSE
});
```

**Fix:**
```dart
final storageServiceProvider = Provider<StorageService>((ref) {
  return LocalJsonStorageService();  // ✅ Persists to disk
});
```

**Why critical:** All user data is currently lost when app closes!

---

### 2. Race Condition in Save (P0-1)
**File:** `lib/services/local_json_storage_service.dart`

**Add to pubspec.yaml:**
```yaml
dependencies:
  synchronized: ^3.1.0
```

**In LocalJsonStorageService:**
```dart
import 'package:synchronized/synchronized.dart';

class LocalJsonStorageService implements StorageService {
  final Lock _persistLock = Lock();
  
  Future<void> _persist() async {
    await _persistLock.synchronized(() async {
      final file = await _dataFile();
      final payload = <String, dynamic>{
        'version': _schemaVersion,
        'updatedAt': DateTime.now().toIso8601String(),
        'tanks': _tanks.map((k, v) => MapEntry(k, _tankToJson(v))),
        'livestock': _livestock.map((k, v) => MapEntry(k, _livestockToJson(v))),
        'equipment': _equipment.map((k, v) => MapEntry(k, _equipmentToJson(v))),
        'logs': _logs.map((k, v) => MapEntry(k, _logToJson(v))),
        'tasks': _tasks.map((k, v) => MapEntry(k, _taskToJson(v))),
      };

      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(jsonEncode(payload));
      await tmp.rename(file.path);
    });
  }
}
```

---

### 3. Monthly Task Date Crash (P0-3)
**File:** `lib/models/task.dart`

**Replace:**
```dart
case RecurrenceType.monthly:
  return DateTime(now.year, now.month + 1, now.day);
```

**With:**
```dart
case RecurrenceType.monthly:
  // Handle month-end dates safely
  int nextMonth = now.month + 1;
  int nextYear = now.year;
  
  if (nextMonth > 12) {
    nextMonth = 1;
    nextYear += 1;
  }
  
  // Get last valid day of next month
  final lastDayOfMonth = DateTime(nextYear, nextMonth + 1, 0).day;
  final safeDay = now.day > lastDayOfMonth ? lastDayOfMonth : now.day;
  
  return DateTime(nextYear, nextMonth, safeDay);
```

---

### 4. Error Handling for Data Corruption (P0-2)
**File:** `lib/services/local_json_storage_service.dart`

**Replace:**
```dart
} catch (_) {
  // ⚠️ Silent failure
  _loaded = true;
}
```

**With:**
```dart
} catch (e, stack) {
  print('❌ Data corruption detected: $e');
  print(stack);
  
  // Try to recover by backing up corrupted file
  try {
    final corruptedFile = await _dataFile();
    final backupFile = File('${corruptedFile.path}.corrupted.${DateTime.now().millisecondsSinceEpoch}');
    await corruptedFile.copy(backupFile.path);
    print('💾 Corrupted file backed up to: ${backupFile.path}');
  } catch (_) {}
  
  _loaded = true;
  
  // TODO: Show error dialog to user with recovery options
  // For now, app continues with empty state
}
```

---

### 5. Streak Calculation Bug (P0-4)
**File:** `lib/providers/user_profile_provider.dart`

**Replace:**
```dart
if (current.lastActivityDate != null) {
  final lastDate = DateTime(
    current.lastActivityDate!.year,
    current.lastActivityDate!.month,
    current.lastActivityDate!.day,
  );
  final yesterday = today.subtract(const Duration(days: 1));

  if (lastDate == yesterday) {
    // Continuing streak
    newStreak = current.currentStreak + 1;
  } else if (lastDate != today) {
    // Streak broken (more than 1 day gap)
    newStreak = 1;
  }
  // If lastDate == today, keep current streak
} else {
  // First activity ever
  newStreak = 1;
}
```

**With:**
```dart
if (current.lastActivityDate != null) {
  final lastDate = DateTime(
    current.lastActivityDate!.year,
    current.lastActivityDate!.month,
    current.lastActivityDate!.day,
  );
  final yesterday = today.subtract(const Duration(days: 1));

  if (lastDate == today) {
    // Already logged today, keep current streak (don't increment again)
    newStreak = current.currentStreak;
  } else if (lastDate == yesterday) {
    // Continuing streak from yesterday
    newStreak = current.currentStreak + 1;
  } else {
    // Streak broken (more than 1 day gap)
    newStreak = 1;
  }
} else {
  // First activity ever
  newStreak = 1;
}
```

---

## 🔥 HIGH PRIORITY (Fix This Week)

### 6. Input Validation - Water Tests
**File:** `lib/screens/add_log_screen.dart`

**Modify `_ParameterField` widget:**
```dart
class _ParameterField extends StatelessWidget {
  // ... existing fields ...
  final double? minValue;
  final double? maxValue;

  const _ParameterField({
    required this.label,
    this.unit,
    required this.value,
    required this.onChanged,
    this.decimal = false,
    this.warningThreshold,
    this.dangerThreshold,
    this.minValue,  // ← Add
    this.maxValue,  // ← Add
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        suffixIcon: statusColor != null
            ? Icon(Icons.circle, color: statusColor, size: 12)
            : null,
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),  // ← Better regex
      ],
      onChanged: (v) {
        final parsed = double.tryParse(v);
        if (parsed == null) {
          onChanged(null);
          return;
        }
        
        // Validate range
        if (minValue != null && parsed < minValue!) return;
        if (maxValue != null && parsed > maxValue!) return;
        
        onChanged(parsed);
      },
    );
  }
}
```

**Update usage:**
```dart
_ParameterField(
  label: 'Temperature',
  unit: '°C',
  value: _temperature,
  onChanged: (v) => setState(() => _temperature = v),
  minValue: 0,    // ← Add
  maxValue: 45,   // ← Add
),
_ParameterField(
  label: 'pH',
  value: _ph,
  onChanged: (v) => setState(() => _ph = v),
  decimal: true,
  minValue: 0,    // ← Add
  maxValue: 14,   // ← Add
),
```

---

### 7. Tank Volume Validation
**File:** `lib/screens/create_tank_screen.dart`

**In `_SizePage`:**
```dart
TextFormField(
  initialValue: volumeLitres > 0 ? volumeLitres.toString() : '',
  decoration: const InputDecoration(
    labelText: 'Volume (litres)',
    hintText: 'e.g., 120',
    suffixText: 'L',
  ),
  keyboardType: const TextInputType.numberWithOptions(decimal: true),
  inputFormatters: [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
  ],
  onChanged: (v) {
    final value = double.tryParse(v);
    if (value != null && value > 0 && value < 10000) {  // ← Add validation
      onVolumeChanged(value);
    }
  },
  validator: (v) {  // ← Add validator
    final value = double.tryParse(v ?? '');
    if (value == null || value <= 0) {
      return 'Enter a valid volume';
    }
    if (value > 10000) {
      return 'Volume seems unrealistic';
    }
    return null;
  },
),
```

---

### 8. Onboarding Error Handling
**File:** `lib/main.dart`

**Replace:**
```dart
Future<void> _checkOnboarding() async {
  final service = await OnboardingService.getInstance();
  setState(() {
    _showOnboarding = !service.isOnboardingCompleted;
    _isLoading = false;
  });
}
```

**With:**
```dart
Future<void> _checkOnboarding() async {
  try {
    final service = await OnboardingService.getInstance();
    setState(() {
      _showOnboarding = !service.isOnboardingCompleted;
      _isLoading = false;
    });
  } catch (e, stack) {
    print('❌ Onboarding check failed: $e');
    print(stack);
    
    // Default to main app on error (safer than infinite loading)
    setState(() {
      _showOnboarding = false;
      _isLoading = false;
    });
  }
}
```

---

## 🧪 TESTING CHECKLIST

After applying fixes, test these scenarios:

- [ ] Create 5 tanks in quick succession (test P0-1 race condition fix)
- [ ] Close and reopen app - verify tanks are still there (test P0-5 persistence)
- [ ] Create monthly task on Jan 31, complete it multiple times (test P0-3)
- [ ] Log activity twice in same day - verify streak only increments once (test P0-4)
- [ ] Enter negative temperature in water test - verify it's rejected (test P1-2)
- [ ] Try to create tank with 0L volume - verify it's rejected (test P1-3)
- [ ] Corrupt the data file manually and restart app - verify graceful error (test P0-2)
- [ ] Force onboarding service to fail - verify app still loads (test P1-11)

---

## 📊 IMPACT ASSESSMENT

Fixing these 8 bugs will:
- ✅ Eliminate all P0 (critical) bugs
- ✅ Prevent data loss scenarios
- ✅ Stop crashes from edge case inputs
- ✅ Make app actually usable in production

**Estimated time:** 4-6 hours  
**Risk of breaking existing code:** Low (mostly adding validation)  
**User impact:** HIGH - prevents frustration and data loss

---

## 🔄 DEPLOYMENT NOTES

1. **Test on fresh install** - Verify onboarding works
2. **Test with existing data** - Ensure migration smooth
3. **Test on low-end device** - Verify no performance regressions
4. **Monitor crash reports** after deployment

**Recommended release notes:**
```
🐛 Bug Fixes:
- Fixed critical data persistence issue
- Improved data validation for water tests
- Fixed crashes with monthly recurring tasks
- Enhanced error handling throughout the app
- Better input validation to prevent invalid data
```
