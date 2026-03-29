# Danio — Finish Line Definition

**Locked:** 2026-03-29
**Reference:** `final-gap-register.md` (master item list), `finish-contract.md` (hard gate)

---

## What "Finished" Means

Danio v1.0 is finished when it passes the Finish Contract (`finish-contract.md`):
1. No educational content that could harm fish
2. No feature that lies about what it does
3. No purchase that takes gems and delivers nothing
4. No user-facing crash on any standard path
5. No silent data loss on critical paths
6. All user-facing screens work as presented
7. Visual assets follow a single cohesive art direction
8. Content is factually accurate and appropriately deep
9. Accessibility baseline met
10. Final adversarial verification passes

---

## What's In Scope

**35 Finish Blockers** — non-negotiable fixes across safety, honesty, broken flows, and trust.
**27 Finish Quality Requirements** — required for the app to feel genuinely finished.
**9 Research First** — design decisions that must be made before implementation.

See `final-gap-register.md` for every item with ID, detail, and source.

---

## What's Explicitly Out of Scope

- New features (friends, leaderboard, cloud sync, video, social auth)
- Large-scale design system cleanup (339 colour values, 114 TextStyle bypasses)
- Species sprite generation at scale (15/126 have sprites — 🐠 fallback acceptable)
- Fish mood/happiness system (new feature, not a fix)
- Architectural refactors (god objects have plans, are functional)
- MaterialPageRoute migration (works, visual-only improvement)

Full defer list with reasons: `final-gap-register.md` section E.

---

## Scope Control

1. No new features during finish phase
2. No blocker reclassification without `decision-ledger.md` entry
3. No un-deferring without Tiarnan's approval
4. Every fix verified against the specific finding
5. "Good enough" is not done

---

## How to Use This Document

- **Before any wave:** Read this + `final-gap-register.md`
- **Before any scope discussion:** Read `finish-contract.md`
- **Before any code change:** Check the relevant FB/FQ ID
- **After any decision:** Log in `decision-ledger.md`
