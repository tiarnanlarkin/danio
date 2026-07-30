# Temperature And Water-Quality Side-Panel Redesign

Status: current ordered manual continuation authority; Phase 3 complete; Phase 4 not started
Authorized: 2026-07-30
Authority epoch: `WF-2026-07-30-027`
Marker: `danio-temperature-water-quality-side-panel-redesign-2026-07-30/1`

## Outcome

Redesign the existing Home-stage temperature and water-quality side panels so
their information hierarchy, target state, and tank-context actions are clearer
without replacing Danio's established local data model, navigation surfaces, or
visual identity.

This is a bounded continuation after the local phone candidate. It is not a
release reopening, a frozen-autonomy reactivation, or authority for unrelated
screens. "Autonomous" means the single local coordinator may continue through
the ordered phases below without repeated approval while every live
precondition remains true. It does not authorize automatic successor tasks.

## Live Authority And Preserved Exploration

- Repository authority is local `main` in
  `C:\Users\larki\OneDrive\Documents\App Projects\Danio Aquarium App Project\repo`.
- The fetched Phase 2 starting point is clean, aligned `main` at
  `5e6e1a0c7cd8069ea3361bc4e178c37ae8d321cc`, tree
  `1c212fc5a54bfbb8e367861a8e199fe5e8ef98cd`, with
  `main...origin/main = 0 0`.
- Archive branch `archive/antigravity-exploration-wip-20260730` at
  `0f3167bb411ae1e6bc51966371c4cb986ae5a5c2` preserves the earlier exploratory
  bytes. It is evidence only: do not merge, cherry-pick, restore, or treat its
  source as implementation authority.
- The Antigravity PNGs, including the retro temperature and water gadget
  images, are visual references only. They are not shipping assets and must not
  be copied to `main`, registered in `pubspec.yaml`, or represented as approved
  production assets. Any later production asset needs its own provenance and
  approval record.
- Current-source implementation begins from
  `lib/widgets/stage/temp_panel_content.dart`,
  `lib/widgets/stage/water_panel_content.dart`, and the existing
  `SwissArmyPanel` integration in `lib/screens/home/home_screen.dart`.
- Current focused coverage begins with
  `test/widgets/stage/temp_panel_content_test.dart`,
  `test/widgets/stage/water_panel_content_test.dart`, and
  `test/widgets/stage/swiss_army_panel_test.dart`.
- Root plan `docs/plans/2026-04-07-side-panel-redesign-plan.md` is retained
  historical implementation evidence. Its stale branch, baseline, task list,
  shipping-screenshot instructions, and push/PR routing cannot select current
  work; this plan supersedes it for side-panel work selection.
- The closed phone RC plans remain historical evidence. They no longer select
  work for this redesign.

## Fixed Product Decisions

1. The temperature-target selector has an explicit `Custom` state. It reflects
   the tank's current `WaterTargets.tempMin` and `WaterTargets.tempMax`; it must
   not silently present an unmatched stored range as a named preset. Reuse the
   existing tank target model and save path. Do not add another persistence
   store or a schema migration for this redesign.
2. The temperature panel's primary shortcut order is:
   `Log Temperature`, `Charts/History`, `Equipment`, then `Alerts`.
3. `Tank Settings` is present but visually secondary to those four actions.
4. Existing readings, streaks, trends, health scores, target ranges, and empty
   states remain data-driven. No decorative control may fabricate a reading,
   heater state, history item, equipment state, or alert.

## Cross-Cutting Interaction Contract

- Close the originating stage panel before pushing a destination so back
  navigation returns to a coherent Home state.
- Lock each shortcut's destination from current local source before writing its
  route test. Preserve `tankId`; do not invent a cloud service or duplicate
  destination to satisfy a label.
- Each shortcut keeps a distinct semantic label, tooltip where appropriate,
  and at least a 48 by 48 dp effective target.
- The primary/secondary hierarchy must survive a 390 by 844 phone viewport,
  2.0x text scale, dark and light themes, and all current room themes without
  clipped actions or unreachable content.
- Honor `MediaQuery.disableAnimations` and the persisted haptic preference.
  Use the existing preference-aware haptic adapter only; do not add direct
  platform haptic calls.
- Preserve loading, missing-reading, provider-error, and empty-history honesty.
- Prefer existing theme tokens, route helpers, widgets, and dependencies. No
  package or asset addition is authorized by this plan.

## Ordered Phases

### Phase 2 - Durable authority checkpoint

