# Danio Safe Codex Workflow

Last updated: 2026-05-02

This is the canonical workflow for using Codex on Danio now that the app is close to release. It is intentionally conservative: preserve the current app, inspect before editing, change one thing at a time, and prove each change with local tests plus Android device checks where possible.

## Source Of Truth

- Repo: `C:\Users\larki\Documents\Danio Aquarium App Project\repo`
- App: `apps/aquarium_app`
- Default branch: `main`
- Remote: `https://github.com/tiarnanlarkin/danio.git`
- Package id: `com.tiarnanlarkin.danio`

Current baseline from the 2026-05-02 audit:

- Local `main` was clean and 1 commit ahead of `origin/main`.
- `flutter analyze --no-pub` passed locally.
- `flutter test` passed locally with 938 tests.
- `flutter build apk --debug --target-platform android-arm64 --no-pub` passed locally.
- GitHub Actions was blocked before runner startup by a GitHub account/billing issue, so red CI runs were not evidence of app failure.

## Default Work Loop

1. Start from the repo root and check status:

   ```powershell
   cd "C:\Users\larki\Documents\Danio Aquarium App Project\repo"
   git status --short --branch
   git log --oneline --decorate --max-count=5
   ```

2. Create a small branch before changing anything:

   ```powershell
   git checkout -b fix/short-description
   ```

3. Read the relevant files first and write a short risk note before edits.

4. Make the narrowest useful change. Avoid broad refactors, formatting churn, dependency upgrades, and unrelated cleanup.

5. Run the smallest relevant test first, then the standard gate:

   ```powershell
   cd "C:\Users\larki\Documents\Danio Aquarium App Project\repo\apps\aquarium_app"
   flutter analyze --no-pub
   flutter test
   flutter build apk --debug --target-platform android-arm64 --no-pub
   ```

6. For UI, navigation, onboarding, Tank, or release-sensitive changes, also run Android device smoke checks after Android tooling is available:

   ```powershell
   flutter test integration_test\smoke_test_v2.dart -d <device-id>
   patrol test -t integration_test\smoke_test.dart --device <device-id>
   maestro test .maestro
   ```

7. Summarize the change, test evidence, and any remaining risk. Do not merge or push unless explicitly requested.

## High-Risk Areas

Read these files before touching the related area.

| Area | Required context |
| --- | --- |
| Navigation/layout | `lib/main.dart`, `lib/screens/tab_navigator.dart`, `lib/navigation/app_routes.dart`, notification payload handling |
| Tank UI | `lib/screens/home/home_screen.dart`, `lib/widgets/stage/bottom_sheet_panel.dart`, stage widgets, home sheet files |
| Persistence/backup/sync | `storage_service.dart`, `local_json_storage_service.dart`, `storage_provider.dart`, SharedPreferences-backed providers, `cloud_sync_service.dart` |
| Smart/AI | `ai_proxy_service.dart`, `openai_service.dart`, Supabase proxy docs/config |

Known risk contracts:

- The tab shell is global. `TabNavigator` owns nested navigators, back handling, bottom nav, and bottom padding.
- The Tank tab has a fragile inset contract: `TabNavigator` adds nav-bar bottom space, `HomeScreen` removes bottom padding around the bottom sheet, and `BottomSheetPanel` intentionally avoids extra bottom padding.
- Persistence is split between JSON file storage for tanks/logs/tasks and SharedPreferences for profile/settings/gamification/practice state.
- Smart/AI implementation and proxy documentation need reconciliation before production behavior is changed.

## Android Tooling Setup

Android is the authoritative visual target for release. Before relying on E2E automation, verify the SDK tools are on PATH:

```powershell
cd "C:\Users\larki\Documents\Danio Aquarium App Project\repo"
.\scripts\check_android_tooling.ps1
```

If the script reports missing tools, set the session PATH:

```powershell
$env:ANDROID_HOME="$env:LOCALAPPDATA\Android\Sdk"
$env:ANDROID_SDK_ROOT=$env:ANDROID_HOME
$env:Path="$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\emulator;$env:ANDROID_HOME\cmdline-tools\latest\bin;$env:Path"
```

Then verify:

```powershell
adb devices
emulator -list-avds
Test-Path "$env:ANDROID_HOME\cmdline-tools\latest\bin\apkanalyzer.bat"
flutter devices
```

On Windows, Flutter requires `apkanalyzer.bat` for release app bundle verification. If only an extensionless `apkanalyzer` file exists, the Android command-line tools package is wrong for Windows; reinstall Android SDK Command-line Tools from Android Studio SDK Manager before trusting release AAB checks.

Patrol and Maestro are optional until E2E checks are needed, but they must be available before treating Android automation as complete:

```powershell
dart pub global activate patrol_cli
patrol --version
maestro --version
```

## Launch Gates

Use this order for launch readiness:

1. Clean Git status on a branch or explicit release commit.
2. Local analyze, tests, and debug APK build pass.
3. Release AAB build passes:

   ```powershell
   flutter build appbundle --release
   ```

4. Android emulator/device smoke passes.
5. Maestro/Patrol flows pass for changed areas.
6. GitHub Actions is green after the account/billing lock is resolved.
7. Legal URLs and Play Store metadata show current Danio wording.

Do not use Windows desktop as a release gate until the Firebase C++ SDK setup is fixed. Chrome/web is useful for quick visual checks only; it is not final mobile truth.

## Scout Agents

Use subagents only as read-only scouts unless a future task is explicitly split into isolated edit scopes.

Recommended scout split for large audits:

- Architecture scout: screens/widgets/providers/services coupling and risky modules.
- QA scout: tests, device automation, launch commands, environment blockers.
- GitHub/release scout: CI, PRs, releases, docs consistency, legal URLs.

The main Codex instance remains the only editor unless the user explicitly approves worker agents with disjoint file ownership.

## GitHub And Release Hygiene

- Resolve the GitHub Actions account/billing lock before trusting CI.
- Keep `main` protected by workflow, not habit: branch, verify, PR or explicit user-approved merge.
- Treat stale release/readiness docs as historical until reconciled with current code and CI.
- Regenerate and publish legal HTML before Play Store submission.
- Do not force-push, reset, rebase shared branches, or discard local changes without explicit user approval.
