# Danio Complete Local Current Audit

Status: Active current-state audit
Created: 2026-06-13
Scope: Android local completion workstream

## 1. Verification Baseline

Environment:

- Flutter 3.44.0 stable, Dart 3.12.0.
- Branch: `qa/production-tool-audit-2026-05-25`.
- Android emulator configured: `danio_api36`.
- Physical Android device visible as `RFCY8022D5R`, but currently unauthorized
  over ADB in this Windows-reset environment.

Passing checks in this pass:

- `flutter test`: pass, 1450 tests.
- `flutter analyze`: pass, no issues.
- `flutter test test/copy/current_docs_local_truth_test.dart`: pass.
- `flutter test test/scripts/android_main_activity_test.dart`: pass.
- `flutter test test/services/shop_service_test.dart
  test/widget_tests/gem_shop_screen_test.dart
  test/widget_tests/inventory_screen_test.dart
  test/widget_tests/account_screen_test.dart
  test/scripts/android_main_activity_test.dart`: pass.
- `flutter build apk --debug --target lib/main.dart`: pass.

Build warning:

- Flutter reports that the app/plugins still apply the Kotlin Gradle Plugin in
  a way that future Flutter versions will reject. This does not block the
  current debug build, but it is a future toolchain maintenance item.

## 2. Android QA State

`danio_api36` booted successfully as `emulator-5554`, but the emulator dropped
off ADB during blackbox/focused verification attempts. The only remaining ADB
device was the unauthorized physical phone. This prevented a full fresh
screen-by-screen Android capture in this pass.

Observed emulator/ADB failures:

- Full blackbox smoke timed out after the emulator disappeared from ADB.
- Focused cold-start QA deep-link verification also timed out after the
  emulator disappeared from ADB.
- Latest failure artifacts show ADB transport loss, not an app crash:
  `error: device 'emulator-5554' not found`.

Action:

- Treat CL-QA-001 and CL-QA-002 as blocked on stable Android emulator/device
  transport for now.
- Continue product/code work using analyzer, tests, debug builds, code audits,
  and prior screenshot evidence until the emulator/device connection is stable.

## 3. Reliability Finding Fixed In This Pass

Older blackbox artifacts revealed an app-level error boundary during a QA
settings deep-link attempt:

- Failure: `Expected UI pattern not visible within 12 seconds: Preferences`.
- Screen: "Oops! Something went wrong".
- Logcat root cause: Flutter attempted to route `RouteSettings("/settings")`
  and failed because `MaterialApp` has no `/settings` named route.

Cause:

- Warm QA intents were already intercepted by `MainActivity.onNewIntent`, but
  cold-start QA links could still be interpreted by FlutterActivity's native
  deep-link route forwarding before the debug QA MethodChannel handled them.

Fix:

- `MainActivity` now treats debug `danio://qa...` intents as QA-only.
- `shouldHandleDeeplinking()` returns `false` for debug QA intents.
- `getInitialRoute()` returns `/` for debug QA intents.
- Warm intents still dispatch through `danio/qa_links`.
- Regression coverage added in `test/scripts/android_main_activity_test.dart`.

Verification:

- Focused script test passed.
- Analyzer passed.
- Debug APK build passed.
- Direct emulator confirmation is still pending because ADB transport dropped.

## 4. Feature Honesty Progress

CL-P0-003 has covered the local/offline, rewards, weekly-progress, returning
milestones, onboarding feature-summary, debug visibility, freshwater-scope, and
Smart optional-AI surfaces, plus the dormant backend-sync queue and social
reward scaffolds.

Fixed:

- Settings now labels the account/data entry as "Offline Data" with the
  subtitle "Local storage and backup guidance", instead of implying account
  status in the local-only build.
- `AccountScreen` code comments now describe the local-first behavior and the
  optional nature of cloud account management when cloud services are
  configured.
