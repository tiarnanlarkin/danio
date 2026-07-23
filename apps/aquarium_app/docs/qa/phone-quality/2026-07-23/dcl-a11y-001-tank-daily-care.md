# Tank and daily-care phone-quality evidence

Date: 2026-07-23
Epoch: `DR-2026-07-23-072`
Marker: `danio-phone-quality-cluster-1-tank-daily-care-2026-07-23/1`
Device: `danio_api36 (emulator-5554)` at 2.625 px/dp

## Scope and result

This is the first of the five ordered phone-quality clusters. It covers the
current Tank root, tank detail, Add Log, Tasks, Equipment, and Livestock daily-
care surfaces. One P1 essential-accessibility defect was proved and fixed: the
compact energy action on the Tank root exposed a semantic button but measured
only 140 x 70 px (53.3 x 26.7 dp) in the current baseline hierarchy.

The smallest product change opts only the Tank-root instance into a 48 x 48 dp
minimum constraint. The focused widget RED observed 26.0 dp height before the
change; the same test is GREEN after it. Fresh device evidence measures the
control at 140 x 126 px (53.3 x 48.0 dp).

The cluster is **not complete**. A bounded 2.0x probe proved additional Tank-
detail and Add Log layout failures after this epoch's one permitted product
finding, and the repository does not establish the explicit usage-rights basis
for two active visual assets. Those are durable stop conditions, not inferred
passes or additional fixes in this epoch.

## Evidence by release criterion

- **48 dp and semantics:** `test/widget_tests/heart_indicator_test.dart`
  asserts the compact action's semantic label and both minimum dimensions.
  Fresh `phone-tank-energy-48dp.xml` labels it `5 of 5 energy remaining` and
  bounds it at `[394,157][534,283]`. Every clickable control in that fresh Tank
  hierarchy is at least 126 px in both dimensions.
- **2.0x text reflow:** `test/widget_tests/home_screen_layout_test.dart` now
  exercises the primary Tank controls at `TextScaler.linear(2)` and passes.
  Temporary 390 x 844 probes then exercised populated Tank detail, Add Log,
  Tasks, Equipment, and Livestock surfaces. Tasks, Equipment, and Livestock
  passed. Tank detail failed with four overflows: 422 px right and 76 px bottom
  in `tank_health_card.dart`, plus 10 px and 44 px right in `quick_stats.dart`.
  Add Log failed with a 57 px right overflow. The temporary probes were removed
  after recording the focused REDs so this one-finding epoch can retain a green
  required gate; the two proven P1 layout findings remain unresolved.
- **Contrast and non-colour state:** the fresh Tank capture preserves legible
  white icon/text on the dark energy overlay. Current daily-care captures use
  text and/or icon state in addition to colour: Tank Health includes the
  `Excellent` label, water-parameter state includes `Safe`/`Warning`/`Danger`,
  and compatibility/care warnings include explanatory text and warning icons.
  Visual inspection found no material P1 contrast or colour-only state defect.
- **Reduced motion:** the Tank route continues to receive the global
  `MediaQuery.disableAnimations` override. Direct coverage remains in
  `test/widgets/reduced_motion_media_query_test.dart`,
  `test/widgets/room/animated_swimming_fish_test.dart`, and
  `test/widgets/room/species_fish_test.dart`; the relevant Tank animation paths
  disable or mute motion when that flag is set.
- **Disabled haptics:** `test/utils/haptic_feedback_test.dart` proves a
  persisted disabled preference emits zero platform haptic calls, including
  before settings hydration. `test/quality/haptic_boundary_contract_test.dart`
  keeps all product calls behind the preference-aware adapter. The cluster
  introduces no new haptic boundary.
- **Affected visuals:** current reference captures inspected were
  `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-03-tank-root.png`,
  `phone-60-tank-detail.png`, `phone-62-add-log.png`, `phone-69-tasks.png`,
  `phone-71-equipment.png`, and `phone-72-livestock.png` in that same folder.
  The fresh post-fix Tank capture shows the enlarged hit area aligned with the
  neighbouring 48 dp app-bar controls, with no overlap or clipping. The new
  `enforceMinimumTapTarget` opt-in is used only by the Tank root; Practice Hub,
  Lesson, and Review Session retain their prior compact layout and are not
  claimed or visually changed by this epoch.
- **Asset provenance and rights HOLD:** this epoch adds or changes no visual
  asset. No file
  beneath `assets/` has changed since current visual baseline commit
  `6fa6ae2f`. Commit `6f282e18`, authored by Tiarnan Larkin, records the active
  ocean room background as Gemini-generated (SHA-256
  `9EB413514D278EF6291BA8D59D955A50BF4CBFB879F8073BD93DA1B328CF2E5D`),
  but the repo has no explicit licence/usage-basis record. The active Neon
  Tetra WebP was regenerated in Tiarnan Larkin's commit `f9142713` from a PNG
  first integrated by Tiarnan Larkin in commit `081a9e8e` (SHA-256
  `EC8425F198A8E9CD9368161A4D43CBC06ABF4CD83E65669B98692D8F934725AA`).
  Neither commit records the original creator/generator or licence/usage basis.
  Review status is therefore `HOLD`: ownership cannot be inferred from Git
  authorship, and the RC asset-rights criterion remains unresolved.

## Captured output and verification

- Screenshot:
  `docs/qa/screenshots/2026-07-23/dcl-a11y-001-tank-daily-care/phone-tank-energy-48dp.png`
  - SHA-256:
    `72CC11FBEEA2AF411139F8439FCB2A3241AB7FCD0A39A09467FECB4B40503C44`
- UI hierarchy:
  `docs/qa/screenshots/2026-07-23/dcl-a11y-001-tank-daily-care/phone-tank-energy-48dp.xml`
  - SHA-256:
    `BBE03B7C74ECF90CF6955B775395589619E4F8DF07C36FEFB4735DA0A35A79F2`
- Focused RED: `opted-in compact energy control keeps a 48dp touch target`
  originated as `compact energy control keeps a 48dp touch target` and failed for
  the intended reason: actual height 26.0 was below 48.0.
- Initial focused GREEN: `GATE_TOTAL|PASS|10752|Focused`; final scoped
  widget/source GREEN passed at `GATE_TOTAL|PASS|13620|Focused`.
- Visual: `GATE_TOTAL|PASS|18059|Visual`; 33 affected, haptic, reduced-motion,
  visual-contract, and golden checks plus analysis passed.
- Documentation closeout: `GATE_TOTAL|PASS|4921|Docs`; current-doc contracts
  and the tracked signing-credential guard passed.
- Full attempt 1 exposed stale generated Android transform paths. The reset-
  assisted run then exposed the missing historical `DR-2026-07-23-071` handoff
  contract; all 26 current-doc tests passed after that contract was restored.
  The corrected reset-assisted Full passed at
  `GATE_TOTAL|PASS|200329|Full`, including dependency validation, custom lint,
  the complete Flutter suite, analysis, and debug APK.
- Independent read-only review confirmed the 48 dp fix and identified the 2.0x,
  rights, and cross-surface evidence gaps. After the fix was scoped to Tank and
  the cluster was marked open/HOLD, re-review found only a timing-wording P2;
  that inconsistency is corrected in this closeout.
- 2.0x named test: `keeps primary controls stable at 2.0x text scale` passed.

This first cluster and the other four phone-quality clusters are not claimed.
`DCL-A11Y-001`, `DCL-VIS-001`, `DCL-VIS-002`, and `DCL-MOTION-001` remain open.
The independent performance rows and dropped-frame evidence were not
interpreted, rerun, or changed in this cluster.
