# Build Instructions for Aquarium App

## Quick Build (Easiest Method)

**Just double-click:** `build-debug.bat`

This will:
- Build the debug APK
- Show you the output location
- Pause so you can see any errors

The APK will be at:
```
build\app\outputs\flutter-apk\app-debug.apk
```

---

## Manual Build Options

### Option 1: Flutter Command (Recommended)
```cmd
flutter build apk --debug
```

### Option 2: Gradle Direct
```cmd
cd android
.\gradlew.bat assembleDebug
```

### Option 3: Android Studio
1. Open project in Android Studio
2. Click Run (green play button)
3. Select your device/emulator

---

## Troubleshooting

### "JAVA_HOME not set" Error

If you see this error, you need to install Java:

1. **Check if Java is installed:**
   ```cmd
   java -version
   ```

2. **If not installed, download JDK:**
   - Download from: https://www.oracle.com/java/technologies/downloads/
   - Or use Android Studio's bundled JDK (see below)

3. **Set JAVA_HOME (if using installed JDK):**
   ```cmd
   set JAVA_HOME=C:\Program Files\Java\jdk-17
   ```

4. **Or use Android Studio's JDK:**
   ```cmd
   set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
   ```

### "Flutter not found" Error

Make sure Flutter is in your PATH:
```cmd
set PATH=%PATH%;C:\Users\larki\flutter\bin
```

### Android SDK Issues

Make sure `local.properties` in the `android` folder contains:
```properties
sdk.dir=C:\\Users\\larki\\AppData\\Local\\Android\\Sdk
```

---

## Building from WSL (Advanced)

WSL doesn't have Java configured. Use Windows methods above instead.

To enable WSL builds (not recommended):
1. Install OpenJDK in WSL: `sudo apt install openjdk-17-jdk`
2. Set JAVA_HOME: `export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64`
3. Build: `cd android && ./gradlew assembleDebug`

But Windows builds are easier and better supported!

---

## After Building

Install on device/emulator:
```cmd
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

Or just use `flutter run` to build + install + launch in one command!
