# Danio — Android Build Guide

> Last updated: Wave D (March 2026)

---

## Prerequisites

- Flutter SDK installed at `C:\Users\larki\flutter\`
- Android SDK + NDK (see `android/app/build.gradle.kts` for NDK version)
- Keystore file at `android/app/aquarium-release.jks`
- `android/key.properties` present and correctly populated (see below)

---

## Key Paths

| Item | Path |
|------|------|
| App root | `apps/aquarium_app/` |
| Android build config | `android/app/build.gradle.kts` |
| Keystore file | `android/app/aquarium-release.jks` |
| Key properties | `android/key.properties` *(gitignored — never commit)* |
| AAB output | `build/app/outputs/bundle/release/app-release.aab` |
| APK output | `build/app/outputs/apk/release/app-release.apk` |

---

## key.properties Format

```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=aquarium
storeFile=aquarium-release.jks
```

> ⚠️ **Never commit `key.properties` or `*.jks` to source control.**
> Both are `.gitignore`d. Keep secure backups of the keystore file — if lost, you cannot update the app on Play Store.

---

## Building a Release AAB (Play Store)

Play Store requires AAB format since August 2021. Always use AAB for production uploads.

```bash
cd apps/aquarium_app
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

> ℹ️ ABI splits are **disabled** in `build.gradle.kts` for AAB builds. Play Store handles per-device ABI delivery automatically via the AAB format. Do not re-enable `splits { abi { isEnable = true } }` when targeting AAB — it causes a Gradle build failure.

---

## Building a Release APK (Sideloading / Testing)

```bash
cd apps/aquarium_app
flutter build apk --release
```

Output: `build/app/outputs/apk/release/app-release.apk`

If you need per-ABI split APKs (smaller file sizes for direct distribution), temporarily set `isEnable = true` in the `splits { abi { ... } }` block of `build.gradle.kts` and rebuild. **Revert before building AAB.**

---

## Version Bumping

Version is controlled in `pubspec.yaml`:

```yaml
version: 1.0.0+1
#         ^^^^^  ← versionName (shown to users)
#               ^ ← versionCode (must increment for every Play Store upload)
```

**Rules:**
- `versionCode` (the `+N` integer) **must be incremented** for every Play Store submission — even hotfixes.
- `versionName` (the `X.Y.Z` string) is what users see. Follow semantic versioning: `MAJOR.MINOR.PATCH`.

Example: `version: 1.1.0+5` → versionName = `1.1.0`, versionCode = `5`

These values are read by `build.gradle.kts` via `flutter.versionCode` and `flutter.versionName`.

---

## What NOT to Include in Release Builds

### ❌ Do NOT pass `--dart-define` API keys at build time

```bash
# WRONG — never do this for release builds
flutter build appbundle --release --dart-define=SUPABASE_KEY=abc123

# WHY: --dart-define values are embedded in the compiled binary and can be
# extracted with reverse engineering tools. API keys in production AABs are
# not safe from extraction.
```

### ✅ Correct approach for production secrets

- Supabase URL and anon key: these are **public by design** (Row-Level Security enforces access). Use your standard `.env` or `dart_defines` approach, but understand they are not truly secret.
- Any truly sensitive secrets (admin keys, private APIs): **must not be in the client app at all** — route through a backend/Cloud Function.

---

## Debug Symbols Warning

After building, Flutter may report:

```
Release app bundle failed to strip debug symbols from native libraries.
```

This is a **non-fatal warning** caused by NDK symbol stripping on Windows WSL. The AAB is still valid and uploadable to Play Store. To suppress it properly, ensure `flutter doctor` shows no Android toolchain issues.

---

## Signing Verification

The release signing config is in `build.gradle.kts`:

```kotlin
signingConfigs {
    create("release") {
        if (keystorePropertiesFile.exists()) {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }
}
```

The `storeFile` path resolves relative to the `android/app/` directory.

---

## ProGuard / R8 Minification

Enabled in release builds:

```kotlin
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

If you encounter runtime crashes in release builds that don't appear in debug, check `android/app/proguard-rules.pro` — you may need to add `-keep` rules for reflection-heavy libraries.
