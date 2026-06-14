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

- `flutter test`: pass, 1617 tests.
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
  species facts or pretending reminder persistence exists yet.

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

CL-P1-003F Species Watch For guidance:

- Fish species detail sheets now include a Watch For card derived from existing
  species fields: minimum group size, avoid-list tankmates, adult size,
  minimum tank size, care level, and treatment warnings when present.
- The guidance improves common-problem awareness without adding unsourced new
  species facts.

CL-P1-003G Plant Watch For guidance:

- Plant detail sheets now include Watch For guidance derived from existing
  propagation, care-tip, growth-rate, height, CO2, and difficulty fields.
- This gives plant pages practical common-problem cues while staying within
  the local database facts already present.

CL-P1-003H Species add-to-tank handoff:

- Fish species detail sheets now include an Add to tank action that reuses the
  existing tank picker and `LivestockAddDialog` flow.
- The handoff prefills common/scientific names and uses the species minimum
  school size for schooling fish, while keeping actual livestock persistence,
  logs, XP, validation, and provider invalidation inside the existing dialog.

CL-P1-003I Species care task creation:

- Fish species detail sheets now include a Create care task action that saves
  or updates a weekly tank task through the existing task storage path.
- The saved task records minimum group, minimum tank, temperature, pH, and
  tankmate/treatment cautions when present, so species guidance can surface in
  Tank, Today, and Tasks without adding a separate reminder silo.

CL-P1-003J Care source trails:

- Fish species and plant detail sheets now show a subtle Source trail card with
  broad references behind Danio's care guidance.
- Fish sources include FishBase, Merck Veterinary Manual, and RSPCA fish
  welfare advice. Plant sources include Tropica's plant database and INJAF's
  planted aquarium beginner guide.
- The card opens sources externally and avoids claiming every local field has
  been individually source-audited.

CL-P1-003K Care profile cards:

- Fish species detail sheets now include a Care Profile card with tank fit,
  group plan, water window, and feeding style derived from local species data.
- Plant detail sheets now include a Planting Profile card with layout role,
  growth pace, light/CO2 needs, and propagation derived from local plant data.
- This completes the current local species/plant guide pass: detail pages now
  have profiles, actions, watch-outs, wishlist saves, tank/task handoffs, missing
  species request guidance, and source trails.

CL-P1-004A Structured lesson guides:

- Lessons can now carry structured guide metadata: learning outcomes, a
  real-tank scenario, care drill steps, and source references.
- Lesson pages render that guide before the main lesson body, keeping practical
  context, drills, and subtle references close to the learning flow without
  replacing the existing bite-sized sections and quizzes.
- All six Nitrogen Cycle lessons now include guide metadata using broad
  references from INJAF, Merck Veterinary Manual, and RSPCA aquarium water
  quality guidance.
- A data contract verifies every Nitrogen Cycle lesson has at least two
  outcomes, a scenario, at least two drill steps, and a source reference.

CL-P1-004B Water Parameters guide coverage:

- Shared lesson source references now live in `lib/data/lesson_sources.dart`,
  so learning paths can reuse the same cited source data instead of duplicating
  private constants.
- Water Parameters now has structured guide metadata across all six lessons:
  pH, temperature, GH/KH, chlorine/chloramine, TDS, and seasonal water
  challenges.
- A focused data contract verifies every Water Parameters lesson has at least
  two outcomes, a real-tank scenario, at least two care drill steps, and an
  HTTPS source reference.

CL-P1-004C First Fish guide coverage:

- First Fish now has structured guide metadata across all six beginner
  decision lessons: choosing hardy species, acclimation, feeding, behaviour,
  quarantine, and common mistakes.
- Shared lesson references now include Merck Veterinary Manual fish home/routine
  care pages and RSPCA fish diet/tropical care pages for acclimation,
  quarantine, feeding, and beginner decision guidance.
- A focused data contract verifies every First Fish lesson has at least two
  outcomes, a real-tank scenario, at least two care drill steps, and an HTTPS
  source reference.

CL-P1-004D Maintenance guide coverage:

- Maintenance now has structured guide metadata across all six care-habit
  lessons: water changes, filter care, gravel vacuuming, algae control, safe
  cleaning, and routine planning.
- The guide content turns each maintenance topic into an outcome, realistic
  tank scenario, and care drill, using the existing shared INJAF, Merck, and
  RSPCA source references.
- A focused data contract verifies every Maintenance lesson has at least two
  outcomes, a real-tank scenario, at least two care drill steps, and an HTTPS
  source reference.

CL-P1-004E Planted Tanks guide coverage:

- Planted Tanks now has structured guide metadata across all five lessons:
  live-plant benefits, light and nutrients, substrate choice, CO2 decisions,
  and propagation.
- Shared lesson references now include Tropica plant/care pages and INJAF's
  aquarium plant beginner guide, alongside existing RSPCA/Merck water-quality
  references where the lesson touches fish safety or water chemistry.
- A focused data contract verifies every Planted Tanks lesson has at least two
  outcomes, a real-tank scenario, at least two care drill steps, and an HTTPS
  source reference.

CL-P1-004F Equipment guide coverage:

