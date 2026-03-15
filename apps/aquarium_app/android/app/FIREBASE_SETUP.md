# Firebase Setup — Danio

## What You Need To Do

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com/)
2. **Add an Android app** with package name: `com.tiarnanlarkin.danio`
3. **Download `google-services.json`** and place it in this directory:
   ```
   android/app/google-services.json
   ```
4. **Enable Crashlytics** in the Firebase console (Build → Crashlytics → Enable)
5. **Enable Analytics** in the Firebase console (it's usually on by default)

## Without `google-services.json`

The app **will still compile and run** — Firebase initialisation is wrapped in a
try/catch with graceful fallback. However:

- ❌ Crash reporting won't work
- ❌ Analytics events won't be recorded
- ❌ You'll see a warning in logcat: `Firebase init failed (app will run without it)`

## Files Changed for Firebase

- `pubspec.yaml` — `firebase_core`, `firebase_analytics`, `firebase_crashlytics`
- `android/settings.gradle.kts` — `com.google.gms.google-services` plugin
- `android/app/build.gradle.kts` — applied `google-services` plugin
- `lib/main.dart` — `Firebase.initializeApp()` + Crashlytics error handlers
- `lib/services/firebase_analytics_service.dart` — centralised analytics events
