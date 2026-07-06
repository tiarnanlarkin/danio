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

The ledger does not replace `FINISH_MAP.md`. The Finish Map owns rank and
completion status; this ledger owns traceable closure IDs, disposition,
evidence, and exact done conditions.

## Dispositions

| Disposition | Meaning |
| --- | --- |
| `FIX_LOCALLY` | Implement or repair local app behavior with focused proof. |
| `VERIFY_LOCALLY` | The next work is evidence gathering, walkthrough, or audit before code. |
| `PRODUCT_DECISION` | The app can only proceed after the user chooses scope or accepts a limitation. |
| `EXTERNAL_PARKED` | Outside complete-local unless the user explicitly approves cloud, account, paid, key, store, or release work. |
| `ACCEPTED_LOCAL_LIMITATION` | Documented as acceptable for complete-local; re-open only with new product direction. |
| `NOT_CURRENT_ARCHIVED` | Older finding is superseded by newer repo evidence and is not a current slice target. |

## Ledger Rules

- Every implementation slice must list the ledger ID it advances in its slice
  contract, `ACTIVE_HANDOFF.md`, or `SLICE_LOG.md`.
- If the roadmap, source, tests, and ledger disagree, stop and reconcile the
  docs before editing product code.
- Prefer local-only evidence: focused tests, local gates, source inspection,
  local screenshots, local Android builds, and owned emulator proof.
- External/cloud/account/paid/API-key/store/deploy items are parked outside the
  complete-local path unless the user gives explicit current-thread approval.
- Do not close a ledger row from stale chat memory. Use current repo docs,
  current source, current tests, and current command output.

## Active Findings

