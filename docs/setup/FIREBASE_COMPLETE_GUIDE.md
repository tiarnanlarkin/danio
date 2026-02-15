# Firebase Complete Implementation Guide

## Overview
This guide walks you through setting up Firebase Analytics, Crashlytics, and Performance Monitoring for the Aquarium App.

**Current Status:** All code infrastructure is in place, **waiting for Firebase configuration files**.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Console Setup](#firebase-console-setup)
3. [Configuration Files](#configuration-files)
4. [Activate Dependencies](#activate-dependencies)
5. [Platform-Specific Setup](#platform-specific-setup)
6. [Testing](#testing)
7. [Monitoring](#monitoring)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- [ ] Google account
- [ ] Firebase Console access (https://console.firebase.google.com)
- [ ] Flutter SDK installed
- [ ] Android Studio / Xcode installed (for respective platforms)
- [ ] Git access to this repository

---

## Firebase Console Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Add project"**
3. **Project name:** `Aquarium App`
4. **Enable Google Analytics:** ✅ Yes (recommended)
5. **Analytics account:** Create new or select existing
6. **Analytics location:** Choose your region
7. Click **"Create project"**
8. Wait for project to be created (~30 seconds)

### Step 2: Add Android App

1. In Firebase project, click **"Add app"** → **Android**
2. **Android package name:** `com.tiarnanlarkin.aquarium.aquarium_app`
   - ⚠️ Must match exactly (check `android/app/build.gradle`)
3. **App nickname:** "Aquarium App Android" (optional)
4. **Debug signing certificate SHA-1:** (optional for now, needed for Auth later)
5. Click **"Register app"**
6. **Download `google-services.json`**
7. Place file in: `apps/aquarium_app/android/app/google-services.json`
8. Click **"Next"** → **"Next"** → **"Continue to console"**

### Step 3: Add iOS App

1. In Firebase project, click **"Add app"** → **iOS**
2. **iOS bundle ID:** `com.tiarnanlarkin.aquarium.aquariumApp`
   - ⚠️ Must match exactly (check `ios/Runner/Info.plist`)
3. **App nickname:** "Aquarium App iOS" (optional)
4. Click **"Register app"**
5. **Download `GoogleService-Info.plist`**
6. Place file in: `apps/aquarium_app/ios/Runner/GoogleService-Info.plist`
7. Click **"Next"** → **"Next"** → **"Continue to console"**

### Step 4: Enable Services

#### Enable Crashlytics
1. In Firebase Console → **Build** → **Crashlytics**
2. Click **"Enable Crashlytics"**
3. Accept terms
4. Wait for service to activate

#### Enable Performance Monitoring
1. In Firebase Console → **Build** → **Performance**
2. Click **"Get started"**
3. Service will auto-enable

#### Verify Analytics
1. In Firebase Console → **Analytics** → **Dashboard**
2. Should see "Waiting for data..." (data appears after first app run)

---

## Configuration Files

### Android: google-services.json

**Location:** `apps/aquarium_app/android/app/google-services.json`

**Example structure:**
```json
{
  "project_info": {
    "project_number": "123456789012",
    "project_id": "aquarium-app-xyz",
    "storage_bucket": "aquarium-app-xyz.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789012:android:abcdef...",
        "android_client_info": {
          "package_name": "com.tiarnanlarkin.aquarium.aquarium_app"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "AIzaSy..."
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": []
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

### iOS: GoogleService-Info.plist

**Location:** `apps/aquarium_app/ios/Runner/GoogleService-Info.plist`

This is a binary plist file downloaded from Firebase Console. Contains:
- CLIENT_ID
- REVERSED_CLIENT_ID
- API_KEY
- GCM_SENDER_ID
- BUNDLE_ID
- PROJECT_ID
- GOOGLE_APP_ID
- etc.

⚠️ **Do not manually edit** this file - always download fresh from Firebase Console.

---

## Activate Dependencies

### Step 1: Uncomment Dependencies in pubspec.yaml

Open `apps/aquarium_app/pubspec.yaml` and uncomment Firebase packages:

```yaml
dependencies:
  # Firebase (configuration pending - see docs/setup/FIREBASE_SETUP_GUIDE.md)
  firebase_core: ^2.24.2           # ← Uncomment this line
  firebase_analytics: ^10.7.4      # ← Uncomment this line
  firebase_crashlytics: ^3.4.9     # ← Uncomment this line
  firebase_performance: ^0.9.3+6   # ← Uncomment this line
```

### Step 2: Run Flutter Pub Get

```bash
cd "/path/to/repo/apps/aquarium_app"
flutter pub get
```

### Step 3: Uncomment Firebase Initialization in main.dart

Open `lib/main.dart` and uncomment these sections:

#### Import statements (top of file):
```dart
// Firebase imports (uncomment when Firebase is configured)
import 'package:firebase_core/firebase_core.dart';            // ← Uncomment
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // ← Uncomment
import 'dart:async';                                          // ← Uncomment
```

```dart
import 'services/firebase_analytics_service.dart';  // ← Uncomment
```

#### In main() function:
```dart
// Initialize Firebase
await Firebase.initializeApp();  // ← Uncomment

// Initialize Firebase Crashlytics
FlutterError.onError = (errorDetails) {  // ← Uncomment entire block
  FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
};

PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};

// Send to Firebase Crashlytics when enabled
FirebaseCrashlytics.instance.recordError(error, stack);  // ← Uncomment (inside onError callback)

// Initialize Firebase Analytics
await FirebaseAnalyticsService().initialize();  // ← Uncomment
```

#### In MaterialApp:
```dart
// Add Firebase Analytics observer when configured
navigatorObservers: [                      // ← Uncomment entire block
  FirebaseAnalyticsService().observer,
],
```

### Step 4: Uncomment Analytics Calls in Screens

Search for `FirebaseAnalyticsService` in screen files and uncomment the calls.

**Example - in any screen with analytics:**
```dart
@override
void initState() {
  super.initState();
  FirebaseAnalyticsService().logScreenView('home');  // ← Uncomment
}
```

**Screens to update** (10-15 key screens):
- `lib/screens/home/home_screen.dart`
- `lib/screens/tank_detail/tank_detail_screen.dart`
- `lib/screens/create_tank_screen.dart`
- `lib/screens/learn_screen.dart`
- `lib/screens/achievements_screen.dart`
- `lib/screens/settings_screen.dart`
- `lib/screens/enhanced_quiz_screen.dart`
- `lib/screens/lesson_detail_screen.dart` (if exists)
- `lib/screens/search_screen.dart`
- `lib/screens/onboarding_screen.dart`
- etc.

---

## Platform-Specific Setup

### Android Configuration

#### 1. Update `android/build.gradle` (project-level)

Add Google services classpath:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0'
        // Add these lines:
        classpath 'com.google.gms:google-services:4.4.0'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
    }
}
```

#### 2. Update `android/app/build.gradle`

Add plugins at the **bottom** of the file:

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

android {
    // ... existing config ...
}

dependencies {
    // ... existing dependencies ...
}

// Add these lines at the BOTTOM:
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
```

#### 3. Verify Package Name

In `android/app/build.gradle`, confirm:
```gradle
android {
    defaultConfig {
        applicationId "com.tiarnanlarkin.aquarium.aquarium_app"  // Must match Firebase
    }
}
```

### iOS Configuration

#### 1. Update `ios/Podfile`

Ensure minimum iOS version:
```ruby
platform :ios, '13.0'  # Firebase requires iOS 13+
```

#### 2. Add GoogleService-Info.plist to Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Right-click `Runner` folder → **Add Files to "Runner"**
3. Select `GoogleService-Info.plist`
4. ✅ Ensure **"Copy items if needed"** is checked
5. ✅ Ensure **"Add to targets: Runner"** is checked
6. Click **"Add"**

#### 3. Verify Bundle ID

In Xcode, select `Runner` target → **General** tab:
- **Bundle Identifier:** `com.tiarnanlarkin.aquarium.aquariumApp`  
  (Must match Firebase exactly)

#### 4. Install Pods

```bash
cd ios
pod install
cd ..
```

---

## Testing

### Test Analytics (Debug Mode)

#### Enable Debug View in Firebase Console
1. Firebase Console → **Analytics** → **DebugView**
2. Wait for page to load

#### Enable Debug Mode on Device

**Android:**
```bash
adb shell setprop debug.firebase.analytics.app com.tiarnanlarkin.aquarium.aquarium_app
```

**iOS:**
In Xcode, add argument to scheme:
1. Product → Scheme → Edit Scheme
2. Run → Arguments → Add: `-FIRDebugEnabled`

#### Temporarily Enable Analytics in Debug

In `lib/services/firebase_analytics_service.dart`, comment out the debug check:

```dart
Future<void> initialize() async {
  _analytics = FirebaseAnalytics.instance;
  _observer = FirebaseAnalyticsObserver(analytics: _analytics);
  
  // if (kDebugMode) {  // ← Comment these lines temporarily
  //   await _analytics.setAnalyticsCollectionEnabled(false);
  //   debugPrint('Firebase Analytics disabled in debug mode');
  // }
}
```

#### Run App and Verify

1. Run app in debug mode
2. Navigate through screens
3. Check Firebase Console → Analytics → DebugView
4. You should see events appear in real-time

**⚠️ Remember to uncomment the debug check after testing!**

---

### Test Crashlytics

#### Force a Test Crash

Add a test crash button in settings/debug menu:

```dart
ElevatedButton(
  onPressed: () {
    FirebaseCrashlytics.instance.crash();  // This will crash the app
  },
  child: const Text('Test Crash'),
),
```

Or test a non-fatal error:
```dart
try {
  throw Exception('Test exception for Crashlytics');
} catch (error, stackTrace) {
  FirebaseCrashlytics.instance.recordError(error, stackTrace);
}
```

#### Verify in Console

1. Trigger crash/error
2. Restart app
3. Firebase Console → **Build** → **Crashlytics**
4. Wait 5-10 minutes for crash to appear
5. Crash should appear in dashboard

---

### Test Performance Monitoring

Performance monitoring is automatic once enabled.

#### Verify in Console

1. Run app and use it normally
2. Firebase Console → **Build** → **Performance**
3. Wait 15-30 minutes for data
4. Should see:
   - App start time
   - Screen rendering metrics
   - Network requests (if using Firebase libraries)

---

## Monitoring

### Analytics Dashboard

**Key Metrics to Watch:**
- Daily Active Users (DAU)
- Session duration
- Screen views (most popular screens)
- Custom events (lessons completed, tanks created, etc.)
- User retention (1-day, 7-day, 30-day)

**Location:** Firebase Console → **Analytics** → **Dashboard**

### Crashlytics Dashboard

**What to Monitor:**
- Crash-free users percentage (goal: >99%)
- Top crashes by count
- New vs recurring crashes
- Crashes by device/OS version

**Location:** Firebase Console → **Build** → **Crashlytics**

**Best Practice:** Check daily, fix critical crashes immediately.

### Performance Dashboard

**What to Monitor:**
- App start time (goal: <3 seconds)
- Screen rendering (60 FPS)
- Slow frames
- Frozen frames

**Location:** Firebase Console → **Build** → **Performance**

---

## Troubleshooting

### Common Issues

#### 1. "google-services.json not found"

**Cause:** File not in correct location  
**Fix:** Ensure file is in `android/app/google-services.json` (not `android/`)

#### 2. "GoogleService-Info.plist not found"

**Cause:** File not added to Xcode project  
**Fix:** Add file through Xcode (see iOS setup above)

#### 3. "Package name mismatch"

**Cause:** Package name in Firebase doesn't match app  
**Fix:** 
- Check `android/app/build.gradle` → `applicationId`
- Check `ios/Runner/Info.plist` → `CFBundleIdentifier`
- Must match Firebase exactly

#### 4. Analytics not appearing in console

**Possible causes:**
- Debug mode disabled analytics (check `firebase_analytics_service.dart`)
- Not enough time passed (wait 24 hours for production data)
- Events not being logged (check implementation)
- Wrong project selected in console

**Fix:** Enable DebugView and test in debug mode

#### 5. Crashlytics not showing crashes

**Possible causes:**
- App needs to restart after crash for upload
- Crash happened in debug mode (some crashes don't upload)
- Crashlytics not initialized properly

**Fix:** 
- Test with release build: `flutter build apk --release`
- Ensure `Firebase.initializeApp()` runs before crash

#### 6. Build fails after adding Firebase

**Possible causes:**
- Missing google-services plugin
- Gradle version mismatch
- Kotlin version mismatch

**Fix:**
- Check all build.gradle files updated correctly
- Run `flutter clean` then rebuild
- Update Gradle wrapper if needed

---

## Security Best Practices

### Protecting Configuration Files

#### Public Repository
If repo is public, **never commit** configuration files:

Add to `.gitignore`:
```gitignore
# Firebase config files
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

#### Private Repository
Safe to commit if repo is private and team-only.

### Environment-Specific Configs

For staging/production separation:

1. Create separate Firebase projects:
   - `aquarium-app-dev`
   - `aquarium-app-staging`
   - `aquarium-app-production`

2. Use build flavors (advanced):
   ```
   android/app/src/
     ├── dev/google-services.json
     ├── staging/google-services.json
     └── production/google-services.json
   ```

---

## Production Checklist

Before releasing to production:

- [ ] Firebase project created
- [ ] Android app registered with correct package name
- [ ] iOS app registered with correct bundle ID
- [ ] `google-services.json` in place and tested
- [ ] `GoogleService-Info.plist` in place and tested
- [ ] Firebase dependencies uncommented in `pubspec.yaml`
- [ ] Firebase initialization uncommented in `main.dart`
- [ ] Analytics observer added to MaterialApp
- [ ] Analytics calls uncommented in 10-15 key screens
- [ ] Crashlytics tested with test crash
- [ ] Analytics tested in DebugView
- [ ] Debug mode check re-enabled in `firebase_analytics_service.dart`
- [ ] Build succeeds on both Android and iOS
- [ ] Release build tested
- [ ] Analytics appearing in Firebase Console
- [ ] Crashlytics active and monitoring
- [ ] Performance monitoring active
- [ ] User consent mechanism implemented (GDPR)
- [ ] Privacy policy updated to mention analytics
- [ ] Team trained on Firebase Console

---

## Additional Resources

### Official Documentation
- [FlutterFire Overview](https://firebase.flutter.dev/)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Firebase Performance](https://firebase.google.com/docs/perf-mon)

### Related Docs in This Project
- [FIREBASE_SETUP_GUIDE.md](./FIREBASE_SETUP_GUIDE.md) - Quick setup reference
- [ANALYTICS_EVENTS.md](./ANALYTICS_EVENTS.md) - All analytics events documented

### Support
- [Firebase Support](https://firebase.google.com/support)
- [FlutterFire GitHub Issues](https://github.com/firebase/flutterfire/issues)
- [Stack Overflow - Firebase](https://stackoverflow.com/questions/tagged/firebase)

---

## Maintenance

### Regular Tasks

**Daily:**
- Check Crashlytics for new crashes
- Review critical errors

**Weekly:**
- Review analytics dashboard
- Check user retention trends
- Identify popular/unused features

**Monthly:**
- Review performance metrics
- Analyze user behavior patterns
- Update analytics events as needed
- Clean up old/unused events

**Quarterly:**
- Audit user properties
- Review and optimize event tracking
- Update this documentation with learnings

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2024-02-14 | Initial setup guide created |

---

**Questions?** Contact the development team or refer to official Firebase documentation.
