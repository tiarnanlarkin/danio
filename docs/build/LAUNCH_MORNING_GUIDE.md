# 🚀 Launch Morning Build Guide
**Date:** 2026-02-16  
**Goal:** Build release AAB and submit to Play Store

## Pre-Flight Checklist ✅

Before building, verify these in WSL or PowerShell:

```powershell
# 1. Navigate to project
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"

# 2. Check git status (should be clean)
git status

# 3. Verify version number
# Check pubspec.yaml - should match what you want in Play Store
type pubspec.yaml | findstr "version:"

# 4. Verify keystore exists
dir "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app\android\app\aquarium-release-keystore.jks"
```

Expected version in pubspec.yaml: `version: 1.0.0+1`

---

## Build Release AAB (PowerShell)

### Step 1: Clean Build
```powershell
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get
```

### Step 2: Build AAB
```powershell
# Build release AAB (signed automatically via gradle config)
flutter build appbundle --release
```

**Expected output location:**
```
C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app\build\app\outputs\bundle\release\app-release.aab
```

### Step 3: Verify AAB
```powershell
# Check file exists and size (should be 20-40 MB typically)
dir "build\app\outputs\bundle\release\app-release.aab"
```

**What to look for:**
- File exists ✅
- Size is reasonable (not 0 bytes, not 500+ MB)
- File date is today

---

## Upload to Play Console

### Step 1: Navigate to Play Console
1. Go to: https://play.google.com/console
2. Sign in with your Google account
3. Select "Aquarium Hobby Helper" app (or create new app if first time)

### Step 2: Create Release
1. Navigate to: **Production** → **Create new release**
2. Upload AAB: Click "Upload" button
3. Select: `app-release.aab` from build folder
4. Wait for upload (1-5 min depending on internet)

### Step 3: Complete Release Info
**Release name:** `1.0.0` (matches version in pubspec.yaml)

**Release notes (English - en-US):**
```
Welcome to Aquarium Hobby Helper! 🐠

• Complete aquarium management toolkit
• Water parameter tracking and testing guides
• Fish compatibility checker
• Beginner-friendly learning modules
• Beautiful UI with aquarium themes

This is our initial release. We'd love your feedback!
```

### Step 4: Review and Rollout
1. Click "Review release"
2. Check for any warnings (address if critical)
3. Click "Start rollout to Production"
4. Confirm rollout

---

## Pre-Submission Checklist

Before clicking "Start rollout," verify:

- [ ] App icon looks good in preview
- [ ] Screenshots uploaded (7 screenshots ready)
- [ ] Store listing complete:
  - [ ] Short description (80 chars)
  - [ ] Full description
  - [ ] Feature graphic (1024x500)
- [ ] Privacy policy URL added
- [ ] Content rating complete
- [ ] Pricing set (Free)
- [ ] Countries selected (start with a few, expand later)

---

## Post-Submission

**Review time:** Typically 1-3 days (sometimes faster)

**What happens:**
1. Google reviews app for policy compliance
2. You'll get email when approved or if changes needed
3. Once approved, app goes live automatically

**Monitoring:**
- Check Play Console daily for review status
- Watch for user reviews once live
- Monitor crash reports in Firebase (if configured)

---

## Common Issues & Fixes

### Issue: "Upload failed - duplicate version code"
**Fix:** Increment version code in `android/app/build.gradle`
```gradle
versionCode = 2  // was 1
```

### Issue: "Keystore not found"
**Fix:** Verify keystore path in `android/key.properties`:
```properties
storeFile=C:/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app/android/app/aquarium-release-keystore.jks
```

### Issue: "Build failed - dependency error"
**Fix:** Try:
```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

### Issue: "AAB too large (>150 MB)"
**Fix:** Enable app bundle optimizations in `android/app/build.gradle`:
```gradle
android {
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
}
```

---

## Quick Reference Commands

```powershell
# Navigate to project
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"

# Clean build
flutter clean && flutter pub get

# Build release AAB
flutter build appbundle --release

# Check AAB location
dir "build\app\outputs\bundle\release\app-release.aab"

# Check version
type pubspec.yaml | findstr "version:"
```

---

## Success Indicators

✅ Build completes without errors  
✅ AAB file exists in expected location  
✅ Upload to Play Console successful  
✅ No critical warnings in review  
✅ Release submitted for review

**Once submitted, you're done!** Google will email you with review results.

---

## Need Help?

If anything goes wrong:
1. Check error message carefully
2. Try `flutter clean` and rebuild
3. Verify keystore path in key.properties
4. Check build.gradle for correct signing config
5. Ask me (Molt) for help - paste the exact error

**You've got this!** The app is ready. This is just the mechanical part. 🚀
