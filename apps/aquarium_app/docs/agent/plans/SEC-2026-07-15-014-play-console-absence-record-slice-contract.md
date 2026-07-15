# SEC-2026-07-15-014 Play Console Absence Record

## Slice

- ID: `SEC-2026-07-15-014`
- Title: Record the user-confirmed Play Console absence and retire the exposed
  local signing key
- Branch: `maintenance/danio-play-console-absence-2026-07-15`
- Risk tier: 0, documentation and truth-guard only
- Owned files: current release-security banners, the signing containment
  contract, `ACTIVE_HANDOFF.md`, `SLICE_LOG.md`, and the current-doc truth test
- Out of scope: Play Console mutation, account creation, key generation,
  credential rotation, history rewriting, product behavior, writer claim, and
  phone-completion budget mutation

## Observed Fact And Decision

- User-provided observation: Danio is not listed in the Play Console account
  inspected on 2026-07-15.
- Evidence boundary: this is a read-only user observation for the inspected
  account. It does not claim visibility into another Google account.
- Decision: no Danio Play-side key reset is currently available or required in
  the inspected account. The exposed local signing key is retired and must
  never be used for a future release.
- Future release rule: create fresh signing material only during a separately
  authorized release setup, keep it outside Git, and preserve the tracked
  credential guard.
- Remaining external truth: public Git history still contains the old exposure,
  and canonical privacy/terms URLs still need external hosting verification.

## Proof Plan

- RED: extend the current-doc truth test to require the scoped Play Console
  observation in every guarded release document and the governing handoff and
  containment contract.
- GREEN: update only the security/release truth surfaces and rerun the focused
  test.
- Closeout: `git diff --check`, the tracked-signing guard, Docs profile,
  clean-branch Docs, fast-forward merge, clean-main Docs, push, and `0 0`
  alignment.
- Runtime: no emulator, ADB, account, cloud, or external-service action is
  required.

## Rollback

This slice changes documentation and a documentation truth guard only. Revert
the focused commit if the user observation is corrected; never restore the
retired credentials or weaken the tracked-signing guard.
