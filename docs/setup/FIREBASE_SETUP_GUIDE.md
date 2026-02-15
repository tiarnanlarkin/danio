# Firebase Setup Guide

## Prerequisites
- Firebase account (https://console.firebase.google.com)
- Google account

## Steps

### 1. Create Firebase Project
1. Go to Firebase Console
2. Click "Add project"
3. Name: "Aquarium App"
4. Enable Google Analytics
5. Create project

### 2. Add Android App
1. Click "Add app" → Android
2. Package name: `com.tiarnanlarkin.aquarium.aquarium_app`
3. Download `google-services.json`
4. Place in: `apps/aquarium_app/android/app/`

### 3. Add iOS App
1. Click "Add app" → iOS
2. Bundle ID: `com.tiarnanlarkin.aquarium.aquariumApp`
3. Download `GoogleService-Info.plist`
4. Place in: `apps/aquarium_app/ios/Runner/`

### 4. Enable Services
- **Analytics**: Auto-enabled
- **Crashlytics**: Enable in Console → Build → Crashlytics
- **Performance**: Enable in Console → Build → Performance Monitoring

## Configuration Files Needed

### android/app/google-services.json
```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "aquarium-app",
    "storage_bucket": "aquarium-app.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "YOUR_ANDROID_APP_ID",
        "android_client_info": {
          "package_name": "com.tiarnanlarkin.aquarium.aquarium_app"
        }
      },
      "oauth_client": [],
      "api_key": [
        {
          "current_key": "YOUR_API_KEY"
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

### ios/Runner/GoogleService-Info.plist
This file is downloaded from Firebase Console when you add the iOS app. It contains:
- CLIENT_ID
- REVERSED_CLIENT_ID
- API_KEY
- GCM_SENDER_ID
- PLIST_VERSION
- BUNDLE_ID
- PROJECT_ID
- STORAGE_BUCKET
- IS_ADS_ENABLED
- IS_ANALYTICS_ENABLED
- IS_APPINVITE_ENABLED
- IS_GCM_ENABLED
- IS_SIGNIN_ENABLED
- GOOGLE_APP_ID

## Activate Firebase Dependencies

Once configuration files are in place:

1. **Uncomment Firebase dependencies** in `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_analytics: ^10.7.4
  firebase_crashlytics: ^3.4.9
  firebase_performance: ^0.9.3+6
```

2. **Run pub get**:
```bash
flutter pub get
```

3. **Uncomment Firebase initialization** in `lib/main.dart`:
   - Firebase.initializeApp()
   - Crashlytics error handlers
   - AnalyticsService().initialize()
   - Navigator observers

4. **Uncomment analytics calls** in screen files (search for "AnalyticsService")

## Android Configuration

### Update android/build.gradle (project-level)
Add Google services classpath:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.9.9'
    }
}
```

### Update android/app/build.gradle
Add plugins at the bottom:
```gradle
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
```

## iOS Configuration

### Update ios/Podfile
Ensure minimum iOS version is 13.0+:
```ruby
platform :ios, '13.0'
```

### Run pod install
```bash
cd ios
pod install
```

## Testing

### Test Analytics (Debug Mode)
Analytics is disabled in debug mode by default (see `analytics_service.dart`).
To test:
1. Set `kDebugMode` check to false temporarily
2. Run app
3. Check Firebase Console → Analytics → DebugView

### Test Crashlytics
```dart
// Add test crash button in debug menu
FirebaseCrashlytics.instance.crash();
```

### Test Performance
Performance monitoring is automatic once enabled.
Check Firebase Console → Performance for metrics.

## Production Checklist

- [ ] Firebase project created
- [ ] Android app registered
- [ ] iOS app registered
- [ ] google-services.json in place
- [ ] GoogleService-Info.plist in place
- [ ] Firebase dependencies uncommented
- [ ] Main.dart initialization uncommented
- [ ] Analytics calls uncommented in screens
- [ ] Gradle plugins configured
- [ ] Tested in debug mode
- [ ] Crashlytics tested
- [ ] Analytics verified in Firebase Console

## Security

- **Never commit** `google-services.json` or `GoogleService-Info.plist` to public repos
- Add to `.gitignore` if repo is public
- Use environment-specific configs for staging/production

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com)
