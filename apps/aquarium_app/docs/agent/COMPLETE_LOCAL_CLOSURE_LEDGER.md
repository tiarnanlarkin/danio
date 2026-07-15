# Danio Complete-Local Closure Ledger

Status: Active closure control
Created: 2026-07-05
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
Other dispositions may be `open` or `decision_required` as current evidence
requires.

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

## Current Phone Completion Boundary

Confirmed by the user on 2026-07-11:

- The active complete-local target is a polished, resilient, local-first
  Android phone app.
- Tablet implementation, tablet polish, and tablet performance are parked
  until the phone phase closes. Current tablet evidence is retained but does
  not block the phone release-candidate row.
- Cloud/accounts, API-key/provider expansion, premium, store/deploy, public
  release, and iOS remain parked unless explicitly reopened.
- The repo-owned execution plan is
  `plans/2026-07-11-phone-complete-local-completion-program.md`; the visual
  control surface is the Danio phone atlas in Figma.

## Active Findings

| ID | Finding | How Found | Evidence | Disposition | Closure State | Lane | User Input | Done Condition |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DCL-DR-001 | Restore walkthrough and restore failure behavior still need closure evidence beyond the recent photo/import hardening. | The phone completion program begins product work with Phase 1 data resilience; the Finish Map and backlog keep Backup/Data resilience in progress after DS-043. | Phone completion program Phase 1; `FINISH_MAP.md` Backup and restore row; backlog `CL-P1-009`; `CL-QA-006`; DS-2026-07-05-045 added executable proof that restored photo cleanup runs when tank import fails after photo extraction; DS-2026-07-06-046 added executable proof that unknown child backup tank IDs are rejected before any imported tank save is attempted; DS-2026-07-06-047 added executable proof that missing direct-import relationship targets are rejected before any imported tank save is attempted; DS-2026-07-06-048 added executable proof that trim-empty direct-import required tank and child record IDs are rejected before any imported tank save is attempted; DS-2026-07-06-049 added executable proof that restored-photo cleanup failures do not mask the original tank import failure in the import flow; DS-2026-07-06-050 added executable proof that the Backup & Restore screen's outer failure cleanup is also best-effort before reporting the original import failure. | `VERIFY_LOCALLY` | open | Data resilience | No | Current restore paths are audited from source/tests, any missing false-success or rollback behavior is fixed with RED/GREEN proof, and Full gate passes. |
| DCL-DR-002 | Schema migration and corruption-recovery walkthroughs remain open for complete-local confidence. | Finish Map next actions name restore and migration Android walkthrough QA. | `FINISH_MAP.md` Backup and restore row; `FINISH_MAP.md` next development push; `docs/product/danio-complete-local-current-audit-2026-06-13.md` local data notes. | `VERIFY_LOCALLY` | open | Data resilience | No | Migration/corruption paths are proven by source/test or owned-device walkthrough evidence; any missing behavior is fixed locally and Full gate passes. |
| DCL-DR-003 | Broader create/edit/delete/undo data-resilience coverage is not fully closed. | Finish Map `Data resilience` next action still names create/edit/delete coverage after many DS slices. | `FINISH_MAP.md` Data resilience row; `SLICE_LOG.md` DS-2026-07-04-002 through DS-2026-07-05-043. | `FIX_LOCALLY` | open | Data resilience | No | Fresh source/test audit identifies each remaining false-success or orphan boundary, fixes one small boundary per slice or safe epoch, and updates evidence. |
| DCL-DR-004 | Relationship-mapping import integrity needs a final fresh audit after DS-034 through DS-043. | Recent DS chain closed several direct-import relationship boundaries but the Finish Map still keeps relationship-mapping walkthrough coverage open. | `FINISH_MAP.md` Current Data-Resilience Note; `SLICE_LOG.md` DS-034 through DS-043; DS-2026-07-06-046 tightened direct-import preflight for child rows whose backup tank IDs are not imported; DS-2026-07-06-047 tightened direct-import relationship preflight so missing relationship target IDs are rejected before imported tank saves; DS-2026-07-06-048 tightened direct-import required ID preflight so whitespace-only tank and child record IDs are rejected before imported tank saves. | `VERIFY_LOCALLY` | open | Data resilience | No | Audit proves no remaining current direct import relationship false-success boundary, or one specific boundary is fixed with service tests and Full gate. |
| DCL-AI-001 | Any real AI-driven tank-data, task, or reminder write must require user confirmation. | The phone completion program places AI confirmation in Phase 2, and the Finish Map warns not to create fake AI write paths. | Phone completion program Phase 2; `FINISH_MAP.md` AI confirmation row; backlog `CL-P3-002`; current audit Optional AI confirmation notes. | `VERIFY_LOCALLY` | open | Optional AI | Maybe | Audit current AI write surfaces; if real unconfirmed writes exist, add cancel/confirm tests and confirmation UI; if none exist, record no-current-gap evidence. |
| DCL-P1-003 | Guided tools may still have tool-specific save/apply gaps found by walkthroughs. | Finish Map keeps Guided tools in progress. | `FINISH_MAP.md` Guided tools row; backlog `CL-P1-006`. | `VERIFY_LOCALLY` | open | Normal-user P1 depth | No | Walkthrough/source audit finds a concrete missing save/apply path and fixes it, or records no-current-gap evidence for the current tool set. |
| DCL-P1-004 | Timeline and journal still need future source-specific guided-tool or optional-AI save handoff walkthroughs. | Finish Map keeps Timeline and journal in progress. | `FINISH_MAP.md` Timeline and journal row; backlog `CL-P1-008`. | `VERIFY_LOCALLY` | open | Normal-user P1 depth | No | Current save handoffs are walked through or tested; any missing timeline label/context path is fixed with focused proof. |
| DCL-P1-005 | Learning remains open for richer visuals, practice links, scenarios, citations, and broader interaction variety. | Finish Map and backlog leave Learning in progress. | `FINISH_MAP.md` Learning row; backlog `CL-P1-004`. | `FIX_LOCALLY` | open | Normal-user P1 depth | Maybe | User-facing learning depth is scoped to one path or pattern per slice, grounded in current content/tests, and accepted as complete-local or further scoped by user. |
| DCL-P1-006 | Species and plants can still expand database depth, image quality, and source trails. | Finish Map marks Species and plants implemented, not done. | `FINISH_MAP.md` Species and plants row; backlog `CL-P1-003`. | `FIX_LOCALLY` | open | Content and P1 depth | Maybe | A bounded species/plant content or source slice improves one audited gap with content validation, or product scope accepts current breadth for local completion. |
| DCL-PREF-001 | Preferences still has final AI/provider walkthrough gaps. | Finish Map keeps Preferences in progress. | `FINISH_MAP.md` Preferences row; backlog/current audit preference notes. | `VERIFY_LOCALLY` | open | Preferences and Optional AI | No | Current provider/privacy/preference walkthroughs are audited locally; any missing honest-copy or persistence gap is fixed with focused tests. |
| DCL-CONTENT-001 | Content validation needs broader locked-content/source/content-risk coverage. | Finish Map and backlog leave content validation in progress. | `FINISH_MAP.md` Content validation row; backlog `CL-QA-005`. | `FIX_LOCALLY` | open | Content and rule confidence | No | Validator coverage expands for one concrete risk cluster and current content passes without unsafe care or source-trail drift. |
| DCL-RULE-001 | Rule tests need broader recommendation, compatibility, emergency, unit, and calculation coverage. | Finish Map keeps Rule tests in progress. | `FINISH_MAP.md` Rule tests row; backlog `CL-QA-004`. | `FIX_LOCALLY` | open | Content and rule confidence | No | One related rule family gets focused tests and any current behavior drift is fixed with local gates. |
| DCL-A11Y-001 | Phone accessibility remains open across contrast, touch targets, labels, text scaling, reduced motion, and non-colour-only status. | Finish Map keeps Accessibility in progress. | `FINISH_MAP.md` Accessibility row; backlog `CL-P2-004`. | `VERIFY_LOCALLY` | open | Phone accessibility and visual polish | No | A bounded phone screen cluster passes focused accessibility/widget evidence and local visual/accessibility checks; remaining phone clusters are tracked or closed. |
| DCL-VIS-001 | Older audits still identify weak or mismatched visual assets and missing badges/decorations. | Finish Map marks Visual asset quality not started. | `FINISH_MAP.md` Visual asset quality row; backlog `CL-P2-003`. | `FIX_LOCALLY` | open | Phone visual polish | Maybe | Current phone screenshots identify concrete weak assets; replacements use local/permissive/generated assets with source notes and Visual gate evidence. |
| DCL-VIS-002 | Selective visual regression coverage remains incomplete. | Finish Map keeps Visual regression in progress. | `FINISH_MAP.md` Visual regression row; backlog `CL-QA-003`; `docs/design/BASELINES.md`. | `FIX_LOCALLY` | open | Phone visual polish | No | Core phone surfaces get selective goldens/screenshots after visual targets stabilize, and the visual baseline manifest stays valid. |
| DCL-TAB-001 | Tablet layout, accessibility, visual polish, and performance remain incomplete beyond the current 96-row route/evidence map, but the user has sequenced all tablet work after phone complete-local. | User confirmed phone-first completion on 2026-07-11; Finish Map and whole-app tablet evidence remain available for later resumption. | `FINISH_MAP.md` Tablet layout row; `FINISH_MAP.md` Whole-app tablet audit row; `SCREEN_INVENTORY.md`; `plans/2026-07-11-phone-complete-local-completion-program.md`. | `PHASE_PARKED` | parked | Tablet layout, accessibility, visual polish, and performance | Yes | Does not block phone complete-local. Reopen after the phone candidate closes, then define the tablet layout/accessibility/visual/performance boundary from retained evidence. |
| DCL-MOTION-001 | Phone motion and haptics remain open for purposeful feedback on rewards, warnings, onboarding, and tank life. | Finish Map keeps Motion and haptics in progress. | `FINISH_MAP.md` Motion and haptics row; backlog `CL-P2-005`. | `FIX_LOCALLY` | open | Phone motion and visual polish | Maybe | A bounded phone motion slice is grounded in current UI evidence, respects reduced motion/haptics settings, and passes focused tests or visual proof. |
| DCL-PERF-001 | Android phone performance measurement has targets but lacks final local evidence for the active phase. | Finish Map keeps Performance in progress and the user confirmed phone-first completion on 2026-07-11. | `FINISH_MAP.md` Performance row; `docs/agent/PERFORMANCE_TARGETS.md`; `test/utils/performance_targets_test.dart`; `plans/2026-07-11-phone-complete-local-completion-program.md`. | `VERIFY_LOCALLY` | open | Phone performance | No | Startup, warm resume, tab switching, tank animation, scrolling, and local image first paint are measured on the owned Android phone target and summarized without noisy raw logs. |
| DCL-QA-001 | Debug QA seed coverage has one remaining real keyed-AI seed only if it can avoid fake provider readiness. | Finish Map keeps Debug QA seeds in progress. | `FINISH_MAP.md` Debug QA seeds row; backlog `CL-QA-007`. | `EXTERNAL_PARKED` | parked | Debug QA and Optional AI | Yes | Leave parked unless a local, honest keyed-AI seed can be created without secrets or fake readiness; otherwise accept no-key/no-AI seed evidence. |
| DCL-EXT-001 | Non-OpenAI provider connectors are not implemented. | Finish Map parks provider expansion downstream of local quality and approval. | `FINISH_MAP.md` Optional AI providers row; backlog `CL-P3-001`; paid-tool ledger. | `EXTERNAL_PARKED` | parked | Optional AI providers | Yes | Only proceed after explicit user approval and a real local/provider implementation plan; unavailable paths remain honest until then. |
| DCL-PREMIUM-001 | Premium AI remains conceptual and must not appear as fake product behavior. | Finish Map marks Premium AI path not started. | `FINISH_MAP.md` Premium AI path row; backlog `CL-P3-003`. | `EXTERNAL_PARKED` | parked | Premium and monetisation | Yes | Park until the core local app is excellent and the user approves premium scope; no visible fake premium behavior is added. |
| DCL-RC-001 | Final phone release-candidate evidence is last and only valid after every earlier active phone-program row closes or is explicitly accepted/parked. | The phone completion program places release-candidate evidence in terminal Phase 7; the user confirmed tablet is outside the active phone phase. | Phone completion program Phase 7; `QUALITY_LADDER.md` release candidate row; `plans/2026-07-11-phone-complete-local-completion-program.md`. | `VERIFY_LOCALLY` | open | Final evidence | No | Full gate, AndroidPrep, affected phone-state recheck, content validation, visual baseline checks, product-truth scan, and final phone QA note pass on clean main. Tablet and external work remain parked. |
| DCL-EXT-002 | Public store/release/legal hosting/cloud/deploy work is outside complete-local until the app meets the local bar. | Backlog says no public launch/store/legal hosting resumes until complete-local is met. | Backlog section 4 non-negotiable finished bar; `AGENTS.md`; `PAID_TOOL_APPROVAL_LEDGER.md`. | `EXTERNAL_PARKED` | parked | Release and external services | Yes | Do not start until complete-local is met and the user explicitly approves release/cloud/store work. |

