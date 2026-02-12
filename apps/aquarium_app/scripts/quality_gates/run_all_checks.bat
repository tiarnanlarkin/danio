@echo off
REM ============================================
REM Aquarium App - Quality Gate Checks (Windows)
REM ============================================
REM Runs all quality checks before merge/deploy
REM Exit codes: 0 = all pass, 1 = failure
REM ============================================

setlocal EnableDelayedExpansion

set MAX_APK_SIZE_MB=100
set PASSED=0
set FAILED=0

REM Get script directory and project root
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%\..\.."
set "PROJECT_ROOT=%cd%"

echo.
echo 🔍 Running Quality Gate Checks...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo    Project: %PROJECT_ROOT%
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

REM ============================================
REM 1. Flutter Analyze
REM ============================================
echo Running Flutter Analyze...
flutter analyze > temp_analyze.txt 2>&1
set ANALYZE_EXIT=%ERRORLEVEL%

findstr /C:"No issues found" temp_analyze.txt >nul
if %ERRORLEVEL% equ 0 (
    echo ✅ Flutter Analyze: PASS ^(0 errors^)
    set /a PASSED+=1
) else (
    echo ❌ Flutter Analyze: FAIL
    type temp_analyze.txt
    set /a FAILED+=1
)
del temp_analyze.txt 2>nul

REM ============================================
REM 2. Dart Format Check
REM ============================================
echo Running Dart Format Check...
flutter format --set-exit-if-changed --dry-run lib test > temp_format.txt 2>&1
set FORMAT_EXIT=%ERRORLEVEL%

if %FORMAT_EXIT% equ 0 (
    echo ✅ Dart Format: PASS ^(100%% compliant^)
    set /a PASSED+=1
) else (
    echo ❌ Dart Format: FAIL ^(files need formatting^)
    type temp_format.txt
    set /a FAILED+=1
)
del temp_format.txt 2>nul

REM ============================================
REM 3. Flutter Tests
REM ============================================
echo Running Flutter Tests...
flutter test > temp_test.txt 2>&1
set TEST_EXIT=%ERRORLEVEL%

if %TEST_EXIT% equ 0 (
    echo ✅ Flutter Test: PASS ^(all tests passed^)
    set /a PASSED+=1
) else (
    echo ❌ Flutter Test: FAIL
    type temp_test.txt
    set /a FAILED+=1
)
del temp_test.txt 2>nul

REM ============================================
REM 4. APK Size Check
REM ============================================
echo Checking APK Size...
set "APK_PATH=%PROJECT_ROOT%\build\app\outputs\flutter-apk\app-release.apk"
set "APK_DEBUG_PATH=%PROJECT_ROOT%\build\app\outputs\flutter-apk\app-debug.apk"

if exist "%APK_PATH%" (
    set "APK_FILE=%APK_PATH%"
    set "APK_TYPE=release"
) else if exist "%APK_DEBUG_PATH%" (
    set "APK_FILE=%APK_DEBUG_PATH%"
    set "APK_TYPE=debug"
) else (
    set "APK_FILE="
)

if defined APK_FILE (
    for %%A in ("%APK_FILE%") do set APK_SIZE_BYTES=%%~zA
    set /a APK_SIZE_MB=!APK_SIZE_BYTES! / 1024 / 1024
    
    if !APK_SIZE_MB! lss %MAX_APK_SIZE_MB% (
        echo ✅ APK Size: PASS ^(!APK_SIZE_MB!MB ^< %MAX_APK_SIZE_MB%MB^) [!APK_TYPE!]
        set /a PASSED+=1
    ) else (
        echo ❌ APK Size: FAIL ^(!APK_SIZE_MB!MB ^>= %MAX_APK_SIZE_MB%MB^)
        set /a FAILED+=1
    )
) else (
    echo ⚠️  APK Size: SKIP ^(no APK found - run flutter build apk first^)
)

REM ============================================
REM Summary
REM ============================================
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo QUALITY GATE RESULTS
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if %FAILED% equ 0 (
    echo.
    echo 🎉 ALL CHECKS PASSED
    echo.
    exit /b 0
) else (
    echo.
    echo 💥 %FAILED% CHECK^(S^) FAILED
    echo.
    exit /b 1
)