| ID | Finding | How Found | Evidence | Disposition | Lane | User Input | Done Condition |
| --- | --- | --- | --- | --- | --- | --- | --- |
| DCL-DR-001 | Restore walkthrough and restore failure behavior still need closure evidence beyond the recent photo/import hardening. | Finish Map and backlog both keep Backup/Data resilience in progress after DS-043. | `FINISH_MAP.md` Backup and restore row; `FINISH_MAP.md` ranked roadmap rank 1; backlog `CL-P1-009`; `CL-QA-006`; DS-2026-07-05-045 added executable proof that restored photo cleanup runs when tank import fails after photo extraction. | `VERIFY_LOCALLY` | Data resilience | No | Current restore paths are audited from source/tests, any missing false-success or rollback behavior is fixed with RED/GREEN proof, and Full gate passes. |
| DCL-DR-002 | Schema migration and corruption-recovery walkthroughs remain open for complete-local confidence. | Finish Map next actions name restore and migration Android walkthrough QA. | `FINISH_MAP.md` Backup and restore row; `FINISH_MAP.md` next development push; `docs/product/danio-complete-local-current-audit-2026-06-13.md` local data notes. | `VERIFY_LOCALLY` | Data resilience | No | Migration/corruption paths are proven by source/test or owned-device walkthrough evidence; any missing behavior is fixed locally and Full gate passes. |
| DCL-DR-003 | Broader create/edit/delete/undo data-resilience coverage is not fully closed. | Finish Map `Data resilience` next action still names create/edit/delete coverage after many DS slices. | `FINISH_MAP.md` Data resilience row; `SLICE_LOG.md` DS-2026-07-04-002 through DS-2026-07-05-043. | `FIX_LOCALLY` | Data resilience | No | Fresh source/test audit identifies each remaining false-success or orphan boundary, fixes one small boundary per slice or safe epoch, and updates evidence. |
| DCL-DR-004 | Relationship-mapping import integrity needs a final fresh audit after DS-034 through DS-043. | Recent DS chain closed several direct-import relationship boundaries but the Finish Map still keeps relationship-mapping walkthrough coverage open. | `FINISH_MAP.md` Current Data-Resilience Note; `SLICE_LOG.md` DS-034 through DS-043. | `VERIFY_LOCALLY` | Data resilience | No | Audit proves no remaining current direct import relationship false-success boundary, or one specific boundary is fixed with service tests and Full gate. |
| DCL-AI-001 | Any real AI-driven tank-data, task, or reminder write must require user confirmation. | Finish Map ranks AI confirmation second and warns not to create fake AI write paths. | `FINISH_MAP.md` AI confirmation row; backlog `CL-P3-002`; current audit Optional AI confirmation notes. | `VERIFY_LOCALLY` | Optional AI | Maybe | Audit current AI write surfaces; if real unconfirmed writes exist, add cancel/confirm tests and confirmation UI; if none exist, record no-current-gap evidence. |
| DCL-P1-001 | Living Tank still lacks fuller dedicated plant inventory and seasonal variants if product scope requires them. | Finish Map and backlog leave Living Tank in progress. | `FINISH_MAP.md` Living Tank row; backlog `CL-P1-001`. | `PRODUCT_DECISION` | Normal-user P1 depth | Yes | User either scopes plant/seasonal depth for local implementation or accepts the current data-derived cues as enough for complete-local. |
| DCL-P1-002 | Rewards and collectibles still list seasonal cosmetics and deeper plant/decor collections. | Finish Map and backlog leave Rewards in progress. | `FINISH_MAP.md` Rewards and collectibles row; backlog `CL-P1-002`. | `PRODUCT_DECISION` | Normal-user P1 depth | Yes | User chooses a bounded reward-depth target, or the existing local room vibes, badges, inventory, and decorations are accepted as complete-local enough. |
| DCL-P1-003 | Guided tools may still have tool-specific save/apply gaps found by walkthroughs. | Finish Map keeps Guided tools in progress. | `FINISH_MAP.md` Guided tools row; backlog `CL-P1-006`. | `VERIFY_LOCALLY` | Normal-user P1 depth | No | Walkthrough/source audit finds a concrete missing save/apply path and fixes it, or records no-current-gap evidence for the current tool set. |
| DCL-P1-004 | Timeline and journal still need future source-specific guided-tool or optional-AI save handoff walkthroughs. | Finish Map keeps Timeline and journal in progress. | `FINISH_MAP.md` Timeline and journal row; backlog `CL-P1-008`. | `VERIFY_LOCALLY` | Normal-user P1 depth | No | Current save handoffs are walked through or tested; any missing timeline label/context path is fixed with focused proof. |
| DCL-P1-005 | Learning remains open for richer visuals, practice links, scenarios, citations, and broader interaction variety. | Finish Map and backlog leave Learning in progress. | `FINISH_MAP.md` Learning row; backlog `CL-P1-004`. | `FIX_LOCALLY` | Normal-user P1 depth | Maybe | User-facing learning depth is scoped to one path or pattern per slice, grounded in current content/tests, and accepted as complete-local or further scoped by user. |
| DCL-P1-006 | Species and plants can still expand database depth, image quality, and source trails. | Finish Map marks Species and plants implemented, not done. | `FINISH_MAP.md` Species and plants row; backlog `CL-P1-003`. | `FIX_LOCALLY` | Content and P1 depth | Maybe | A bounded species/plant content or source slice improves one audited gap with content validation, or product scope accepts current breadth for local completion. |
| DCL-PREF-001 | Preferences still has final AI/provider walkthrough gaps. | Finish Map keeps Preferences in progress. | `FINISH_MAP.md` Preferences row; backlog/current audit preference notes. | `VERIFY_LOCALLY` | Preferences and Optional AI | No | Current provider/privacy/preference walkthroughs are audited locally; any missing honest-copy or persistence gap is fixed with focused tests. |
| DCL-CONTENT-001 | Content validation needs broader locked-content/source/content-risk coverage. | Finish Map and backlog leave content validation in progress. | `FINISH_MAP.md` Content validation row; backlog `CL-QA-005`. | `FIX_LOCALLY` | Content and rule confidence | No | Validator coverage expands for one concrete risk cluster and current content passes without unsafe care or source-trail drift. |
| DCL-RULE-001 | Rule tests need broader recommendation, compatibility, emergency, unit, and calculation coverage. | Finish Map keeps Rule tests in progress. | `FINISH_MAP.md` Rule tests row; backlog `CL-QA-004`. | `FIX_LOCALLY` | Content and rule confidence | No | One related rule family gets focused tests and any current behavior drift is fixed with local gates. |
| DCL-A11Y-001 | App-wide accessibility pass remains open across contrast, touch targets, labels, text scaling, reduced motion, and non-colour-only status. | Finish Map keeps Accessibility in progress. | `FINISH_MAP.md` Accessibility row; backlog `CL-P2-004`. | `VERIFY_LOCALLY` | Accessibility, tablet, visual polish | No | A bounded screen cluster passes focused accessibility/widget evidence and local visual/accessibility checks; remaining clusters are tracked or closed. |
| DCL-VIS-001 | Older audits still identify weak or mismatched visual assets and missing badges/decorations. | Finish Map marks Visual asset quality not started. | `FINISH_MAP.md` Visual asset quality row; backlog `CL-P2-003`. | `FIX_LOCALLY` | Accessibility, tablet, visual polish | Maybe | Current screenshots identify concrete weak assets; replacements use local/permissive/generated assets with source notes and Visual gate evidence. |
| DCL-VIS-002 | Selective visual regression coverage remains incomplete. | Finish Map keeps Visual regression in progress. | `FINISH_MAP.md` Visual regression row; backlog `CL-QA-003`; `docs/design/BASELINES.md`. | `FIX_LOCALLY` | Accessibility, tablet, visual polish | No | Core surfaces get selective goldens/screenshots after visual targets stabilize, and the visual baseline manifest stays valid. |
| DCL-TAB-001 | Tablet layout remains marked in progress despite current phone/tablet maps passing. | Finish Map keeps Tablet layout in progress and whole-app tablet audit locally verified. | `FINISH_MAP.md` Tablet layout row; `FINISH_MAP.md` Whole-app tablet audit row; `SCREEN_INVENTORY.md`. | `VERIFY_LOCALLY` | Accessibility, tablet, visual polish | No | A fresh audit reconciles the in-progress tablet row with current 96-row pass evidence, or records the next stretched surface with screenshot proof. |
| DCL-MOTION-001 | Motion and haptics remain open for purposeful feedback on rewards, warnings, onboarding, and tank life. | Finish Map keeps Motion and haptics in progress. | `FINISH_MAP.md` Motion and haptics row; backlog `CL-P2-005`. | `FIX_LOCALLY` | Accessibility, tablet, visual polish | Maybe | A bounded motion slice is grounded in current UI evidence, respects reduced motion/haptics settings, and passes focused tests or visual proof. |
| DCL-PERF-001 | Android performance measurement has targets but lacks final local phone/tablet evidence. | Finish Map keeps Performance in progress. | `FINISH_MAP.md` Performance row; `docs/agent/PERFORMANCE_TARGETS.md`; `test/utils/performance_targets_test.dart`. | `VERIFY_LOCALLY` | Performance | No | Startup, warm resume, tab switching, tank animation, scrolling, and local image first paint are measured on owned Android targets and summarized without noisy raw logs. |
| DCL-QA-001 | Debug QA seed coverage has one remaining real keyed-AI seed only if it can avoid fake provider readiness. | Finish Map keeps Debug QA seeds in progress. | `FINISH_MAP.md` Debug QA seeds row; backlog `CL-QA-007`. | `EXTERNAL_PARKED` | Debug QA and Optional AI | Yes | Leave parked unless a local, honest keyed-AI seed can be created without secrets or fake readiness; otherwise accept no-key/no-AI seed evidence. |
| DCL-EXT-001 | Non-OpenAI provider connectors are not implemented. | Finish Map parks provider expansion downstream of local quality and approval. | `FINISH_MAP.md` Optional AI providers row; backlog `CL-P3-001`; paid-tool ledger. | `EXTERNAL_PARKED` | Optional AI providers | Yes | Only proceed after explicit user approval and a real local/provider implementation plan; unavailable paths remain honest until then. |
| DCL-PREMIUM-001 | Premium AI remains conceptual and must not appear as fake product behavior. | Finish Map marks Premium AI path not started. | `FINISH_MAP.md` Premium AI path row; backlog `CL-P3-003`. | `EXTERNAL_PARKED` | Premium and monetisation | Yes | Park until the core local app is excellent and the user approves premium scope; no visible fake premium behavior is added. |
| DCL-RC-001 | Final release-candidate evidence is last and only valid after higher-ranked rows close or are explicitly deferred. | Finish Map ranks release-candidate evidence last. | `FINISH_MAP.md` Final release-candidate evidence rank; `QUALITY_LADDER.md` release candidate row. | `VERIFY_LOCALLY` | Final evidence | No | Full gate, AndroidPrep, phone/tablet recheck as needed, content validation, visual baseline checks, product-truth scan, and final QA note pass on clean main. |
| DCL-EXT-002 | Public store/release/legal hosting/cloud/deploy work is outside complete-local until the app meets the local bar. | Backlog says no public launch/store/legal hosting resumes until complete-local is met. | Backlog section 4 non-negotiable finished bar; `AGENTS.md`; `PAID_TOOL_APPROVAL_LEDGER.md`. | `EXTERNAL_PARKED` | Release and external services | Yes | Do not start until complete-local is met and the user explicitly approves release/cloud/store work. |

