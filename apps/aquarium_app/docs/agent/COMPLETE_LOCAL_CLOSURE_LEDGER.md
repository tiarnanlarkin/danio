# Danio Complete-Local Closure Ledger

Status: Active closure control
Created: 2026-07-05
Authority lock: `danio-completion-roadmap-authority-lock-2026-07-15/1`
Source docs: `FINISH_MAP.md`,
`docs/product/danio-complete-local-audit-backlog-2026-06-13.md`, and
`docs/product/danio-complete-local-current-audit-2026-06-13.md`

## Purpose

This ledger is the finite issue list for Danio's complete-local finish line.
Future slices should name one or more ledger IDs before implementation starts.
New findings discovered during source or test audit must be added here before
they become implementation work.

The ledger does not replace the phone completion program or `FINISH_MAP.md`.
`plans/2026-07-11-phone-complete-local-completion-program.md` is the only
ordered phase authority. This ledger owns traceable closure IDs, closure state,
disposition, evidence, and exact done conditions. The Finish Map owns category
status and quality-bar summaries only. Live Git, source, tests, and fresh
commands remain factual truth.

## Dispositions

| Disposition | Meaning |
| --- | --- |
| `FIX_LOCALLY` | Implement or repair local app behavior with focused proof. |
| `VERIFY_LOCALLY` | The next work is evidence gathering, walkthrough, or audit before code. |
| `PRODUCT_DECISION` | The app can only proceed after the user chooses scope or accepts a limitation. |
| `PHASE_PARKED` | Intentionally sequenced outside the active phone completion phase; reopen only after the phase exit or fresh user direction. |
| `EXTERNAL_PARKED` | Outside complete-local unless the user explicitly approves cloud, account, paid, key, store, or release work. |
| `ACCEPTED_LOCAL_LIMITATION` | Documented as acceptable for complete-local; re-open only with new product direction. |
| `NOT_CURRENT_ARCHIVED` | Older finding is superseded by newer repo evidence and is not a current slice target. |

## Closure States

Closure state is separate from disposition and uses exactly these values:

| Closure State | Meaning |
| --- | --- |
| `open` | Active-scope work or verification remains. |
| `closed` | The row's done condition is satisfied, accepted, or superseded by current evidence. |
| `parked` | The row is outside the active phone scope and cannot be selected without the required reopening decision. |
| `decision_required` | Active-scope closure is blocked on a real product decision. |

`PHASE_PARKED` and `EXTERNAL_PARKED` dispositions require `parked` closure
state. `ACCEPTED_LOCAL_LIMITATION` and `NOT_CURRENT_ARCHIVED` require `closed`.
Other dispositions may be `open`, `closed`, or `decision_required` as current
evidence requires.

## Ledger Rules

- Every implementation slice must list the ledger ID it advances in its slice
  contract, `ACTIVE_HANDOFF.md`, or `SLICE_LOG.md`.
- If the roadmap, source, tests, and ledger disagree, stop and reconcile the
  docs before editing product code.
- The phone completion program orders phases. This ledger and the Finish Map
  must not apply a competing P0/P1/P2/P3 or disposition-based selector.
- Prefer local-only evidence: focused tests, local gates, source inspection,
  local screenshots, local Android builds, and owned emulator proof.
- External/cloud/account/paid/API-key/store/deploy items are parked outside the
  complete-local path unless the user gives explicit current-thread approval.
- Do not close a ledger row from stale chat memory. Use current repo docs,
  current source, current tests, and current command output.
- Open phone rows are verification-first. Implementation begins only after a
  current source/test, validator, screenshot, accessibility, motion/haptic, or
  performance audit proves one concrete defect.

## Current Phone Completion Boundary

Confirmed by the user on 2026-07-11:

- The active complete-local target is a polished, resilient, local-first
  Android phone app.
- Tablet implementation, tablet polish, and tablet performance are parked
  until the phone phase closes. Current tablet evidence is retained but does
  not block the phone release-candidate row.
- Cloud/accounts, API-key/provider expansion, premium, store/deploy, public
  release, and iOS remain parked unless explicitly reopened.
- Keyed-AI seed work, signing, legal hosting, and public-history recovery are
  also parked and cannot be selected from this phone roadmap.
- The current 82 lessons, 75+ species, and 40+ plants are sufficient for phone
  completion. Only an audited defect or current validator failure can require
  additional content.
