# Danio — Finish Contract

**Locked:** 2026-03-29
**Authority:** Tiarnan Larkin + Athena
**Source evidence:** finish-line-review.md, completion-surface-audit.md, final-truth-pass.md (207KB, 9 agents)

---

## Definition of Done

**Danio is only considered finished when ALL of the following are true:**

### 1. Safety Gate
- [ ] No educational content that could result in animal harm
- [ ] All medication/treatment advice includes species-specific warnings
- [ ] Emergency/crisis content is accessible without prerequisite locks
- [ ] Dosing tools clearly state what they are and aren't for

### 2. Honesty Gate
- [ ] No feature presents UI that implies functionality which doesn't exist
- [ ] No purchase takes user currency and delivers nothing
- [ ] No screen displays fabricated data (fake sync counts, fake personalisation output)
- [ ] Every button/CTA either works or doesn't exist
- [ ] Every settings screen persists its state

### 3. Reliability Gate
- [ ] No crashes on any standard user path
- [ ] No silent data loss on critical paths (tanks, logs, profile, gems, SRS)
- [ ] Storage errors surface to user as error states, not empty lists
- [ ] Schema handles app updates without data corruption
- [ ] Critical-path error handlers log and show UI, not swallow silently

### 4. Completeness Gate
- [ ] All Finish Blockers in `final-gap-register.md` resolved
- [ ] All Finish Quality Requirements in `final-gap-register.md` resolved
- [ ] No deceptive/fake-complete behaviour remains
- [ ] No dangerous educational guidance remains
- [ ] No major user-facing broken flows remain
- [ ] No obvious placeholder systems remain

### 5. Quality Gate
- [ ] Visual assets match a single cohesive art direction
- [ ] Design system tokens used on all primary screens (especially onboarding)
- [ ] Content accuracy verified (spellings, units, scientific names)
- [ ] Accessibility baseline met (WCAG AA, 48dp targets, tooltips)

### 6. Documentation Gate
- [ ] All canonical docs updated to reflect final state
- [ ] `feature-registry.md` reflects actual feature status
- [ ] `decision-ledger.md` logs all scope decisions
- [ ] `final-gap-register.md` shows all items resolved or explicitly deferred with reason

### 7. Final Verification
- [ ] Adversarial completion check passes (re-run truth pass on fixed codebase)
- [ ] Tests pass (existing suite + new golden-path tests)
- [ ] Analyze clean (0 issues)

---

## Scope Control Rules

1. **No new features** may be added during the finish phase
2. **No existing blocker** may be reclassified without logging in `decision-ledger.md` with reason
3. **No defer** may be un-deferred without Tiarnan's explicit approval
4. **Every fix** must be verified against the specific finding that triggered it
5. **Every wave** must reference `finish-line.md` + `final-gap-register.md`
6. **"Good enough" is not done.** The contract either passes or it doesn't.

---

## What "Finished" Does NOT Mean

- Ready for store submission (external setup blockers are separate)
- Feature-complete for the full product vision (defers exist and are documented)
- Perfect (no software is; but it must be honest, safe, and reliable)

---

*This contract is the hard gate. It is not aspirational. It is not flexible. It passes or it doesn't.*