- Timed gem rewards now work as real active effects instead of disappearing
  immediately after use. XP Boost, Weekend Amulet, and Goal Shield stay visible
  to derived providers while active and expire cleanly.
- Goal Shield is now a real 24-hour goal relaxer that halves today's XP target,
  rather than claiming to complete the goal with no implementation.
- Legacy no-op Progress Protector is hidden from the available shop.
- Cosmetic shop items that do not yet affect the tank/profile are hidden unless
  they are honest permanent collectible badges visible in My Items.
- Shop catalog strings touched in this pass were changed to ASCII-safe copy so
  corrupted emoji literals do not leak into dialogs if a fallback surface ever
  renders them.
- More now describes Gem Shop as useful boosts and collectible badges, matching
  the currently available reward catalog.
- More's stale Friends/Leaderboard code comments were removed because those
  surfaces are not visible complete-local features.
- Normal Preferences no longer exposes a visible debug-only "Test Error
  Boundary" crash control. Debug tooling remains reachable through the hidden
  version-tap gate in debug builds.
- Smart now presents itself as local aquarium intelligence with optional AI
  tools, instead of implying the whole hub is unavailable without an OpenAI key.
- Locked AI-only Smart cards, the setup banner, the setup sheet, and Preferences
  now use "Optional AI" copy and clarify that local compatibility checks and
  Anomaly History work immediately.
- OpenAI setup failures now direct users to Preferences > Smart Hub > Optional
  AI without mentioning build-time developer flags.
- Smart feature card semantics were hardened so the optional-AI setup action is
  still exposed after the card animation settles.
- Shop Street now describes the working local planning tools: wishlists,
  budget, saved shops, useful gem boosts, and collectible badges. The visible
  "Gear upgrades planned" copy was removed.
- The in-app Privacy Policy now describes the current local build instead of
  dormant cloud-provider implementation details. It no longer tells normal
  users to delete a cloud account or synced cloud rows from Offline Data.
- The normal app shell no longer mounts the debug sync diagnostic indicator in
  debug APKs used for local testing.
- Create Tank and Tank Settings now present Danio as a freshwater-focused local
  product instead of offering disabled "Marine not available" setup choices.
  Tank Settings uses a read-only Freshwater field and always shows the supported
  tropical/coldwater water profile controls.
- Acclimation, equipment, substrate, mascot onboarding prompts, and optional AI
  system prompts now stay aligned to the freshwater local scope. A focused copy
  contract protects those scoped surfaces without removing legitimate brackish
  biology facts from species/lesson content.
- Optional AI setup/status and AI-service failures no longer expose
  developer-facing server/proxy/build-auth wording. Users now see plain
  Danio-managed AI, not-set-up, or this-version-of-Danio copy while local Smart
  Hub checks still work.
- The Delete My Data dialog now frames the contact email as privacy/data help
  instead of implying a server-side deletion process in the local build.
- Settings export/import feedback now uses plain sentence copy for empty export
  and invalid backup states instead of dash-separated app status messages.
- Bulk livestock add now writes plain log titles and success feedback without
  raw emoji or fragile multiplication-symbol output.
- Dead cloud-sync status scaffolding was removed from `AccountScreen` and the
  unused sync indicator/status/dialog/cloud-sync files, so stale sync-state
  wording cannot drift back into the local Offline Data surface.
- The dormant backend sync queue implementation was removed from the profile
  activity path. XP/streak activity now persists through the local profile save
  path directly, with a source guard preventing the fake queue scaffold from
  returning.
- Dormant social reward mechanics were removed from the achievement and gem
  systems. The hidden `social_butterfly` achievement, friend-count achievement
  stats, friend-added achievement hook, and referral gem reward constants are
  gone, with a source guard preventing the fake social mechanics from returning.
- Optional account/cloud backup copy now says cloud services are optional and
  not configured for local builds instead of promising background sync or
  sounding broken.
- Signed-in account management copy now frames sign-out and deletion around
  optional cloud backup/account data instead of "resume syncing" or "synced
  cloud data".
