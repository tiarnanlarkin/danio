# Codex Setup For Danio

This setup is local-first and quality-first. It is for building, testing,
reviewing, and documenting the Flutter app on this machine while keeping Danio
usable without cloud dependencies. Paid or account-backed quality tools may be
used only after explicit user approval in the current thread or an entry in
`PAID_TOOL_APPROVAL_LEDGER.md`.

## What Agents May Use

- Local Flutter, Dart, Android SDK, JDK, Gradle, Git, PowerShell, ripgrep, and local scripts.
- Local Android emulator or physical device only when ownership is clear.
- Local live preview through `docs/agent/LIVE_PREVIEW_WORKFLOW.md` when the
  user wants to watch Danio during implementation.
- Local screenshots and local log capture.
- The local Danio quality gate at
  `scripts/quality_gates/run_local_quality_gate.ps1`.
- Local-only Maestro CLI if already installed or if the user explicitly approves a local install.
- Installed global Codex skills such as Playwright, screenshots, OpenAI docs
  lookup, and security review skills.
- Figma and Product Design workflows when they are grounded in local
  screenshots, current app surfaces, or approved design targets.
- Account-backed quality lanes such as CodeRabbit, Firebase Test Lab,
  BrowserStack/App Percy, Percy, Qodo, Crashlytics, or Sentry only after local
  gates pass and the approval ledger covers the exact purpose.

## What Agents Must Not Use

- Paid services, hosted CI, remote project creation, or external account setup
  without explicit approval for the exact purpose.
- API calls, paid Figma features, Maestro Cloud, Sentry, Qodo, BrowserStack,
  Percy, Firebase billing upgrades, OpenAI API calls, Vercel, Supabase, or
  similar services without an approval ledger entry.
- Any workflow that commits secrets, billing artifacts, account exports, remote
  tokens, or machine-local credential files.
- Any workflow that makes paid/cloud tooling required for Danio to work locally.

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
- For setup/doc slices, edit only `AGENTS.md`, `docs/agent/**`, or the exact
  setup files named by the user. Do not restage or rewrite parallel design
  setup files unless the current slice explicitly owns that update.

## Repo-Local Multi-Agent Setup

Danio includes project-scoped Codex agent configuration under `.codex/`.
Project sessions must trust the repo before Codex loads these project-local
roles.

Configured roles:

- `danio_product_auditor`: read-only product/content completeness audit.
- `danio_ui_auditor`: read-only UI, visual baseline, and accessibility audit.
- `danio_quality_auditor`: read-only tests, scripts, gates, and verification
  audit.
- `danio_reviewer`: read-only post-slice review for regressions and missing
  tests.
- `danio_worker`: implementation worker for explicitly assigned git worktrees
  and disjoint file/module ownership only.
- `danio_android_qa_owner`: single owner for emulator, ADB, Patrol, Firebase
  Test Lab, and Android screenshot evidence after ownership is clear.

The project cap is six open agent threads with direct-child subagents only.
See `docs/agent/MULTI_AGENT_WORKFLOW.md` for the operating model.

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

Run the local gate before committing product code changes:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
```

The Full profile covers `flutter test`, `dart run dependency_validator`,
`dart run custom_lint`, `flutter analyze`,
`flutter build apk --debug --target lib/main.dart`, and `git diff --check`. On
this Windows path, the wrapper runs custom lint through a temporary no-space
junction and clears generated Flutter folders first.

The local wrapper can run the standard gates in consistent profiles:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile AndroidPrep
```

See `docs/agent/AUTONOMOUS_QUALITY_SETUP.md` for the autonomous workflow,
optional local tool lane, account-backed quality lanes, and approval
boundaries. Use `docs/agent/FINISH_MAP.md` to choose completion slices and
`docs/agent/SLICE_CONTRACT_TEMPLATE.md` to define each slice before editing.
Use `docs/agent/PERFORMANCE_TARGETS.md` for Android phone/tablet performance
budgets before claiming performance-sensitive UI or startup work is complete.

## Research-First Planning

Before substantial implementation, plan from current truth instead of memory:

1. Check whether the work should start in a fresh session.
2. Read the active repo docs, current roadmap, relevant source/tests, and
   `git status --short -uall`.
3. Compare the intended approach against current primary sources when
   framework, platform, testing, accessibility, AI, security, or workflow best
   practice matters.
4. Use the narrowest strong research lane: repo inspection, official docs,
   documentation MCP servers, installed skills, browser/app evidence, or a
   specialist plugin when it materially improves quality.
5. Stop and ask before installing tools, enabling plugins, using account-backed
   services, or entering paid lanes. Explain benefit, cost/account needs when
   known, and no-cost alternatives.
6. Record decision-changing research in the slice contract, active handoff, or
   relevant agent docs.

Before using external account-backed quality services, run the local preflight:

```powershell
.\scripts\quality_gates\check_external_quality_readiness.ps1 -Target All
```

The preflight checks local artifacts, CLI availability, and whether required
environment variables are present. It does not upload builds, start cloud
device sessions, or print secret values.

The static analysis stack is:

- `very_good_analysis` as the Flutter/Dart analyzer baseline.
- `dart run dependency_validator` for dependency hygiene.
- `dart run custom_lint` for Danio-specific local lint rules, via the local
  quality gate on Windows paths with spaces.

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

## Live Preview

For substantial Danio app work, especially UI, navigation, product behavior,
Android, or visual slices, start by attempting the local live preview in
`docs/agent/LIVE_PREVIEW_WORKFLOW.md` so the user can see the app while changes
are made. The standard local preview target is the dedicated `danio_api36`
emulator.

Skip live preview for docs-only, tests-only, refactor-only, or device-unsafe
slices. When skipping it, state the reason in the session summary.

Check the device without launching or taking control:

```powershell
.\scripts\run_danio_live_preview.ps1 -CheckOnly
```

Launch or attach to the dedicated preview emulator only when ownership is
clear:

```powershell
.\scripts\run_danio_live_preview.ps1 -LaunchEmulator
```

The preview terminal prints the interactive controls: `r` hot reload, `R` hot
restart, and `q` quit. Treat live preview as an observation lane; it does not
replace focused tests, `flutter analyze`, debug APK builds, or the Full gate.

Capture local preview evidence only when Danio is foreground:

```powershell
.\scripts\capture_danio_screen.ps1
```

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

Figma MCP may be useful for reference, mockups, and design-target creation.
Paid Figma features, Figma Code Connect, paid stock assets, cloud visual
testing, or account-backed design services require an approval ledger entry for
the exact purpose.

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

- Maestro Cloud unless explicitly approved for a specific QA purpose.
- Hosted device farms.
- Remote uploads.
- Account setup.

If Maestro is not installed, do not block ordinary Flutter verification on it.
If it is installed, use it only after confirming emulator/device ownership.

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
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
```

The full Flutter suite and debug APK build are required when docs also assert a
new product state, alter product behavior, or change test/build instructions
that need end-to-end proof.

When changing the quality gate itself, also run:

```powershell
flutter test test/scripts/local_quality_gate_script_test.dart
flutter test test/scripts/external_quality_readiness_script_test.dart
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
```
