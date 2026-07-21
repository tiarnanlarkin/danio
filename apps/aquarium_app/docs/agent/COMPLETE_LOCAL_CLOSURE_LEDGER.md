# Danio Complete-Local Closure Ledger

Status: Active closure control
Created: 2026-07-05
Authority lock: `danio-completion-roadmap-authority-lock-2026-07-15/1`
Current authority marker: `danio-phone-rc-authority-reset-2026-07-19/1`
Source docs: `FINISH_MAP.md`,
`docs/product/danio-complete-local-audit-backlog-2026-06-13.md`, and
`docs/product/danio-complete-local-current-audit-2026-06-13.md`

## Purpose

This ledger is the finite issue list for Danio's complete-local finish line.
Future slices should name one or more ledger IDs before implementation starts.
New findings discovered during source or test audit must be added here before
they become implementation work.

The ledger does not replace the phone release-candidate plan or `FINISH_MAP.md`.
`plans/2026-07-19-phone-release-candidate-finalization-plan.md` is the only
ordered authority. The 2026-07-11 completion program is superseded background.
This ledger owns traceable closure IDs, closure state,
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
- The current finalization plan orders the ten planned product/test epochs and
  owns the P0/P1 release selector. P2/P3 work is accepted or parked unless the
  user explicitly reopens it; this ledger and the Finish Map cannot add a
  competing selector.
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
- Cloud/accounts, new Optional-AI provider connectors, premium, store/deploy,
  public release, and iOS remain parked unless explicitly reopened.
- Android Keystore-backed secure-storage migration remains active under
  `DCL-PREF-001`. Keyed-AI seed work, signing, legal hosting, and
  public-history recovery remain parked and cannot be selected from this phone
  roadmap.
- The current 82 lessons, 75+ species, and 40+ plants are sufficient for phone
  completion. Only an audited defect or current validator failure can require
  additional content.
- Visual assets and motion are defect-based. There is no replacement or
  animation quota; only current screenshot defects, accessibility failures,
  reduced-motion failures, or haptic-preference bypasses require changes.
- The repo-owned execution plan is
  `plans/2026-07-19-phone-release-candidate-finalization-plan.md`; the visual
  control surface is the Danio phone atlas in Figma.

## Active Findings

