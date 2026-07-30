# Temperature Visual-Authority Addendum

Status: current Phase 3 visual-reconciliation authority; implementation not started
Authorized: 2026-07-31
Authority epoch: `WF-2026-07-31-028`
Marker: `danio-temperature-visual-reconciliation-authority-2026-07-31/1`
Parent plan: `2026-07-30-temperature-water-quality-side-panel-redesign.md`

## Purpose And Boundary

Phase 3 behavior is complete at commit
`8b368dddfdab471eae009fcb9c3d6edfc10b927a`, tree
`e29210dea320e705aaab3019315f526b3261db45`, but its visual acceptance is
not reconciled with the agreed retro-aquatic instrument direction. This
addendum inserts Phase 3R before Phase 4 and corrects visual authority without
rolling back or reopening the verified Phase 3 behavior.

Phase 3R must produce one full retro-aquatic, gauge-led Temperature instrument
chassis. It must not resolve into a generic dashboard, a conventional card
stack, a white or glass drawer containing instrument-themed cards, or an
archived image pasted behind current controls.

This addendum supersedes only assertions that require a flat or gradient-free
Temperature surface, forbid one cohesive instrument chassis, remove a
substantial integrated history readout, or fix the trend display to a slim or
at-most-40-dp sparkline. In particular, the visual acceptance assertions at
`test/widgets/stage/temp_panel_content_test.dart:160-227` and
`:253-298` must be replaced test-first during Phase 3R.

The supersession does not authorize a generic card/dashboard layout, archived
shipping assets, new product data, new actions, changed routes, Water Quality
work, or any relaxation of honesty, accessibility, motion, haptic, theme,
tank-context, loading, empty-state, or provider-error contracts.

## Exact Reference Blobs

The preserved archive anchor is branch
`archive/antigravity-exploration-wip-20260730` at commit
`0f3167bb411ae1e6bc51966371c4cb986ae5a5c2`, tree
`893fd1c3ad1d914e989435fd77389ae0aa211a41`.

| Role | Archive path | Git blob | SHA-256 | Exact evidence |
| --- | --- | --- | --- | --- |
| Normative Temperature visual reference | `apps/aquarium_app/assets/images/illustrations/retro_temp_gadget.png` | `c15197615e8cd33a9bb74cdf75525d4b651fcb06` | `0E6A926AA9B738A2255A98927453256C1CC4902358D65495484892A2B278DB26` | 846,404 bytes; 1024 x 1024 JPEG/JFIF bytes despite the `.png` suffix |
| Sibling material-language reference only | `apps/aquarium_app/assets/images/illustrations/retro_water_gadget.png` | `db949745c7675b3cb968c377098d3b76a41da7b5` | `225F132B89E81A27D6A08354CB6E06C3471529F902F739C4D9C17ACBFA8932EB` | 780,968 bytes; 1024 x 1024 JPEG/JFIF bytes despite the `.png` suffix |

Both blobs are visual references only and are absent from `main`. They are not
shipping assets or implementation authority. Do not merge, cherry-pick,
restore, copy, rename, re-encode, register in `pubspec.yaml`, or represent
either blob as an approved production asset. Do not restore archived widget
source. A later production asset would need its own provenance and approval
record.

The Temperature blob controls Phase 3R composition and material vocabulary.
The Water blob records only the sibling vocabulary already named by the parent
plan. It does not start, specify, or authorize Phase 4 Water Quality work.

## Required Instrument Chassis

The complete Temperature drawer surface must read as one physically integrated
instrument:

- a black or gunmetal faceplate with inset zones, seams, bevels, corner
  fasteners, restrained wear, and convincing layered depth;
- brass or aged-metal hardware, an ivory analog dial, an amber numerical
  window, teal aquatic accents, and state-driven jewel lamps;
- warm instrument highlights, cool aquarium spill, and narrow lamp bloom;
- gradients, textures, shadows, highlights, and shaped material layers where
  they establish the reference's depth rather than decorative noise;
- a dominant gauge and readout, an integrated target assembly, a substantial
  instrument-style seven-day display, and a tactile action bank within the
  chassis rather than separate dashboard cards.

Decorative bolts, plates, seams, scratches, reflections, and lights must be
silent to assistive technology and must not receive a hit target. No additional
knob, switch, button, lamp, socket, dial, or lever may appear to be actionable
or stateful unless it has an exact mapping in the contract below.

## Honest Control And Readout Contract

