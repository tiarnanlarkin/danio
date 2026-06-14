# Danio Agent Instructions

This repo is developed local-first. Agents must keep work no-cost, offline-capable, and honest unless the user explicitly requests a separate paid/cloud setup.

## Scope

- Primary app: `apps/aquarium_app`.
- Main product docs: `apps/aquarium_app/docs/product`.
- Agent setup docs: `apps/aquarium_app/docs/agent`.

## Non-Negotiable Rules

- Do not set up paid services, hosted CI, cloud projects, external accounts, or API-backed workflows.
- Do not call paid APIs or require OpenAI, Supabase, Vercel, Sentry, Figma paid features, Maestro Cloud, or similar services.
- Do not add fake premium, fake social, fake cloud sync, fake leaderboards, or dormant monetisation promises.
- Keep Danio usable without optional AI keys. Smart Hub must work locally first.
- Optional AI must degrade gracefully and must never make the app feel broken when no key or backend is configured.
- Do not make care claims that imply veterinary or professional advice. Danio is educational and practical, not a vet substitute.

## Dirty Worktree Protection

- Run `git status --short -uall` before editing and before staging.
- Never revert, delete, or overwrite user changes you did not make.
- If unrelated files are dirty, leave them alone.
- If files you need are dirty, inspect them and work with the changes.
- If another Codex session has active dirty work, do not stage, format, or
  rewrite those files. Either wait for a clean handoff or work only in files
  that are clearly isolated from that session's slice.
- Commit focused slices separately. Docs-only setup changes must stay separate from product behavior changes.

## Local Verification Gates

Run commands from `apps/aquarium_app` unless stated otherwise.

Required standard gates for product changes:

```powershell
flutter test
flutter analyze
flutter build apk --debug --target lib/main.dart
git diff --check
```

Also run focused tests for changed areas before the full suite, especially
focused widget tests for changed screens or settings flows:

```powershell
flutter test test/widget_tests/journal_screen_test.dart
flutter test test/widget_tests/search_screen_test.dart
flutter test test/widget/settings_screen_test.dart
flutter test test/copy/current_docs_local_truth_test.dart
```

For docs-only changes, at minimum run:

```powershell
git diff --check
flutter test test/copy/current_docs_local_truth_test.dart
flutter analyze
rg -n "paid|cloud|OpenAI API calls|Maestro Cloud|fake premium|fake social" AGENTS.md apps/aquarium_app/docs/agent
```

Run Flutter/doc truth tests when docs assert current product behavior. A debug
APK build is required for product behavior changes and for documentation updates
that make new build/readiness claims.

## Android Emulator Discipline

- Multiple Codex sessions may be active on this machine.
- Do not start, stop, wipe, kill, or commandeer an emulator/device without confirming it is safe.
- Before emulator use, check `adb devices` and foreground package ownership.
- Prefer compile/test/build verification when device ownership is unclear.
- Local APK builds are allowed. Emulator installs, taps, screenshots, and logcat capture require device ownership clarity.

## Screenshots

- Use local screenshots only.
- Save reusable screenshots under `apps/aquarium_app/docs/qa/screenshots/<date-or-branch>/<slice>/`.
- Temporary screenshots can stay in a temp folder if they are only for inspection.
- Do not upload screenshots to external services unless the user explicitly asks.

## Design And Visual QA

- Before material UI, layout, illustration, icon, chart, or visual polish work,
  ground the change in a current screenshot, Flutter golden, mockup, Figma
  frame, or existing app surface.
- Use `apps/aquarium_app/docs/design-direction.md`,
  `apps/aquarium_app/docs/theme-system.md`, and the setup docs under
  `apps/aquarium_app/docs/design/` for local design decisions.
- Figma and Product Design skills may be used only within no-cost access. The
  current Figma setup may be reference-only; do not use Figma Code Connect,
  paid Figma features, paid assets, or cloud visual QA.
- Preserve Danio's local-first product honesty: no fake AI, fake premium, fake
  social, fake cloud sync, or care claims that imply veterinary advice.
- For visual changes, run the applicable Flutter/golden/screenshot checks from
  `apps/aquarium_app/docs/design/VISUAL_QA_CHECKLIST.md`.
- Preserve design setup docs from parallel sessions. Extend them only when the
  current slice explicitly owns that update, and keep design-baseline changes in
  their own focused commit when practical.

## Documentation References

- Codex setup: `apps/aquarium_app/docs/agent/CODEX_SETUP.md`
- Testing checklist: `apps/aquarium_app/docs/agent/TESTING_CHECKLIST.md`
- Current local audit: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Backlog: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
