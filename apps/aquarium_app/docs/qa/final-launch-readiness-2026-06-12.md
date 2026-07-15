> Current security clearance (2026-07-15): **NOT RELEASE-READY.**
> Danio is not listed in the Play Console account inspected on 2026-07-15. The exposed local signing key is retired and must not be used for a future release.
> Public Git history retains the old exposure, and the canonical privacy and terms URLs require current external hosting and content verification. This historical evidence is not release approval.

# Danio Final Launch Readiness - 2026-06-12

## Current Decision

Android build quality is green for a v1.0 release candidate. The remaining
blockers are external publication/account tasks, not app-runtime defects.

## Verified Engineering Gates

| Gate | Result |
|---|---|
| `flutter pub get` | Pass |
| `flutter analyze --no-pub` | Pass, no issues |
| `flutter test` | Pass, 1311 tests |
| `integration_test/smoke_test_v2.dart` on Android emulator | Pass, 5 tests |
| Debug Android black-box smoke with QA deep links | Pass |
| Release APK black-box smoke | Pass |
| Release AAB build | Pass |
| Release APK build | Pass |
| Release APK signing verification | Pass |
| Release AAB signature verification | Pass |

## Release Artifacts

| Artifact | Path | Size |
|---|---|---|
| Play upload bundle | `build/app/outputs/bundle/release/app-release.aab` | 88.37 MB |
| Release APK | `build/app/outputs/flutter-apk/app-release.apk` | 94.23 MB |

Signing certificate for the release APK:

`60d2d7c9e5d81102f47ad31c14c32fc9cf860b6ff6dd45ba6431b0ba911c42a2`

## Fix Applied During Final QA

Debug QA deep links were being passed to FlutterActivity's default route
handler after the app-specific QA channel handled them. That caused a false
ErrorBoundary state for `danio://qa/settings`, because Flutter tried to push a
normal `/settings` route with no generator.

`MainActivity.onNewIntent()` now returns immediately for debug-only
`danio://qa` links after dispatching them to the QA channel. A regression test
covers this ordering.

## Store Assets

Current Play-ready files:

| Asset | Path | Validation |
|---|---|---|
| Icon | `store_assets/icon-512.png` | 512x512 RGBA PNG, 349 KB |
| Feature graphic | `store_assets/feature-graphic.png` | 1024x500 RGB PNG, 723 KB |
| Alternate feature graphic | `store_assets/feature-graphic-1024x500.png` | 1024x500 RGB PNG, 801 KB |
| Phone screenshots | `store_assets/screenshots/*.png` | Six 1080x1920 RGB PNGs, all under 8 MB |

Screenshot upload order and alt text are documented in
`store_assets/screenshots/README.md`.

## Legal And Play Console State

The app links to:

- `https://tiarnanlarkin.github.io/danio/privacy-policy.html`
- `https://tiarnanlarkin.github.io/danio/terms-of-service.html`

Local root `docs/` files have been refreshed to the current Danio-branded legal
pages so those URLs can be served by GitHub Pages once the branch is merged or
published.

Direct network check on 2026-06-12 returned 404 for both public URLs, so hosting
is still a launch blocker until GitHub Pages serves the updated files.

## Remaining External Launch Tasks

1. Merge/publish the refreshed root `docs/` legal files to the GitHub Pages
   source branch and verify both public URLs return HTTP 200.
2. Upload `app-release.aab` to Google Play Console.
3. Complete Play Console Data Safety using `docs/PLAY_CONSOLE_DECLARATIONS.md`
   and `docs/DATA_SAFETY_FORM.md`.
4. Complete Content Rating and Target Audience; keep target audience 13+.
5. Complete the exact alarm permission declaration for maintenance/review
   reminders.
6. Upload icon, feature graphic, and the six phone screenshots from
   `store_assets/`.
7. Confirm the release keystore is backed up somewhere outside the repository
   and outside this reset-prone machine.

## Non-Blocking Follow-Ups

- Flutter warns that the Kotlin Gradle Plugin integration will need migration
  for a future Flutter release. Current Android builds pass.
- The release AAB is 88.37 MB. App size optimization can be a later polish pass.
- Supabase runs in offline-only mode with placeholder credentials in this build;
  this matches the current offline-first launch posture.
