# DCL-A11Y-001 first run and destructive/recovery dialogs

Date: 2026-07-25
Epoch: `DR-2026-07-25-080`
Marker: `danio-phone-quality-cluster-5-first-run-destructive-recovery-dialogs-2026-07-25/1`
Base commit: `7d230f6ea5345bb03625253d24ebb5d40dc04c7f`

## Outcome

Phone-quality Cluster 5 is complete. Focused RED proved that the consent
screen overflowed vertically by 980 pixels at 390x844 and 2.0x text, the
Preferences danger-zone heading overflowed horizontally by 8.9 pixels.

Consent now scrolls only when its content needs more height while retaining
the existing balanced layout at normal text. Preventive shared-dialog
hardening keeps action buttons visible while the body can scroll; the recovery
probe found its Start Fresh entry below the parent scroll fold, not a dialog
overflow. Shared full-width buttons gain
height and wrap constrained labels at large text, and the Preferences section
heading can reflow within its row. No destructive behavior, storage semantics,
privacy copy, feature, asset, provider, account, or cloud behavior changed.

Permanent 390x844 2.0x coverage now protects consent, Delete My Data, and the
Start Fresh recovery confirmation. The wider 145-test first-run and
destructive/recovery set passes. Existing 48 dp, semantics, contrast,
non-colour state, reduced-motion, disabled-haptics, and asset-provenance
contracts remain unchanged. No asset bytes changed.

## Verification

- Focused REDs: consent `RenderFlex overflowed by 980 pixels on the bottom`;
  Preferences danger-zone heading `RenderFlex overflowed by 8.9 pixels on the
  right`. The recovery probe instead established that Start Fresh must be
  scrolled into view before opening its confirmation.
- Three exact 2.0x regression cases: pass.
- Affected 145-test first-run/destructive/recovery set: pass.
- Focused: `GATE_TOTAL|PASS|20167|Focused`.
- Visual: `GATE_TOTAL|PASS|17579|Visual`.
- Reset-assisted AndroidPrep:
  `GATE_TOTAL|PASS|97940|AndroidPrep`; its first attempt found only four
  documentation-test analyzer warnings introduced during receipt updates,
  which were removed before the passing rerun.
- Independent local read-only settled-diff review found one premature-closure
  contradiction and two evidence/test-strength gaps. All findings were
  resolved; the final recheck found no remaining findings.
- Reset-assisted Full: `GATE_TOTAL|PASS|258664|Full`. Its first run found only
  the 800-character rolling-log guard introduced by the provisional receipt;
  the narrow guard passed after compaction, then Full passed. Final Full remains
  required again at `DCL-RC-001`.

## Device evidence

One serial-pinned `danio_api36 (emulator-5554)` pass built and installed the
current debug APK, performed a Danio-only app-data reset, temporarily used
font scale 2.0, and captured only changed surfaces. Visual inspection found no
overflow stripe or clipped critical action. Scoped logcat contained no
`RenderFlex`, `overflowed`, `FlutterError`, or `FATAL EXCEPTION` match.

- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-first-run-destructive-recovery-dialogs/consent-2x.png`:
  `C1EF1CBEDFDE680C9151D0AEDF3FE438F35C7760B2FAFC3349CA510D321A1CA8`
- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-first-run-destructive-recovery-dialogs/consent-2x.xml`:
  `79E8DA19FF6C7E4B6E77AC508E1BF423605C3520F0F747923BF57E04F621CBB2`
- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-first-run-destructive-recovery-dialogs/consent-bottom-2x.png`:
  `9CC37C8D4044AA78C06E1E9F067EA2FFD653E31F8F2206FE8F236D1D1DE99AD6`
- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-first-run-destructive-recovery-dialogs/delete-my-data-dialog-2x.png`:
  `E3548369953B90C4D219694302CA6822205C20D01DA5A68449C03BEAF1F8C1D6`
- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-first-run-destructive-recovery-dialogs/delete-my-data-dialog-2x.xml`:
  `11B2A5EF4534BB3BF1BA54F7339C08326EE3C91211BE79DF7A75EA023F852F18`

The damaged-local-storage recovery card has no safe debug seed, so its Start
Fresh confirmation is proved by the deterministic 390x844 widget test rather
than manufacturing device corruption. The device was released with font scale
1.0, Danio stopped, launcher foreground, and serial-pinned CheckOnly passing.
The emulator remained running.

## Routing

All five phone-quality clusters are complete. `DCL-PERF-001 remains open`; its
Tank and scrolling dropped-frame budgets are next, followed by `DCL-RC-001`.
