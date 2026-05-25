import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('blackbox smoke script can install an APK before clearing state', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains(r'[string]$InstallApkPath'));
    expect(source, contains('Installing debug APK'));
    expect(source, contains('"install", "-r"'));
  });

  test('blackbox smoke script retries install after emulator storage refusal', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('INSTALL_FAILED_INSUFFICIENT_STORAGE'));
    expect(source, contains('"cmd", "package", "trim-caches", "2G"'));
    expect(source, contains('Existing package blocks install'));
    expect(source, contains(r'Invoke-Adb @("shell", "pm", "path", $AppId)'));
    expect(source, contains(r'Invoke-Adb @("uninstall", $AppId)'));
  });

  test('blackbox smoke script waits for any first visible app state', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('Wait-FirstVisibleAppState'));
    expect(source, contains(r'param([int]$TimeoutSeconds = 35)'));
    expect(source, contains('Your Privacy Matters'));
    expect(source, contains('Your fish deserve better'));
    expect(source, contains('Learning Paths'));
    expect(source, contains('Tank Toolbox'));
  });

  test('blackbox smoke script taps consent controls by enabled UI label', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains(r'GetAttribute("enabled") -ne "true"'));
    expect(source, contains('Tap-Visible "Age confirmation checkbox" 10'));
    expect(
      source,
      contains(
        'Tap-Visible "Terms of Service and Privacy Policy acceptance checkbox" 10',
      ),
    );
    expect(source, contains('Try-Tap-Visible "No Thanks|Share Crash Reports"'));
    expect(source, contains('Try-WaitFirstVisibleAppState 2'));
    expect(source, contains("android.widget.CheckBox"));
    expect(source, contains(r'$tapNode = $checkboxChild'));
    expect(source, contains(r'$clickableChild = $node.SelectSingleNode'));
    expect(source, contains(r'$tapNode = $clickableChild'));
    expect(
      source,
      contains(
        r'if ($tapNode.GetAttribute("class") -eq "android.widget.CheckBox")',
      ),
    );
    expect(
      source,
      contains(r'$center.X = [int][math]::Min($center.X, $left + 96)'),
    );
  });

  test('blackbox smoke script verifies create tank dirty text was entered', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('danio://qa/create-tank?name=Q'));
    expect(source, contains('"input", "text", "Q"'));
    expect(
      source,
      contains(r'Assert-Visible "text=`"Q`"|49 characters remaining" 6'),
    );
    expect(source, contains('function Hide-SoftKeyboard'));
    expect(source, contains('Hide-SoftKeyboard'));
    expect(source, contains(r'if (Try-Assert-Visible "Discard new tank\?" 1)'));
  });

  test('blackbox smoke script can bypass first-run onboarding', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'Tap-Visible "Skip setup, explore first|Skip setup, I\'ll explore first"',
      ),
    );
  });

  test('blackbox smoke script verifies launched app is foreground', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('Wait-AppForeground'));
    expect(source, contains('"dumpsys", "window"'));
    expect(source, contains('"am", "force-stop"'));
  });

  test('blackbox smoke script retries transient hierarchy dumps', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('Get-Hierarchy'));
    expect(source, contains('uiautomator dump'));
    expect(source, contains('null root node'));
  });

  test('blackbox smoke script waits for Workshop between tool routes', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('Assert-Visible "Workshop|Tools.*calculators" 10'));
    expect(source, contains(r'Tap-Visible $TapPattern 20'));
    expect(source, contains(r'Assert-Visible $ExpectedPattern 10'));
  });

  test('blackbox smoke script gives tab transitions enough Android time', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('Assert-Visible "Smart" 12'));
    expect(source, contains('Assert-Visible "More" 12'));
    expect(source, contains('Tap-Visible "Workshop" 10'));
    expect(source, contains('Assert-Visible "Workshop|Tools.*calculators" 12'));
  });

  test('blackbox smoke script retries adb transport failures', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains(r'for ($attempt = 1; $attempt -le 4; $attempt++)'));
    expect(
      source,
      contains(r'$previousErrorActionPreference = $ErrorActionPreference'),
    );
    expect(source, contains(r'$ErrorActionPreference = "Continue"'));
    expect(source, contains(r'Start-Sleep -Milliseconds (500 * $attempt)'));
    expect(source, contains(r'$outputText'));
  });

  test(
    'blackbox smoke script can stop known emulator-interfering packages',
    () {
      final source = File(
        'scripts/run_android_blackbox_smoke.ps1',
      ).readAsStringSync();

      expect(source, contains(r'[string[]]$ForceStopPackageIds = @()'));
      expect(source, contains('function Stop-InterferingPackages'));
      expect(source, contains('Force-stopping emulator package'));
      expect(source, contains(r'"am", "force-stop", $packageId'));
    },
  );

  test('blackbox smoke script recovers if another app steals foreground', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('function Ensure-AppForeground'));
    expect(source, contains('function Bring-AppForeground'));
    expect(source, contains("interrupted smoke; bringing \$AppId back"));
    expect(source, contains('Ensure-AppForeground'));
    expect(source, contains(r'if ($ForceStopPackageIds -contains $package)'));
    expect(
      source,
      contains(r'Invoke-Adb @("shell", "am", "force-stop", $package)'),
    );
  });

  test(
    'blackbox smoke script does not over-back out of More after Workshop',
    () {
      final source = File(
        'scripts/run_android_blackbox_smoke.ps1',
      ).readAsStringSync();

      expect(source, contains('if (-not (Try-Assert-Visible "More" 2)) {'));
      expect(source, contains('Assert-Visible "More"'));
    },
  );
}