- Equipment now has structured guide metadata across all 11 merged lessons:
  filters, heaters, lighting, test kits, first setup, filter maintenance,
  water-change equipment, aeration, CO2 systems, aquascaping tools, and
  substrate.
- The guide content turns equipment choices into practical outcomes,
  realistic setup/maintenance scenarios, and care drills using the existing
  shared INJAF, Merck, RSPCA, and Tropica source references.
- A focused data contract verifies every merged Equipment lesson has at least
  two outcomes, a real-tank scenario, at least two care drill steps, and an
  HTTPS source reference.

CL-P1-004G Fish Health guide coverage:

- Fish Health now has structured guide metadata across all seven lessons:
  prevention, ich, fin rot, fungal infections, parasites, safe medication
  dosing, and hospital tank setup.
- Shared lesson references now include official Merck Veterinary Manual fish
  disease and aquarium-fish management pages, RSPCA fish health guidance, and
  CDC fish health/safe-handling guidance for hospital and isolation context.
- A focused data contract verifies every Fish Health lesson has at least two
  outcomes, a real-tank scenario, at least two care drill steps, and an HTTPS
  source reference.

CL-P1-004H Species Care guide coverage:

- Species Care now has structured guide metadata across all 13 merged lessons:
  bettas, goldfish, tetras, cichlids, shrimp, snails, Corydoras, livebearers,
  rasboras, angelfish, plecos, gouramis, and loaches.
- Shared lesson references now include FishBase and RSPCA freshwater fish
  welfare guidance, alongside existing Merck/RSPCA health, environment,
  water-quality, and diet references where relevant.
- A focused data contract verifies every merged Species Care lesson has at
  least two outcomes, a real-tank scenario, at least two care drill steps, and
  an HTTPS source reference.

CL-P1-004I Advanced Topics guide coverage:

- Advanced Topics now has structured guide metadata across all six lessons:
  livebearer breeding, egg-layer breeding, aquascaping fundamentals, biotope
  aquariums, emergency troubleshooting, and advanced water chemistry.
- Shared lesson references now include Merck breeding/reproduction guidance,
  INJAF livebearer guidance, FishBase reproduction-table context, and GOV.UK
  rehome-not-release guidance, alongside existing plant, water-quality, and
  fish-health references where relevant.
- A focused data contract verifies every Advanced Topics lesson has at least
  two outcomes, a real-tank scenario, at least two care drill steps, and an
  HTTPS source reference.

CL-P1-004J Aquascaping guide coverage:

- Aquascaping now has structured guide metadata across all four lessons:
  layout styles, plant zones, fertilisation, and algae management.
- The guide content turns aquascape design into practical setup and maintenance
  choices using the existing shared Tropica, INJAF, RSPCA, and Merck plant and
  water-quality references.
- A focused data contract verifies every Aquascaping lesson has at least two
  outcomes, a real-tank scenario, at least two care drill steps, and an HTTPS
  source reference.

CL-P1-004K Breeding Basics guide coverage:

- Breeding Basics now has structured guide metadata across all six lessons:
  breeding tank setup, fry raising, egg-layer techniques, livebearer breeding,
  fry grow-out health, and responsible rehoming.
- The guide content connects breeding ambition to welfare, water stability,
  first-food readiness, fry capacity, and rehome-not-release responsibility
  using the shared Merck, FishBase, INJAF, RSPCA, and GOV.UK source trail.
- A focused data contract verifies every Breeding Basics lesson has at least
  two outcomes, a real-tank scenario, at least two care drill steps, and an
  HTTPS source reference.

CL-P1-004L Troubleshooting guide coverage:

- Troubleshooting now has structured guide metadata across all six emergency
  lessons: fish distress, disease diagnosis, cloudy water, power outage
  recovery, temperature crash, and pH crash.
- The guide content keeps emergency advice practical and safety-focused:
  test first, protect oxygen and temperature, isolate when appropriate, and
  avoid reactive treatments that can destabilise the tank further.
- A focused data contract verifies every Troubleshooting lesson has at least
  two outcomes, a real-tank scenario, at least two care drill steps, and an
  HTTPS source reference.
- Every current learning path now has structured guide metadata coverage.

CL-P1-005A Practice Skill Drills:

- Practice Hub now includes five workflow-based Skill Drills when a review deck
  exists: Parameter Reading, Diagnosis Practice, Compatibility Checks, Setup
  Planning, and Emergency Decisions.
- Drill readiness is derived from existing review cards and their lesson paths,
  so users see unlocked care-skill practice based on what they have actually
  learned.
- Unlocked drills start filtered practice sessions through the existing review
  screen, prioritising related due cards before other related cards.
- Focused coverage verifies the drill catalog, path-based unlocking, filtered
  card selection, locked copy, and Practice Hub rendering.

CL-P1-005B Parameter Reading drill questions:

- The Parameter Reading drill now resolves related cards into scenario-style
  multiple-choice questions instead of only reusing generic lesson recall.
- Covered scenarios include pH swings, low tropical temperature, untreated tap
  water, ammonia/nitrite spikes, nitrate/maintenance drift, and a general
  water-test interpretation fallback.
- Other drill types still use the normal question resolver until their
  scenario formats are implemented.
