param(
  [string]$AvdName = "danio_api36",
  [string]$AppId = "com.tiarnanlarkin.danio",
  [string]$Target = "lib/main.dart",
  [string]$DeviceId = "",
  [switch]$UseLocalEnv,
  [string]$EnvFile = "",
  [switch]$LaunchEmulator,
  [switch]$ColdBoot,
  [switch]$CheckOnly,
  [int]$WaitSeconds = 90,
  [int]$AdbCommandTimeoutSeconds = 10
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
Write-Host "Supported switches: -CheckOnly, -LaunchEmulator, -ColdBoot, -UseLocalEnv, -EnvFile, -WaitSeconds, -AdbCommandTimeoutSeconds."

if ($WaitSeconds -le 0) {
  throw "WaitSeconds must be greater than zero."
}
if ($AdbCommandTimeoutSeconds -le 0) {
  throw "AdbCommandTimeoutSeconds must be greater than zero."
}
if ($ColdBoot -and -not $LaunchEmulator) {
  throw "ColdBoot requires -LaunchEmulator."
}

function ConvertTo-NativeArgument {
  param([Parameter(Mandatory = $true)][string]$Argument)

  if ($Argument -notmatch '[\s"]') {
    return $Argument
  }

  return '"' + ($Argument -replace '"', '\"') + '"'
}

function Split-NativeOutput {
  param([string]$Text)

  if (-not $Text) {
    return @()
  }

  return @(
    $Text -split "`r?`n" |
      Where-Object { $_ -ne "" }
  )
}

function Invoke-NativeCommand {
  param(
    [Parameter(Mandatory = $true)][string]$FileName,
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [Parameter(Mandatory = $true)][string]$CommandName,
    [Parameter(Mandatory = $true)][int]$TimeoutSeconds
  )

  $startInfo = New-Object System.Diagnostics.ProcessStartInfo
  $startInfo.FileName = $FileName
  $startInfo.Arguments = ($Arguments | ForEach-Object {
      ConvertTo-NativeArgument -Argument $_
    }) -join " "
  $startInfo.RedirectStandardError = $true
  $startInfo.RedirectStandardOutput = $true
  $startInfo.UseShellExecute = $false
  $startInfo.CreateNoWindow = $true

  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $startInfo
  [void]$process.Start()
  $stdoutTask = $process.StandardOutput.ReadToEndAsync()
  $stderrTask = $process.StandardError.ReadToEndAsync()
  $timeoutMilliseconds = $TimeoutSeconds * 1000
  if (-not $process.WaitForExit($timeoutMilliseconds)) {
    $process.Kill()
    $process.WaitForExit()
    throw "$CommandName timed out after $TimeoutSeconds seconds."
  }

  $output = @()
  $output += Split-NativeOutput -Text $stdoutTask.Result
  $output += Split-NativeOutput -Text $stderrTask.Result
  return [pscustomobject]@{
    ExitCode = $process.ExitCode
    Output = $output
  }
}

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

  $adbArguments = @($base + $Arguments)
  $result = Invoke-NativeCommand `
    -FileName $script:Adb `
    -Arguments $adbArguments `
    -CommandName "adb $($adbArguments -join ' ')" `
    -TimeoutSeconds $AdbCommandTimeoutSeconds
  if ($result.ExitCode -ne 0) {
    throw "adb $($Arguments -join ' ') failed for '$Serial': $($result.Output -join ' ')"
  }
  return @($result.Output)
}

function Initialize-Adb {
  Write-Host "Starting or confirming the adb server..."
  Invoke-Adb -Arguments @("start-server") | Out-Null
}

function Get-AvailableAvds {
  $result = Invoke-NativeCommand `
    -FileName $script:Emulator `
    -Arguments @("-list-avds") `
    -CommandName "emulator -list-avds" `
    -TimeoutSeconds $AdbCommandTimeoutSeconds
  if ($result.ExitCode -ne 0) {
    throw "emulator -list-avds failed: $($result.Output -join ' ')"
  }
  return @($result.Output | Where-Object { $_ -and $_.Trim() })
}

function Assert-AvdAvailable {
  $availableAvds = Get-AvailableAvds
  if ($availableAvds -cnotcontains $AvdName) {
    throw "AVD '$AvdName' is not present in emulator -list-avds."
  }
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

  Write-Host "Checking AVD identity for $Serial..."
  try {
    $propertyOutput = Invoke-Adb `
      -Serial $Serial `
      -Arguments @("shell", "getprop", "ro.boot.qemu.avd_name")
    $propertyAvd = $propertyOutput |
      Where-Object { $_ -and $_.Trim() } |
      Select-Object -First 1
    if ($propertyAvd) {
      return $propertyAvd.Trim()
    }
  }
  catch {
    # Fall through to the emulator console identity check.
  }

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
  Assert-AvdAvailable
  $emulatorArguments = @("-avd", $AvdName)
  if ($ColdBoot) {
    $emulatorArguments += @("-no-snapshot-load", "-no-snapshot-save")
  }
  Write-Host "Starting Android emulator AVD '$AvdName' for visible Danio preview..."
  Start-Process -FilePath $script:Emulator -ArgumentList $emulatorArguments
}

function Resolve-DanioDevice {
  if ($DeviceId) {
    $devices = Get-ReadyDevices
    if ($devices -notcontains $DeviceId) {
      throw "Requested device '$DeviceId' is not listed as ready by adb devices."
    }
    $deviceAvd = Get-DeviceAvdName -Serial $DeviceId
    if ($deviceAvd -cne $AvdName) {
      throw "Requested device '$DeviceId' is AVD '$deviceAvd', not '$AvdName'."
    }
    $foreground = Assert-ForegroundSafe -Serial $DeviceId
    return [pscustomobject]@{
      Serial = $DeviceId
      Avd = $deviceAvd
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
      if ($ColdBoot) {
        Write-Host "ColdBoot only applies when this script starts the AVD; the running device will not be restarted."
      }
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
  Initialize-Adb
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
