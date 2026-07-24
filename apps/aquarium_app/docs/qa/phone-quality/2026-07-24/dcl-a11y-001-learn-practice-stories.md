# DCL-A11Y-001 Learn, Practice, and stories

Date: 2026-07-24
Epoch: `DR-2026-07-24-077`
Marker: `danio-phone-quality-cluster-2-learn-practice-stories-2026-07-24/1`
Base commit: `e16a31c6f987bfd79010822deb62b0f18b3df0b2`

## Outcome

Phone-quality cluster 2 is complete. Three phone-quality clusters remain.
Focused REDs proved three P1 defects:

1. `LearnPracticeCard` overflowed by **91 pixels on the right** at 360 x 800
   and 2.0x text.
2. the Practice Session progress row overflowed by **15 pixels on the right**
   at 390 x 560 and 2.0x text;
3. multiple-choice answer tiles kept their 200 ms colour transition when the
   platform requested reduced motion instead of using `Duration.zero`.

The smallest fixes let the Learn title wrap beside its badge, let the Practice
progress labels wrap, and disable the answer-tile transition through
`MediaQuery.disableAnimations`. No other product behavior changed.

## Audit boundary

The current repo-owned phone baselines were inspected before code changes:

- `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-01-learn-root.png`
- `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-02-practice-root.png`
- `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-12-practice-session.png`
- `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-78-story-browser.png`
- `docs/qa/screenshots/2026-07-04/cl-qa-001-phone-whole-app-map/phone-79-story-play.png`

The audit was limited to current Learn, Practice, and story surfaces:

- 2.0x coverage now selects the Learn root, weak-lesson Practice card, empty
  Practice hub, resolved Practice Session, story browser, and story play;
- existing controls remain standard `IconButton`, `AppButton`, or whole-card
  targets meeting the **48 dp** target rule; no smaller interactive target was
  reproduced;
- correct and incorrect Practice states retain icon plus colour, locked stories
  retain a lock icon plus explanatory tap feedback, and no colour-only P1 was
  reproduced;
- the existing semantic labels and navigation tests remain green;
- disabled haptics remain routed through the settled global preference adapter;
  this slice adds no haptic call;
- reduced-motion RED/GREEN now permanently covers the affected answer-tile
  animation;
- current Learn/story illustration bytes and source notes were reviewed. **No
  asset bytes changed**. The already-settled user-confirmed local ComfyUI
  provenance for the active ocean-room and Neon Tetra assets was not reopened.

No P0/P1 was reproduced on story layout, target size, semantics, contrast,
non-colour state, haptics, or asset provenance, so story product code remains
unchanged.

## Verification

- Focused RED: weak-lesson card reported `A RenderFlex overflowed by 91 pixels
  on the right`.
- Focused RED: Practice Session progress reported `A RenderFlex overflowed by
  15 pixels on the right`; the diagnostic stack bound it to
  `review_session_screen.dart`.
- Focused RED: reduced-motion selector found the option transitions were not
  `Duration.zero`.
- Focused GREEN:
  `GATE_TOTAL|PASS|19197|Focused` (59 tests plus analyze and diff checks).
- Visual:
  `GATE_TOTAL|PASS|17301|Visual` (66 tests, baseline manifest, analyze, and
  diff checks).
- Documentation guard RED: the DR-077 evidence file was absent.
- Documentation guard GREEN: the focused DR-077 guard and complete 30-test
  current-document contract suite pass.
- Settled reset-assisted Full:
  `GATE_TOTAL|PASS|297670|Full` (dependency validation, custom lint, full
  Flutter tests, analyze, and debug APK build).

## Device boundary

Ownership of `danio_api36 (emulator-5554)` was reacquired through both bounded
and serial-pinned CheckOnly preflights. The current debug APK built successfully
with SHA-256
`08EAC702065802B21A0107AE2699D3D34D03A969D95C6F327899FC37B6AB5041`
and installed without clearing app data.

At temporary font scale 2.0, the Learn deep-link wait timed out and UIAutomator
returned no root; a bounded retry remained on the splash screen. This matches
the already-closed whole-emulator pressure diagnosis and supplies **no
contradictory product evidence**. It was not converted into performance or
product evidence, and no screenshot from that non-rendered state is retained.

The device was released with font scale `1.0`, Danio stopped, the Nexus launcher
foreground, serial-pinned CheckOnly passing, and the emulator left running. No
wipe, restart, emulator kill, app-data clear, or performance rerun occurred.

`DCL-PERF-001 remains open` on its existing immutable authority. This epoch does
not alter its metrics, budgets, status, or next marker.

## Routing

This closeout leaves three verified sessions and three phone-quality clusters.
No successor was created because current repository authority supplies no exact
cluster-3 marker. Later clusters, final performance decision, final phone
sign-off, tablet, iOS, store, cloud, accounts, providers, paid services, and
secrets remain excluded.
