# Release Build Instructions - Aquarium Hobbyist App

**Status:** ⚠️ Release AAB build configuration complete, but build from WSL timing out

## ✅ What's Already Done

1. **Release Keystore Created**
   - Location: `android/app/aquarium-release.jks`
   - Alias: `aquarium`
   - Valid for 10,000 days

2. **Signing Configuration Complete**
   - `android/key.properties` created with credentials
   - `android/app/build.gradle.kts` configured with release signing
   - Keystore passwords: See `KEYSTORE_INFO.txt` (SECURE THIS FILE!)

3. **Version Updated**
   - Changed from `0.1.0+1` to `1.0.0+1` in `pubspec.yaml`

4. **Build Configuration**
   - Java 21 compatibility configured
   - Gradle 8.14
   - Kotlin configured properly

## 🚧 Issue: WSL Build Timeout

**Problem:** Building release AAB from WSL is taking 10+ minutes (Gradle daemon running but slow)

**Solution:** Build from Windows PowerShell instead (faster, environment already set up)

## 🪟 **RECOMMENDED: Build from Windows PowerShell**

### Step 1: Open PowerShell in Project Directory

```powershell
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"
```

### Step 2: Set Java Home (if needed)

```powershell
$env:JAVA_HOME="C:\Program Files\Android\Android Studio\jbr"
```

### Step 3: Build Release AAB

```powershell
flutter build appbundle --release
```

**Expected output location:**
```
build\app\outputs\bundle\release\app-release.aab
```

### Step 4: Verify AAB

```powershell
# Check file size (should be 20-50 MB)
Get-ChildItem "build\app\outputs\bundle\release\app-release.aab"

# Check it's signed
# Upload to Play Console will verify signature
```

## 📦 What the AAB Contains

- **App Name:** Aquarium Hobbyist
- **Package:** com.tiarnanlarkin.aquarium.aquarium_app
- **Version:** 1.0.0 (version code 1)
- **Signed:** Yes (with aquarium-release.jks)
- **Minification:** Disabled for v1.0 (can enable later)

## 🔐 Important Security Notes

1. **NEVER commit these files to git:**
   - `android/key.properties`
   - `android/app/aquarium-release.jks`
   - `KEYSTORE_INFO.txt`

2. **Backup the keystore!**
   - Store `aquarium-release.jks` in a secure location
   - You MUST use this exact keystore for all future updates
   - Losing it means you can't update the app!

3. **Keep passwords secure**
   - Store `KEYSTORE_INFO.txt` securely
   - Don't share passwords

## 🐛 Troubleshooting

### "Keystore file not found"
- Ensure you're in the correct directory
- Check `android/key.properties` has correct path

### "Invalid keystore format"
- The keystore is valid (JKS format)
- Ensure you're using the correct passwords from `KEYSTORE_INFO.txt`

### "Gradle build failed"
- Try: `flutter clean` then rebuild
- Ensure Android SDK is installed
- Check JAVA_HOME is set correctly

## ✅ Next Steps After Build

1. **Upload to Play Console**
   - Go to https://play.google.com/console
   - Create new app
   - Upload the AAB file

2. **Fill in Store Listing**
   - Use content from `STORE_LISTING_CONTENT.md`
   - Upload screenshots from `screenshots/` folder
   - Use privacy policy from `privacy-policy.md`

3. **Submit for Review**
   - Complete content rating questionnaire
   - Submit for review (takes 1-3 days)

## 📊 Build Stats

When successful, expect:
- Build time: 1-3 minutes (Windows) vs 10+ minutes (WSL)
- AAB size: ~30-40 MB
- Debug symbols: Included

---

**Created:** 2026-02-07  
**Issue:** WSL build timeout after 11+ minutes  
**Resolution:** Build from Windows PowerShell (much faster)
