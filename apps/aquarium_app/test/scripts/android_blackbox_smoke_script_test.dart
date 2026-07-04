import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('blackbox smoke script can install an APK before clearing state', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains(r'[string]$InstallApkPath'));
    expect(source, contains(r'[switch]$CleanInstall'));
    expect(source, contains('Installing debug APK'));
    expect(source, contains('"install", "-r"'));
  });

  test(
    'blackbox smoke script can clean install to avoid stale emulator state',
    () {
      final source = File(
        'scripts/run_android_blackbox_smoke.ps1',
      ).readAsStringSync();

      expect(source, contains(r'if ($CleanInstall)'));
      expect(source, contains('Clean install requested'));
      expect(source, contains(r'Invoke-Adb @("shell", "pm", "path", $AppId)'));
      expect(source, contains(r'Invoke-Adb @("uninstall", $AppId)'));
      expect(
        source,
        contains(r'No installed $AppId package found before clean install.'),
      );
    },
  );

  test(
    'blackbox smoke script retries install after emulator storage refusal',
    () {
      final source = File(
        'scripts/run_android_blackbox_smoke.ps1',
      ).readAsStringSync();

      expect(source, contains('INSTALL_FAILED_INSUFFICIENT_STORAGE'));
      expect(source, contains('"cmd", "package", "trim-caches", "2G"'));
      expect(source, contains('Existing package blocks install'));
      expect(source, contains(r'Invoke-Adb @("shell", "pm", "path", $AppId)'));
      expect(source, contains(r'Invoke-Adb @("uninstall", $AppId)'));
    },
  );

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

    expect(
      source,
      contains(
        'Assert-VisibleOutsideBottomDock "Workshop|Tools.*calculators" 10',
      ),
    );
    expect(source, contains(r'Tap-Visible $TapPattern 20'));
    expect(
      source,
      contains(r'Assert-VisibleOutsideBottomDock $ExpectedPattern 10'),
    );
  });

  test('blackbox smoke script gives tab transitions enough Android time', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('Assert-SelectedTab "Smart" 12'));
    expect(
      source,
      contains(
        'Assert-VisibleOutsideBottomDock "Aquarium Intelligence|Optional AI tools" 12',
      ),
    );
    expect(source, contains('Assert-SelectedTab "More" 12'));
    expect(source, contains('Tap-Visible "Workshop" 10'));
    expect(
      source,
      contains(
        'Assert-VisibleOutsideBottomDock "Workshop|Tools.*calculators" 12',
      ),
    );
  });

  test('blackbox smoke script asserts selected tabs outside dock labels', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('function Assert-SelectedTab'));
    expect(source, contains(r'$node.GetAttribute("selected") -eq "true"'));
    expect(source, contains(r'$node.GetAttribute("content-desc") -match'));
    expect(source, contains('Assert-SelectedTab "Practice" 12'));
    expect(source, contains('Assert-SelectedTab "Tank" 12'));
    expect(source, contains('Assert-SelectedTab "Smart" 12'));
    expect(source, contains('Assert-SelectedTab "More" 12'));
  });

  test('blackbox smoke script adjusts taps covered by the bottom dock', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(source, contains('function Get-BottomDockTop'));
    expect(source, contains('function Adjust-TapCenterForDock'));
    expect(source, contains('Tab [1-5] of 5'));
    expect(source, contains(r'if ($center.Y -ge $dockTop)'));
    expect(
      source,
      contains(r'$center.Y = [int][math]::Max($top + 8, $dockTop - 24)'),
    );
    expect(source, contains('Tap target is fully covered by the bottom dock'));
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

  test('blackbox smoke script scrolls About above the bottom dock before tap', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    final backupIndex = source.indexOf('Tap-Visible "Backup"');
    final aboutIndex = source.indexOf('Tap-Visible "About|Version"');
    final safeAboutIndex = source.indexOf(
      'Assert-VisibleOutsideBottomDock "About|Version" 10',
    );

    expect(backupIndex, isNonNegative);
    expect(aboutIndex, isNonNegative);
    expect(safeAboutIndex, isNonNegative);
    expect(safeAboutIndex, greaterThan(backupIndex));
    expect(safeAboutIndex, lessThan(aboutIndex));
  });

  test('blackbox smoke script scrolls Workshop above the tablet dock before tap', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    final sectionIndex = source.indexOf('Write-Host "Checking Workshop routes..."');
    final workshopTapIndex = source.indexOf('Tap-Visible "Workshop" 10');
    final swipeIndex = source.indexOf('Swipe-Percent 50 82 50 52 500');
    final safeWorkshopIndex = source.indexOf(
      'Assert-VisibleOutsideBottomDock "Workshop" 10',
    );

    expect(sectionIndex, isNonNegative);
    expect(workshopTapIndex, isNonNegative);
    expect(swipeIndex, isNonNegative);
    expect(safeWorkshopIndex, isNonNegative);
    expect(swipeIndex, greaterThan(sectionIndex));
    expect(swipeIndex, lessThan(workshopTapIndex));
    expect(safeWorkshopIndex, greaterThan(swipeIndex));
    expect(safeWorkshopIndex, lessThan(workshopTapIndex));
  });

  test('blackbox smoke script scrolls Preferences above the tablet dock before tap', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    final achievementsBackIndex = source.indexOf(
      'Assert-Visible "More"',
      source.indexOf('Tap-Visible "Trophy Case|Achievements"'),
    );
    final preferencesTapIndex = source.indexOf('Tap-Visible "Preferences|Settings"');
    final swipeIndex = source.indexOf(
      'Swipe-Percent 50 82 50 52 500',
      achievementsBackIndex + 1,
    );
    final safePreferencesIndex = source.indexOf(
      'Assert-VisibleOutsideBottomDock "Preferences|Settings" 10',
    );

    expect(achievementsBackIndex, isNonNegative);
    expect(preferencesTapIndex, isNonNegative);
    expect(swipeIndex, isNonNegative);
    expect(safePreferencesIndex, isNonNegative);
    expect(swipeIndex, greaterThan(achievementsBackIndex));
    expect(swipeIndex, lessThan(preferencesTapIndex));
    expect(safePreferencesIndex, greaterThan(swipeIndex));
    expect(safePreferencesIndex, lessThan(preferencesTapIndex));
  });

  test('blackbox smoke script accepts current care-clue hint copy', () {
    final source = File(
      'scripts/run_android_blackbox_smoke.ps1',
    ).readAsStringSync();

    expect(
      source,
      contains('Assert-Visible "Use this care clue|Hint shown" 8'),
    );
  });
}