- Focused coverage verifies pH scenario generation, cycling-spike immediate
  action guidance, and non-parameter fallback behaviour.

CL-P1-005C Diagnosis Practice drill questions:

- Diagnosis Practice now resolves related health/troubleshooting cards into
  symptom-triage scenarios instead of only generic lesson recall.
- Covered scenarios include ich-style white spots/flashing, fin damage after
  stress or nitrate drift, fungal-looking injury patches, parasite-like weight
  loss/flashing/stringy waste, quarantine/prevention, and general uncertain
  symptom triage.
- The question copy emphasises water tests, recent history, observation,
  isolation when appropriate, and avoiding random medication mixes.
- Focused coverage verifies ich diagnosis, troubleshooting diagnosis triage,
  and the general diagnosis fallback.

CL-P1-005D Compatibility Checks drill questions:

- Compatibility Checks now resolves related species/first-fish cards into
  stocking decision scenarios instead of generic recall.
- Covered scenarios include betta tank-mate temperament and fin-nipping risk,
  goldfish/tropical mismatch, schooling/social group-size checks, territorial
  species planning, and a general community compatibility checklist.
- The question copy focuses on adult size, group size, temperament, water
  needs, diet, swimming space, and backup plans.
- Focused coverage verifies betta, goldfish, and general compatibility
  scenarios.

CL-P1-005E Emergency Decisions drill questions:

- Emergency Decisions now resolves related emergency/troubleshooting cards into
  urgent prioritisation scenarios instead of generic recall.
- Covered scenarios include fish gasping or unsafe water, power outage,
  temperature crash, pH crash, and general uncertain emergency triage.
- The question copy prioritises oxygen, temperature, conditioned water changes,
  water tests, toxin removal, retesting, and avoiding random medication before
  basic life-support checks.
- Focused coverage verifies immediate unsafe-water triage, power outage
  oxygen/temperature handling, and the general emergency fallback.

CL-P1-005F Setup Planning drill questions:

- Setup Planning now resolves related equipment/planted cards into scenario
  questions instead of generic recall.
- Covered scenarios include filter flow and bioload planning, lighting and
  photoperiod planning, first-tank equipment/checklist planning, and general
  setup planning before livestock is bought.
- The question copy reinforces adult size, water needs, equipment, layout,
  cycling, stocking pace, and maintainable care routines.
- Focused coverage verifies filter planning, planted lighting, first-tank
  checklist, and general setup fallback scenarios.

CL-P1-005G Practice tank-context recommendations:

- Skill Drill summaries now accept local tank context from water-test logs,
  care tasks, livestock health state, and equipment records.
- The Practice Hub reads the first visible tank and quietly reorders/enriches
  drill cards with context hints when a relevant local condition exists.
- Covered signals include unsafe ammonia/nitrite prioritising Emergency
  Decisions, missing or stale water tests prioritising Parameter Reading,
  health alerts prioritising Diagnosis Practice, missing equipment/overdue care
  prioritising Setup Planning, and stocked tanks nudging Compatibility Checks.
- Focused coverage verifies service ordering/hints and visible Practice Hub
  context copy for an unsafe-water tank.

CL-P1-006A Water Change guided workflow:

- The Water Change Calculator can now launch with tank context from Workshop,
  including the selected tank ID and tank volume.
- Workshop opens Water Change as a standalone calculator when there are no
  tanks, automatically passes context when there is one tank, and asks the user
  to choose a tank when multiple tanks exist.
- Valid water-change results now include a guided next-step card explaining why
  saving the result matters, with a `Log this water change` action.
- The guided action opens `AddLogScreen` as a water-change log with the
  calculated percentage prefilled while still reusing the existing log-save path
  and validation.
- Focused coverage verifies AddLog suggested-percent persistence, calculator
  handoff into AddLog, Workshop tank-volume prefill, safe-area coverage, and
  Workshop tool text encoding.

CL-P1-006B Tank Volume guided workflow:

- The Tank Volume Calculator can now launch with tank context from Workshop and
  apply a calculated litre value back to the selected local tank profile.
- Workshop opens Tank Volume as a standalone calculator when there are no tanks,
  automatically passes context when there is one tank, and asks the user to
  choose a tank when multiple tanks exist.
- Valid tank-volume results now include a guided next-step card explaining why
  applying the result matters, with an `Apply to tank profile` action.
- The guided action reuses `tankActionsProvider.updateTank(...)`, invalidates
  existing tank providers, and shows local success/error feedback.
- Focused coverage verifies direct calculator persistence and Workshop handoff
  into the contextual calculator.

CL-P1-006C Dosing guided workflow:

- The Dosing Calculator can now launch with tank context from Workshop,
  including the selected tank ID and tank volume.
- Valid liquid-product dose results now include a guided next-step card with a
  `Log this dosing note` action.
- The guided action opens `AddLogScreen` as an observation with a prefilled dose
  summary covering total dose, tank volume, dose rate, and a product-label
  reminder.
- `AddLogScreen` now supports `initialNotes` for observation-style handoffs
  while still using the existing validation and log-save path.
- Focused coverage verifies AddLog initial-note persistence, direct Dosing
  handoff into AddLog, and Workshop Dosing tank-volume prefill.

