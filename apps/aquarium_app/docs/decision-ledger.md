# Danio — Decision Ledger

**Created:** 2026-03-29
**Rule:** Every meaningful scope, classification, or direction decision is logged here.

---

## Format

Each entry:
- **Date**
- **Decision**
- **Reason**
- **Impact** (what changed as a result)
- **Decided by**

---

## Decisions

### 2026-03-29 — Finish line locked from truth pass
**Decision:** Convert truth pass findings into hard finish contract with 4 buckets: Finish Blockers (35), Finish Quality Requirements (27), Deferred (18), Future Scope (13).
**Reason:** Three rounds of audits (finish-line review, surface audit, truth pass) provided sufficient evidence to lock scope.
**Impact:** Created `finish-contract.md`, `final-gap-register.md`, and all canonical docs. No more broad discovery — execution mode only.
**Decided by:** Tiarnan

### 2026-03-29 — SyncService classified as Finish Blocker (not defer)
**Decision:** SyncService must be hidden/removed, not just acknowledged as scaffolding.
**Reason:** Displaying "Synced 3 actions" when no HTTP request is made is actively deceptive. Users will believe their data is backed up when it isn't. This is worse than having no sync feature — it breaks trust.
**Impact:** FB-H1. Must either hide all sync UI or make the "local only" status explicitly clear.
**Decided by:** Athena (based on truth pass evidence from Themis + Aphrodite)

### 2026-03-29 — Fish Health path prerequisite classified as Finish Blocker
**Decision:** Fish Health lessons must be accessible without completing Nitrogen Cycle first.
**Reason:** Users whose fish is sick RIGHT NOW cannot wait through 6 unrelated lessons. This causes fish death and immediate uninstall. Prometheus truth pass identified this as the single highest-severity UX failure.
**Impact:** FB-S3. Must remove or reduce the prerequisite lock.
**Decided by:** Athena (based on Prometheus truth pass)

### 2026-03-29 — 339 hardcoded Color values deferred (DE-9)
**Decision:** Not required for this finish line.
**Reason:** Typography (89%) and spacing (91.6%) compliance are strong. Colour cleanup is the weakest axis but is a large incremental task (339 values). The app looks correct — the issue is maintainability, not user-facing quality. Defer to post-launch cleanup.
**Impact:** DE-9. Not tracked as blocker or quality requirement.
**Decided by:** Athena

### 2026-03-29 — Fish mood/happiness system deferred (DE-13)
**Decision:** Not required for this finish line.
**Reason:** This would be a new feature (Tamagotchi-style feedback loop), not a fix. High-value for engagement but out of scope for finishing what exists. Plan for v1.1.
**Impact:** DE-13. Explicitly deferred.
**Decided by:** Athena

### 2026-03-29 — Species sprites at scale deferred (DE-14)
**Decision:** 15/126 species having sprites is acceptable for v1.
**Reason:** Generating 111 additional chibi sprites is a massive art task. The 🐠 emoji fallback works. The 15 that exist are high quality. Focus art effort on the 9 specific broken/missing assets in FQ-V instead.
**Impact:** DE-14. Not a finish requirement.
**Decided by:** Athena

### 2026-03-29 — Test quality reassessed upward
**Decision:** Previous "75% smoke test" claim was wrong. Actual ratio is 78% genuine behaviour tests.
**Reason:** Orpheus truth pass sampled 5 test files and classified every test. The earlier Argus assessment was too harsh.
**Impact:** Test quality is a genuine strength, not a weakness. 3 missing golden-path tests (FQ-Q2) still needed but the existing suite is much better than claimed.
**Decided by:** Athena (based on Orpheus evidence)

### 2026-03-29 — Wave R: All 9 Research First decisions locked
**Decision:** All RF items resolved per Athena recommendations (reviewed + approved by Tiarnan in execution plan v2).

| ID | Decision | Reason |
|----|----------|--------|
| RF-1 | **Hide** TankComparisonScreen | Building real comparison is new feature work. Hide entry point, keep code dormant. |
| RF-2 | **Keep 3 tabs** in bottom sheet | Update docs to match code. Adding Tools tab is new feature work. |
| RF-3 | **Add** Cycling Assistant to Workshop grid | Single route addition. Tool is polished (833 lines) and hidden. |
| RF-4 | **Remove** ThemeGalleryScreen | Orphaned dead code. No user path leads to it. |
| RF-5 | **Gate** dual level-up systems | Add guard so only one fires per event. Merging is too much refactoring. |
| RF-6 | **Remove** dead Light Intensity button | Dead UI worse than absent UI. Wiring is new feature work. |
| RF-7 | **Navigate** Fish ID "Add to Tank" to livestock add with pre-filled species | Minimal wiring, clear user expectation. |
| RF-8 | **Copy:** "Dismissed — will flag again if detected" | Clear semantics, no ambiguity. |
| RF-9 | **Move** GDPR consent after welcome screen | User should see what Danio is before a legal form. |

**Impact:** All RF items resolved. RF-3, RF-4, RF-5, RF-6 implementations go into Wave 3. RF-9 affects FB-H2 in Wave 1B.
**Decided by:** Tiarnan (approved plan containing all recommendations without override)

### 2026-03-29 — Wave 1A CLOSED
**Items resolved:** FB-S1, FB-S2, FB-S3, FB-S4, FB-H1, FB-H6, FB-H7 (7/7)
**Verification:** Argus confirmed 7/7 against original findings
**Same-class sweep:** Pythia extended medication warnings to 25 species (was 5). Clean — no new blocker-class items.
**Analyze:** 4 issues (all pre-existing in test file)
**Commit:** `e2e6ac4`
**Argus follow-up observations (non-blocking):** P3 dosing preset labelling inconsistency, P2 no edit-reminder UI
**Decision:** Wave 1A CLOSED. Proceeding to Wave 1B.

### 2026-03-29 — Agent task sizing rule: max 2–3 items per spawn
**Decision:** No agent gets more than 2–3 focused items per spawn. Split across more agents instead.
**Reason:** Hephaestus timed out with 5 items in Wave 1A. Pythia finished 2 items in 9 minutes. Pattern recurring — Tiarnan flagged it.
**Impact:** All remaining waves will use more granular agent assignments. Increases parallelism, reduces timeout risk.
**Decided by:** Tiarnan (directive) + Athena (enforcement)

### 2026-03-29 — Execution plan v2 approved for autonomous execution
**Decision:** Full autonomous execution authorised through all waves.
**Reason:** Tiarnan directive: "proceed fully autonomously against the approved plan."
**Impact:** No inter-wave check-ins required. Escalate only on: unresolved RF, external blockers, material plan changes, safety decisions.
**Decided by:** Tiarnan

### 2026-03-29 — Play Store submission remains ON HOLD
**Decision:** Do not push for submission readiness, AAB builds, or store assets.
**Reason:** Per Tiarnan (2026-03-29): "App still needs loads of work." External setup blockers (EX-4 through EX-7) are tracked but not on the critical path.
**Impact:** External blockers separated from product blockers in the gap register.
**Decided by:** Tiarnan