## Closed, Accepted, Or Superseded Findings

| ID | Finding | Superseding Evidence | Disposition | Closure State | Rule |
| --- | --- | --- | --- | --- | --- |
| DCL-ARCH-001 | The 2026-06-13 Android emulator transport blocker prevented full fresh screen captures during that older audit. | Current Finish Map records 2026-07-04 phone and tablet whole-app maps as locally verified with all 96 `SCREEN_INVENTORY.md` rows passing. | `NOT_CURRENT_ARCHIVED` | closed | Do not use this as a current blocker unless a fresh device preflight reproduces it. |
| DCL-DR-005 | Future debounced local writers need app-kill flush coverage when new debounced writers are added. | DS-2026-07-05-044 source inventory found the current durable debounced local writers are gems and achievement progress; `main.dart` flushes pending gem writes on paused/inactive/detached, `_AchievementProgressLifecycleListener` flushes achievement progress on paused/detached, and focused lifecycle/persistence tests cover those paths. The current profile lifecycle observer flushes the already-visible profile snapshot after immediate saves, so it is not an open debounced-writer target. | `NOT_CURRENT_ARCHIVED` | closed | No current implementation target remains. Re-open only when a new durable debounced local writer is added or the lifecycle proof changes. |
| DCL-P1-001 | Fuller dedicated plant inventory and broader seasonal Living Tank variants were optional product-depth expansion. | On 2026-07-11 the user accepted the current data-derived plant, aquascape, decoration, progression, and seasonal cues as sufficient for phone complete-local. | `ACCEPTED_LOCAL_LIMITATION` | closed | Fix concrete defects found by later phone quality passes. Reopen dedicated plant inventory or broader seasonal variants only after fresh user direction. |
| DCL-P1-002 | Seasonal cosmetics and deeper plant/decor collections were optional rewards-depth expansion. | On 2026-07-11 the user accepted the current room vibes, badges, inventory, earned decorations, and equip controls as sufficient for phone complete-local. | `ACCEPTED_LOCAL_LIMITATION` | closed | Fix concrete defects found by later phone quality passes. Reopen broader cosmetic or collection depth only after fresh user direction. |

## Next Ledger Target Rule

`DCL-DR-001` is the next manual ledger target. It remains `open` and
unstarted. Begin only in a new explicit manual epoch after the
`WF-2026-07-15-019` hard pause, and perform the ordered read-only
restore-matrix audit before any implementation. Select no other product row
unless current evidence or a user decision explicitly changes the target.

Rows in `parked` or `decision_required` closure state are stop-and-ask items,
not automatic implementation targets. This ledger records their state and done
conditions. The dated phone completion program retains phase/scope history, but
its former autonomous activation conditions are not current execution
authority.