| Visual element | Exact honest meaning or action | Affordance boundary |
| --- | --- | --- |
| `Temperature` title plate and streak counter | Identifies this instrument; the streak is consecutive calendar days backed by local water-test logs and is hidden when there is no current temperature reading | Read-only |
| Dominant analog gauge | Latest manually logged `WaterTestResults.temperature`, with the saved target arc; default scale 18-30 degrees C expands only for an outlying stored reading or target | Read-only; no sensor or live-telemetry implication |
| Amber numerical window and age | The same manually logged value to one decimal plus the latest qualifying local entry's relative `Last logged` age; `--` and no age when absent | Read-only; combine semantics with the gauge so the same value is not announced twice |
| LOW / TARGET / HIGH lamps | LOW for current `cool` or `tooCold`; TARGET for `perfect`; HIGH for `warm` or `tooHot`, derived only from the latest stored reading against a complete saved target | Read-only; all unlit when the reading or complete target is unavailable |
| Exact target-range display | The valid saved `WaterTargets.tempMin` and `tempMax`; unavailable when the stored range is incomplete or invalid | Read-only; it is a user target, not a thermostat setpoint |
| Tropical selector | Saves only 24-28 degrees C to this tank's existing target model | Interactive named preset with preference-aware selection haptic |
| Coldwater selector | Saves only 15-22 degrees C to this tank's existing target model | Interactive named preset with preference-aware selection haptic |
| Custom range window | Derived selected state for any unmatched saved range, showing its exact stored values or honest unavailable copy | Read-only; never a selectable or fake editing control |
| Target-state pilot and copy | Only loading, saving, saved-to-this-tank, unavailable, or failed-and-reverted target state | Read-only and data-driven; no equipment-state meaning |
| Temperature status plate | `Perfect`, `A little warm/cool`, or `Too hot/cold` from the current Phase 3 target comparison | Read-only; not whole-tank, heater, alarm, or hardware health |
| Seven-day instrument strip | The most recent manually logged temperature per calendar day for the last seven days, with min/average/max for available points | Read-only; preserve honest zero-, one-, and many-reading states and history errors |
| `Log Temperature` momentary control | Closes `StagePanel.temp`, then opens `AddLogScreen` for the same `tankId` with `LogType.waterTest` | Primary action; it opens the form and does not log a value immediately |
| `Charts/History` control | Closes the panel, then opens `ChartsScreen(tankId, initialParam: 'temp')` | Genuine action |
| `Equipment` control | Closes the panel, then opens `EquipmentScreen(tankId)` | Genuine navigation only; never a heater or power toggle |
| Red-capped `Alerts` control | Closes the panel, then opens `TankDetailScreen(tankId)`, which contains the Alerts surface | Genuine navigation only; normally unlit and never an active-alarm claim without real alert data |
| Recessed `Tank Settings` control | Closes the panel, then opens `TankSettingsScreen(tankId)` | Genuine action, visually and semantically secondary to the four primary actions |

The primary action order remains `Log Temperature`, `Charts/History`,
`Equipment`, `Alerts`, followed by secondary `Tank Settings`. Every route must
preserve `tankId` and close `StagePanel.temp` before pushing.

## Prohibited Claims

The chassis must not display, imply, or simulate any of the following without a
separately verified authoritative data and action contract:

- live, real-time, continuous, automatic, connected, or sensor-sourced
  temperature;
- sensor connected, online, offline, calibrated, or fault state;
- heater ON/OFF, heating or cooling activity, thermostat state, heater power,
  mains power, power consumption, flow, fan, or lighting state;
- a power, heater, sensor, auto/manual, calibrate, flow, fan, or light toggle;
- equipment operating state, active alarm, alarm acknowledgement, `SYSTEM OK`,
  or controller-health claims;
- any suggestion that Tropical or Coldwater operates physical equipment.

The dormant `HeaterStatusPill`, archive no-op heater control, fabricated
fallback temperature, and default-on heater state are negative evidence only.
They must not be revived. `Equipment` remains navigation to registered
equipment; `Alerts` remains navigation to Tank Detail.

## Responsive, Accessibility, Motion, And Theme Contract

- Preserve the scroll and bottom-dock clearance at a 390 by 844 phone viewport.
- At 2.0x text, reflow instrument groups without clipping, hidden copy, or
  unreachable actions; use a single-column control bank when necessary.
- Keep each real action at least 48 by 48 dp with visible text, distinct
  semantics, semantic order, and tooltip where appropriate.
- Engraved microcopy cannot be the only accessible label. The primary readout
  must announce that it is the latest manually logged temperature and expose no
  tap action.
- Preserve light and dark brightness plus every current room theme with
  readable contrast while keeping the same instrument identity.
- Under `MediaQuery.disableAnimations`, needle, lamp, press, and save-state
  transitions settle immediately; no lamp may pulse.
- Continue using only the persisted preference-aware haptic adapter. Decorative
  hardware and readouts emit no haptic feedback.
- Preserve loading, missing-reading, target-unavailable, provider-error,
  zero-history, one-reading, save failure/revert, cross-tank isolation, and
  route-close honesty.

## Later Test-First Implementation Order

No product implementation belongs to `WF-2026-07-31-028`. A later separately
executed Phase 3R product epoch must:

1. Write chassis, dominant-gauge, manual-readout, and honest empty/error REDs
   before replacing the flat surface.
2. Write target-assembly and data-driven lamp REDs while retaining every
   preset persistence, save failure, and Custom-state test.
3. Write the tactile action-bank and Temperature-specific visual acceptance
   REDs while retaining the route, order, secondary Settings, 48 dp, 2.0x,
   theme, reduced-motion, and haptic contracts.
4. Implement the smallest current-source widget changes without copying archive
   bytes, adding assets or packages, or changing Water Quality.
5. Run the affected Focused and Visual profiles, add one current Temperature
   visual baseline grounded in this addendum, obtain an independent settled-
   diff review, and run one final Full gate on the settled product tree.

Phase 4 remains unstarted and blocked from selection until Phase 3R reaches its
own clean, verified checkpoint. Never create an automatic successor task.

## This Docs-Only Checkpoint

This authority epoch may change only this addendum, the parent ordered plan,
`ACTIVE_HANDOFF.md`, `SLICE_LOG.md`, and the rolling overflow archive for the
required verbatim row rollover. It authorizes one Docs profile, explicit diff
checks, a docs-only commit, and one non-force push after fresh remote
comparison.

It authorizes no product source, product test, asset, dependency, build, Full
or Visual gate, device, emulator, archive restoration, Water Quality,
cloud/account, or successor-task work. Stop after the clean pushed docs
checkpoint; do not begin Phase 3R implementation in the same task.