CL-P1-006D CO2 guided workflow:

- The CO2 Calculator can now launch with tank context from Workshop.
- Valid CO2 estimates now include a guided next-step card with a
  `Log this CO2 note` action.
- The guided action opens `AddLogScreen` as an observation with a prefilled note
  covering calculated CO2 ppm, status, pH, KH, and an estimate caveat.
- The touched CO2 calculator and tests were cleaned of mojibake/non-ASCII
  artifacts in comments, hints, and bullet markers.
- Focused coverage verifies direct CO2 handoff into AddLog and Workshop CO2
  context routing.

CL-P1-006E Lighting guided workflow:

- The Lighting Schedule tool can now launch with tank context from Workshop.
- Tank-context Lighting schedules now include a guided next-step card with a
  `Log this lighting schedule` action.
- The guided action opens `AddLogScreen` as an observation with a prefilled note
  covering lights-on/off times, total hours, siesta state, planted/CO2/algae
  setup context, and the current recommendation.
- The touched Lighting screen and test were cleaned of mojibake/non-ASCII
  artifacts in headings and CO2 timing bullets.
- Focused coverage verifies direct Lighting handoff into AddLog and Workshop
  Lighting context routing.

CL-P1-006F Stocking guided workflow:

- The Stocking Calculator can now launch with tank context and tank-volume
  prefill from Workshop.
- Stocking checks with selected fish now include a guided next-step action:
  `Log stocking check`.
- The guided action opens `AddLogScreen` as an observation with a prefilled note
  covering tank volume, filter rating, plant state, stocking percentage/level,
  species counts, and a planning-estimate caveat.
- The touched Stocking screen and test were cleaned of mojibake/non-ASCII
  artifacts in headings, filter label, and stock math copy.
- Focused coverage verifies direct Stocking handoff into AddLog and Workshop
  Stocking context routing.

CL-P1-006G Compatibility guided workflow:

- The Compatibility Checker can now launch with selected tank context from
  Workshop.
- Tank-context checks now use the selected tank as the size reference instead
  of silently falling back to the largest owned tank.
- Two-or-more-species checks now include a guided next-step card with
  `Log compatibility check`.
- The guided action opens `AddLogScreen` as an observation with a prefilled note
  covering selected species, verdict, issue details, recommended tank/
  temperature/pH context, selected tank reference, and an educational caveat.
- The touched Compatibility screen and test were cleaned of mojibake/non-ASCII
  artifacts in headings and temperature copy.
- Focused coverage verifies direct Compatibility handoff into AddLog and
  Workshop Compatibility context routing.

CL-P1-006H Unit Converter label polish:

- The Unit Converter now uses plain `C`, `F`, `K`, `ppm CaCO3`, and
  `mg/L CaCO3` labels instead of degree/subscript glyphs that were rendering as
  mojibake on this Windows setup.
- Focused coverage verifies readable temperature labels, C-to-F output, and
  hardness labels.
- The touched Unit Converter screen and test were cleaned of mojibake/non-ASCII
  source text.

CL-P1-006I Cycling Assistant guided actions:

- Cycling Assistant now shows a visible `Guided next step` card near the top of
  the tank-scoped cycle view.
- `Log water test` opens `AddLogScreen` directly as a water-test log for the
  current tank.
- `Create cycling reminder` saves a phase-aware local task through the existing
  task storage path. Phase 2 creates a high-priority custom 2-day `Test ammonia
  and nitrite` reminder; other cycle phases use matching 3-day, 2-day, or
  weekly guidance.
- Focused coverage verifies the AddLog handoff and task creation persistence.

CL-P1-006J Cost Tracker currency/settings polish:

- Cost Tracker settings now keep a saved or locale-derived active currency in
  the dropdown even when it is not one of the built-in symbol shortcuts.
- Built-in currency symbols now use source-safe string escapes, and expense
  subtitles use an ASCII separator.
- Focused coverage verifies opening settings with a custom saved `CHF`
  currency does not trigger a dropdown assertion and keeps `CHF` selectable.

CL-P1-007A Multi-tank priority strip:

- Compare Tanks now evaluates all tanks for the priority insight, not only the
  selected two-tank detail pair.
- When three or more tanks exist, a visible `All tanks at a glance` card shows
  the highest-priority tank and compact reasons for the top tanks.
- The detailed Water, Care rhythm, Livestock, Equipment, and Activity sections
  still compare the selected pair, preserving the existing focused comparison
  workflow.
- Focused coverage verifies an urgent unselected third tank remains visible as
  `Highest priority: Tank C`.

CL-P1-008A Unified Tank Journal timeline:

- Tank Journal now renders all local log types from `allLogsProvider`, not only
  `LogType.observation` notes.
- Journal timeline cards now show type-aware icons, titles, date/time metadata,
  water-test readings, water-change summaries, task-completion titles, notes,
  and photo counts.
- Adding a new Journal entry still saves an observation through the existing
  local storage path and now invalidates both recent and all-log providers.
- Focused coverage verifies water-test and completed-care-task events appear in
  the Journal and suppress the empty state.

CL-P1-007B / CL-P1-008B All-tanks activity timeline:

