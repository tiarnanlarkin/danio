# Build Release AAB for Aquarium App
# Runs from Windows PowerShell (3-5x faster than WSL)

Write-Host "🚀 Building Aquarium App Release AAB..." -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "❌ Error: Must run from app root directory" -ForegroundColor Red
    Write-Host "Expected: C:\Users\larki\Documents\Aquarium App Dev\repo\apps\aquarium_app" -ForegroundColor Yellow
    exit 1
}

# Check if Flutter is available
try {
    flutter --version | Out-Null
} catch {
    Write-Host "❌ Error: Flutter not found in PATH" -ForegroundColor Red
    Write-Host "Add Flutter to your system PATH or use full path" -ForegroundColor Yellow
    exit 1
}

# Clean previous build
Write-Host "🧹 Cleaning previous build..." -ForegroundColor Yellow
flutter clean

# Get dependencies
Write-Host "📦 Getting dependencies..." -ForegroundColor Yellow
flutter pub get

# Build release AAB
Write-Host "🔨 Building release AAB (this takes 2-4 minutes)..." -ForegroundColor Yellow
$startTime = Get-Date
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    $duration = (Get-Date) - $startTime
    $minutes = [math]::Floor($duration.TotalMinutes)
    $seconds = $duration.Seconds
    
    Write-Host ""
    Write-Host "✅ Build successful! ($minutes min $seconds sec)" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 AAB Location:" -ForegroundColor Cyan
    Write-Host "   build\app\outputs\bundle\release\app-release.aab" -ForegroundColor White
    Write-Host ""
    
    # Check file size
    $aabPath = "build\app\outputs\bundle\release\app-release.aab"
    if (Test-Path $aabPath) {
        $sizeMB = [math]::Round((Get-Item $aabPath).Length / 1MB, 2)
        Write-Host "📊 File size: $sizeMB MB" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "🎯 Next steps:" -ForegroundColor Yellow
        Write-Host "   1. Upload to Play Console" -ForegroundColor White
        Write-Host "   2. Fill out store listing" -ForegroundColor White
        Write-Host "   3. Submit for review" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "❌ Build failed. Check errors above." -ForegroundColor Red
    exit 1
}