- Visual assets and motion are defect-based. There is no replacement or
  animation quota; only current screenshot defects, accessibility failures,
  reduced-motion failures, or haptic-preference bypasses require changes.
- The repo-owned execution plan is
  `plans/2026-07-11-phone-complete-local-completion-program.md`; the visual
  control surface is the Danio phone atlas in Figma.

## Active Findings

| ID | Finding | How Found | Evidence | Disposition | Closure State | Lane | User Input | Done Condition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DCL-DR-002 | Schema migration and corruption-recovery paths remain open for complete-local confidence. | `DR-2026-07-16-007` fixed inaccessible `ioError` retry; `DR-2026-07-16-008` fixed false recovery-copy assurance after backup-copy failure; `DR-2026-07-16-009` proved repaired and unchanged malformed real-file retries; `DR-2026-07-16-010` proved cancel/back cannot reach destructive recovery; `DR-2026-07-16-011` proved confirmed recovery is main-file scoped and exposes healthy emptiness only after deletion; `DR-2026-07-16-012` proved recovery failure retains retryable state without provider refresh or false success; `DR-2026-07-16-013` proved the v0 schema stamp preserves every existing preference key, value, and primitive type. | `DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md`; `I/O load error offers real retry without destructive start fresh`; `malformed JSON copy failure does not advertise recovery path`; `corruption without recovery path never claims a copy exists`; `unchanged malformed JSON retry stays corrupted and blocks empty success`; `repaired malformed JSON succeeds only through retry without rewriting repair`; `canceling start fresh preserves corrupted storage and provider state`; `system back dismisses start fresh without recovery side effects`; `start fresh deletes only corrupt main and exposes healthy empty storage`; `failed start fresh retains recovery state without false success`; `v0 stamp preserves every existing preference value and type`. | `VERIFY_LOCALLY` | open | Data resilience | No | Migration/corruption paths are proven by source/test or owned-device walkthrough evidence; any missing behavior is fixed locally and Full gate passes. |
| DCL-DR-003 | Broader create/edit/delete/undo data-resilience coverage needs a final current proof inventory. | Finish Map `Data resilience` evidence records extensive DS coverage, so remaining work must be proven rather than assumed. | `FINISH_MAP.md` Data resilience row; archived `SLICE_LOG.md` DS-2026-07-04-002 through DS-2026-07-05-043. | `VERIFY_LOCALLY` | open | Data resilience | No | A fresh source/test matrix accounts for current create, edit, delete, bulk-delete, undo, false-success, and orphan boundaries; each proven gap receives its own focused RED/GREEN slice, or the row closes with no-current-gap evidence and Full passes. |
| DCL-DR-004 | Relationship-mapping import integrity needs a final fresh audit after DS-034 through DS-043. | Recent DS chain closed several direct-import relationship boundaries but the Finish Map still keeps relationship-mapping walkthrough coverage open. | `FINISH_MAP.md` Current Data-Resilience Note; `SLICE_LOG.md` DS-034 through DS-043; DS-2026-07-06-046 tightened direct-import preflight for child rows whose backup tank IDs are not imported; DS-2026-07-06-047 tightened direct-import relationship preflight so missing relationship target IDs are rejected before imported tank saves; DS-2026-07-06-048 tightened direct-import required ID preflight so whitespace-only tank and child record IDs are rejected before imported tank saves. | `VERIFY_LOCALLY` | open | Data resilience | No | Audit proves no remaining current direct import relationship false-success boundary, or one specific boundary is fixed with service tests and Full gate. |
| DCL-AI-001 | Any local persistence of AI output requires explicit user confirmation. Fish ID and AI Compatibility each have a known unconfirmed AI-history persistence gap. | Current source writes Fish ID and AI Compatibility summaries to AI history immediately after successful responses, while already-closed AI surfaces use confirmation. | `lib/features/smart/fish_id/fish_id_screen.dart`; `lib/widgets/compatibility_checker_widget.dart`; phone completion program Phase 2; `FINISH_MAP.md` AI confirmation row. | `VERIFY_LOCALLY` | open | Optional AI | No | Close Fish ID and AI Compatibility in separate future single-slice epochs, each with cancel/no-write and confirm/write-once RED/GREEN proof; then audit the remaining current AI surfaces and record no additional unconfirmed persistence. |
| DCL-P1-003 | Guided tools may still have tool-specific save/apply gaps found by walkthroughs. | Finish Map keeps Guided tools in progress. | `FINISH_MAP.md` Guided tools row; backlog `CL-P1-006`. | `VERIFY_LOCALLY` | open | Normal-user P1 depth | No | Walkthrough/source audit finds a concrete missing save/apply path and fixes it, or records no-current-gap evidence for the current tool set. |
| DCL-P1-004 | Timeline and journal still need future source-specific guided-tool or optional-AI save handoff walkthroughs. | Finish Map keeps Timeline and journal in progress. | `FINISH_MAP.md` Timeline and journal row; backlog `CL-P1-008`. | `VERIFY_LOCALLY` | open | Normal-user P1 depth | No | Current save handoffs are walked through or tested; any missing timeline label/context path is fixed with focused proof. |
| DCL-P1-005 | Learning needs a final verification pass, not a breadth quota. | The user accepted the current 82-lesson breadth for phone completion; only audited defects or validator failures remain actionable. | `FINISH_MAP.md` Learning row; `test/quality/content_validation_test.dart`; backlog `CL-P1-004`. | `VERIFY_LOCALLY` | open | Normal-user P1 depth | No | Current learning validators and representative phone paths pass; every concrete navigation, lock, practice-link, citation, content, or visual defect found by that audit is fixed with focused proof, with no requirement to add lessons or interaction types. |
| DCL-P1-006 | Species and plants need a final verification pass, not database expansion. | The user accepted the current 75+ species and 40+ plants for phone completion; only audited defects or validator failures remain actionable. | `FINISH_MAP.md` Species and plants row; `test/quality/content_validation_test.dart`; backlog `CL-P1-003`. | `VERIFY_LOCALLY` | open | Content and P1 depth | No | Current species/plant validators and representative phone paths pass; every concrete data, source, image, handoff, or display defect found by that audit is fixed with focused proof, with no requirement to add entries. |
| DCL-PREF-001 | Preferences still has final AI/provider walkthrough gaps. | Finish Map keeps Preferences in progress. | `FINISH_MAP.md` Preferences row; backlog/current audit preference notes. | `VERIFY_LOCALLY` | open | Preferences and Optional AI | No | Current provider/privacy/preference walkthroughs are audited locally; any missing honest-copy or persistence gap is fixed with focused tests. |
| DCL-CONTENT-001 | Current content and source-risk validators need a finite final audit. | Finish Map and backlog leave content validation open, but accepted breadth removes speculative expansion from scope. | `FINISH_MAP.md` Content validation row; `test/quality/content_validation_test.dart`; backlog `CL-QA-005`. | `VERIFY_LOCALLY` | open | Content and rule confidence | No | The current validator covers the identified locked-content, source, unsafe-care, and educational-positioning risks and passes; add a validator only for a concrete uncovered risk, then fix any failure. |
| DCL-RULE-001 | Current recommendation, compatibility, emergency, unit, and calculation rules need a finite test inventory. | Finish Map keeps rule confidence open without proving a current missing rule family. | `FINISH_MAP.md` Rule tests row; backlog `CL-QA-004`. | `VERIFY_LOCALLY` | open | Content and rule confidence | No | A source/test inventory maps each current high-risk rule family to focused coverage; add tests and fix behavior only for a concrete uncovered or failing rule, then close when the inventory and tests pass. |
| DCL-A11Y-001 | Phone accessibility remains open across contrast, touch targets, labels, text scaling, reduced motion, and non-colour-only status. | Finish Map keeps Accessibility in progress. | `FINISH_MAP.md` Accessibility row; backlog `CL-P2-004`. | `VERIFY_LOCALLY` | open | Phone accessibility and visual polish | No | Each ordered phone cluster is audited with current screenshots and focused widget/accessibility paths; all concrete failures are fixed and the affected tests and Visual checks pass, with no untracked phone cluster remaining. |
| DCL-VIS-001 | Current phone assets need defect verification; the March visual asset audit is historical evidence, not current defect authority. | The 2026-07-04 phone screenshots and current repo assets supersede assumptions from the 2026-03-29 audit. | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`; `docs/visual-asset-audit.md`; `docs/design/BASELINES.md`. | `VERIFY_LOCALLY` | open | Phone visual polish | No | Current phone screenshots and repo assets are inspected; every concrete weak, mismatched, missing, licensed-source, clipping, or contrast defect is fixed with affected Visual proof, or no-current-gap evidence closes the row. There is no asset-replacement quota. |
| DCL-VIS-002 | Selective visual regression needs a final defect-based baseline review. | Current July phone screenshots and the existing golden harness provide a bounded baseline set. | `FINISH_MAP.md` Whole-app phone audit row; `docs/design/BASELINES.md`; `test/quality/visual_baseline_manifest_test.dart`. | `VERIFY_LOCALLY` | open | Phone visual polish | No | The baseline manifest points to current phone evidence, changed high-risk surfaces have targeted screenshot/golden proof where useful, and all current baseline checks pass; no minimum number of new goldens is required. |
| DCL-TAB-001 | Tablet layout, accessibility, visual polish, and performance remain incomplete beyond the current 96-row route/evidence map, but the user has sequenced all tablet work after phone complete-local. | User confirmed phone-first completion on 2026-07-11; Finish Map and whole-app tablet evidence remain available for later resumption. | `FINISH_MAP.md` Tablet layout row; `FINISH_MAP.md` Whole-app tablet audit row; `SCREEN_INVENTORY.md`; `plans/2026-07-11-phone-complete-local-completion-program.md`. | `PHASE_PARKED` | parked | Tablet layout, accessibility, visual polish, and performance | Yes | Does not block phone complete-local. Reopen after the phone candidate closes, then define the tablet layout/accessibility/visual/performance boundary from retained evidence. |
| DCL-MOTION-001 | Phone motion and haptics need a defect audit for reduced-motion and haptic-preference compliance. | Existing motion and haptic integration exists; the locked scope has no new-animation quota. | `FINISH_MAP.md` Motion and haptics row; current phone screenshots; relevant reduced-motion and haptic tests; backlog `CL-P2-005`. | `VERIFY_LOCALLY` | open | Phone motion and visual polish | No | Current animated and haptic phone flows are inventoried; every reduced-motion failure, haptic-preference bypass, or clarity defect is fixed with focused proof, or the row closes with no-current-gap evidence. No new animation is required. |
| DCL-PERF-001 | Android phone performance measurement has targets but lacks final local evidence for the active phase. | Finish Map keeps Performance in progress and the user confirmed phone-first completion on 2026-07-11. | `FINISH_MAP.md` Performance row; `docs/agent/PERFORMANCE_TARGETS.md`; `test/utils/performance_targets_test.dart`; `plans/2026-07-11-phone-complete-local-completion-program.md`. | `VERIFY_LOCALLY` | open | Phone performance | No | Startup, warm resume, tab switching, tank animation, scrolling, and local image first paint are measured on the owned Android phone target and summarized without noisy raw logs. |
| DCL-QA-001 | Debug QA seed coverage has one remaining real keyed-AI seed only if it can avoid fake provider readiness. | Finish Map keeps Debug QA seeds in progress. | `FINISH_MAP.md` Debug QA seeds row; backlog `CL-QA-007`. | `EXTERNAL_PARKED` | parked | Debug QA and Optional AI | Yes | Leave parked unless a local, honest keyed-AI seed can be created without secrets or fake readiness; otherwise accept no-key/no-AI seed evidence. |
| DCL-EXT-001 | Non-OpenAI provider connectors are not implemented. | Finish Map parks provider expansion downstream of local quality and approval. | `FINISH_MAP.md` Optional AI providers row; backlog `CL-P3-001`; paid-tool ledger. | `EXTERNAL_PARKED` | parked | Optional AI providers | Yes | Only proceed after explicit user approval and a real local/provider implementation plan; unavailable paths remain honest until then. |
| DCL-PREMIUM-001 | Premium AI remains conceptual and must not appear as fake product behavior. | Finish Map marks Premium AI path not started. | `FINISH_MAP.md` Premium AI path row; backlog `CL-P3-003`. | `EXTERNAL_PARKED` | parked | Premium and monetisation | Yes | Park until the core local app is excellent and the user approves premium scope; no visible fake premium behavior is added. |
| DCL-RC-001 | Final phone acceptance is last and only valid after every earlier active phone-program row closes or is explicitly accepted/parked. | The phone completion program places final acceptance in terminal Phase 7; tablet and external work are outside the active phone boundary. | Phone completion program Phase 7; `QUALITY_LADDER.md`; `plans/2026-07-11-phone-complete-local-completion-program.md`. | `VERIFY_LOCALLY` | open | Final evidence | No | Every earlier active phone row is closed or explicitly accepted/parked; Full, AndroidPrep, affected phone-state recheck, current content validation, current visual baseline checks, product-truth scan, and the final phone QA note pass on clean main with no known untracked phone defect. |
| DCL-EXT-002 | Store/deploy, public release, cloud/accounts, signing, legal hosting, public-history recovery, and iOS are outside complete-local. | These lanes require separate user authority, accounts, secrets, legal/release decisions, or public-history recovery planning. | `AGENTS.md`; `ACTIVE_HANDOFF.md`; `PAID_TOOL_APPROVAL_LEDGER.md`; current security hold. | `EXTERNAL_PARKED` | parked | Release and external services | Yes | Do not start any listed lane until phone complete-local is met and the user explicitly authorizes its separate plan. |

## Closed, Accepted, Or Superseded Findings

| ID | Finding | Superseding Evidence | Disposition | Closure State | Rule |
| --- | --- | --- | --- | --- | --- |
| DCL-DR-001 | Restore walkthrough and restore failure behavior required a complete current source/test matrix. | Phase 1 Task 1.1; `DR-2026-07-16-001` through `DR-2026-07-16-006`; `DCL_DR_001_RESTORE_BEHAVIOR_MATRIX.md`; F1 through F3 are locally fixed, F4 through F6 are locally verified with no further product gap, every ordered path has named evidence, and the final Full gate passed. | `VERIFY_LOCALLY` | closed | Reopen only if restore behavior changes or fresh evidence exposes an unexplained false-success, rollback, cleanup, error-replacement, or user-feedback path. |
| DCL-ARCH-001 | The 2026-06-13 Android emulator transport blocker prevented full fresh screen captures during that older audit. | Current Finish Map records 2026-07-04 phone and tablet whole-app maps as locally verified with all 96 `SCREEN_INVENTORY.md` rows passing. | `NOT_CURRENT_ARCHIVED` | closed | Do not use this as a current blocker unless a fresh device preflight reproduces it. |
| DCL-DR-005 | Future debounced local writers need app-kill flush coverage when new debounced writers are added. | DS-2026-07-05-044 source inventory found the current durable debounced local writers are gems and achievement progress; `main.dart` flushes pending gem writes on paused/inactive/detached, `_AchievementProgressLifecycleListener` flushes achievement progress on paused/detached, and focused lifecycle/persistence tests cover those paths. The current profile lifecycle observer flushes the already-visible profile snapshot after immediate saves, so it is not an open debounced-writer target. | `NOT_CURRENT_ARCHIVED` | closed | No current implementation target remains. Re-open only when a new durable debounced local writer is added or the lifecycle proof changes. |
| DCL-P1-001 | Fuller dedicated plant inventory and broader seasonal Living Tank variants were optional product-depth expansion. | On 2026-07-11 the user accepted the current data-derived plant, aquascape, decoration, progression, and seasonal cues as sufficient for phone complete-local. | `ACCEPTED_LOCAL_LIMITATION` | closed | Fix concrete defects found by later phone quality passes. Reopen dedicated plant inventory or broader seasonal variants only after fresh user direction. |
| DCL-P1-002 | Seasonal cosmetics and deeper plant/decor collections were optional rewards-depth expansion. | On 2026-07-11 the user accepted the current room vibes, badges, inventory, earned decorations, and equip controls as sufficient for phone complete-local. | `ACCEPTED_LOCAL_LIMITATION` | closed | Fix concrete defects found by later phone quality passes. Reopen broader cosmetic or collection depth only after fresh user direction. |

## Next Ledger Target Rule

`DCL-DR-001` is closed: F1 through F3 are locally fixed and F4 through F6 are
locally verified. `DCL-DR-002` is the current manual ledger target and remains
open; `DCL-DR-002-F1` and `DCL-DR-002-F2` are locally fixed, and
`DCL-DR-002-F3`, `DCL-DR-002-F4`, `DCL-DR-002-F5`, `DCL-DR-002-F6`, and
`DCL-DR-002-F7` are locally verified. After this checkpoint is clean, pushed,
and aligned, continue the next manual F8 local-JSON first-run proof under marker
`danio-dcl-dr-002-local-json-first-run-proof-2026-07-16/1`. Do not select
`DCL-DR-003`, `DCL-DR-004`, or a later phone phase first.

Rows in `parked` or `decision_required` closure state are stop-and-ask items,
not automatic implementation targets. This ledger records their state and done
conditions. The locked phone completion program retains the seven ordered phone
phases. Frozen claim, budget, launch, and successor material cannot authorize,
select, reorder, or resume product work.