- Compare Tanks now collects the already-loaded local logs for every tank and
  sorts them into a recent all-tanks activity card.
- The card shows the latest five events with tank name, log title, type/date
  metadata, and either notes, a water/maintenance summary, or a plain fallback.
- Journal and Compare Tanks now share `LogEntryDisplay` for log icons, titles,
  summaries, and fallback wording.
- Focused coverage verifies recent activity across three tanks, including an
  unselected tank, appears in the comparison flow.

CL-P1-008C Saved tool-result timeline labels:

- Tank Journal now recognises observation notes saved by guided tools and
  labels them as `Tool Result` timeline entries instead of generic
  observations.
- Existing saved notes with known guided-tool prefixes such as
  `Dosing calculation:`, `CO2 estimate:`, `Lighting schedule`,
  `Compatibility check`, and `Stocking estimate` get specific journal titles.
- The change is display-only and keeps the existing local `LogEntry` schema, so
  previously saved local tool notes improve without a migration.
- Focused coverage verifies a saved dosing-calculator note appears as
  `Dosing Calculator Result` with `Tool Result` metadata.

CL-P1-008D Saved milestone timeline labels:

- Tank Journal now recognises saved observation notes that begin with
  `Milestone:` and labels them as `Milestone` timeline entries instead of
  generic observations.
- Milestone cards show the clean milestone text without repeating the raw
  prefix, while keeping the existing local `LogEntry` schema.
- Focused coverage verifies a saved milestone note appears with `Milestone`
  metadata and no empty-state fallback.

CL-P1-008E Saved AI-note timeline labels:

- Tank Journal now recognises saved accepted AI notes such as Symptom Triage
  journal saves and labels them as `AI Note` timeline entries instead of
  generic observations.
- Saved AI notes get a specific title such as `Symptom Triage AI Note`, and the
  visible summary drops the raw saved-note prefix so the card reads like a
  timeline event.
- Focused coverage verifies a saved Symptom Triage journal result appears with
  `AI Note` metadata and the saved guidance body.

CL-P1-009A Backup import safety copy:

- Backup & Restore now explains import behavior in normal-user terms:
  backed-up tanks are added as new tanks, existing tanks/logs stay on-device,
  and app-wide profile, learning progress, gems, and preferences are replaced
  from the backup.
- The backup screen source no longer contains corrupted bullet/check/em-dash
  glyphs in touched copy paths.
- Focused coverage verifies the visible import-safety copy and guards the
  backup screen source against non-ASCII/mojibake artifacts.

CL-P1-009B Backup data validation:

- Backup preview/import now uses the same required-data validation as restore
  before resolving portable photo references.
- `BackupService.getBackupData` now rejects backup JSON that does not contain a
  `tanks` array instead of returning malformed data to the import UI.
- Focused coverage verifies malformed backup ZIP data fails with
  `Invalid format: missing tanks array`.

CL-P1-009C Backup tank-entry validation:

- Backup preview/import now rejects tank arrays containing non-object entries
  or tank objects without a non-empty string `id`.
- The validation lives in `BackupService._readValidatedBackupData`, so
  `getBackupData` and `restoreBackup` share the same guard before UI preview or
  photo restore proceeds.
- Focused coverage verifies `Invalid format: tank entries must be objects` and
  `Invalid format: tank entries must include an id`.

CL-P1-009D Backup duplicate tank-ID validation:

- Backup preview/import now rejects duplicate tank IDs before preview, photo
  resolution, or restore proceeds.
- The guard lives in the shared backup-data reader, so duplicate IDs cannot
  create ambiguous tank relationships during either preview or import.
- Focused coverage verifies duplicate `tank-1` entries fail with
  `Invalid format: duplicate tank id`.

CL-P1-009E Backup child tank-relationship validation:

- Backup preview/import now rejects logs, livestock, equipment, and tasks whose
  `tankId` does not match any tank in the backup before preview, photo
  resolution, or restore proceeds.
- The guard lives in the shared backup-data reader, so users do not confirm an
  import that will silently drop orphaned child records during tank-ID remap.
- Focused coverage verifies each tank-scoped child collection fails with
  `Invalid format: <collection> entries reference unknown tank id`.

CL-P1-009F Backup child collection shape validation:

- Backup preview/import now rejects `logs`, `livestock`, `equipment`, and
  `tasks` when those fields are present but are not arrays.
- The guard lives in the shared backup-data reader, so malformed child
  collections fail before the user confirms an import or the import screen casts
  those fields.
- Focused coverage verifies each tank-scoped child collection fails with
  `Invalid format: <collection> must be an array`.

CL-P1-009G Backup child record ID validation:

- Backup preview/import now rejects `logs`, `livestock`, `equipment`, and
  `tasks` entries that do not include a non-empty `id`.
- The same shared validator also rejects duplicate child record IDs within each
  tank-scoped collection, preventing import remapping from silently skipping or
  overwriting child records.
- Focused coverage verifies missing child IDs and duplicate child IDs fail with
  `Invalid format: <collection> entries must include an id` or
  `Invalid format: duplicate <collection> id`.

CL-P1-009H Backup child required-field validation:

- Backup preview/import now rejects child records that have valid IDs but are
  missing fields required by the import parser: log `timestamp`, livestock
  `commonName` and `dateAdded`, equipment `name`, and task `title`.
- The guard lives in the shared backup-data reader, so users do not confirm an
  import whose child records will fail later during local model parsing.
- Focused coverage verifies each required field fails with
  `Invalid format: <collection> entries must include <field>`.

CL-P1-009I Optional cloud-restore orphan child-record guard:

- Optional cloud-backup restore now tracks locally known tank IDs plus any tanks
  accepted from the incoming backup before importing child records.
- Livestock, equipment, logs, and tank-scoped tasks are skipped when their
  `tankId` is not present locally or in the backup, preventing hidden orphan
  data from being saved into local storage.
- Focused coverage verifies orphan child records are not saved and their missing
  tank ID is not reported as changed.

CL-P1-009J Backup nested log-shape validation:

- Backup preview/import now rejects log records whose nested `waterTest` value
  is not an object.
- Backup preview/import also rejects log `photoUrls` values that are not arrays
  of strings, so malformed photo lists do not pass preview and fail later during
  import parsing.
- Focused coverage verifies both malformed nested log shapes fail before the
  backup data is returned to the import flow.

CL-P1-009K Backup water-test numeric validation:

- Backup preview/import now checks known nested water-test fields and rejects
  any present values that are not numeric.
- This prevents a backup with values like `"ammonia": "high"` from passing
  preview and later failing during local log parsing.
- Focused coverage verifies non-numeric nested water-test readings fail with a
  normal validation message before the backup data is returned.

CL-P1-009L Backup required-date validation:

- Backup preview/import now rejects required log `timestamp` and livestock
  `dateAdded` values that are present but cannot be parsed as dates.
- This prevents malformed date strings from passing backup preview and later
  being skipped or failing during local model parsing.
- Focused coverage verifies invalid required date strings fail before the backup
  data is returned.

CL-P1-009M Backup optional-date validation:

- Backup preview/import now rejects invalid optional equipment date fields:
  `lastServiced`, `installedDate`, and `purchaseDate`.
- Backup preview/import also rejects invalid optional task date fields:
  `dueDate` and `lastCompletedAt`.
- This prevents optional date metadata from passing preview and then causing
  partial equipment/task imports during local parsing.

CL-P1-009N Backup numeric child-field validation:

- Backup preview/import now rejects non-numeric values in numeric child fields
  that are parsed during import.
- Covered fields include log `waterChangePercent`, livestock `count`,
  equipment `maintenanceIntervalDays`, and task `intervalDays`, with the shared
  guard also covering related numeric size/lifespan/completion fields.
- This prevents malformed child records from passing preview and then being
  skipped during local import parsing.

CL-P1-009O Backup photo archive filename validation:

- Backup preview/import now rejects ZIP photo entries that would restore to the
  same local filename after Danio applies its import prefix.
- Photo entry basename handling now normalizes slash and backslash separators,
  so Windows-style photo archive entries keep the same restore behavior as
  standard `photos/...` entries.
- This prevents malformed external backups from making multiple photo
  references point at the same restored file or silently skipping one image.

CL-P1-009P Backup integer child-field validation:

- Backup preview/import now rejects decimal values for child fields parsed as
  integers during restore.
- Covered fields include log `waterChangePercent`, livestock `count`,
  equipment `maintenanceIntervalDays`/`expectedLifespanMonths`, and task
  `intervalDays`/`completionCount`.
- This prevents backups from passing preview with numeric values that later
  fail model parsing because the app expects whole numbers.

CL-P1-009Q Backup tank field validation:

- Backup preview/import now rejects malformed tank root fields before import
  parsing: non-string text fields, non-numeric volume/dimension fields,
  decimal/non-integer `sortOrder`, non-boolean `isDemoTank`, and invalid tank
  date strings.
- Tank `targets` must now be an object when present, and known target range
  fields such as `tempMin`, `phMax`, `ghMin`, and `khMax` must be numbers.
- This prevents malformed tank records from passing preview and then failing
  restore parsing or silently defaulting important tank setup values.

CL-P1-009R Backup enum validation:

- Backup preview/import now rejects invalid enum values before restore parsing
  can silently default them.
- Covered fields include tank `type`, log `type`, livestock `temperament` and
  `healthStatus`, equipment `type`, and task `recurrence`/`priority`.
- This keeps imported records honest instead of quietly changing unknown
  backup values into default care, task, equipment, or tank categories.

CL-P1-009S Backup child metadata-date validation:

- Backup preview/import now rejects child records missing date metadata required
  by restore model parsing.
- Covered fields include log `createdAt`, livestock `createdAt`/`updatedAt`,
  equipment `createdAt`/`updatedAt`, and task `createdAt`/`updatedAt`.
- These metadata fields are also validated as dates before import.

CL-P1-009T Backup referenced-photo validation:

- Backup preview/import now rejects JSON photo references when the matching
  bundled photo file is missing from the archive.
- This covers tank `imageUrl` refs and log `photoUrls` refs, preventing import
  from writing records that point at local photo files that were never restored.
- The shared photo-ref scanner now also finds strings inside lists, so list-based
  photo references are handled consistently.

