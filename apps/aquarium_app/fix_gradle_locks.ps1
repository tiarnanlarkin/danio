# Fix Gradle Lock Issues - Run from PowerShell (Windows)
# This script clears Gradle caches and locks to fix build issues

Write-Host "🔧 Fixing Gradle Build Lock Issues..." -ForegroundColor Cyan
Write-Host ""

# Stop any running Gradle daemons
Write-Host "1. Stopping Gradle daemons..." -ForegroundColor Yellow
& .\android\gradlew.bat --stop
Start-Sleep -Seconds 2

# Clean Flutter build cache
Write-Host ""
Write-Host "2. Running flutter clean..." -ForegroundColor Yellow
flutter clean

# Remove Gradle cache directory
Write-Host ""
Write-Host "3. Removing Gradle cache..." -ForegroundColor Yellow
$gradleCache = "android\.gradle"
if (Test-Path $gradleCache) {
    Remove-Item -Recurse -Force $gradleCache
    Write-Host "   ✓ Removed $gradleCache" -ForegroundColor Green
} else {
    Write-Host "   • Cache directory not found (already clean)" -ForegroundColor Gray
}

# Clear build directory
Write-Host ""
Write-Host "4. Clearing build directory..." -ForegroundColor Yellow
$buildDir = "build"
if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
    Write-Host "   ✓ Removed $buildDir" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Gradle locks cleared!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run: flutter build apk --debug" -ForegroundColor White
Write-Host "  2. If successful, continue ListView migrations" -ForegroundColor White
Write-Host ""
Write-Host "📝 See SUBAGENT-SUMMARY-1.3c.md for migration details" -ForegroundColor Gray
