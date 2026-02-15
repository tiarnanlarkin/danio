# Release Build Guide - Aquarium App

## Quick Release Build

```bash
# Navigate to project
cd "C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app"

# Build release AAB (App Bundle)
flutter build appbundle --release

# Output location
# build/app/outputs/bundle/release/app-release.aab
```

**Expected output:** `app-release.aab` (~58MB)

---

## Build Configuration

### R8/ProGuard Optimization
**File:** `android/app/build.gradle.kts`

Release build automatically includes:
- ✅ Code minification (R8)
- ✅ Resource shrinking
- ✅ ProGuard obfuscation
- ✅ Dead code elimination

### ProGuard Rules
**File:** `android/app/proguard-rules.pro`

Configured to preserve:
- Flutter framework classes
- Plugin interfaces
- App data models
- Play Core services

---

## Testing Release Build Locally

### Method 1: Using bundletool (Recommended)

```bash
# Install bundletool (one-time)
# Download from: https://github.com/google/bundletool/releases

# Generate APKs from AAB
bundletool build-apks \
  --bundle=build/app/outputs/bundle/release/app-release.aab \
  --output=app.apks \
  --mode=universal

# Install on connected device
bundletool install-apks --apks=app.apks
```

### Method 2: Build Universal APK

```bash
# Build standalone APK for testing
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Note:** Universal APK will be larger (~58MB) than Play Store downloads (40-50MB)

---

## Play Store Upload

### Preparation

1. **Verify signing:**
   - Keystore: `android/app/aquarium-release.jks`
   - Config: `android/key.properties`
   - Ensure credentials are correct

2. **Version bump:**
   ```yaml
   # pubspec.yaml
   version: 1.0.0+1  # Update before each release
   ```

3. **Build release AAB:**
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```

### Upload Steps

1. Go to [Google Play Console](https://play.google.com/console)
2. Select "Aquarium App"
3. Navigate to **Release** → **Testing** (or Production)
4. Create new release
5. Upload `build/app/outputs/bundle/release/app-release.aab`
6. Add release notes
7. Review and rollout

---

## Size Optimization Summary

**Current optimization level:** Maximum

| Optimization | Status | Impact |
|--------------|--------|--------|
| R8 Minification | ✅ Enabled | ~40% code reduction |
| Resource Shrinking | ✅ Enabled | ~20% asset reduction |
| Font Tree-Shaking | ✅ Automatic | 97.7% icon font reduction |
| Native Symbol Stripping | ✅ Automatic | Default Flutter behavior |
| AAB Format | ✅ Used | 20-30% Play Store download reduction |

**Result:** 209MB debug → 58.4MB release AAB (72% reduction)

---

## Known Issues & Workarounds

### Issue: integration_test Plugin Conflict

**Symptom:**
```
error: package dev.flutter.plugins.integration_test does not exist
```

**Workaround:**
If building release fails with this error, temporarily comment out integration_test:

```yaml
# pubspec.yaml
dev_dependencies:
  # integration_test:
  #   sdk: flutter
```

Then rebuild. **Remember to re-enable for development!**

---

## Build Troubleshooting

### Build Fails: "Compilation failed"

**Solution:**
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### Build Fails: "Keystore not found"

**Check:**
- `android/key.properties` exists
- `android/app/aquarium-release.jks` exists
- Paths in key.properties are correct

### Build Succeeds but AAB is Too Large

**Verify:**
- R8 minification is enabled (check build.gradle.kts)
- Resource shrinking is enabled
- No debug symbols included (release mode)

Expected size: 55-60MB

---

## Performance Validation

After installing release build, verify:

1. **App startup:** <2 seconds on mid-range device
2. **Memory usage:** <150MB for typical session
3. **Animations:** Smooth 60fps Rive playback
4. **Network:** API calls function correctly
5. **Offline mode:** Works without network
6. **Data persistence:** Tank data saves/loads correctly

---

## CI/CD Integration (Future)

```yaml
# Example GitHub Actions workflow
name: Build Release AAB
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build appbundle --release
      - uses: actions/upload-artifact@v3
        with:
          name: release-aab
          path: build/app/outputs/bundle/release/app-release.aab
```

---

## Version Management

**Semantic versioning:** `MAJOR.MINOR.PATCH+BUILD`

```yaml
# pubspec.yaml
version: 1.0.0+1
#        │ │ │  └─ Build number (auto-increment)
#        │ │ └──── Patch (bug fixes)
#        │ └────── Minor (new features)
#        └──────── Major (breaking changes)
```

**Example progression:**
- `1.0.0+1` - Initial release
- `1.0.1+2` - Bug fix release
- `1.1.0+3` - New feature release
- `2.0.0+4` - Major update

---

## File Checklist

Before each release build:

- [ ] Version bumped in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated
- [ ] All tests passing (`flutter test`)
- [ ] No debug code or print statements
- [ ] Keystore and credentials available
- [ ] Release notes prepared
- [ ] Privacy policy updated (if needed)

---

## Contact & Support

**Repository:** `C:\Users\larki\Documents\Aquarium App Dev\repo`  
**Documentation:** `docs/`  
**Build issues:** Check `docs/completed/PHASE_1.2_APK_OPTIMIZATION_COMPLETE.md`

---

**Last updated:** February 15, 2025  
**Build system:** Flutter 3.38.9 + Gradle 8.7 + R8