- Onboarding and the debug QA menu now label the no-paywall onboarding value
  screen as "Feature Summary" instead of stale "Paywall Stub" wording.
- The Feature Summary subtitle now uses calmer plain sentence copy for
  "Danio is free to use. No subscription needed." instead of a heavy
  paywall-style dash line.
- The 30-day returning-user milestone is now framed as a celebration-only card
  with an optional "explore" CTA hook, not a hidden upgrade/paywall promise.
- Legacy marine profile copy now says marine setup support is outside Danio's
  freshwater focus instead of advertising future availability.
- Local weekly progress now uses tier/momentum language, including "Weekly
  Climber", instead of implying a social leaderboard, competitive league, or
  promotion race.
- The age-blocked onboarding screen no longer tells users to set up an account
  in the local-first flow. It now points parent/guardian review without
  implying cloud account setup is required.
- The shared online-error state no longer says "Server Error" or "Our servers"
  in generic local-first surfaces. It now frames the problem as an unavailable
  online feature.
- Privacy Policy cloud/account copy now says "this version of Danio" instead
  of "local build", and the policy content uses plain ASCII separators for a
  cleaner in-app reading experience.
- Optional cloud account and account-deletion service failures now say the
  cloud feature is not set up and reassure users that local Danio data still
  works or stays on the device.
- README, Feature Registry, and Data Resilience docs now describe the current
  local-first build instead of treating Supabase backend setup, fake sync
  queues, or removed social/friends scaffolds as current architecture. A focused
  docs-honesty guard prevents those claims from drifting back.

CL-P0-003 closeout:

- Source-level honesty/copy audit is complete for the current tree. Remaining
  findings from future emulator/device walkthroughs should be filed under the
  relevant feature P0/P1 item instead of keeping CL-P0-003 open indefinitely.
- Badge collectibles remain honest as current local collectibles, but the
  deeper reward-loop quality question belongs to CL-P1-002.

CL-P0-004A first-run region/units progress:

- Profile region context now persists through `UserProfile` JSON and notifier
  create/update paths.
- Onboarding now asks a broad region/units question before experience level,
  keeps the flow skippable, and persists the existing unit preference.
- Preferences now exposes a Units picker so users can change units after
  onboarding.
- Quick start remains unguessed: it does not fabricate a region when the user
  skips personalisation.

CL-P0-004B quick-start/sample handoff progress:

- Quick start now creates the existing populated freshwater sample tank instead
  of an empty guessed 60L starter tank.
- Skipped onboarding still leaves inferred region and tank-status context unset.
- Quick start routes to the centre Tank tab and uses disclosure copy that makes
  the sample-data nature clear.

CL-P0-004C tank stage/goals progress:

- Onboarding now captures multiple user goals after tank stage instead of
  reducing every user to one inferred goal.
- The goals step marks one recommendation based on known tank stage/experience
  context and keeps the choice lightweight rather than a formal track.
- Profile create/update now persists selected goals, falling back only to the
  derived recommendation when no explicit goals were selected.

CL-P0-004D contextual missing-context progress:

- Preferences now lets skipped users add or change region and tank stage later.
- Smart now shows a setup-context nudge only when a loaded profile is missing
  region or tank stage, because those fields improve risks, reminders, and care
  plans.

CL-P0-005A Tank care priority progress:

- Tank Today Board now computes a care priority from water logs and tasks,
  surfaces the next-best action, and routes quick actions to existing log/task
  flows.

CL-P0-005B Tank quick-feed progress:

- Main Tank Feed quick action now saves a feeding log directly and gives
  safety-aware portion feedback, while the room food object still opens the
  deeper feeding guidance sheet.

CL-P0-005C Tank visible care actions progress:

- Tank Today Board now keeps Feed, Test, Change, and Tasks visible as a compact
  care-action rail instead of relying only on the floating action menu or
  illustration tap targets.