CL-P1-009U Backup optional child-string validation:

- Backup preview/import now rejects malformed optional string fields on child
  records before the user confirms an import.
- Covered families include log titles/notes/relationship IDs, livestock
  scientific/source/notes/image fields, equipment brand/model/notes, and task
  descriptions/equipment links.
- This keeps import conversion from silently skipping otherwise valid records
  because an optional field used the wrong JSON type.

CL-P1-009V Backup optional task-boolean validation:

- Backup preview/import now rejects malformed optional task boolean fields
  before the user confirms an import.
- Covered fields are task `isEnabled` and `isAutoGenerated`, matching the
  restore conversion paths that require JSON booleans when those fields exist.
- This prevents otherwise valid imported task records from being skipped after
  preview because an optional toggle had the wrong JSON type.

CL-P1-009W Backup equipment settings validation:

- Backup preview/import now rejects malformed equipment `settings` values before
  the user confirms an import.
- `settings` remains optional, but when present it must be a JSON object, matching
  the restore conversion path that casts settings into a string-keyed map.
- This prevents otherwise valid equipment records from being skipped after
  preview because optional type-specific settings used the wrong JSON shape.

CL-P1-010A Tank Settings water-profile copy:

- Tank Settings now shows readable tropical/coldwater target labels:
  `24-28 C - most community fish` and `15-22 C - goldfish etc.`.
- The touched Tank Settings source no longer contains degree/bullet glyphs that
  were rendering as mojibake on this Windows setup.
- Focused coverage verifies the visible labels and guards the screen source
  against non-ASCII artifacts.

CL-P1-010B Preferences setup editing:

- Preferences now lets users edit experience level and goals alongside existing
  units, region, and tank stage controls, so skipped or changed onboarding
  context can be repaired locally.
- Experience level uses a single-choice sheet with the existing beginner,
  intermediate, and expert labels. Goals use a local multi-select sheet ordered
  like onboarding and save through `userProfileProvider.updateProfile`.
- Focused widget coverage verifies the visible profile summaries and both
  picker update paths.

CL-P1-010C Preferences haptic-feedback control:

- The visible Haptic Feedback preference now controls shared snackbar feedback
  haptics from `AppFeedback.showSuccess`, `showError`, and `showWarning`.
- `AppFeedback` reads `settingsProvider` from the active `ProviderScope` and
  falls back to enabled only when feedback is shown outside app/provider scope.
- Focused coverage verifies success feedback stays silent when haptics are
  disabled and still fires the expected success pattern when enabled.

CL-P1-010D Reduce Motion MediaQuery bridge:

- `DanioApp` now wraps the existing app shell in `ReducedMotionMediaQuery`, so
  the in-app Reduce Motion override also reaches widgets that read
  `MediaQuery.disableAnimations`.
- The bridge preserves system reduced-motion state and only forces
  `disableAnimations` on when either the system or Danio preference asks for
  reduced motion.
- Focused coverage verifies a saved `reduced_motion_override` makes descendant
  `MediaQuery.disableAnimations` true.

CL-P1-010E Reminder intensity presets:

- Notification Settings now has a guided Reminder Intensity control with
  Quiet, Review only, Daily habit, and Full support presets.
- Presets map to the existing local review-reminder and streak-reminder flags
  instead of introducing fake notification behavior.
- Selecting Quiet cancels review/streak scheduling paths and updates both
  visible reminder toggles to off.
- Focused widget coverage verifies the Full support state, opens the preset
  sheet, selects Quiet, and observes both reminder toggles off.

CL-P1-010F Preferences Privacy Policy route:

- Preferences now exposes a direct Privacy Policy entry in the About & Privacy
  section instead of requiring users to discover it through About or search.
- The route opens the existing local Privacy Policy screen covering local data,
  crash reports, optional AI services, cloud-sync/account status, deletion, and
  contact details.
- Focused widget coverage verifies the Privacy Policy entry is reachable from
  Preferences and opens the local policy screen.

CL-P1-010G Optional AI disclosure reset:

- Optional AI data-disclosure acceptance now uses a shared local preference
  helper instead of duplicated feature-screen key handling.
- Preferences > Smart Hub > Optional AI now shows whether the disclosure has
  already been accepted and lets users reset it, so Danio will show the
  disclosure again before Optional AI sends photos, text, or tank context.
- Focused widget coverage verifies the reset action removes the saved local
  disclosure flag from SharedPreferences.

### CL-P1-011A Global Destination And Log Search

- Global search now indexes app destinations, calculators, guides, learning
  paths, settings/privacy/backup destinations, species database results,
  livestock/equipment matches, and local tank log history.
- Search results are grouped into App, Tools, Learning, Guides, Tanks, Logs,
  Livestock, Equipment, and Species Database sections so it stays a contextual
  finder rather than becoming another bottom navigation surface.
- App/tool results route to the existing destination screens, using the first
  local tank for tools that benefit from tank context and falling back to the
  relevant hub when no tank exists.
- Log results search tank name, log type, display title, summary, fallback copy,
  title, and notes, then route back to the owning tank detail screen.
