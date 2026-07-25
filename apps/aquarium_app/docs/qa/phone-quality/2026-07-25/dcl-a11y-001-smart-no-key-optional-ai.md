# DCL-A11Y-001 Smart, no-key, and Optional AI

Date: 2026-07-25
Epoch: `DR-2026-07-24-078`
Marker: `danio-phone-quality-cluster-3-smart-no-key-optional-ai-2026-07-24/1`
Base commit: `508d8e5a4cfdb34a58333acbaed8601fb7308ac2`

## Outcome

Phone-quality cluster 3 is complete. Two phone-quality clusters remain.
Focused REDs in the preserved bundle proved material 2.0x reflow and
reduced-motion defects on the Smart and Optional-AI surfaces:

1. keyless Smart feature titles and setup guidance were forced to one line and
   ellipsized rather than reflowing;
2. the Weekly Plan AI disclaimer could not reflow safely at 2.0x;
3. Smart cards, Fish ID loading/results, Symptom Triage loading, Weekly Plan
   day cards, and the shared bubble loader still created animation wrappers
   when the platform requested reduced motion.

The smallest fixes remove the one-line truncation, allow the disclaimer to
flex, and bypass only those animations when
`MediaQuery.disableAnimations` is true. No feature, provider connector, key,
account, cloud behavior, or persistence path was added.

## Audit boundary

The bounded audit covered 48 dp controls, semantics, contrast, non-colour
state, 2.0x reflow and clipping, reduced motion, disabled haptics, no-key and
provider honesty, and affected visual evidence.

- Existing whole-card, `AppButton`, and standard icon controls retain the
  established 48 dp target contract; no smaller scoped control was reproduced.
- Locked Optional-AI cards expose setup actions to semantics. The device XML
  distinguishes `Local checks, no AI key needed` from
  `Optional AI setup required`.
- Local Aquarium Intelligence remains available without a provider key;
  Fish ID, Symptom Checker, and Weekly Plan remain visibly locked until the
  user configures Optional AI in Preferences.
- Lock icons, explanatory text, and semantic labels keep state non-colour-only.
- No scoped P0/P1 contrast defect was reproduced in the current light-theme
  screenshots or widget paths.
- The settled global preference adapter still owns disabled haptics; this
  epoch adds no haptic call.
- **No asset bytes changed.** Current asset provenance and the open performance
  findings were not reopened. `DCL-PERF-001 remains open`.

## Verification

- Focused GREEN:
  `GATE_TOTAL|PASS|105677|Focused` (36 affected tests, analyze, worktree, and
  diff checks).
- Visual:
  `GATE_TOTAL|PASS|14653|Visual` (affected tests, visual contracts/goldens,
  analyze, worktree, and diff checks).
- The first Full attempt stopped on missing generated Android transform
  directories while the full Flutter suite, analyze, and APK build passed.
  It was not counted as closure evidence.
- The one user-authorized reset-assisted retry passed:
  `GATE_TOTAL|PASS|253493|Full` (generated-output reset, signing guard,
  dependency validation, custom lint, 2,381 Flutter tests, analyze, and debug
  APK build).

## Device evidence

The named Quick Boot path and serial-pinned CheckOnly confirmed
`danio_api36 (emulator-5554)`. The current debug APK, SHA-256
`6D09ED8FA0D0545D6AD1967DCBC4C644CA68015D8233B26F7987FAC163D7B8EA`,
installed without clearing app data.

At temporary font scale 2.0, `danio://qa/smart` rendered the keyless Smart root
and the local/locked card boundary without visible clipping or truncation. The
UI hierarchy exposed the intended semantics, and the scoped logcat scan found
no RenderFlex overflow, Flutter exception, ANR, or fatal boundary.

Evidence:

- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-smart-no-key-optional-ai/phone-smart-no-key-2x.png`
  - SHA-256 `DBA72B02B6C77CA95C0ED5A51194854E6E56EAC30AA6068F953A3794DDB3D316`
- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-smart-no-key-optional-ai/phone-smart-no-key-2x.xml`
  - SHA-256 `07EEEFAC9367ED9D039F1FC6E09B6F8C651C2AEC86803797934604339B48CF9E`
- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-smart-no-key-optional-ai/phone-smart-no-key-2x-logcat.txt`
  - SHA-256 `6B6BA48790CB1B308F93279EC4506B3C48E82C3643A665F128318FE0B5EA23AC`
- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-smart-no-key-optional-ai/phone-smart-no-key-cards-2x.png`
  - SHA-256 `3F8F680FCFD0537CE6D6EC437F7C38A1683683F114D8750E43187159A09934F0`
- `docs/qa/screenshots/2026-07-25/dcl-a11y-001-smart-no-key-optional-ai/phone-smart-no-key-cards-2x.xml`
  - SHA-256 `FD002D9F0553612727A9C742AB72049BA258861776654485089B318A3EB97C2F`

The device was released with font scale `1.0`, Danio stopped, the Nexus
launcher foreground, serial-pinned CheckOnly passing, and the emulator left
running. No wipe, restart, emulator kill, app-data clear, provider setup, or
performance rerun occurred.

## Routing

This closeout leaves two verified sessions and two phone-quality clusters.
No successor was created. No later cluster is selected; Cluster 4/5,
performance, tablet, iOS, store, cloud, accounts, providers, paid services,
secrets, and external actions remain excluded pending explicit direction.
