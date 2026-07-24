# Danio emulator/app freeze diagnosis

Date: 2026-07-24
Epoch: `DR-2026-07-24-076`
Marker: `danio-emulator-app-freeze-diagnosis-2026-07-24/1`
Source commit: `64a9e83b7b74990cf5518eb0cef028d0b3cc1641`
Device: `danio_api36 (emulator-5554)`, Android 16, 1080 x 2400 px

## Conclusion

The reported frozen state was reproduced in the already-installed debug APK,
including an Android ANR dialog, but it was not reproduced as a current-commit
profile-mode ANR. The evidence instead isolates a severely pressured emulator
and debug/test environment: Android Settings was also slow, the ANR report
showed system-wide CPU and memory pressure, and the same product source in a
profile APK recovered, exposed a complete UI hierarchy, and accepted a
non-destructive Back interaction.

No product change was made. The open performance budgets remain governed by
`DCL-PERF-001`; this diagnostic does not convert a pressured debug/emulator run
into a new product P0/P1 or override the prior controlled profile harness.

## Initial state and user close

- The bounded named-AVD and serial-pinned preflights passed for
  `danio_api36 (emulator-5554)`.
- The Nexus launcher was foreground, system font scale was `1.0`, and no Danio
  process was running.
- Android process-exit history recorded the user's close at
  `2026-07-24 19:11:39.198` as reason `USER REQUESTED`, subreason
  `REMOVE TASK`, status `0`. It did not record a crash or ANR exit for that
  close.
- No competing Flutter/Dart process or repository-writing Git process was
  active.

## Debug reproduction

The installed debug APK was SHA-256
`02A214529E094DC4138AA49F2EE98E9ECA84D88DC3133210C125B750E7D0D5F0`.
A normal launcher start returned `Status: timeout` with
`WaitTime: 14602 ms`; the process existed, but the first UI hierarchy returned
no root.

Android then recorded an input-dispatch ANR while waiting 5,002 ms for
`FocusEvent(hasFocus=true)`. The ANR snapshot reported:

- 96% total guest CPU, including 84% kernel time;
- Danio at 85% CPU, with 70% kernel time;
- memory pressure avg10=32.47 and I/O pressure avg10=20.59;
- only 122,128 KiB guest memory free and 643,100 KiB swap in use during the
  diagnostic window.

The screenshot below binds the visible result. No Dart exception,
`FlutterError`, `RenderFlex`, fatal exception, or crash exit was found.

## Paired controls

- Android Settings on the same running AVD took `4884 ms` to open and its first
  UI-hierarchy attempt also returned no root, demonstrating system-wide
  emulator slowness rather than a Danio-only transport failure.
- A current-source Android x64 profile APK built successfully at SHA-256
  `28F7A6C15CE918FAFB0E11A26A305AC1961082EF2EB890CC8E13AA136AE2742A`.
- The first profile launch was also delayed by the pressured environment, but
  it recovered, drew the Tank surface, exposed semantics, and accepted a
  system Back interaction from the streak prompt.
- A no-reinstall profile cold repeat completed in `12,200 ms`, reported the
  activity fully drawn, exposed the Tank controls and five tabs through the UI
  hierarchy, and produced no profile ANR or fatal/Flutter error.

These timings are not accepted product performance results. They are paired
diagnostic evidence from the already-degraded AVD. The controlled
snapshot-disabled profile harness remains the performance authority.

## Bound screenshots

| Evidence | SHA-256 |
| --- | --- |
| `docs/qa/screenshots/live-preview/2026-07-24-danio-freeze-diagnosis/2026-07-24/screen-emulator-5554-191931675.png` | `C7875D50341B48B38AFE6512352F92D206F8D42490B8D946A41A9C5E3D4079E6` |
| `docs/qa/screenshots/live-preview/2026-07-24-danio-freeze-diagnosis/2026-07-24/screen-emulator-5554-193255556.png` | `99898C599AC1A816CAE125D4DDABF7C564AEDD4ADE68523A3E4062B9B1B2CD29` |

The first image shows the debug ANR dialog. The second shows the responsive
current-commit profile Tank surface after the cold repeat. Raw focus and logcat
captures were inspected locally but are not retained in Git because they
contain broad system-process noise beyond the bounded Danio evidence above.

## Release state

The exact debug APK was restored after the paired run. Danio was stopped, the
Nexus launcher was returned to the foreground, font scale `1.0` was confirmed,
and the serial-pinned CheckOnly passed. The emulator was left running and
device ownership was released.

No product change, emulator restart, wipe, app-data clear, tablet action, iOS,
store, cloud, account, provider, or secret action occurred.
