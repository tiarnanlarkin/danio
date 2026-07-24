import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'CheckOnly shares one deadline across sequential preflight commands',
    () async {
      if (!Platform.isWindows) {
        return;
      }

      final fixture = await Directory.systemTemp.createTemp(
        'danio-live-preview-preflight-',
      );
      try {
        final bin = Directory('${fixture.path}\\bin')..createSync();
        final fakeChildPid = File('${fixture.path}\\fake-child.pid');
        File('${bin.path}\\flutter.cmd').writeAsStringSync(
          '@echo off\r\n'
          'exit /b 0\r\n',
        );
        File('${bin.path}\\emulator.cmd').writeAsStringSync(
          '@echo off\r\n'
          'if "%1"=="-list-avds" echo danio_api36\r\n'
          'exit /b 0\r\n',
        );
        File('${bin.path}\\adb.cmd').writeAsStringSync(
          '@echo off\r\n'
          'if "%1"=="start-server" exit /b 0\r\n'
          'if "%1"=="devices" (\r\n'
          '  echo List of devices attached\r\n'
          '  echo emulator-5554    device\r\n'
          '  exit /b 0\r\n'
          ')\r\n'
          'if "%3"=="shell" if "%4"=="getprop" (\r\n'
          '  powershell.exe -NoLogo -NoProfile -NonInteractive '
          '-Command "\$PID | Set-Content -LiteralPath '
          '\$env:DANIO_FAKE_CHILD_PID; Start-Sleep -Seconds 5"\r\n'
          '  echo danio_api36\r\n'
          '  exit /b 0\r\n'
          ')\r\n'
          'exit /b 0\r\n',
        );

        final stopwatch = Stopwatch()..start();
        final result = await Process.run(
          'powershell.exe',
          [
            '-NoLogo',
            '-NoProfile',
            '-NonInteractive',
            '-File',
            'scripts/run_danio_live_preview.ps1',
            '-CheckOnly',
            '-AdbCommandTimeoutSeconds',
            '10',
            '-PreflightTimeoutSeconds',
            '1',
          ],
          workingDirectory: Directory.current.path,
          environment: {
            'PATH': '${bin.path};${Platform.environment['PATH'] ?? ''}',
            'DANIO_FAKE_CHILD_PID': fakeChildPid.path,
          },
          includeParentEnvironment: true,
        );
        stopwatch.stop();

        final output = '${result.stdout}\n${result.stderr}';
        expect(fakeChildPid.existsSync(), isTrue, reason: output);
        final childPid = int.parse(fakeChildPid.readAsStringSync().trim());
        final childProcessCheck = await Process.run(
          'powershell.exe',
          [
            '-NoLogo',
            '-NoProfile',
            '-NonInteractive',
            '-Command',
            'if (Get-Process -Id $childPid -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }',
          ],
        );
        expect(result.exitCode, isNot(0), reason: output);
        expect(
          childProcessCheck.exitCode,
          0,
          reason: 'The timed-out fake device process was left running.',
        );
        expect(output, contains('PREFLIGHT_PHASE|adb_start_server'));
        expect(output, contains('PREFLIGHT_PHASE|adb_devices'));
        expect(output, contains('PREFLIGHT_PHASE|adb_avd_identity_getprop'));
        expect(
          output,
          contains(
            'PREFLIGHT_TIMEOUT|phase=adb_avd_identity_getprop|limit=1s',
          ),
        );
        expect(
          stopwatch.elapsed,
          lessThan(const Duration(seconds: 4)),
          reason: 'The overall preflight deadline was not enforced: $output',
        );
      } finally {
        await fixture.delete(recursive: true);
      }
    },
  );
}