- The Today Board Feed action saves a feeding log directly with portion-safety
  feedback, while Test, Change, and Tasks route to the existing tank-context
  flows.

CL-P0-006A Tank emergency access progress:

- Tank top bar now exposes Emergency Guide directly beside core tank actions, so
  urgent help is reachable from the centre screen without going through
  Settings.

CL-P0-006B unsafe-water emergency routing progress:

- Unsafe ammonia/nitrite priority on the Tank Today Board now opens Emergency
  Guide, keeping emergency steps one tap away from the alert.

CL-P0-006C Smart emergency access progress:

- Smart Hub now has an always-available Emergency Guide action near the top of
  its local actions, so urgent help is reachable without optional AI setup.

CL-P0-006D Search emergency access progress:

- Global search now treats urgent terms such as ammonia, nitrite, gasping,
  heater, filter, injury, poisoning, and sick/disease queries as guide matches
  and opens Emergency Guide directly.

CL-P0-006E More emergency access progress:

- More now exposes Emergency Guide as a direct Care Safety tile near the top of
  the hub instead of requiring users to open Preferences first.

CL-P0-006F Lesson emergency access progress:

- Lesson screens now expose Emergency Guide from the app bar while users are
  reading lesson material, keeping urgent help available from Learn content.

CL-P0-006G Species emergency access progress:

- Species detail sheets now show a Species Safety callout with a direct
  Emergency Guide action for illness, injury, gasping, or unsafe-water issues.

CL-P0-006H Water-log emergency access progress:

- Unsafe water-test saves now keep users in flow with an Unsafe Water Logged
  action sheet and direct Emergency Guide route instead of only showing a
  generic saved message.
- Dismissing that sheet now leaves the already-saved log clean, so Back does
  not show a discard warning for a saved unsafe-water entry.

CL-P0-007A Local Aquarium Intelligence foundation progress:

- Smart now opens with an Aquarium Intelligence section that works without an
  AI key and summarizes local risks, care actions, compatibility signals,
  anomaly history, and visible reasons.
- The local rule engine evaluates unsafe ammonia/nitrite, stale water tests,
  overdue care tasks, sick/quarantine livestock, compatibility issues,
  active anomalies, and equipment maintenance from on-device tank data.
- Smart widget coverage now verifies the no-AI local intelligence section with
  an unsafe-water reason, while service coverage protects the rule outputs.

CL-P0-007B Aquarium Intelligence details progress:

- The compact Smart intelligence section now opens a full Aquarium Intelligence
  review screen with local summary counts, a Local Care Plan, item reasons,
  action routes, and a plain-language list of what Danio checked.
- The detail screen keeps urgent unsafe-water items actionable through the
  Emergency Guide while still explaining the local checks behind the result.

CL-P1-001A Living tank water-state progress:

- The central Tank aquarium now derives a visual water state from the latest
  water-test log and subtly tints the illustrated water for unsafe nitrogen,
  high nitrate/stale water, and temperature extremes.
- The water-state layer is non-interactive and has an accessibility label, so
  the visual cue remains tied to real care data without adding visible text or
  disrupting the current watercolor tank style.

CL-P1-001B Living tank water-change age progress:

- The same water-state visual layer now considers recent tank logs, so a water
  change older than 14 days makes the illustrated water look stale even when
  the latest test readings are otherwise safe.
- Unsafe nitrogen and temperature/high-nitrate readings stay higher priority
  than water-change age, so serious care states are not hidden by routine
  maintenance signals.

CL-P1-001C Living tank feeding feedback progress:

- Main Tank quick feeding and the Today Board Feed action now trigger a
  short, non-interactive food-particle pulse in the central aquarium after the
  feeding log is saved.
- The pulse is keyed per tank event, supports reduced-motion users with a
  static particle burst, and keeps the aquarium feedback visual rather than
  adding extra instructional text.

CL-P1-001D Living tank livestock cue progress:

