# Aquarium App - Release Build Configuration Summary

**Date:** February 7, 2025  
**Version:** 1.0.0+1  
**Package:** com.tiarnanlarkin.aquarium.aquarium_app

---

## ✅ Completed Tasks

### 1. Release Keystore Generation
- **Location:** `android/app/aquarium-release.jks`
- **Algorithm:** RSA 2048-bit
- **Validity:** 10,000 days (~27 years)
- **Alias:** `aquarium`
- **Certificate:** CN=Tiarnan Larkin, OU=Development, O=Aquarium App, L=Dublin, ST=Leinster, C=IE
- **Status:** ✅ Generated successfully
- **Credentials:** Saved to `/mnt/c/Users/larki/Documents/Aquarium App Dev/KEYSTORE_INFO.txt`

### 2. Key Properties File
- **Location:** `android/key.properties`
- **Purpose:** Stores signing credentials for Gradle build
- **Contents:**
  ```properties
  storePassword=<stored securely>
  keyPassword=<stored securely>
  keyAlias=aquarium
  storeFile=aquarium-release.jks
  ```
- **Status:** ✅ Created and configured
- **Git Status:** ✅ Added to .gitignore

### 3. Build Configuration Updates

#### android/app/build.gradle.kts
- ✅ Added keystore properties loader
- ✅ Configured `signingConfigs.release` block
- ✅ Updated `buildTypes.release` to use release signing
- ✅ Enabled code shrinking and obfuscation:
  - `isMinifyEnabled = true`
  - `isShrinkResources = true`
  - ProGuard rules configured

#### android/app/proguard-rules.pro
- ✅ Created ProGuard configuration
- Keeps Flutter framework classes
- Preserves Gson serialization (if needed)
- Protects app-specific classes

#### android/gradle.properties
- ✅ Set Java home: `org.gradle.java.home=C:\\Program Files\\Android\\openjdk\\jdk-21.0.8`

#### android/local.properties
- ✅ Updated SDK path to Windows format: `C:\\Users\\larki\\AppData\\Local\\Android\\Sdk`

### 4. Version Update
- **File:** `pubspec.yaml`
- **Version:** Changed from `0.1.0+1` to `1.0.0+1`
- **Format:** `MAJOR.MINOR.PATCH+BUILD_NUMBER`
  - `1.0.0` = Version name (user-facing)
  - `1` = Version code (Play Store internal, must increment for each release)

### 5. Security Configuration
- **Updated .gitignore:**
  ```gitignore
  # Release signing (NEVER commit these!)
  android/key.properties
  android/app/*.jks
  android/app/*.keystore
  ```

---

## 🔄 In Progress

### 6. Release AAB Build
- **Command:** `flutter build appbundle --release`
- **Status:** 🔄 Building (Gradle 8.14 extraction in progress)
- **Expected Output:** `build/app/outputs/bundle/release/app-release.aab`

**Note:** First-time Gradle setup on WSL can take 10-15 minutes to download and extract Gradle distribution (~150MB).

---

## 📦 Release Build Process

### Future Builds (After Initial Setup)
```bash
cd "/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"

# Update version in pubspec.yaml first!
# Increment version code for each Play Store release

# Build release AAB
/home/tiarnanlarkin/flutter/bin/flutter build appbundle --release

# Output location
# build/app/outputs/bundle/release/app-release.aab
```

### Version Numbering Strategy
- **Major (X.0.0):** Breaking changes, major features
- **Minor (1.X.0):** New features, backwards compatible
- **Patch (1.0.X):** Bug fixes, minor improvements
- **Build (+X):** Must increment for every Play Store upload

**Example progression:**
- `1.0.0+1` → Initial release
- `1.0.1+2` → Bug fix
- `1.1.0+3` → New feature
- `2.0.0+4` → Major redesign

---

## 🔐 Security Checklist

- ✅ Keystore stored in `android/app/` (git-ignored)
- ✅ Key properties file created (git-ignored)
- ✅ Credentials saved to secure location
- ✅ .gitignore updated to exclude sensitive files
- ⚠️ **TODO:** Back up keystore to secure external location
- ⚠️ **TODO:** Store KEYSTORE_INFO.txt in password manager or encrypted storage

---

## 🚀 Play Store Submission Checklist

Before uploading AAB to Play Store:
- [ ] Test release build on physical device
- [ ] Verify app signing works (check signature)
- [ ] Complete Play Store listing (screenshots, description, etc.)
- [ ] Set up Play App Signing (recommended)
- [ ] Prepare privacy policy URL
- [ ] Complete content rating questionnaire
- [ ] Review app permissions and justifications

---

## 📝 Notes

- **JDK Version:** 21.0.8 (Android OpenJDK)
- **Gradle Version:** 8.14
- **Flutter SDK:** /home/tiarnanlarkin/flutter
- **Android SDK:** C:\\Users\\larki\\AppData\\Local\\Android\\Sdk
- **Build Environment:** WSL2 (Ubuntu) on Windows

---

## 🔧 Troubleshooting

### If build fails:
1. Check JAVA_HOME is set correctly in gradle.properties
2. Ensure key.properties exists and has correct paths
3. Verify keystore file exists at android/app/aquarium-release.jks
4. Clean build: `flutter clean && flutter pub get`

### If signing fails:
1. Verify keystore passwords in key.properties
2. Check keystore file permissions
3. Test keystore: `keytool -list -v -keystore android/app/aquarium-release.jks`

### Future Updates:
Always use the same keystore and credentials. If lost, you cannot update the app on Google Play Store!

---

**Generated:** February 7, 2025  
**Next Step:** Complete AAB build and test on device before Play Store submission