## Archived Or Superseded Findings

| ID | Finding | Superseding Evidence | Disposition | Rule |
| --- | --- | --- | --- | --- |
| DCL-ARCH-001 | The 2026-06-13 Android emulator transport blocker prevented full fresh screen captures during that older audit. | Current Finish Map records 2026-07-04 phone and tablet whole-app maps as locally verified with all 96 `SCREEN_INVENTORY.md` rows passing. | `NOT_CURRENT_ARCHIVED` | Do not use this as a current blocker unless a fresh device preflight reproduces it. |
| DCL-DR-005 | Future debounced local writers need app-kill flush coverage when new debounced writers are added. | DS-2026-07-05-044 source inventory found the current durable debounced local writers are gems and achievement progress; `main.dart` flushes pending gem writes on paused/inactive/detached, `_AchievementProgressLifecycleListener` flushes achievement progress on paused/detached, and focused lifecycle/persistence tests cover those paths. The current profile lifecycle observer flushes the already-visible profile snapshot after immediate saves, so it is not an open debounced-writer target. | `NOT_CURRENT_ARCHIVED` | No current implementation target remains. Re-open only when a new durable debounced local writer is added or the lifecycle proof changes. |

## Next Ledger Target Rule

The next product slice should start at the first open `FIX_LOCALLY` or
`VERIFY_LOCALLY` item in this order unless fresh source/test evidence proves a
higher risk:

1. `DCL-DR-*`
2. `DCL-AI-001`
3. `DCL-P1-*` and `DCL-PREF-001`
4. `DCL-CONTENT-001` and `DCL-RULE-001`
5. `DCL-A11Y-001`, `DCL-VIS-*`, `DCL-TAB-001`, `DCL-MOTION-001`
6. `DCL-PERF-001`
7. `DCL-RC-001`

Rows marked `PRODUCT_DECISION` or `EXTERNAL_PARKED` are stop-and-ask items, not
automatic implementation targets.
