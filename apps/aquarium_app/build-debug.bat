@echo off
REM Quick build script for Aquarium App (Debug APK)
cd /d "%~dp0"
echo Building Aquarium App (Debug)...
echo.

REM Use Flutter build
flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo Build successful!
    echo APK location:
    echo %CD%\build\app\outputs\flutter-apk\app-debug.apk
    echo ============================================
    pause
) else (
    echo.
    echo ============================================
    echo Build failed! Check errors above.
    echo ============================================
    pause
    exit /b 1
)
