# Permissions Quick Reference - Aquarium Hobbyist App

**Keep this handy during development to maintain excellent permission hygiene!**

---

## 🎯 Current Permissions (Keep This List Short!)

| Permission | Why | Where Used |
|------------|-----|------------|
| `INTERNET` | Development + future features | Debug manifests |
| `VIBRATE` | Notification haptics | `flutter_local_notifications` |
| `POST_NOTIFICATIONS` | Maintenance reminders | `notification_service.dart` |

**Total Dangerous Permissions:** 1 (POST_NOTIFICATIONS)

---

## ✅ Modern APIs We Use (No Permissions Needed!)

### 📸 Photo Picker (image_picker)
```dart
// DON'T add camera/storage permissions!
final picked = await ImagePicker().pickMultiImage();

// This uses Photo Picker API (Android 13+) or gallery picker (older)
// NO permissions required ✨
```

**Behind the scenes:**
- Android 13+: System photo picker (no permissions)
- Android 7-12: Gallery intent (no permissions)
- User can take new photo from within picker
- App only gets access to selected images

---

### 📁 File Picker (file_picker)
```dart
// DON'T add storage permissions!
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['json'],
);

// This uses Storage Access Framework (SAF)
// NO permissions required ✨
```

**Behind the scenes:**
- Uses system file picker
- User explicitly chooses files
- Scoped access only
- Works back to Android 5.0

---

## ⚠️ NEVER Add These Permissions (We Don't Need Them!)

### ❌ DON'T Add:
```xml
<!-- DON'T DO THIS - we use modern APIs instead! -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION"/>
```

**Why not?**
- Photo picker handles camera access ✅
- SAF handles file access ✅
- These permissions reduce user trust ⚠️
- Play Store scrutinizes these heavily 🔍
- Our modern approach is better for privacy 🔒

---

## 🛡️ Adding New Features? Permission Decision Tree

### Decision Tree:

```
New feature needs [X]?
│
├─ Photos/Images?
│  └─ Use: image_picker (NO permission needed)
│
├─ Files (backup/export)?
│  └─ Use: file_picker or share_plus (NO permission needed)
│
├─ Notifications?
│  └─ Already handled! (POST_NOTIFICATIONS)
│
├─ Location (e.g., local fish stores)?
│  ├─ Coarse: Add ACCESS_COARSE_LOCATION + runtime request
│  └─ Fine: Add ACCESS_FINE_LOCATION + runtime request + justification
│
├─ Internet (API calls)?
│  └─ Already have INTERNET permission ✅
│
├─ Camera (QR codes, AR features)?
│  ├─ Option 1: Use image_picker with camera source (NO permission)
│  └─ Option 2: Use camera plugin (REQUIRES CAMERA permission)
│     └─ ⚠️ Only if image_picker insufficient!
│
└─ Other?
   └─ Research Android 13+ privacy-friendly alternatives FIRST!
```

---

## 🎓 Modern Android Privacy Principles

### Always Ask First:
1. **Can I use a system picker instead?** (photo picker, file picker, contacts picker)
2. **Can I use scoped access?** (SAF, MediaStore)
3. **Do I really need this?** (can feature work without it?)
4. **Can I defer it?** (request only when feature used, not at startup)

### Golden Rules:
- ✅ **Pickers > Permissions** (whenever possible)
- ✅ **Runtime > Manifest** (request when needed, not at install)
- ✅ **Explain > Demand** (show rationale before requesting)
- ✅ **Optional > Required** (graceful degradation)

---

## 🔧 Common Scenarios

### Scenario: User wants to share a log entry

**❌ Bad Approach:**
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```
```dart
// Write to Downloads folder, requires permission
final file = File('/storage/emulated/0/Download/log.json');
await file.writeAsString(data);
```

**✅ Good Approach (Already Implemented!):**
```dart
// Use share_plus - no permission needed
await Share.shareXFiles([XFile.fromData(data, mimeType: 'application/json')]);

// Or use file_picker with SAF
final path = await FilePicker.platform.saveFile();
if (path != null) await File(path).writeAsString(data);
```

---

### Scenario: User wants to add a tank photo

**❌ Bad Approach:**
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```
```dart
// Old approach
final camera = await availableCameras();
final image = await Navigator.push(context, CameraRoute(camera.first));
```

**✅ Good Approach (Already Implemented!):**
```dart
// Modern approach - no permissions!
final image = await ImagePicker().pickImage(source: ImageSource.camera);
// This opens camera through photo picker - no permission needed!
```

---

### Scenario: User wants to export all data as CSV

**❌ Bad Approach:**
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

**✅ Good Approach:**
```dart
// Option 1: Share (no permission)
await Share.shareXFiles([XFile.fromData(csvData, mimeType: 'text/csv')]);

// Option 2: SAF save dialog (no permission)
final path = await FilePicker.platform.saveFile(
  fileName: 'aquarium-data.csv',
  type: FileType.custom,
  allowedExtensions: ['csv'],
);
if (path != null) await File(path).writeAsString(csvData);
```

