# Danio Complete-Local Forecast

Status: Active forecast
Created: 2026-07-05
Evidence: `FINISH_MAP.md`, `COMPLETE_LOCAL_CLOSURE_LEDGER.md`,
`SLICE_LOG.md`, and the 2026-07-05 accelerated epoch plan

## Purpose

This forecast makes the remaining complete-local path finite enough to plan
against. It is not a promise that every row will need code. Some rows should
close through local verification, some need user product decisions, and some
stay parked outside complete-local.

## Forecast Summary

Current estimate from repo evidence after DS-2026-07-05-044:

| Range | Session Count | What It Assumes |
| --- | --- | --- |
| Minimum | 10 to 14 verified sessions | Data-resilience audit finds few remaining defects, several P1/P2 rows close by verification or accepted scope, and no major Android/device instability appears. |
| Likely | 17 to 25 verified sessions | Data resilience needs several more fixes, AI/write and P1 depth need targeted slices, accessibility/visual/content/performance each need bounded proof, and final RC evidence gets its own pass. |
| Upper bound | 34 to 44 verified sessions | User chooses deeper plant/reward/learning/asset scope, visual/accessibility work uncovers real defects, performance evidence needs iteration, or provider/premium work is reopened. |

The fastest safe path is not "one issue per session forever". It is evidence
first, then bundle 2 to 3 related micro-slices only when the proof setup is
shared and the stop conditions stay clear.

## Epoch Forecast

| Epoch | Ledger IDs | Minimum | Likely | Upper | Exit Condition |
| --- | --- | --- | --- | --- | --- |
| 1. Data-resilience closure | `DCL-DR-001` through `DCL-DR-004` | 3 | 4 to 6 | 11 | Restore, migration, create/delete/undo, and relationship mapping are fixed or verified with Full-gate evidence. `DCL-DR-005` is a no-current-gap future-watch item after DS-2026-07-05-044. |
| 2. Optional AI write audit | `DCL-AI-001`, `DCL-PREF-001` | 1 | 2 to 3 | 5 | Real current AI writes are confirmed-before-write or audited as no-current-gap; no fake AI path is created. |
| 3. Normal-user P1 depth | `DCL-P1-001` through `DCL-P1-006` | 2 | 4 to 7 | 12 | User-scoped plant/reward/learning/species/guided-tool/timeline gaps are implemented or accepted as current local scope. |
| 4. Content and rule confidence | `DCL-CONTENT-001`, `DCL-RULE-001` | 1 | 2 to 4 | 6 | Broader validators and rule tests cover the next concrete risk clusters without unsafe care-copy drift. |
| 5. Accessibility, visual, tablet, motion | `DCL-A11Y-001`, `DCL-VIS-001`, `DCL-VIS-002`, `DCL-TAB-001`, `DCL-MOTION-001` | 2 | 4 to 7 | 12 | Current screenshots/goldens prove the bounded visual/accessibility/tablet/motion bar or identify exact follow-up rows. |
| 6. Performance evidence | `DCL-PERF-001` | 1 | 1 to 2 | 4 | Owned Android evidence covers startup, resume, tab switching, tank animation, scrolling, and image first paint against the local targets. |
| 7. Final RC packet | `DCL-RC-001` | 1 | 1 to 3 | 5 | Clean `main` passes final local gate set, AndroidPrep, product truth scan, and release QA note. |

Parked rows are not counted in the local completion minimum unless the user
explicitly reopens them: `DCL-QA-001`, `DCL-EXT-001`, `DCL-PREMIUM-001`, and
`DCL-EXT-002`.

## Stop-And-Ask Conditions

Ask one direct question instead of implementing when:

- A ledger row is `PRODUCT_DECISION` or `EXTERNAL_PARKED`.
- Source/tests prove the current candidate is already covered and no next
  highest ledger target is unambiguous.
- A visible product-depth choice would change what "complete" means for users,
  especially plant inventory, seasonal rewards, richer learning visuals,
  premium AI, providers, or release/store scope.
- Android evidence is required but device ownership is unclear.
- A change would require paid services, cloud setup, external accounts, API
  keys, hosted CI, store submission, or deploy work.
- The ledger, Finish Map, active handoff, and source evidence disagree.

## User Decisions Still Needed

| Decision | Related IDs | Default Until User Decides |
| --- | --- | --- |
| Whether dedicated plant inventory and seasonal living-tank variants are required for local completion. | `DCL-P1-001` | Keep existing data-derived plant/decor cues and ask before large product expansion. |
| Whether seasonal cosmetics and deeper plant/decor collections are required. | `DCL-P1-002` | Keep existing local room vibes, badges, inventory, and equipped decorations. |
| How far to expand richer learning visuals and species/plant depth before final local signoff. | `DCL-P1-005`, `DCL-P1-006` | Improve only concrete audit/test gaps; avoid broad redesign. |
| Whether to accept current tablet evidence as enough or run another targeted tablet reconciliation pass. | `DCL-TAB-001` | Verify locally before code. |
| Whether to reopen non-OpenAI providers, premium AI, keyed-AI seed states, store/release, cloud, deploy, or account-backed work. | `DCL-QA-001`, `DCL-EXT-001`, `DCL-PREMIUM-001`, `DCL-EXT-002` | Park outside complete-local. |

## How To Make It Faster

- Use the ledger to skip repeated broad audits.
- Batch only tightly related rows, such as two restore tests in one service
  family or two rule-validator gaps in one test file.
- Keep docs-only workflow updates separate from product behavior.
- Avoid Android runtime work until the chosen ledger row truly requires it.
- Stop early on product decisions instead of implementing speculative scope.
