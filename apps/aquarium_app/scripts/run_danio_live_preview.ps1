param(
  [string]$AvdName = "danio_api36",
  [string]$AppId = "com.tiarnanlarkin.danio",
  [string]$Target = "lib/main.dart",
  [string]$DeviceId = "",
  [switch]$UseLocalEnv,
  [string]$EnvFile = "",
  [switch]$LaunchEmulator,
  [switch]$CheckOnly,
  [int]$WaitSeconds = 90
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptsDir = Split-Path -Parent $ScriptPath
$AppRoot = Split-Path -Parent $ScriptsDir
$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $AppRoot "..\..")).Path

function Resolve-Tool {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [string[]]$FallbackPaths = @()
  )

  $command = Get-Command $Name -ErrorAction SilentlyContinue
  if ($command) {
    return $command.Source
  }

  foreach ($path in $FallbackPaths) {
    if ($path -and (Test-Path -LiteralPath $path)) {
      return (Resolve-Path -LiteralPath $path).Path
    }
  }

  throw "$Name was not found on PATH or in the expected local SDK paths."
}

function Resolve-LocalEnvFile {
  if ($EnvFile) {
    if ([System.IO.Path]::IsPathRooted($EnvFile)) {
      return $EnvFile
    }

    return (Join-Path $RepoRoot $EnvFile)
  }

  return (Join-Path $RepoRoot ".env.local")
}

