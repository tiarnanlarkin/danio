# Danio Complete-Local Forecast

Status: Active forecast
Created: 2026-07-05
Recalibrated: 2026-07-11 after DS-050, the phone atlas audit, the confirmed
phone-only completion boundary, and both accepted product-depth decisions
Evidence: `FINISH_MAP.md`, `COMPLETE_LOCAL_CLOSURE_LEDGER.md`,
`SLICE_LOG.md`, and
`plans/2026-07-11-phone-complete-local-completion-program.md`

## Purpose

This forecast makes the remaining complete-local path finite enough to plan
against. It is not a promise that every row will need code. Some rows should
close through local verification, some need user product decisions, and some
stay parked outside complete-local.

## Forecast Summary

Current estimate from repo evidence after DS-2026-07-06-050 and the 2026-07-11
phone-only audit:

| Range | Session Count | What It Assumes |
| --- | --- | --- |
| Lower bound | 10 to 13 verified sessions | Several verification rows close without code, the accepted plant/reward boundaries remain stable, and no material phone accessibility or performance defects appear. |
| Planning range | 13 to 22 verified sessions | Data resilience needs targeted fixes, phone visual/accessibility work finds bounded defects, and each high-risk phase receives its own closeout evidence. |
| Expanded scope | 18 to 30 verified sessions | The accepted plant/reward boundary is later reopened, visual assets need broad replacement, or phone performance/accessibility evidence requires iteration. |

The fastest safe path is not "one issue per session forever". It is evidence
first, then bundle 2 to 3 related micro-slices only when the proof setup is
shared and the stop conditions stay clear.

## Epoch Forecast

| Epoch | Ledger IDs | Minimum | Likely | Upper | Exit Condition |
| --- | --- | --- | --- | --- | --- |
| 1. Data-resilience closure | `DCL-DR-001` through `DCL-DR-004` | 2 | 3 to 5 | 8 | Restore, migration/corruption, create/delete/undo, and relationship mapping are fixed or verified with Full-gate evidence. `DCL-DR-005` remains archived future-watch. |
| 2. Optional AI and preferences | `DCL-AI-001`, `DCL-PREF-001` | 1 | 1 to 2 | 3 | Real current AI writes are confirmed-before-write or audited as no-current-gap; keyless/provider/privacy preferences remain honest. |
| 3. Normal-user P1 depth | `DCL-P1-003` through `DCL-P1-006` | 2 | 2 to 5 | 8 | Guided-tool, timeline, learning, and species/plant gaps are implemented or accepted within the current phone scope. |
| 4. Content and rule confidence | `DCL-CONTENT-001`, `DCL-RULE-001` | 1 | 2 to 3 | 5 | Broader validators and rule tests cover the next concrete risk clusters without unsafe care-copy drift. |
| 5. Phone accessibility, visual, motion | `DCL-A11Y-001`, `DCL-VIS-001`, `DCL-VIS-002`, `DCL-MOTION-001` | 2 | 3 to 5 | 8 | Current phone screenshots/Figma targets and focused proof close bounded visual, accessibility, reduced-motion, and haptic gaps. |
| 6. Phone performance evidence | phone portion of `DCL-PERF-001` | 1 | 1 to 2 | 3 | Owned Android phone evidence covers startup, resume, tab switching, tank animation, scrolling, and image first paint against local targets. |
| 7. Final phone candidate | `DCL-RC-001` | 1 | 1 to 2 | 3 | Clean `main` passes the final local gate set, AndroidPrep, affected phone-state recheck, product truth scan, and final phone QA note. |

Phase-parked and external rows are not counted unless the user explicitly
reopens them: `DCL-TAB-001`, the tablet portion of `DCL-PERF-001`,
`DCL-QA-001`, `DCL-EXT-001`, `DCL-PREMIUM-001`, and `DCL-EXT-002`.

## Stop-And-Ask Conditions

Ask one direct question instead of implementing when:

- A ledger row is `PRODUCT_DECISION`, `PHASE_PARKED`, or `EXTERNAL_PARKED`.
- Source/tests prove the current candidate is already covered and no next
  highest ledger target is unambiguous.
- A visible product-depth choice would change what "complete" means for users,
  especially plant inventory, seasonal rewards, richer learning visuals,
  premium AI, providers, or release/store scope.
- Android evidence is required but device ownership is unclear.
- A change would require paid services, cloud setup, external accounts, API
  keys, hosted CI, store submission, or deploy work.
- The ledger, Finish Map, active handoff, and source evidence disagree.

## Product Scope Decisions

| Decision | Related IDs | Current status |
| --- | --- | --- |
| Whether dedicated plant inventory and broader seasonal living-tank variants are required for phone completion. | `DCL-P1-001` | Resolved 2026-07-11: current data-derived plant/decor/seasonal cues are accepted; expansion is parked. |
| Whether seasonal cosmetics and deeper plant/decor collections are required for phone completion. | `DCL-P1-002` | Resolved 2026-07-11: current room vibes, badges, inventory, and equipped decorations are accepted; expansion is parked. |
| Tablet sequencing. | `DCL-TAB-001`, tablet portion of `DCL-PERF-001` | Decided 2026-07-11: park until phone complete-local closes. |
| Whether to reopen non-OpenAI providers, premium AI, keyed-AI seed states, store/release, cloud, deploy, or account-backed work. | `DCL-QA-001`, `DCL-EXT-001`, `DCL-PREMIUM-001`, `DCL-EXT-002` | Park outside complete-local. |

## How To Make It Faster

- Use the ledger to skip repeated broad audits.
- Batch only tightly related rows, such as two restore tests in one service
  family or two rule-validator gaps in one test file.
- Keep docs-only workflow updates separate from product behavior.
- Avoid Android runtime work until the chosen ledger row truly requires it.
- Stop early on product decisions instead of implementing speculative scope.
