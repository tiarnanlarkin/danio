# Phone-quality cluster 5: first run and destructive/recovery dialogs

Status: complete
Epoch: `DR-2026-07-25-080`
Marker: `danio-phone-quality-cluster-5-first-run-destructive-recovery-dialogs-2026-07-25/1`

## Contract

- Audit only current first-run, destructive-action, and local data-recovery
  phone surfaces for concrete P0/P1 defects.
- Check 48 dp targets, semantics, contrast, non-colour state, 2.0x text,
  reduced motion, disabled haptics, affected visual evidence, and asset
  provenance without expanding accepted feature breadth.
- Use focused RED/GREEN, settled-diff review, affected Visual proof, one
  serial-pinned `danio_api36` pass, AndroidPrep, and the controlling Full gate.
- Apply the user-approved lean cadence: narrow checks while implementing, one
  controlled device pass for this cluster, and no broad rerun solely for
  receipt-only changes when the Docs profile is sufficient. Final Full remains
  reserved again for `DCL-RC-001`.

## Exclusions

Clusters 1-4, performance disposition, release signoff, tablets, iOS,
provider/account setup, premium/store/deploy work, and external actions.

## Closeout

Focused RED proved 2.0x consent overflow and a Preferences danger-zone heading
overflow. Preventive shared-dialog hardening and stronger action-reachability
tests cover the destructive/recovery confirmations. The smallest scroll/reflow
fixes pass through AndroidPrep, independent review, and the controlling Full.
Device evidence covers the changed consent and destructive dialog;
the recovery-error state remains deterministically covered by its widget test
because no safe debug seed exists for damaged local storage. Evidence:
`docs/qa/phone-quality/2026-07-25/dcl-a11y-001-first-run-destructive-recovery-dialogs.md`.
