# Codex Setup For Danio

This setup is intentionally no-cost and local-first. It is for building, testing, reviewing, and documenting the Flutter app on this machine without adding cloud dependencies.

## What Agents May Use

- Local Flutter, Dart, Android SDK, JDK, Gradle, Git, PowerShell, ripgrep, and local scripts.
- Local Android emulator or physical device only when ownership is clear.
- Local screenshots and local log capture.
- Local-only Maestro CLI if already installed or if the user explicitly approves a local install.
- Installed global Codex skills such as Playwright, screenshots, OpenAI docs lookup, and security review skills, provided they do not call paid services or require external accounts.
- Installed no-cost design skills such as Figma, Product Design workflows, Playwright, and screenshots, provided they stay local/reference-only and do not require paid seats, secrets, uploads, or external accounts.

## What Agents Must Not Use

- Paid services.
- Hosted CI setup.
- Vercel, Supabase, Sentry, Figma paid features, Maestro Cloud, OpenAI API calls, or external account setup.
- Any workflow that requires secrets, billing, remote project creation, or cloud storage.

## Repo Orientation

From repo root:

```text
apps/aquarium_app/        Flutter app
apps/aquarium_app/lib/    App source
apps/aquarium_app/test/   Dart, widget, service, and copy tests
apps/aquarium_app/docs/   Product, QA, release, and agent docs
```

Use `apps/aquarium_app` as the working directory for Flutter commands.

## Dirty Worktree And Parallel Session Discipline

Before any edit:

```powershell
git status --short -uall
```

Rules:

- Treat dirty files as owned by the user or another Codex session unless you
  made them in the current slice.
- Do not stage, format, rewrite, delete, or revert unrelated dirty files.
- If a needed file is already dirty, inspect the diff first and preserve the
  existing work.
- Keep product changes, docs-only setup, and design-baseline updates in
  separate commits.
- After each committed slice, run `git status --short -uall` and continue only
  when the worktree is clean or the remaining dirt is explicitly understood.

## Windows Environment

If the shell cannot find Flutter, Java, or Android tools, set the local paths for the current PowerShell session:

```powershell
$env:JAVA_HOME = Join-Path $env:USERPROFILE 'development\jdk-21'
$env:ANDROID_SDK_ROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$env:ANDROID_HOME = $env:ANDROID_SDK_ROOT
$env:Path = "$env:LOCALAPPDATA\Programs\Git\cmd;$env:USERPROFILE\development\flutter\bin;$env:JAVA_HOME\bin;$env:ANDROID_SDK_ROOT\platform-tools;$env:Path"
```

Do not write these paths into tracked files unless the user asks for machine setup documentation.

## Standard Local Gates

Run these before committing product code changes:

```powershell
flutter test
flutter analyze
flutter build apk --debug --target lib/main.dart
git diff --check
```

Run focused tests for the changed area before the full suite:

```powershell
flutter test test/widget_tests/<changed_screen>_test.dart
flutter test test/widget/<changed_flow>_test.dart
flutter test test/services/<changed_service>_test.dart
flutter test test/copy/current_docs_local_truth_test.dart
```

Use `dart format` on touched Dart files, then normalize line endings back to LF if the formatter converts files to CRLF:

```powershell
$files = @('lib\path\file.dart','test\path\file_test.dart')
foreach ($file in $files) {
  $path = Resolve-Path -LiteralPath $file
  $text = [System.IO.File]::ReadAllText($path)
  $text = $text -replace "`r`n", "`n"
  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $text, $utf8NoBom)
}
```

For touched Dart source that is intended to remain ASCII-safe, scan it:

```powershell
rg -n '[^\x00-\x7F]' lib\path\file.dart test\path\file_test.dart
```

No output means the scan is clean.

## Android Emulator Discipline

Before any emulator or device action:

```powershell
adb devices
adb shell dumpsys window | Select-String -Pattern 'mCurrentFocus|mFocusedApp'
```

Rules:

- Do not use an emulator if another Codex session appears to be using it.
- Do not kill, wipe, restart, or install onto a device unless ownership is clear.
- Prefer `flutter build apk --debug --target lib/main.dart` when ownership is unclear.
- Store local QA screenshots and logs under `docs/qa/screenshots/...` only when they are useful evidence.

## Local Screenshots

Acceptable local screenshot options:

- Android emulator screenshot through local tools when device ownership is clear.
- Local browser/desktop screenshots for docs or web surfaces.
- Codex screenshot skill when it only captures local UI and does not upload to a paid service.

Do not use external screenshot hosting.

## Design Skills And Baselines

Use these docs before UI, illustration, chart, or visual polish work:

- `docs/design-direction.md`
- `docs/theme-system.md`
- `docs/design/DESIGN_SYSTEM.md`
- `docs/design/BASELINES.md`
- `docs/design/VISUAL_QA_CHECKLIST.md`

Figma MCP may be useful for reference or no-cost exploration, but the current
seat may be read/reference-only. Do not use Figma Code Connect, paid Figma
features, paid stock assets, cloud visual testing, or account-backed design
services.

Flutter golden tests are local verification aids. Their reference images are
platform-dependent and ignored by this repo, so use them for focused local
regression checks rather than cross-machine visual truth.

## Parallel Design Setup Coordination

The design autonomy setup under `docs/design/` is treated as active project
infrastructure. Do not overwrite those files while another session owns a
design-baseline slice.

For UI or visual work:

- Start from the relevant design doc, screenshot, golden, mockup, or existing
  in-app surface.
- Keep screenshots and golden checks local-only.
- Record the changed surfaces and verification evidence in the active QA or
  agent docs.
- Keep design-baseline updates separate from unrelated product behavior
  commits when practical.

For non-UI work, note that visual QA was not required instead of capturing
unrelated screenshots.

## Optional Local-Only Maestro CLI Notes

Maestro is optional and local-only for this repo.

Allowed:

```powershell
maestro test .\maestro\some_flow.yaml
```

Not allowed:

- Maestro Cloud.
- Hosted device farms.
- Remote uploads.
- Account setup.

If Maestro is not installed, do not block ordinary Flutter verification on it.

## Product Rules For Agents

- Smart Hub must provide useful local aquarium intelligence without AI.
- Optional AI may add extra power, but missing keys or backend config must show calm setup copy and never break the core app.
- Do not add fake premium gates, fake subscriptions, fake social features, fake friend systems, fake leaderboards, or fake cloud sync.
- Backup/export/import must remain understandable to normal users.
- User data is local by default. Do not add hidden network behavior.
- Care guidance must be practical, educational, and clear about not replacing qualified professional advice.

## Commit Rules

- Keep commits focused.
- Commit docs-only setup separately from product behavior changes.
- Include verification results in the final response after each committed slice.
- Push only after tests/checks requested for that slice have passed.

## Setup Verification Notes

For docs-only setup slices, verify at minimum:

```powershell
git diff --check
flutter test test/copy/current_docs_local_truth_test.dart
flutter analyze
```

The full Flutter suite and debug APK build are required when docs also assert a
new product state, alter product behavior, or change test/build instructions
that need end-to-end proof.