- Focused coverage verifies Backup & Restore, Unit Converter, Nitrogen Cycle
  learning, and local log-note search results.

### CL-P1-012A Resettable Sample Tank

- Settings now presents the sample-tank action as `Reset Sample Tank` and tells
  users it replaces demo data without touching real tanks.
- `TankActions.addDemoTank()` now removes only existing `isDemoTank` records
  before creating a fresh populated sample tank, so onboarding, empty-state, and
  Settings flows cannot pile up duplicate demo tanks.
- Focused provider coverage verifies existing demo tanks are replaced while a
  real user tank remains in storage.

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
- Species and plant detail pages now have the first complete local guide pass:
  profiles, actions, watch-outs, wishlist saves, tank/task handoffs, missing
  species request guidance, and source trails. Future species work is content
  database depth and visual asset quality, not missing core page actions.
- Learning depth is now started with structured guide metadata plus Nitrogen
  Cycle, Water Parameters, First Fish, Maintenance, Planted Tanks, Equipment,
  Fish Health, Species Care, Advanced Topics, Aquascaping, and Breeding Basics
  path enrichment, plus Troubleshooting emergency enrichment. Every current
  learning path now has structured guide coverage.
  Remaining learning work is expanding visual depth and richer learning
  interactions across the catalog.
- Practice depth now includes workflow-based Skill Drills mapped to existing
  lesson paths, filtered review sessions, scenario-style Parameter Reading,
  Diagnosis Practice, Compatibility Checks, Setup Planning, and Emergency
  Decisions questions, plus tank-context recommendation hints in Practice Hub.
  Richer persisted tool-result context belongs with CL-P1-006 guided tools.
- Multi-tank comparison now has a first all-tanks priority overview and recent
  all-tanks activity card. Remaining multi-tank work is switching polish and
  Android phone/tablet QA.
- Tank Journal now has a first unified local timeline pass for current log
  types, saved guided-tool notes now appear as Tool Result entries, and Compare
  Tanks now surfaces recent history across tanks. Saved `Milestone:` journal
  notes now appear as Milestone entries, and saved accepted AI notes now appear
  as AI Note entries. Remaining timeline work is any richer
  tool-result/AI-note/milestone detail cards found in walkthroughs.
- Backup & Restore now has clearer import safety copy and validates required
  backup JSON, malformed tank entries, duplicate tank IDs, and orphaned
  tank-scoped child records, plus non-array tank-scoped child collections,
  missing child record IDs, and duplicate child record IDs before
  preview/import. It also rejects child records missing import-required fields
  before preview/import, rejects malformed nested log water-test/photo data,
  rejects non-numeric nested water-test readings, rejects invalid required log
  and livestock dates, rejects invalid optional equipment/task dates, rejects
  non-numeric child fields, rejects duplicate restored photo archive filenames,
  rejects decimal values for integer-only child fields, and optional cloud
  restore now skips child records whose tanks are not present locally or in the
  backup. Tank records now also validate text, numeric, integer, boolean, date,
  and water-target field shapes before preview/import. Backup enum fields now
  reject unknown values instead of silently defaulting during import. Child
  records now reject missing import-required metadata dates before preview.
  Backup JSON photo references now reject missing bundled archive files before
  preview/import. Optional child string fields now reject malformed values before
  preview/import. Optional task boolean fields now reject malformed values before
  preview/import. Equipment settings now reject non-object values before
  preview/import. Remaining backup/data work is deeper import validation UX, edit/delete/undo coverage, and
  restore/migration walkthrough QA.
- Profile/preferences now centralises units, region, tank stage, experience
  level, and goals. Tank Settings water-profile labels are readable and
  source-safe. The Haptic Feedback preference now controls shared snackbar
  haptics, the Reduce Motion preference now reaches descendant MediaQuery
  animation checks, Notification Settings now has guided reminder intensity
  presets, Preferences links directly to the Privacy Policy, and Optional AI
  disclosure acceptance can be reset from Preferences. Remaining
  profile/preferences work is any final AI/provider and privacy walkthrough
  gaps.
- Global search now has first complete-local coverage for app destinations,
  tools, learning paths, guides, settings/privacy/backup, species, equipment,
  livestock, and local logs. Remaining search work is Android phone/tablet
  walkthrough QA and any future direct-per-lesson deep links.
- Demo mode now has a resettable populated sample tank that replaces existing
  demo data without deleting real tanks. Remaining demo work is final screen QA.
- Tablet verification is not yet current.
- Visual asset quality still has known older audit gaps.
- Full local screen audit is blocked until Android target is stable.
- Richer per-tank intelligence drill-downs and save/apply flows remain useful
  future depth, but the P0 no-AI Smart hub acceptance is now covered.

## 6. Next Execution Step

Continue CL-P1-007/CL-P1-008 remaining local depth while Android transport is
reserved by other sessions:

- Expand accepted AI-note/milestone timeline handoffs, polish multi-tank
  switching, continue CL-P1-009 data-safety hardening, continue CL-P1-010
  preference centralisation, and keep CL-P1-011 direct-per-lesson search/deep
  links as optional polish if walkthroughs show users need it.
- Keep Android phone/tablet visual QA deferred until emulator/device ownership
  is confirmed.
