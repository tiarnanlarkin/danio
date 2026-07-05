# Danio Agent Instructions

This repo is developed local-first. Danio must stay offline-capable and honest,
but the user has approved quality-first paid or account-backed tooling when it
materially improves autonomous completion. Paid/cloud tools require explicit
approval in the current thread or an existing entry in
`apps/aquarium_app/docs/agent/PAID_TOOL_APPROVAL_LEDGER.md`.

## Scope

- Primary app: `apps/aquarium_app`.
- Main product docs: `apps/aquarium_app/docs/product`.
- Agent setup docs: `apps/aquarium_app/docs/agent`.

## Non-Negotiable Rules

- Do not set up paid services, hosted CI, cloud projects, external accounts, or API-backed workflows unless the current thread explicitly approves that tool and purpose.
- Do not call paid APIs or require OpenAI, Supabase, Vercel, Sentry, Figma paid features, Maestro Cloud, or similar services without an approval ledger entry that covers the exact use.
- Never commit secrets, API keys, tokens, account exports, billing artifacts, or machine-local credential files.
- Paid/account-backed services are quality lanes only. They must not become required for local Danio use or replace local verification gates.
- Do not add fake premium, fake social, fake cloud sync, fake leaderboards, or dormant monetisation promises.
- Keep Danio usable without optional AI keys. Smart Hub must work locally first.
- Optional AI must degrade gracefully and must never make the app feel broken when no key or backend is configured.
- Do not make care claims that imply veterinary or professional advice. Danio is educational and practical, not a vet substitute.

## Dirty Worktree Protection

- Run `git status --short -uall` before editing and before staging.
- Use `-uall` so untracked screenshots, generated docs, or other-agent files
  are visible before you choose a working area.
- Never revert, delete, or overwrite user changes you did not make.
- If unrelated files are dirty, leave them alone.
- If files you need are dirty, inspect them and work with the changes.
- If another Codex session has active dirty work, do not stage, format, or
  rewrite those files. Either wait for a clean handoff or work only in files
  that are clearly isolated from that session's slice.
- Commit focused slices separately. Docs-only setup changes must stay separate from product behavior changes.

## Session Freshness

- When a Codex session becomes long, usage-limited, heavily compacted, or is
  about to start a broad new slice, pause at the next clean checkpoint and
  recommend starting a fresh session.
- Prefer pausing after commit/push with `git status --short -uall` clean.
- Provide a concise handoff prompt before stopping so the next session can
  continue from the current repo state without rebuilding context from chat.

## Research-First Planning

- Before substantial implementation, pause and plan from current repo state.
  Start by checking whether the work should move to a fresh session, then read
  the active repo docs, roadmap, relevant source, tests, and current worktree
  state before proposing or editing.
- Do not guess current best practice when it can be checked. For technology,
  framework, testing, platform, accessibility, AI, security, or workflow
  decisions, compare the intended approach against current primary sources
  before implementation. Prefer official docs, standards, vendor docs, repo
  docs, and directly inspected code over blogs or memory.
- Use the narrowest powerful research lane that fits the task:
  repo inspection for local truth; official docs or MCP documentation servers
  for current APIs and platform guidance; installed skills for repeatable
  workflows; browser/app tools for live UI evidence; specialist plugins only
  when they materially improve quality.
- If a useful tool, plugin, MCP server, account-backed service, or paid lane is
  missing, stop before installing or using it. Explain the benefit, expected
  cost or account requirement if known, local/no-cost alternatives, and wait for
  explicit approval or a matching approval-ledger entry.
- Record research that changes implementation direction in the slice contract,
  active handoff, or relevant agent docs so future agents can see why the
  approach was chosen.

## Local Verification Gates

Run commands from `apps/aquarium_app` unless stated otherwise.

Required standard gates for product changes:

```powershell
flutter test
flutter analyze
flutter build apk --debug --target lib/main.dart
git diff --check
```

The local quality gate can run these checks in repeatable profiles:

```powershell
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Focused
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Docs
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Full
.\scripts\quality_gates\run_local_quality_gate.ps1 -Profile Visual
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
- For substantial Danio app work, especially UI, navigation, product behavior,
  Android, or visual slices, attempt to start the Danio live-preview workflow at
  the beginning of the session so the user can follow along. Use
  `apps/aquarium_app/docs/agent/LIVE_PREVIEW_WORKFLOW.md` and keep the emulator
  visible while making changes.
- Live preview is not required for docs-only, tests-only, refactor-only, or
  device-unsafe slices, but state when it was skipped and why.
- Use `apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md` before any emulator,
  ADB, Patrol, Firebase Test Lab, live-preview, or screenshot evidence work.
- Standardize Danio live preview on the dedicated `danio_api36` emulator; do
  not use whichever emulator happens to be connected.
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
- Figma and Product Design skills may be used for visual targets. Paid Figma
  features, paid assets, Figma Code Connect, or cloud visual QA require an
  approval ledger entry for the exact purpose.
- Preserve Danio's local-first product honesty: no fake AI, fake premium, fake
  social, fake cloud sync, or care claims that imply veterinary advice.
- For visual changes, run the applicable Flutter/golden/screenshot checks from
  `apps/aquarium_app/docs/design/VISUAL_QA_CHECKLIST.md`.
- Preserve design setup docs from parallel sessions. Extend them only when the
  current slice explicitly owns that update, and keep design-baseline changes in
  their own focused commit when practical.

## Multi-Agent Workflow

- Repo-local Codex agent roles live under `.codex/`.
- Use `apps/aquarium_app/docs/agent/MULTI_AGENT_WORKFLOW.md` for the current
  coordinator, auditor, reviewer, worker, and Android QA ownership rules.
- Keep read-only auditors separate from implementation workers.
- Implementation workers may edit only in explicitly assigned git worktrees with
  disjoint file/module ownership.
- Only one Android QA owner may control emulator, ADB, Patrol, Firebase Test
  Lab, or Android screenshot evidence at a time.

## Documentation References

- Workflow charter: `apps/aquarium_app/docs/agent/WORKFLOW_CHARTER.md`
- Research protocol: `apps/aquarium_app/docs/agent/RESEARCH_PROTOCOL.md`
- Active handoff: `apps/aquarium_app/docs/agent/ACTIVE_HANDOFF.md`
- Complete-local closure ledger: `apps/aquarium_app/docs/agent/COMPLETE_LOCAL_CLOSURE_LEDGER.md`
- Verified slice execution contract: `apps/aquarium_app/docs/agent/VERIFIED_SLICE_EXECUTION_CONTRACT.md`
- Complete-local forecast: `apps/aquarium_app/docs/agent/COMPLETE_LOCAL_FORECAST.md`
- Autonomous chain handoff prompt: `apps/aquarium_app/docs/agent/AUTONOMOUS_CHAIN_HANDOFF_PROMPT.md`
- Screen inventory: `apps/aquarium_app/docs/agent/SCREEN_INVENTORY.md`
- Slice log: `apps/aquarium_app/docs/agent/SLICE_LOG.md`
- Housekeeping: `apps/aquarium_app/docs/agent/HOUSEKEEPING.md`
- Quality ladder: `apps/aquarium_app/docs/agent/QUALITY_LADDER.md`
- Source references: `apps/aquarium_app/docs/agent/SOURCE_REFERENCES.md`
- Codex setup: `apps/aquarium_app/docs/agent/CODEX_SETUP.md`
- Testing checklist: `apps/aquarium_app/docs/agent/TESTING_CHECKLIST.md`
- Autonomous quality setup: `apps/aquarium_app/docs/agent/AUTONOMOUS_QUALITY_SETUP.md`
- Finish map: `apps/aquarium_app/docs/agent/FINISH_MAP.md`
- Paid tool approval ledger: `apps/aquarium_app/docs/agent/PAID_TOOL_APPROVAL_LEDGER.md`
- Device ownership: `apps/aquarium_app/docs/agent/DEVICE_OWNERSHIP.md`
- Slice contract template: `apps/aquarium_app/docs/agent/SLICE_CONTRACT_TEMPLATE.md`
- Multi-agent workflow: `apps/aquarium_app/docs/agent/MULTI_AGENT_WORKFLOW.md`
- Live preview workflow: `apps/aquarium_app/docs/agent/LIVE_PREVIEW_WORKFLOW.md`
- Current local audit: `apps/aquarium_app/docs/product/danio-complete-local-current-audit-2026-06-13.md`
- Backlog: `apps/aquarium_app/docs/product/danio-complete-local-audit-backlog-2026-06-13.md`
