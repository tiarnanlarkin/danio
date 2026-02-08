# Play Store Permissions Checklist - Aquarium Hobbyist App

Use this checklist when filling out the Play Console submission forms.

---

## ✅ Permissions Declaration

### App uses the following permissions:

- [x] `android.permission.INTERNET` (Normal - auto-granted)
- [x] `android.permission.VIBRATE` (Normal - auto-granted)
- [x] `android.permission.POST_NOTIFICATIONS` (Dangerous - runtime permission)

### Sensitive permissions NOT used:

- [x] ~~Camera~~ (Not requested - uses photo picker instead)
- [x] ~~Location~~ (Not used)
- [x] ~~Contacts~~ (Not used)
- [x] ~~Phone~~ (Not used)
- [x] ~~SMS~~ (Not used)
- [x] ~~Storage (Read/Write)~~ (Not requested - uses SAF instead)
- [x] ~~Microphone~~ (Not used)
- [x] ~~Calendar~~ (Not used)

---

## 📝 Data Safety Form

### Section 1: Data Collection

**Does your app collect or share any of the required user data types?**
- ✅ **NO**

All data is stored locally on the user's device. No data is:
- Transmitted to servers
- Shared with third parties
- Synchronized to cloud
- Used for analytics or advertising

---

### Section 2: Security Practices

**Is all of the user data collected by your app encrypted in transit?**
- ✅ **Not applicable** (no data transmitted)

**Do you provide a way for users to request that their data is deleted?**
- ✅ **YES**
- Method: "Clear All Data" button in Settings, or uninstall app

---

### Section 3: Data Retention

**How long do you retain user data?**
- Until user deletes it (local storage only)
- Data deleted when app uninstalled

---

## 🔔 Permission Justifications

When Play Console asks "Why does your app need this permission?", use these answers:

### POST_NOTIFICATIONS

**Question:** Why does your app request POST_NOTIFICATIONS permission?

**Answer:**
```
This permission is essential for the app's core task reminder functionality. 
Users schedule maintenance tasks such as water changes, filter cleaning, and 
water testing, then receive timely notifications when these tasks are due. 
This helps aquarium hobbyists maintain a healthy environment for their fish 
by ensuring critical maintenance is not forgotten.

The permission is requested only when the user explicitly enables the 
"Notifications" feature in Settings. The app remains fully functional if 
the user chooses to deny this permission - they can manually check their 
task schedule within the app.

Implementation follows Android best practices:
- Runtime permission request (Android 13+)
- Clear user consent (toggle in Settings)
- Graceful degradation if denied
- No forced permission requests
```

---

### INTERNET

**Question:** Why does your app request INTERNET permission?

**Answer:**
```
The INTERNET permission is currently used for development and debugging 
purposes (Flutter hot reload). In production, the app functions fully offline 
with all data stored locally on the device.

This permission is retained to enable potential future features that users 
may request, such as:
- Optional cloud backup/restore
- Online species database updates
- Community features

All such features would be opt-in and clearly communicated to users before 
implementation. Currently, no user data is transmitted over the network.
```

---

### VIBRATE

**Question:** Why does your app request VIBRATE permission?

**Answer:**
```
Vibration provides haptic feedback when maintenance reminder notifications 
are delivered, ensuring users notice important aquarium care tasks even when 
their device is in silent mode or pocket. This permission is automatically 
granted by Android and enhances the notification experience for time-sensitive 
tasks like water quality testing or feeding reminders.
```

---

## 📱 App Description Mentions

### Store Listing Description

Include these permission-related benefits in your Play Store description:

```
✨ PRIVACY-FRIENDLY DESIGN ✨

• No account required - your data stays on your device
• No internet connection needed - works completely offline
• No cloud storage - full control of your aquarium data
• Optional notifications - remind yourself of maintenance tasks
• Modern photo picker - add fish photos without granting storage permissions
```

### Privacy Highlights

```
🔒 YOUR DATA, YOUR DEVICE

Unlike other aquarium apps, we use modern Android APIs that require 
minimal permissions:
• Add photos without camera permission (uses system photo picker)
• Backup/restore without storage permission (uses file picker)
• Only one permission requires your approval: notifications (optional!)
```

---

## 🧪 Pre-Submission Testing

### Test on Android 13+ Device:

- [ ] Install fresh copy of app
- [ ] Navigate to Settings
- [ ] Toggle "Enable Notifications" → System permission dialog appears
- [ ] Tap "Allow" → Notifications enabled, snackbar confirms
- [ ] Uninstall and reinstall
- [ ] Toggle "Enable Notifications" → System permission dialog appears
- [ ] Tap "Don't Allow" → Snackbar shows "Notification permission denied"
- [ ] Verify app still functions (manual task checking)
- [ ] Toggle again → Permission dialog reappears (can retry)

### Test Photo Picker:

