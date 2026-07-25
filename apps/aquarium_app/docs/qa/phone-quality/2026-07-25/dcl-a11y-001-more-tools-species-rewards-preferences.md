# DCL-A11Y-001 More, tools, species, rewards, and preferences

Date: 2026-07-25
Epoch: `DR-2026-07-25-079`
Marker: `danio-phone-quality-cluster-4-more-tools-species-rewards-preferences-2026-07-25/1`
Base commit: `abae6462d0c3cda4da407384d304687644cc6d46`

## Outcome

Phone-quality cluster 4 is complete. One phone-quality cluster remains.
Focused RED and device evidence proved:

1. Workshop tool cards and Cost Tracker could not reflow at 2.0x;
2. the Achievements header and Recently Unlocked strip overflowed, while its
   grid retained an unsuitable two-column phone layout;
3. Gem Shop cards overflowed and its fixed tab row clipped category labels.

Large text now uses bounded single-column cards where needed, flexible
headers, a taller recent-achievement strip, and a scrollable Gem Shop tab row.
No feature, persistence, reward rule, asset, provider, account, or cloud
behavior changed.

More, species, plants, Inventory, and Preferences received permanent 390x844
2.0x coverage. Existing 48 dp, semantics, non-colour state, reduced-motion,
disabled-haptic, and asset-provenance contracts remain unchanged. No scoped
contrast or asset-rights P0/P1 was reproduced. `DCL-PERF-001 remains open`.

## Verification

- Affected 158-test set: pass.
- Focused: `GATE_TOTAL|PASS|31694|Focused`.
- Visual before review: `GATE_TOTAL|PASS|16038|Visual`.
- Reviewer-finding Visual rerun: `GATE_TOTAL|PASS|13574|Visual`.
- Reset-assisted AndroidPrep:
  `GATE_TOTAL|PASS|104124|AndroidPrep`; its initial stale-transform attempt is
  tooling uncertainty, not closure evidence.
- Independent local repository-read-only review found one P1 card-density
  issue and one P2 vertical-scroll test gap. Both were resolved and rechecked;
  its final settled review found no remaining product blocker and identified
  the controlling Full requirement.
- Reset-assisted Full: `GATE_TOTAL|PASS|206858|Full`; the first attempt exposed
  only the documented stale Android transform paths plus receipt-guard drift.
  The narrow docs guards were repaired before this passing rerun. Final Full
  remains required again at `DCL-RC-001`.

## Device evidence

One serial-pinned `danio_api36 (emulator-5554)` pass installed the current
debug APK (SHA-256
`B4707F759CABBC1612713245F93AC2ACC2FF1CC6232ACF4FF191862733B96E9D`),
temporarily used font scale 2.0, and captured only changed surfaces. Visual
inspection found no clipping, overflow stripe, or unusable card density after
review corrections; scoped logcat found no Flutter overflow/fatal boundary.

- `workshop-2x.png`: `547AC53EB07130DC01C2A394110E6F1FA7316B100B6F6BE36DB5E9D1766F74EE`
- `workshop-2x.xml`: `24C186555DF3AA6EAAF6FBAD30D803136D29B733C4C049DF4B8FC32856FC591D`
- `achievements-2x.png`: `6D146FCE0645A1AB82C0C033CB0E631E0C68202CF2BB8AEF6E076A562DE0EDE7`
- `achievements-2x.xml`: `4A36FFF660BFB4A8652F353FF3B29C09C6B83385FDF5C351339012C55B60DC10`
- `gem-shop-2x.png`: `9A3F97A387540F6850EE95DF4740785C2B68D7D49B3446BC551F4DA59ECB190B`
- `gem-shop-2x.xml`: `ADFC354A4A08C6ECECD801AED0939D892185E40BD80C6ABF4643951F18345D44`

The device was released with font scale 1.0, Danio stopped, launcher
foreground, and serial-pinned CheckOnly passing. The emulator remained
running; no wipe, restart, app-data clear, or non-Danio device was used.

## Routing

The authorized next slice is phone-quality Cluster 5: first run plus
destructive/data-recovery dialogs. Clusters 1-4 stay closed. Performance
disposition and `DCL-RC-001` remain later in the approved order.