function Assert-LocalEnvFileSafe {
  param([Parameter(Mandatory = $true)][string]$Path)

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "Local env file not found at '$Path'."
  }

  $hasOpenAiKey = $false
  foreach ($line in [System.IO.File]::ReadLines($Path)) {
    if ($line -match "^\s*OPENAI_API_KEY\s*=\s*(.+)\s*$") {
      $value = $Matches[1].Trim()
      if ($value -and $value -ne '""' -and $value -ne "''") {
        $hasOpenAiKey = $true
      }
      break
    }
  }

  if (-not $hasOpenAiKey) {
    throw "Local env file does not contain a non-empty OPENAI_API_KEY entry."
  }

  $resolvedPath = (Resolve-Path -LiteralPath $Path).Path
  $repoRootPrefix = $RepoRoot.TrimEnd("\", "/")
  if (-not $resolvedPath.StartsWith("$repoRootPrefix\", [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Local env file must stay inside the repo root."
  }
  $relativePath = $resolvedPath.Substring($repoRootPrefix.Length).TrimStart("\", "/")
  $relativePath = $relativePath -replace "\\", "/"

  & git -C $RepoRoot check-ignore -q -- $relativePath
  if ($LASTEXITCODE -ne 0) {
    throw "Local env file '$relativePath' is not git-ignored."
  }

  return $resolvedPath
}

function Resolve-EmulatorTool {
  $paths = @(
    (Join-Path $env:LOCALAPPDATA "Android\Sdk\emulator\emulator.exe"),
    (Join-Path $env:ANDROID_SDK_ROOT "emulator\emulator.exe"),
    (Join-Path $env:ANDROID_HOME "emulator\emulator.exe")
  )

  return Resolve-Tool -Name "emulator" -FallbackPaths $paths
}

$script:Flutter = Resolve-Tool -Name "flutter" -FallbackPaths @(
  (Join-Path $env:USERPROFILE "development\flutter\bin\flutter.bat")
)
$script:Adb = Resolve-Tool -Name "adb" -FallbackPaths @(
  (Join-Path $env:LOCALAPPDATA "Android\Sdk\platform-tools\adb.exe")
)
$script:Emulator = Resolve-EmulatorTool
Write-Host "Supported switches: -CheckOnly, -LaunchEmulator, -UseLocalEnv, -EnvFile, -WaitSeconds."

function Invoke-Adb {
  param(
    [string]$Serial = "",
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments
  )

  $base = @()
  if ($Serial) {
    $base += @("-s", $Serial)
  }

  $output = & $script:Adb @base @Arguments 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw "adb $($Arguments -join ' ') failed for '$Serial': $($output -join ' ')"
  }
  return $output
}

function Get-ReadyDevices {
  Write-Host "Checking adb devices..."
  $output = Invoke-Adb -Arguments @("devices")
  return @(
    $output |
      Select-Object -Skip 1 |
      Where-Object { $_ -match "^\S+\s+device$" } |
      ForEach-Object { ($_ -split "\s+")[0] }
  )
}

function Get-DeviceAvdName {
  param([Parameter(Mandatory = $true)][string]$Serial)

  Write-Host "Checking emu avd name for $Serial..."
  try {
    $output = Invoke-Adb -Serial $Serial -Arguments @("emu", "avd", "name")
    return (
      $output |
        Where-Object { $_ -and $_.Trim() -and $_.Trim() -ne "OK" } |
        Select-Object -First 1
    ).Trim()
  }
  catch {
    return ""
  }
}

function Get-ForegroundPackage {
  param([Parameter(Mandatory = $true)][string]$Serial)

  $window = (Invoke-Adb -Serial $Serial -Arguments @("shell", "dumpsys", "window")) -join "`n"
  if ($window -match "mCurrentFocus=Window\{[^ ]+ [^ ]+ ([^/ ]+)/") {
    return $Matches[1]
  }
  if ($window -match "mFocusedApp=ActivityRecord\{[^ ]+ [^ ]+ ([^/ ]+)/") {
    return $Matches[1]
  }
  return ""
}

function Assert-ForegroundSafe {
  param([Parameter(Mandatory = $true)][string]$Serial)

  try {
    $package = Get-ForegroundPackage -Serial $Serial
  }
  catch {
    if ($_.Exception.Message -match "Can't find service: window") {
      throw "Android window service is not ready on $Serial."
    }
    throw
  }

  $allowedSystemPackages = @(
    "",
    "android",
    "com.android.launcher3",
    "com.google.android.apps.nexuslauncher"
  )

  if ($package -eq $AppId -or $allowedSystemPackages -contains $package) {
    return $package
  }

  if ($package -match "^com\.android\.") {
    return $package
  }

  throw "Refusing to take over $Serial because foreground package is '$package'."
}

function Start-DanioEmulator {
  Write-Host "Starting Android emulator AVD '$AvdName' for visible Danio preview..."
  Start-Process -FilePath $script:Emulator -ArgumentList @("-avd", $AvdName)
}

function Resolve-DanioDevice {
  if ($DeviceId) {
    $devices = Get-ReadyDevices
    if ($devices -notcontains $DeviceId) {
      throw "Requested device '$DeviceId' is not listed as ready by adb devices."
    }
    $foreground = Assert-ForegroundSafe -Serial $DeviceId
    return [pscustomobject]@{
      Serial = $DeviceId
      Avd = Get-DeviceAvdName -Serial $DeviceId
      Foreground = $foreground
    }
  }

  $deadline = (Get-Date).AddSeconds($WaitSeconds)
  $started = $false
  do {
    $devices = Get-ReadyDevices
    $matches = @()
    foreach ($serial in $devices) {
      $deviceAvd = Get-DeviceAvdName -Serial $serial
      if ($deviceAvd -eq $AvdName) {
        $matches += [pscustomobject]@{
          Serial = $serial
          Avd = $deviceAvd
        }
      }
    }

    if ($matches.Count -eq 1) {
      try {
        $foreground = Assert-ForegroundSafe -Serial $matches[0].Serial
      }
      catch {
        if ($_.Exception.Message -match "Android window service is not ready") {
          Write-Host "$($_.Exception.Message) Waiting..."
          Start-Sleep -Seconds 2
          continue
        }
        throw
      }

      return [pscustomobject]@{
        Serial = $matches[0].Serial
        Avd = $matches[0].Avd
        Foreground = $foreground
      }
    }

    if ($matches.Count -gt 1) {
      throw "Multiple ready devices match AVD '$AvdName': $($matches.Serial -join ', '). Pass -DeviceId."
    }

    if (-not $LaunchEmulator) {
      throw "AVD '$AvdName' is not running. Start it or rerun with -LaunchEmulator."
    }

    if (-not $started) {
      Start-DanioEmulator
      $started = $true
    }

    Start-Sleep -Seconds 2
  } while ((Get-Date) -lt $deadline)

  throw "Timed out waiting for AVD '$AvdName' to become ready."
}

Push-Location -LiteralPath $AppRoot
try {
  $localEnvFile = ""
  if ($UseLocalEnv) {
    $localEnvFile = Assert-LocalEnvFileSafe -Path (Resolve-LocalEnvFile)
    Write-Host "Using git-ignored local env file for debug defines: $localEnvFile"
  }

  $device = Resolve-DanioDevice
  Write-Host "Danio live preview device: $($device.Serial)"
  Write-Host "AVD: $($device.Avd)"
  Write-Host "Foreground package: $($device.Foreground)"

  if ($CheckOnly) {
    Write-Host "CheckOnly passed. Device is safe for Danio live preview."
    exit 0
  }

  $flutterArgs = @("run", "-d", $device.Serial, "--target", $Target)
  if ($UseLocalEnv) {
    $flutterArgs += @("--dart-define-from-file=$localEnvFile")
  }

  Write-Host "flutter run -d $($device.Serial) --target $Target"
  if ($UseLocalEnv) {
    Write-Host "Includes --dart-define-from-file=<local env file>; values are not printed."
  }
  Write-Host "Controls: r hot reload, R hot restart, q quit."
  & $script:Flutter @flutterArgs
  if ($LASTEXITCODE -ne 0) {
    throw "flutter run exited with code $LASTEXITCODE."
  }
}
finally {
  Pop-Location
}