| ID | Finding | How Found | Evidence | Disposition | Closure State | Lane | User Input | Done Condition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DCL-DR-002 | Schema migration and corruption-recovery paths have complete-local confidence. | `DR-2026-07-16-007` fixed inaccessible `ioError` retry; `DR-2026-07-16-008` fixed false recovery-copy assurance; `DR-2026-07-16-009` proved malformed-file retry boundaries; `DR-2026-07-16-010` proved cancel/back safety; `DR-2026-07-16-011` proved scoped recovery deletion; `DR-2026-07-16-012` proved honest recovery failure; `DR-2026-07-16-013` proved v0 preference preservation; `DR-2026-07-16-014` proved missing, zero-byte, and whitespace-only local JSON starts healthy and empty without rewrite or artifacts. | `DCL_DR_002_MIGRATION_CORRUPTION_RECOVERY_MATRIX.md`; `I/O load error offers real retry without destructive start fresh`; `malformed JSON copy failure does not advertise recovery path`; `corruption without recovery path never claims a copy exists`; `unchanged malformed JSON retry stays corrupted and blocks empty success`; `repaired malformed JSON succeeds only through retry without rewriting repair`; `canceling start fresh preserves corrupted storage and provider state`; `system back dismisses start fresh without recovery side effects`; `start fresh deletes only corrupt main and exposes healthy empty storage`; `failed start fresh retains recovery state without false success`; `v0 stamp preserves every existing preference value and type`; `missing local JSON loads healthy empty without recovery artifacts`; `empty local JSON loads healthy empty without rewrite or recovery artifacts`; row-closing Full gate. | `VERIFY_LOCALLY` | closed | Data resilience | No | Migration/corruption paths are proven by source/test or owned-device walkthrough evidence; any missing behavior is fixed locally and Full gate passes. |
| DCL-DR-003 | Broader create/edit/delete/undo data-resilience coverage needs final P0/P1 closure. | F1 through F38 are settled. `DR-2026-07-21-062` proves and fixes Wishlist double-submit/captured-callback replay; complete matrix reinspection found no other current P0/P1 and explicitly parked lower-severity omission-only evidence gaps. | `DCL_DR_003_CRUD_UNDO_RESILIENCE_MATRIX.md`; `captured stale add callback cannot replay across failure and retry`; reset-assisted Full with 2,279 tests/lint/analyze/APK in 187,023 ms; `FINISH_MAP.md`; rolling and archived `SLICE_LOG.md`. | `VERIFY_LOCALLY` | closed | Data resilience | No | Reopen only if CRUD/undo behavior changes or contradictory current P0/P1 evidence invalidates the settled F1-F38 matrix. |
| DCL-DR-004 | Livestock-removal history needs one explicit backup tombstone relationship contract. | Current relationship validation requires live mapped targets, while valid `livestockRemoved` history can outlive its livestock record. | `FINISH_MAP.md` Current Data-Resilience Note; current BackupService relationship validation and import tests. | `VERIFY_LOCALLY` | open | Data resilience | No | A nonblank `livestockRemoved` livestock ID is preserved verbatim as an opaque tombstone through self-generated backup preview/import without entering the live ID map or resurrecting livestock; every other dangling, malformed, cross-tank, or invalid relationship still fails; Full passes. |
| DCL-AI-001 | Any local persistence of AI output requires explicit user confirmation. Fish ID and AI Compatibility each have a known unconfirmed AI-history persistence gap. | Current source writes Fish ID and AI Compatibility summaries to AI history immediately after successful responses, while already-closed AI surfaces use confirmation. | `lib/features/smart/fish_id/fish_id_screen.dart`; `lib/widgets/compatibility_checker_widget.dart`; current release-candidate plan; `FINISH_MAP.md` AI confirmation row. | `VERIFY_LOCALLY` | open | Optional AI | No | Fish ID and AI Compatibility each prove dismiss/cancel writes nothing, confirm writes exactly once, and a history-write failure never hides the visible result; every already-gated AI surface is reverified. |
| DCL-P1-003 | Guided tools may still have tool-specific save/apply gaps found by walkthroughs. | Finish Map keeps Guided tools in progress. | `FINISH_MAP.md` Guided tools row; backlog `CL-P1-006`. | `VERIFY_LOCALLY` | open | Normal-user P1 depth | No | Walkthrough/source audit finds a concrete missing save/apply path and fixes it, or records no-current-gap evidence for the current tool set. |
| DCL-P1-004 | Timeline and journal still need future source-specific guided-tool or optional-AI save handoff walkthroughs. | Finish Map keeps Timeline and journal in progress. | `FINISH_MAP.md` Timeline and journal row; backlog `CL-P1-008`. | `VERIFY_LOCALLY` | open | Normal-user P1 depth | No | Current save handoffs are walked through or tested; any missing timeline label/context path is fixed with focused proof. |
| DCL-P1-005 | Learning needs a final verification pass, not a breadth quota. | The user accepted the current 82-lesson breadth for phone completion; only audited defects or validator failures remain actionable. | `FINISH_MAP.md` Learning row; `test/quality/content_validation_test.dart`; backlog `CL-P1-004`. | `VERIFY_LOCALLY` | open | Normal-user P1 depth | No | Current learning validators and representative phone paths pass; every concrete navigation, lock, practice-link, citation, content, or visual defect found by that audit is fixed with focused proof, with no requirement to add lessons or interaction types. |
| DCL-P1-006 | Species and plants need a final verification pass, not database expansion. | The user accepted the current 75+ species and 40+ plants for phone completion; only audited defects or validator failures remain actionable. | `FINISH_MAP.md` Species and plants row; `test/quality/content_validation_test.dart`; backlog `CL-P1-003`. | `VERIFY_LOCALLY` | open | Content and P1 depth | No | Current species/plant validators and representative phone paths pass; every concrete data, source, image, handoff, or display defect found by that audit is fixed with focused proof, with no requirement to add entries. |
| DCL-PREF-001 | Preferences needs secure user AI-key storage and final provider/privacy proof. | The current key path is preference-backed; the authorized phone candidate requires Android Keystore-backed storage with safe legacy migration. | `FINISH_MAP.md` Preferences row; current release-candidate plan; current AI key service and tests. | `VERIFY_LOCALLY` | open | Preferences and Optional AI | No | `ApiKeyStore` secure read/write/delete and safe legacy migration pass; failed migration retains the legacy value; deletion clears both locations; no plaintext key appears in preferences, logs, backups, errors, or diagnostics; keyless/provider/privacy paths pass. |
| DCL-CONTENT-001 | Current content and source-risk validators need a finite final audit. | Finish Map and backlog leave content validation open, but accepted breadth removes speculative expansion from scope. | `FINISH_MAP.md` Content validation row; `test/quality/content_validation_test.dart`; backlog `CL-QA-005`. | `VERIFY_LOCALLY` | open | Content and rule confidence | No | The current validator covers the identified locked-content, source, unsafe-care, and educational-positioning risks and passes; add a validator only for a concrete uncovered risk, then fix any failure. |
| DCL-RULE-001 | Current recommendation, compatibility, emergency, unit, and calculation rules need a finite executable inventory. | Direct coverage is missing for the full CompatibilityService matrix, all five Tank Volume shapes, and complete Unit Converter numeric families. | `FINISH_MAP.md` Rule tests row; current release-candidate plan; relevant service/widget tests. | `VERIFY_LOCALLY` | open | Content and rule confidence | No | Temperature, pH, GH, tank size, school size, conflicts, temperament, predation, five Tank Volume shapes, and length/volume/hardness conversions have numeric executable proof; any wrong behavior is fixed in its own P1 epoch; all mapped suites pass. |
| DCL-A11Y-001 | Phone accessibility remains open across contrast, touch targets, labels, text scaling, reduced motion, and non-colour-only status. | Finish Map keeps Accessibility in progress. | `FINISH_MAP.md` Accessibility row; backlog `CL-P2-004`. | `VERIFY_LOCALLY` | open | Phone accessibility and visual polish | No | Each ordered phone cluster is audited with current screenshots and focused widget/accessibility paths; all concrete failures are fixed and the affected tests and Visual checks pass, with no untracked phone cluster remaining. |
| DCL-VIS-001 | Current phone assets need defect verification; the March visual asset audit is historical evidence, not current defect authority. | The 2026-07-04 phone screenshots and current repo assets supersede assumptions from the 2026-03-29 audit. | `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/`; `docs/visual-asset-audit.md`; `docs/design/BASELINES.md`. | `VERIFY_LOCALLY` | open | Phone visual polish | No | Current phone screenshots and repo assets are inspected; every concrete weak, mismatched, missing, licensed-source, clipping, or contrast defect is fixed with affected Visual proof, or no-current-gap evidence closes the row. There is no asset-replacement quota. |
| DCL-VIS-002 | Selective visual regression needs a final defect-based baseline review. | Current July phone screenshots and the existing golden harness provide a bounded baseline set. | `FINISH_MAP.md` Whole-app phone audit row; `docs/design/BASELINES.md`; `test/quality/visual_baseline_manifest_test.dart`. | `VERIFY_LOCALLY` | open | Phone visual polish | No | The baseline manifest points to current phone evidence, changed high-risk surfaces have targeted screenshot/golden proof where useful, and all current baseline checks pass; no minimum number of new goldens is required. |
| DCL-TAB-001 | Tablet layout, accessibility, visual polish, and performance remain incomplete beyond the current 96-row route/evidence map, but the user has sequenced all tablet work after phone complete-local. | User confirmed phone-first completion on 2026-07-11; Finish Map and whole-app tablet evidence remain available for later resumption. | `FINISH_MAP.md` Tablet layout row; `FINISH_MAP.md` Whole-app tablet audit row; `SCREEN_INVENTORY.md`; `plans/2026-07-11-phone-complete-local-completion-program.md`. | `PHASE_PARKED` | parked | Tablet layout, accessibility, visual polish, and performance | Yes | Does not block phone complete-local. Reopen after the phone candidate closes, then define the tablet layout/accessibility/visual/performance boundary from retained evidence. |
| DCL-MOTION-001 | Phone motion and haptics need final reduced-motion and preference enforcement. | Direct platform haptic calls and default-enabled helper calls bypass a single persisted preference-aware boundary. | `FINISH_MAP.md` Motion and haptics row; current release-candidate plan; relevant reduced-motion and haptic tests. | `VERIFY_LOCALLY` | open | Phone motion and visual polish | No | A source guard permits platform haptics only inside the preference-aware adapter; disabled emits zero platform calls; enabled actions do not duplicate calls; reduced-motion checks pass across the five phone clusters. |
| DCL-PERF-001 | Android phone performance measurement has targets but lacks final profile-mode evidence. | Existing constants do not provide repeatable scenario samples or a machine-readable report on the approved emulator. | `FINISH_MAP.md` Performance row; `docs/agent/PERFORMANCE_TARGETS.md`; `test/utils/performance_targets_test.dart`; current release-candidate plan. | `VERIFY_LOCALLY` | open | Phone performance | No | The profile harness records commit, `danio_api36`, scenario, samples, median/frame statistics, budget, and result; all six current budgets pass with the specified warm-up/iteration/trace counts. |
| DCL-QA-001 | Debug QA seed coverage has one remaining real keyed-AI seed only if it can avoid fake provider readiness. | Finish Map keeps Debug QA seeds in progress. | `FINISH_MAP.md` Debug QA seeds row; backlog `CL-QA-007`. | `EXTERNAL_PARKED` | parked | Debug QA and Optional AI | Yes | Leave parked unless a local, honest keyed-AI seed can be created without secrets or fake readiness; otherwise accept no-key/no-AI seed evidence. |
| DCL-EXT-001 | Non-OpenAI provider connectors are not implemented. | Finish Map parks provider expansion downstream of local quality and approval. | `FINISH_MAP.md` Optional AI providers row; backlog `CL-P3-001`; paid-tool ledger. | `EXTERNAL_PARKED` | parked | Optional AI providers | Yes | Only proceed after explicit user approval and a real local/provider implementation plan; unavailable paths remain honest until then. |
| DCL-PREMIUM-001 | Premium AI remains conceptual and must not appear as fake product behavior. | Finish Map marks Premium AI path not started. | `FINISH_MAP.md` Premium AI path row; backlog `CL-P3-003`. | `EXTERNAL_PARKED` | parked | Premium and monetisation | Yes | Park until the core local app is excellent and the user approves premium scope; no visible fake premium behavior is added. |
| DCL-RC-001 | Final phone acceptance is last and valid only after every earlier phone row closes or is explicitly accepted/parked. | The current finite plan places candidate signoff after the ten planned product/test epochs; tablet and external work remain outside the boundary. | `QUALITY_LADDER.md`; `plans/2026-07-19-phone-release-candidate-finalization-plan.md`. | `VERIFY_LOCALLY` | open | Final evidence | No | No P0/P1 remains; all preceding rows are closed, accepted, or parked; route/render, content/rule, data/privacy, Visual, Full, AndroidPrep, performance, emulator, and black-box checks pass; product/tree/device/gate/APK SHA-256 evidence and P2/P3 limitations are recorded on clean aligned main. |
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

`DCL-DR-001` and `DCL-DR-002` are closed. `DCL-DR-003` is closed after settled
findings F1 through F38, complete current-matrix reinspection, and the required
final Full gate in epoch 062. `DCL-DR-004` is the next manual action; do not select a
later sequence item first. The next manual action follows
`plans/2026-07-19-phone-release-candidate-finalization-plan.md`.

Rows in `parked` or `decision_required` closure state are stop-and-ask items,
not automatic implementation targets. This ledger records their state and done
conditions. The current finalization plan owns the fixed P0/P1 sequence; P2/P3
stays accepted or parked unless explicitly reopened. Frozen claim, budget,
launch, and successor material cannot authorize, select, reorder, or resume
product work.
