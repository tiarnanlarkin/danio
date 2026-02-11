# Privacy Policy for Aquarium Hobbyist

**Last Updated:** February 6, 2025

## Introduction

Aquarium Hobbyist ("we", "our", or "the app") is committed to protecting your privacy. This Privacy Policy explains how we handle your information when you use our Android application.

**The short version:** We don't collect, transmit, or store any of your data on external servers. Everything stays on your device.

## Information Collection and Storage

### What Data Does the App Store?

Aquarium Hobbyist stores the following information **locally on your device only**:

- **Tank Information:** Tank names, sizes, types, and setup dates
- **Livestock Data:** Fish species, quantities, and addition dates
- **Equipment Records:** Filter types, heater settings, lighting schedules
- **Water Test Logs:** pH, ammonia, nitrite, nitrate, and other parameter readings
- **Maintenance Logs:** Water changes, filter cleanings, and other maintenance activities
- **Photos:** Images you add to your tanks (stored in app's local directory)
- **Reminders:** Notification schedules for maintenance tasks
- **App Settings:** Your preferences for units, themes, and notifications

### How Is Data Stored?

All data is stored in:
- **JSON files** in the app's private storage directory
- **Local database** for efficient querying
- **Device's photo directory** for images (only if you choose to add photos)

**No cloud storage. No remote servers. No external databases.**

## Data We Do NOT Collect

We do **not** collect, transmit, or have access to:

- ❌ Personal identification information
- ❌ Email addresses or phone numbers
- ❌ Location data
- ❌ Usage analytics or statistics
- ❌ Device information
- ❌ Crash reports
- ❌ Advertising identifiers

## Third-Party Services

Aquarium Hobbyist v1.0 does **not** use any third-party services that collect data, including:

- ❌ No analytics services (Google Analytics, Firebase, etc.)
- ❌ No advertising networks
- ❌ No cloud sync services
- ❌ No social media integrations
- ❌ No crash reporting services

### Android Permissions Used

The app requests the following permissions for local functionality only:

1. **Notifications** (`POST_NOTIFICATIONS`)
   - **Purpose:** To send you reminders about water changes and maintenance tasks
   - **Library:** `flutter_local_notifications` (local only, no external communication)

2. **Storage/Photos** (`READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`)
   - **Purpose:** To let you add photos to your tanks and create/restore backups
   - **Libraries:** `image_picker` and `file_picker` (local file access only)

**None of these permissions are used to transmit data off your device.**

## Your Data Rights

Since all data is stored locally on your device, **you have complete control**:

### ✅ Access
View all your data anytime within the app.

### ✅ Export
Use the **Backup** feature to export all data to a JSON file you can save anywhere.

### ✅ Delete
- Delete individual items within the app
- Clear all data via the app settings
- Uninstall the app to remove all data permanently

### ✅ Portability
Backup files are in standard JSON format, making your data portable and readable.

## Data Security

Your data security is inherent in our design:

- **Local storage only:** Data never leaves your device
- **No network transmission:** The app does not communicate with external servers
- **Android security:** Protected by your device's security (lock screen, encryption)
- **No account system:** No passwords to leak, no accounts to compromise

### Backup Security

When you create a backup:
- **You choose where to save it** (device storage, SD card, cloud service via your file manager)
- **If you share a backup file with someone, they can read your data**
- We recommend storing backups securely and not sharing them publicly

## Children's Privacy

Aquarium Hobbyist does not collect any personal information from anyone, including children under 13. The app can be safely used by hobbyists of all ages.

## Changes to This Policy

If we add features that involve data collection in future versions:
- We will update this policy
- We will notify you within the app
- We will always prioritize your privacy

**Current version (1.0):** No data collection, fully local storage.

## Open Source Transparency

The libraries we use are open source and privacy-respecting:

- **flutter_local_notifications:** Local notification scheduling (no external servers)
- **image_picker:** Access device camera/gallery (local only)
- **file_picker:** File selection dialog (local only)

You can verify that these libraries do not collect or transmit data by reviewing their public source code.

## Play Store Data Safety

In accordance with Google Play Store's Data Safety requirements, we declare:

- **Data collection:** None
- **Data sharing:** None
- **Data security practices:** Not applicable (no data collected)
- **App functionality:** Fully functional without data collection

## Contact Information

If you have questions about this Privacy Policy or data practices:

**Email:** tiarnan.larkin@gmail.com

**Response Time:** We aim to respond within 7 business days.

## Your Consent

By using Aquarium Hobbyist, you agree to this Privacy Policy. Since we don't collect your data, your privacy is protected by default.

---

## Summary (TL;DR)

✅ **All data stored locally on your device**  
✅ **No internet connection required**  
✅ **No analytics, ads, or tracking**  
✅ **You own and control your data**  
✅ **Export backups anytime**  
✅ **Delete data anytime**  

**We built this app for the aquarium community, by hobbyists who value privacy.**

---

**Aquarium Hobbyist v1.0**  
Package: `com.tiarnanlarkin.aquarium.aquarium_app`  
Developer: Tiarnan Larkin
