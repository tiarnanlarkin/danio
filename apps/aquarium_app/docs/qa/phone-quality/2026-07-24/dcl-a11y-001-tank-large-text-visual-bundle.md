# Tank Detail and Add Log 2.0x large-text visual bundle

Date: 2026-07-24
Epoch: `DR-2026-07-24-075`
Marker: `danio-phone-quality-cluster-1-tank-large-text-visual-bundle-2026-07-24/1`
Device: `danio_api36 (emulator-5554)`, 1080 x 2400 px at 2.625 px/dp

## Scope and outcome

This bundle resolves only the known Tank Detail and Add Log P1 layout failures
at 2.0x text scale. Permanent widget coverage uses a 390 x 844 logical-pixel
phone viewport and `TextScaler.linear(2)`. The product changes are limited to
reflowing the affected rows, labels, and score gauge; no asset, animation,
haptic, performance, storage, tablet, iOS, account, provider, store, or cloud
behavior changed.

Phone-quality cluster 1 is complete. `DCL-A11Y-001`, `DCL-VIS-001`,
`DCL-VIS-002`, and `DCL-MOTION-001` remain open because four phone-quality
clusters remain.

## Focused RED evidence

The permanent named tests are:

- `keeps populated tank detail free of overflow at 2.0x text scale`
- `keeps Add Log free of overflow at 2.0x text scale`

Before the product fix, the Tank test failed for the expected layout reasons:
the Tank Health header overflowed 422 px right, its fixed-height score gauge
overflowed 76 px bottom, the quick-stat row overflowed 10 px right, and the
last-water-change row overflowed 44 px right. The Add Log date/time row
overflowed 77 px right.

The first device pass then exposed an additional populated-state stripe at the
Latest Water Snapshot header. The Tank test was tightened before the follow-up
fix by seeding a current water test and scrolling to the card. That valid RED
reported a 64 px right overflow in the populated Tank Health header and a
161 px right overflow in the snapshot header. The captured pre-fix device
stripe itself reported 76 px right:
`docs/qa/screenshots/2026-07-24/dcl-a11y-001-tank-large-text/phone-tank-detail-2x-snapshot-red.png`.

## Smallest related fix

- `tank_health_card.dart` gives the title and status label bounded flexible
  space and lets the 100 dp-wide score gauge grow vertically for scaled text.
- `quick_stats.dart` gives each stat an equal bounded column and lets the
  last-water-change label wrap beside its icon.
- `snapshot_card.dart` lets the populated title wrap while preserving the
  date.
- `add_log_screen.dart` lets the date/time text wrap while preserving the
  `Now` action.

No speculative polish or later phone-quality surface was included.

## GREEN and visual verification

- Final affected widget/analyze gate:
  `GATE_TOTAL|PASS|22419|Focused`.
- Final affected visual/golden/analyze gate:
  `GATE_TOTAL|PASS|28820|Visual`.
- A settled Android x64 debug APK build completed in 25.7 seconds.
- The final APK was installed only after serial-pinned ownership and
  `danio_api36` identity checks. Seeded Tank Detail and Add Log routes were
  inspected at Android system `font_scale=2.0`; the header, gauge, quick stats,
  water-change banner, populated snapshot header, Add Log top, and date/time
  row showed no overflow stripe, clipping, or lost action.
- Logcat was cleared before the definitive run. A case-insensitive scan of the
  five definitive capture logs returned no RenderFlex, FlutterError, fatal, or
  unhandled-exception matches.
- Ownership release restored `font_scale` from `2.0` to `1.0`, stopped Danio,
  returned to the Nexus launcher, and passed the serial-pinned CheckOnly
  preflight. The dedicated emulator was left running.
- Final reset-assisted settled-tree gate:
  `GATE_TOTAL|PASS|378547|Full`; signing and dependency guards, custom lint,
  2,365 Flutter tests, analysis, and the debug APK all passed.

## Bound screenshots

| Evidence | SHA-256 |
| --- | --- |
| `docs/qa/screenshots/2026-07-24/dcl-a11y-001-tank-large-text/phone-add-log-2x-date-green.png` | `45F2077E1454008320CBEF7F8135CDBA888248443ECC0F9A0C42551CC529B397` |
| `docs/qa/screenshots/2026-07-24/dcl-a11y-001-tank-large-text/phone-add-log-2x-top-green.png` | `F30572D76D91F2770DDEEC401E9EC809A94EF67CBE7AB50AC8EE800BF0370A6F` |
| `docs/qa/screenshots/2026-07-24/dcl-a11y-001-tank-large-text/phone-tank-detail-2x-health-green.png` | `CF72B402DDFE7A36906C828DB2DDDEE991576503344616A76999C0DABB59281C` |
| `docs/qa/screenshots/2026-07-24/dcl-a11y-001-tank-large-text/phone-tank-detail-2x-snapshot-green.png` | `FA013E71A15B2423C55E89AECFEE6CBB7B97B3C58CA73CE5E4EE90BE534AFEA5` |
| `docs/qa/screenshots/2026-07-24/dcl-a11y-001-tank-large-text/phone-tank-detail-2x-snapshot-red.png` | `F25FB6BE4C581809047C50B8D3ABCFDCC189218544E0676B0406D492FAB2CB9E` |
| `docs/qa/screenshots/2026-07-24/dcl-a11y-001-tank-large-text/phone-tank-detail-2x-top-green.png` | `57D1409AF4221C79E2B4FA139BC3B541C8000A6F717C648F3AE4BF3ECE795A27` |

The pre-fix screenshot is retained only as the visual RED. All `green`
screenshots come from the final settled APK after the last layout change.

## Routing boundary

The ordered next surface group is Learn/Practice/stories, but current
repository authority does not assign it an exact successor marker. No
successor was created or guessed. Cluster 2 and every later cluster remain
outside this epoch.