This documentation-only epoch creates this plan, points `ACTIVE_HANDOFF.md` to
it, and adds the rolling `SLICE_LOG.md` receipt. Because the live log is already
at its 25-row cap, preserve the unpinned `DR-2026-07-21-065` row byte-for-byte
in the existing overflow archive before replacing that live slot.

Allowed files:

- this plan;
- `docs/agent/ACTIVE_HANDOFF.md`;
- `docs/agent/SLICE_LOG.md`;
- `docs/archive/agent-workflow-2026-07-16/SLICE_LOG-rolling-overflow.md` only
  for the required row-cap rollover.

No product source, product-test file, asset, dependency, build, device,
emulator, or heavy operation belongs to Phase 2. The focused docs-record guard
and one Docs profile are the only authorized test execution. Prove the
missing-record guard RED, the completed record GREEN, `git diff --check`, and
one Docs gate. Commit only this docs epoch. The current instruction explicitly
forbids a push.

### Phase 3 - Temperature panel behavior and action hierarchy

Start from the clean committed Phase 2 checkpoint, fetch and confirm the remote
is not ahead, re-check coordination, and hold the writer claim. Ground the
change in a current-source screenshot or existing visual baseline before
editing. Record the four shortcut destinations from current routes/screens
before RED; if a label has more than one materially different honest
destination, stop for that product decision rather than choosing silently.

Write focused failing tests first for:

- an unmatched persisted temperature range rendering `Custom` as the selected
  target state and remaining stable across widget rebuild;
- the exact primary shortcut order and secondary `Tank Settings` placement;
- each action preserving `tankId`, closing `StagePanel.temp`, and reaching its
  current local destination;
- 2.0x reflow, 48 dp targets, semantics, and reduced-motion behavior affected
  by the settled design.

Then make the smallest current-source implementation. Likely files are
`temp_panel_content.dart`, a narrowly scoped temperature or shared stage
widget, and the existing temperature panel test. Reuse `WaterTargets`; do not
copy archived gadget code or PNGs. If the current save contract cannot express
the approved `Custom` state without a model/schema migration, stop before that
write and record the exact blocker rather than inventing persistence.

Close Phase 3 with the affected Focused and Visual profiles, an independent
read-only settled-diff review, and one final Full gate. Claim the shared heavy
lane before Flutter/Full work. No device run is required unless current
visual evidence is insufficient; any device use needs separate ownership.

### Phase 4 - Water-quality panel hierarchy

Keep the temperature phase settled. Audit the water-quality panel's current
actions and destinations, then record its own focused hierarchy before
implementation; do not infer that a temperature-only label belongs there.
Test-first, preserve its six current parameter readouts, health and trend
honesty, and `Log Water Test` meaning. Reuse the shared action component only
if Phase 3 proves that extraction is smaller and clearer than duplication.
Keep asset and dependency scope closed.

Close with affected Focused and Visual profiles, settled-diff review, and one
Full gate under the heavy-lane contract.

### Phase 5 - Integrated visual and accessibility closeout

Compare both panels against their current baseline and the reference-only
exploration, without importing archived bytes. Resolve only reproducible panel
regressions: hierarchy, contrast, 2.0x reflow, 48 dp targets, semantics,
reduced motion, haptic preference, and route behavior. Run the smallest
affected checks plus one final Full gate if product bytes change. Add owned
device evidence only after explicit device ownership and AndroidPrep.

Update the handoff and rolling log at every completed epoch. Do not claim a new
release candidate or reopen closed phone rows merely because this redesign
completes.

## Verification And Git Boundary

- Product behavior uses focused RED, smallest GREEN, affected Focused/Visual,
  independent settled-diff review, then one Full gate.
- Documentation-only Phase 2 uses the Docs profile and no Full gate.
- All gates run from `apps/aquarium_app`.
- Stage only the files named by the active phase and inspect staged and
  unstaged diffs before commit.
- Do not push Phase 2. A later push requires a separate instruction and a fresh
  fetch/remote comparison.
- Do not touch the archive branch, frozen autonomy state, cloud/accounts,
  provider keys, Play Store, iOS, tablet scope, or unrelated branches.

## Communication Convention

Voice chat is optional and never a gate, authority source, or dependency.
Live Git and the repo-owned plan, handoff, and epoch log outrank voice or chat
history after a restart. During active execution, post a concise progress
update at each material checkpoint and at least every 20 minutes, plus an
immediate update for any authority, coordination, test, gate, scope, or device
blocker.

## Next Manual Action

Phase 3 `DR-2026-07-30-083` is complete at its clean pushed checkpoint.
Phase 4 Water Quality remains the next ordered phase but is not started; rebuild
live Git and coordination authority before a later instruction, and never
create an automatic successor.
