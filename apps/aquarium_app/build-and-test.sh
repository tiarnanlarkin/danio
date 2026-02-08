#!/bin/bash
# Automated build and test script for Aquarium App
# Works from WSL - proven successful!

set -e  # Exit on error

APP_DIR="/mnt/c/Users/larki/Documents/Aquarium App Dev/repo/apps/aquarium_app"
FLUTTER="/home/tiarnanlarkin/flutter/bin/flutter"
ADB="/mnt/c/Users/larki/AppData/Local/Android/Sdk/platform-tools/adb.exe"
PACKAGE="com.tiarnanlarkin.aquarium.aquarium_app"

echo "🔨 Building APK..."
cd "$APP_DIR"
$FLUTTER build apk --debug

echo "📱 Installing APK..."
$ADB install -r "C:\\Users\\larki\\Documents\\Aquarium App Dev\\repo\\apps\\aquarium_app\\build\\app\\outputs\\flutter-apk\\app-debug.apk"

echo "🚀 Launching app..."
$ADB shell monkey -p $PACKAGE -c android.intent.category.LAUNCHER 1

echo "⏳ Waiting for app to load..."
sleep 3

echo "📸 Taking screenshot..."
$ADB exec-out screencap -p > /tmp/aquarium-app-screenshot.png

echo "✅ Build, install, and test complete!"
echo "📷 Screenshot saved to: /tmp/aquarium-app-screenshot.png"
