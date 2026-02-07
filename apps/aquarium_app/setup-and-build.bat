@echo off
REM Setup and build script for Aquarium App
REM This will check for Java and guide you through setup if needed

cd /d "%~dp0"
echo ============================================
echo Aquarium App - Setup and Build
echo ============================================
echo.

REM Check if Java is available
echo [1/3] Checking for Java...
java -version >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✓ Java found!
    java -version
) else (
    echo ✗ Java not found!
    echo.
    echo You need Java to build Android apps.
    echo.
    echo Options:
    echo   1. Use Android Studio's built-in Java:
    echo      set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
    echo.
    echo   2. Download and install JDK 17+:
    echo      https://www.oracle.com/java/technologies/downloads/
    echo.
    echo After installing Java, run this script again.
    pause
    exit /b 1
)

echo.
echo [2/3] Checking for Flutter...
where flutter >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✓ Flutter found!
    flutter --version | findstr "Flutter"
) else (
    echo ✗ Flutter not found!
    echo.
    echo Make sure Flutter is in your PATH:
    echo   set PATH=%%PATH%%;C:\Users\larki\flutter\bin
    echo.
    pause
    exit /b 1
)

echo.
echo [3/3] Building debug APK...
echo.
flutter build apk --debug

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo ✓ Build successful!
    echo ============================================
    echo.
    echo Your APK is ready at:
    echo %CD%\build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo To install on your device:
    echo   adb install -r build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo Or just run:
    echo   flutter run
    echo.
) else (
    echo.
    echo ============================================
    echo ✗ Build failed!
    echo ============================================
    echo.
    echo Check the errors above and try:
    echo   1. flutter clean
    echo   2. flutter pub get
    echo   3. Try building again
    echo.
)

pause