- The central Tank aquarium now derives a livestock visual cue from current
  tank livestock, using local health flags and the existing compatibility
  service instead of a separate decorative-only model.
- Sick/quarantine livestock produces a health-review cue, and compatibility
  warnings such as risky tankmate combinations produce a compatibility-review
  cue. The cue is non-interactive, text-free, and labelled for accessibility.

CL-P1-001E Living tank aquascape cue progress:

- The central Tank aquarium now derives planted/decorated aquascape cues from
  existing tank equipment records. CO2 systems and planted-labelled equipment
  add extra plant accents, while hardscape/decor-labelled entries add soft
  stone/wood accents.
- This is intentionally an honest cue layer over current data, not a claim
  that Danio has a complete dedicated plant/decor inventory model yet.

CL-P1-001F Living tank progression cue progress:

- The central Tank aquarium now derives a progression visual cue from the
  existing species unlock state. Starter species stay visually normal, while
  lesson-earned species unlocks add subtle collectible sparkle/ripple accents.
- The cue uses the real `speciesUnlockProvider` and `defaultUnlockedSpecies`
  boundary, so it reflects earned lesson/species progression without inventing
  unavailable room, decoration, or tank-theme cosmetics.

CL-P1-002A Room vibe unlock progress:

- The room theme picker now treats premium room vibes as local progression
  unlocks. Starter/cozy vibes remain available, while premium vibes stay visible
  with plain unlock requirements until the user's real progress qualifies.
- Unlock rules are derived from existing local state: earned species, XP,
  streaks, completed lessons, perfect scores, and achievement IDs. Locked vibes
  cannot be applied from the picker, so cosmetics now feel earned without
  adding fake shop inventory or cloud/premium promises.

CL-P1-002B Achievement badge display polish:

- Achievement detail now uses controlled Material badge icons and plain category
  labels instead of rendering stored achievement emoji strings as visible text.
- Achievement category filters now show plain category labels with icon avatars,
  improving polish, accessibility, and rendering consistency while preserving
  the existing achievement metadata for compatibility.

CL-P1-002C Achievement cosmetic reward feedback:

- Room-vibe rewards that are already tied to achievement IDs now surface in
  achievement celebrations, so users see when a streak, lesson, XP, perfect
  score, plant, or species milestone unlocks a room vibe.
- Single-achievement and batch achievement dialogs both summarize earned room
  vibes using the existing theme names and a controlled palette icon, without
  adding fake inventory, currency, or cloud/premium promises.

CL-P1-002D Achievement tank cosmetic cue:

- The central aquarium now derives a small achievement cosmetic overlay from
  the real local profile achievement IDs. One or more earned achievements show
  a subtle badge shelf; five or more show a stronger trophy shelf cue.
- The cue is text-free, non-interactive, and labelled for accessibility, making
  achievements affect the emotional Tank surface without inventing a full
  decoration inventory yet.

CL-P1-003A Missing species request path:

- Fish Database empty search now offers a Request Species action instead of a
  dead end when the local species database has no match.
- The request dialog keeps the local build honest: it shows the searched name,
  tells users what details to email, provides the contact address, and clarifies
  that Danio does not send anything automatically.

CL-P1-003B Species care actions:

- Fish species detail sheets now include a Care Actions card derived from
  existing species data: minimum tank size, group size, temperature/pH range,
  compatibility checks, and treatment-warning review when relevant.
- This makes species pages more actionable without adding unverified new
  species facts or pretending add-to-tank/reminder persistence exists yet.

CL-P1-003C Species stocking handoff:

- Fish species detail sheets now include a Plan stocking fit action that opens
  the Stocking Calculator with that species prefilled.
- The calculator seeds the selected species at its minimum group size so
  schooling fish start from a realistic planning count instead of a single fish.

CL-P1-003D Species wishlist save:

- Fish species detail sheets now let users save the species to the existing
  local fish wishlist.
- The saved item keeps the common name, scientific name, realistic starting
  quantity, and a short planning note without pretending the fish has been
  added to an active tank.