- [ ] Go to Logs screen
- [ ] Tap "Add Log"
- [ ] Tap "Add Photo" button
- [ ] Verify system photo picker appears (NOT a permission dialog)
- [ ] Select a photo
- [ ] Verify photo appears in log
- [ ] NO camera or storage permission requested

### Test File Picker:

- [ ] Go to Settings
- [ ] Tap "Backup Data" (creates backup)
- [ ] Tap "Restore Data"
- [ ] Verify file picker appears (NOT a permission dialog)
- [ ] Select backup file
- [ ] Verify data restored
- [ ] NO storage permission requested

---

## 📸 Screenshots for Play Store

### Recommended Screenshots Showing Permissions:

**Screenshot 1: Settings - Notifications Toggle**
- Shows the clean, user-friendly notification toggle
- Demonstrates opt-in approach
- Caption: "Optional notifications - you're in control"

**Screenshot 2: Photo Picker**
- Shows system photo picker UI (NOT app UI)
- Demonstrates privacy-friendly photo selection
- Caption: "Add photos without granting storage permissions"

**Screenshot 3: Task Notifications**
- Shows a notification in Android notification shade
- Demonstrates the feature users get with permission
- Caption: "Never miss a water change with timely reminders"

---

## 🚨 Common Play Store Rejection Reasons

### Will NOT apply to your app:

- ✅ Requesting camera permission without clear justification → **Not using camera permission**
- ✅ Requesting storage permissions unnecessarily → **Not using storage permissions**
- ✅ Not handling permission denials → **Proper error handling implemented**
- ✅ Forcing users to grant permissions → **Optional, user-initiated**
- ✅ Unclear privacy policy → **No data collection = simple policy**

### Potential questions (easy to answer):

- ⚠️ "Why do you need INTERNET if app works offline?"
  - Answer: Development + future opt-in features (cloud backup)
  
- ⚠️ "How do you handle notification permission denial?"
  - Answer: App works fully, user can check tasks manually

---

## 📋 Privacy Policy Requirements

### Minimal Privacy Policy Template

Since you collect no data, your privacy policy can be very simple:

```markdown
# Privacy Policy - Aquarium Hobbyist App

**Last Updated:** [Date]

## Data Collection
This app does NOT collect, transmit, or share any user data.

## Data Storage
All aquarium data (tanks, fish, logs, tasks) is stored locally on your device.
We have no access to your data.

## Permissions
- **Notifications:** Optional. Used only for maintenance task reminders.
- **Vibration:** Provides haptic feedback for notifications.
- **Internet:** Used for development. No production network usage currently.

## Third-Party Services
This app does not use any third-party analytics, advertising, or tracking services.

## Data Deletion
Your data is deleted when you:
- Use "Clear All Data" in Settings
- Uninstall the app

## Contact
Questions? Email: [your-email@example.com]
```

---

## ✅ Final Pre-Submission Checklist

- [ ] Permissions list matches actual manifest (INTERNET, VIBRATE, POST_NOTIFICATIONS)
- [ ] Data Safety form completed (NO data collection)
- [ ] Permission justifications prepared (copy from above)
- [ ] Privacy policy published (URL required by Play Store)
- [ ] Tested on Android 13+ device
- [ ] Tested permission denial flow
- [ ] Screenshots prepared
- [ ] Store description mentions privacy benefits
- [ ] App version and package name correct

---

## 🎯 Expected Review Time

- **Permissions risk:** 🟢 LOW (minimal, well-justified)
- **Privacy risk:** 🟢 LOW (no data collection)
- **Expected review time:** 1-3 days (typical for low-risk apps)
- **Rejection likelihood:** 🟢 Very Low

---

## 📞 If Reviewer Has Questions

### Prepared Responses:

**Q: "Why do you need INTERNET permission if app is offline?"**

A: The INTERNET permission is used for Flutter development tools (hot reload, debugging). In production, the app currently operates fully offline with all data stored locally. The permission is retained to enable optional future features like cloud backup or species database updates, which would be opt-in and clearly communicated to users. No user data is currently transmitted.

**Q: "How do you access photos without READ_EXTERNAL_STORAGE permission?"**

A: We use the modern Photo Picker API (AndroidX Activity Result API with PickVisualMedia contract) introduced in Android 13 and backported to earlier versions via Google Play Services. This allows users to select photos through the system picker without granting broad storage access. It's the recommended approach in Android's official documentation and provides better privacy than legacy permissions.

**Q: "How does backup/restore work without WRITE_EXTERNAL_STORAGE?"**

A: We use the Storage Access Framework (SAF) with ACTION_CREATE_DOCUMENT and ACTION_OPEN_DOCUMENT intents. Users explicitly choose where to save backups and which file to restore through the system file picker. The app only receives scoped access to the specific file the user selects, following Android's scoped storage best practices.

---

**Document Version:** 1.0  
**For Play Store Submission:** Aquarium Hobbyist v0.1.0+1  
**Ready to Submit:** ✅ YES