---

## 🧪 Testing Checklist Before Adding a Permission

Before you add ANY permission to `AndroidManifest.xml`, verify:

- [ ] Searched for Android 13+ alternative (system pickers, SAF, etc.)
- [ ] Checked if existing plugins handle it permission-free
- [ ] Googled "[feature] android no permission" for modern approach
- [ ] Read Android docs for that permission's recommended alternatives
- [ ] Confirmed plugin's AndroidManifest (it might auto-add permissions!)
- [ ] Have clear justification for Play Store reviewers
- [ ] Implemented runtime request with error handling
- [ ] App works gracefully if permission denied
- [ ] Tested on Android 13+ device

**If ANY checkbox is unchecked → DON'T ADD THE PERMISSION YET!**

---

## 📚 Useful Resources

### Official Android Docs:
- [Photo Picker](https://developer.android.com/training/data-storage/shared/photopicker)
- [Storage Access Framework](https://developer.android.com/guide/topics/providers/document-provider)
- [Permissions Best Practices](https://developer.android.com/training/permissions/requesting)
- [Request App Permissions](https://developer.android.com/training/permissions/requesting)

### Flutter Plugins (Permission-Friendly):
- `image_picker` - Photos/camera (no permissions!)
- `file_picker` - File access (no permissions!)
- `share_plus` - Sharing (no permissions!)
- `path_provider` - App storage (no permissions!)
- `url_launcher` - Open URLs (no permissions!)

### Plugins That Add Permissions (Use Carefully):
- `camera` - Adds CAMERA permission
- `location` - Adds location permissions
- `contacts_service` - Adds contacts permissions
- `geolocator` - Adds location permissions
- Any plugin with "permission" in the name!

---

## 🎯 Permission Hygiene Checklist

### Monthly Review:
- [ ] Open `build/app/intermediates/merged_manifests/debug/AndroidManifest.xml`
- [ ] Count `<uses-permission>` tags
- [ ] Verify each permission is still necessary
- [ ] Check if new plugin added permissions without you knowing
- [ ] Run: `adb shell dumpsys package com.tiarnanlarkin.aquarium.aquarium_app | grep permission`
- [ ] Compare with `PERMISSIONS-REFERENCE.md` (this file!)

### Before Every Release:
- [ ] Verify permission count didn't increase
- [ ] Test permission denial flows still work
- [ ] Update Play Store justifications if permissions changed
- [ ] Check plugin changelogs for new permission requirements

---

## 🚨 Red Flags (Review Before Merging!)

### Code Review Triggers:

If you see this in a PR/commit:
```xml
<uses-permission android:name="android.permission.XXXX"/>
```

**STOP and verify:**
1. Why is this needed?
2. Did we try system pickers/SAF first?
3. Is there a Flutter plugin that avoids this?
4. How do we handle denial gracefully?
5. What's the Play Store justification?

### Dependency Review:

When adding a new plugin:
```bash
# Before: `flutter pub add some_plugin`
# Do this first:

# 1. Check the plugin's example AndroidManifest
curl https://raw.githubusercontent.com/[plugin]/example/android/app/src/main/AndroidManifest.xml

# 2. Check permissions in plugin's AndroidManifest
curl https://raw.githubusercontent.com/[plugin]/android/src/main/AndroidManifest.xml

# 3. Read plugin docs for permission requirements
# 4. Look for "permission" in plugin's README
```

---

## 💡 Quick Wins for Privacy Marketing

### User-Facing Benefits of Our Approach:

```
Our app respects your privacy:
✅ No camera permission needed
✅ No storage permissions needed  
✅ No location tracking
✅ No account required
✅ No cloud upload
✅ Works completely offline
✅ Your data stays on your device

We achieve this through modern Android APIs that give YOU control.
```

### App Store Bullets:
- 🔒 Privacy-first: Minimal permissions
- 📱 Offline-first: No internet needed
- 🎯 Transparent: See exactly what we access
- ✨ Modern: Uses latest Android privacy features

---

## 🎓 Teaching Moment: Why Modern APIs Matter

### Old Way (Android 6-9):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```
- App could access ALL photos
- App could access camera anytime
- Users had to grant broad access or nothing
- Privacy nightmare for users

### New Way (Android 10+):
```dart
ImagePicker().pickImage(source: ImageSource.camera);
```
- App only gets selected photos
- System controls camera access
- Scoped, temporary access
- User trust increases

**This is why our app has only 1 dangerous permission while competitors have 3-5!**

---

## 📞 When in Doubt

Before adding a permission, ask:
1. "Would I trust an app that requests this?"
2. "How would I explain this to a skeptical user?"
3. "Would Play Store reviewers approve this?"
4. "Is there an Android 13+ way that avoids this?"

If ANY answer is "no" or "unsure" → Research more before proceeding!

---

**Last Updated:** 2025-05-22  
**Current Permission Count:** 3 (1 dangerous)  
**Target:** Keep it minimal! 🎯