CL-P1-003E Plant care actions and wishlist save:

- Plant detail sheets now include data-derived Care Actions for placement,
  light level, CO2 setup, and propagation.
- Plant detail sheets can save plants into the existing local plant wishlist
  with common/scientific name and a short setup note.

Current Android device state:

- ADB previously saw `RFCY8022D5R` as `unauthorized`.
- A usable emulator is attached as `emulator-5554`, but it is currently
  foregrounding `com.misescope.app`, so Danio blackbox screen QA remains
  deferred to avoid interfering with another active Codex session.

## 5. Current Complete-Local Gap Map

P0 status:

| ID | State | Notes |
| --- | --- | --- |
| CL-P0-001 | Done | Returning users now land on Tank by default. |
| CL-P0-002 | Done | Canonical docs now point at complete-local as the active finish line. |
| CL-P0-003 | Done | Local/offline account copy, optional account/cloud backup copy, optional cloud account failure copy, signed-in account cloud-data copy, weekly-progress tier copy, returning-user milestone upgrade wording, age-blocked account-setup wording, generic server-error wording, onboarding feature-summary paywall-stub/subscription wording, settings data feedback copy, bulk livestock feedback copy, reward/shop honesty, Shop Street planning copy, Privacy local-build/local-version copy, Delete My Data privacy/help copy, stale social comments, visible debug crash controls, debug sync shell diagnostics, dead sync-status scaffolds, dormant backend-sync queue code, dormant social reward/referral mechanics, unsupported marine setup choices/scope copy, legacy marine profile copy, Optional AI server-config/setup/version copy, Smart optional-AI copy, and current README/registry/data-resilience docs honesty fixed and tested. Future walkthrough findings should be filed against their feature area. |
| CL-P0-004 | In progress | CL-P0-004A completed region/units capture, profile persistence, and Preferences unit reset. CL-P0-004B completed quick-start sample handoff. CL-P0-004C completed explicit multi-goal capture after tank stage. CL-P0-004D completed setup-context Preferences repair and Smart nudge. Remaining first-run work: final Android phone/tablet screen QA. |
| CL-P0-005 | In progress | CL-P0-005A adds care priority and next-best action from water logs/tasks. CL-P0-005B makes the main Tank Feed action a direct log with safety feedback. CL-P0-005C adds a visible Today Board care rail for Feed, Test, Change, and Tasks. Remaining: final Android phone/tablet visual QA. |
| CL-P0-006 | Done | Emergency Guide is now directly reachable from Tank top bar, unsafe-water Tank alerts, Smart Hub, global search, More, LessonScreen, species detail sheets, and unsafe water-test save flows. |
| CL-P0-007 | Done | Smart now works as a no-AI Aquarium Intelligence hub: local rules surface risks, suggestions, compatibility signals, care-plan actions, anomaly history, equipment maintenance, and checked reasons, with a full review screen and action routes. Richer per-tank/save-apply depth belongs to P1 guided workflows. |

High-confidence P1/P2 gaps from code/docs evidence:

- AI is still OpenAI-first rather than provider-aware.
- Living Tank visuals now react to latest water-test state, old water-change
  logs, feeding events, livestock health/compatibility cues, aquascape equipment
  cues, and earned species progression, but do not yet include a dedicated
  plant/decor inventory model.
- Species and plant data are broad but not yet final content-rich guide pages
  with sources, tank actions, and missing-species request flow.
- Tablet verification is not yet current.
- Visual asset quality still has known older audit gaps.
- Full local screen audit is blocked until Android target is stable.
- Richer per-tank intelligence drill-downs and save/apply flows remain useful
  future depth, but the P0 no-AI Smart hub acceptance is now covered.

## 6. Next Execution Step

Continue CL-P0-004 first-run flow work when Android transport is usable:

- Run final first-run screen QA once Android transport is usable.
- Add focused tests before each onboarding behavior change.
