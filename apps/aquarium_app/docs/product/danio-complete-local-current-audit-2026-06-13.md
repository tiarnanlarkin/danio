# Danio Complete Local Current Audit

Status: Active current-state audit
Created: 2026-06-13
Scope: Android local completion workstream

Maintenance note 2026-07-04:

- The source-of-truth branch was consolidated to `main` after the
  `qa/production-tool-audit-2026-05-25` branch was fast-forwarded in.
- The verification baseline below is retained as dated audit history. Use
  `docs/agent/FINISH_MAP.md` and `docs/agent/ACTIVE_HANDOFF.md` for the current
  branch and next-action state.

## 1. Verification Baseline

Environment from the original 2026-06-13 audit pass:

- Flutter 3.44.0 stable, Dart 3.12.0.
- Original branch: `qa/production-tool-audit-2026-05-25`; current
  source-of-truth branch after housekeeping is `main`.
- Android emulator configured: `danio_api36`.
- Physical Android authorization changes over time. Check
  `docs/agent/DEVICE_OWNERSHIP.md` and current `adb devices` output before any
  device work.

Passing checks in this pass:

- `flutter test`: pass, 1747 tests.
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
- Signed-in Account cloud backup copy no longer calls the current backup lane
  "encrypted" in user-facing text; the service docs now name the account-keyed
  encryption boundary and state that it is not user-held or end-to-end backup
  encryption.
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
- Privacy Policy Optional AI copy now describes the current request scope
  across Fish ID photos, symptom descriptions, stocking or compatibility
  requests, and weekly-plan tank context instead of saying Optional AI is
  Fish ID/photo-only.
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

CL-P1-001G Tank Detail feeding pulse handoff:

- Tank Detail QuickAdd feeding now increments the same per-tank feeding pulse
  event used by the main Tank feed action and Today Board Feed action.
- This keeps successful feeding logs visually connected to the central aquarium
  feedback system instead of making Tank Detail feeding feel detached.
- Focused Tank Detail widget coverage verifies the real QuickAdd FAB feeding
  action saves a feeding log and emits `tankFeedingPulseProvider`.

CL-P1-001H Livestock feeding pulse handoff:

- The Livestock screen Feed action now increments the same per-tank feeding
  pulse event after a successful local feeding log save.
- This keeps feeding from the livestock management area connected to the living
  aquarium feedback system instead of only updating journal data.
- Focused Livestock widget coverage verifies the real Feed action saves a
  feeding log and emits `tankFeedingPulseProvider`.

CL-P1-001I Add Log feeding pulse handoff:

- Add Log now increments the same per-tank feeding pulse event when a saved log
  is a feeding entry.
- This keeps direct feeding journal entries connected to the central aquarium
  feedback system, matching the main Tank, Today Board, Tank Detail, and
  Livestock Feed entry points.
- Focused Add Log widget coverage verifies saving a feeding entry emits
  `tankFeedingPulseProvider`.

CL-P1-001J Add Log feeding edit guard:

- Add Log only emits the feeding pulse for newly-created feeding entries, not
  edits to existing feeding logs.
- This avoids replaying a "fed now" aquarium animation when a user is only
  correcting or reviewing a historical feeding record.
- Focused Add Log widget coverage verifies editing an existing feeding log does
  not increment `tankFeedingPulseProvider`.

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

CL-P1-002E Inventory room-vibe collectibles:

- My Items > Permanent now shows earned room vibes from the same local unlock
  rules as the theme picker, including visible locked requirement copy.
- Unlocked room vibes can be applied directly from Inventory through the
  existing local room-theme preference/provider, without adding fake premium,
  social, or cloud inventory.
- Focused widget coverage verifies the room-vibe collection appears without
  shop purchases and applying an unlocked vibe updates `roomThemeProvider`.

CL-P1-002F Earned tank-decoration inventory:

- My Items > Permanent now includes a Tank decorations section with locally
  earned freshwater-appropriate decorations: river stones, driftwood arch,
  mossy hide, and ceramic shelter.
- Decoration unlocks are derived from local progress and persisted earned
  decoration state. Equipped decoration state is saved locally before the
  visible tank cosmetic changes.
- The central aquarium renders the equipped decoration as a text-free
  `CustomPaint` cue with accessibility semantics, using the same overlay
  pattern as aquascape, progress, and achievement cosmetics.
- Backup export/restore now includes earned and equipped decoration preference
  keys so cosmetic progress survives local data transfer.
- Focused service, provider, backup, widget, and Inventory tests cover unlock
  rules, save-before-state equip behavior, backup inclusion, aquarium overlay
  rendering, and Inventory equip feedback.

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

CL-P1-004M Emergency lesson safety boundary:

- Emergency learning content now keeps Danio positioned as educational guidance
  and tells users to escalate severe, persistent, multi-fish,
  medication-uncertain, injury, or poisoning cases to an aquatic vet or
  experienced aquatic professional.
- The boundary copy is present in cycle spike handling, the core emergency
  lesson, temperature crash guidance, and the advanced emergency guide.
- The content validation gate now detects emergency/distress lessons and
  requires both educational positioning and aquatic-vet/professional escalation
  language.

CL-P1-004N Emergency lesson unlock boundary:

- Emergency/distress learning lessons now stay directly accessible instead of
  requiring prior lesson completion.
- `Cycle Emergency: Handling Spikes`, `Emergency! Fish in Distress`, and
  `Temperature Crash: Heater Failure` no longer carry prerequisites.
- The content validation gate now fails if emergency/distress lessons are
  locked behind prerequisites.

CL-P1-004O Story play exit confirmation:

- Story Play now guards unfinished story progress with a `Leave story?`
  confirmation when users use back after making story choices.
- Cancel keeps the user in the current scene, while confirming returns to the
  story hub.
- Focused widget coverage verifies both the cancel and confirmed leave paths.

CL-P1-004P Locked story feedback:

- Locked Story Browser cards now remain tappable and show a Danio info snackbar
  explaining the level or prerequisite story requirement.
- Locked cards still do not navigate into Story Play until their unlock
  conditions are met.
- Focused widget coverage verifies the level-gated locked-story feedback path.

CL-P1-004Q Dedicated learning path detail:

- Lazy path cards now expose an `Open full path` action after content loads.
- Inline expansion is a short preview, while the full-screen detail view shows
  path overview, progress, and the complete lesson sequence.
- Widget coverage verifies the path loads, opens the full-screen view, and keeps
  the retryable load-error path intact.

CL-P1-004R Contextual quiz hints:

- Lesson quiz hints now use the current question explanation to show a
  care-specific clue instead of the old generic "Look for keywords" prompt.
- The hint builder scrubs the correct option text where possible so beginner
  hints guide recall without simply revealing the answer.
- Focused widget coverage verifies the contextual hint panel and screen-reader
  announcement, and QA debug coverage rejects the old generic copy.

CL-P1-004S Locked path prerequisite polish:

- Locked learning path cards now format raw ID-style prerequisite titles into
  readable names before showing unlock guidance.
- The locked `ListTile` now owns a transparent `Material`, avoiding hidden ink
  and debug assertions when rendered inside the decorated path card.
- Widget coverage verifies the friendly prerequisite copy and rejects raw
  underscore ID text in the locked-path subtitle.

CL-P1-004T Story Browser profile-error handling:

- Story Browser now reads profile state through `valueOrNull` and shows a
  non-blocking retry banner when profile loading fails.
- Starter stories remain visible instead of making the screen look silently
  locked by missing profile data.
- Focused widget coverage verifies the profile-error banner and retained story
  hub context.

CL-P1-004U Learn slow local-profile loading guard:

- Learn now detects an extended `userProfileProvider` loading state and swaps
  the skeleton for retryable local-first guidance instead of hanging
  indefinitely.
- The retry action resets the guard and invalidates the profile provider while
  preserving the normal loaded, null-profile, and error paths.
- The first-path auto-scroll retry is now tracked with a cancellable timer so
  disposal cannot leave delayed callbacks behind.
- Focused widget coverage verifies the stuck-loading guidance and existing
  Learn surface tests still pass.

CL-P1-004V Story Play malformed-scene fallback:

- Story Play now handles non-final scenes with no choices by showing a
  "Story step unavailable" fallback instead of leaving users with no action.
- The fallback returns users to the story hub without awarding XP or pretending
  the malformed story step was completed.
- Focused widget coverage verifies the fallback copy and Back to Stories exit
  path.

CL-P1-004W Learning path empty-lesson fallback:

- Expanded learning path cards now show a clear "No lessons in this path yet"
  empty state when a loaded path has no lesson records.
- The empty state avoids showing the full-path CTA for an empty path.
- Focused widget coverage verifies the empty path fallback alongside existing
  locked, loaded, and load-error path card behavior.

CL-P1-004X Story Browser empty-catalog fallback:

- Story Browser now accepts an optional story list for testability while using
  the real hardcoded story catalog in production.
- An empty story catalog now shows a clear "No stories available yet" empty
  state instead of rendering a blank story list.
- Focused widget coverage verifies the empty catalog fallback.

CL-P1-004Y Lesson image-section audit closeout:

- The stale LessonCard image-placeholder audit row is closed against current
  implementation evidence.
- Lesson image sections already render asset/network images in a stable frame
  with caption support and a "Visual unavailable" fallback.
- Existing focused widget and lesson-data checks verify asset rendering and
  reject stale "Visual guide on the way!" placeholder copy.

CL-QA-005A Learning unit spelling validation:

- The content validation gate now fails learning copy that uses US
  `liter`/`liters` volume spelling instead of the app's UK-style
  `litre`/`litres` copy convention.
- Existing learning drift was corrected in First Fish beginner-mistakes copy
  and the Maintenance siphoning lesson.

CL-QA-005B Learning metric-context validation:

- The content validation gate now fails learning copy that mentions gallons
  without a litre/litres equivalent in the same user-facing string.
- Current gallon-only examples were updated in First Fish, Fish Health, Species
  Care, and Advanced Topics so tank-size and treatment-dose copy is readable
  for metric-first users while preserving legacy gallon context.

CL-QA-005C Learning temperature-context validation:

- The content validation gate now fails learning copy that mentions Fahrenheit
  without a Celsius equivalent in the same user-facing string.
- Current Fahrenheit-only examples were updated in Advanced Topics, Species
  Care, and Troubleshooting so temperature guidance remains metric-readable
  while preserving Fahrenheit context where useful.

CL-QA-005D Medical/emergency warning validation:

- The content validation gate now fails medical/emergency learning lessons
  without a warning section.
- Fish Health prevention, ich, fin rot, and parasite lessons now carry explicit
  warning-section safety boundaries around diagnosis, treatment choice, and
  urgent escalation.

CL-QA-005E Unsafe/product-endorsement copy validation:

- The content validation gate now fails overconfident or product-endorsing
  learning copy such as "safe in overdose", "gold standard", "industry
  standard", "lasts forever", "can't overdose", "won't harm your fish", and
  "worth every penny".
- Nitrogen Cycle, Water Parameters, Maintenance, and Species Care copy now uses
  neutral, label-following guidance for test kits, water conditioner,
  emergency water changes, and algae-control snails.

CL-QA-005F Brand-specific emergency-product copy validation:

- The same content validation gate now fails stronger emergency/product
  certainty phrases such as "emergency best friend", "cheap insurance", "buy it
  now", "single most valuable", "will save fish lives", "widely considered the
  best", "best all-rounder", "non-toxic forms", and "temporarily makes it
  non-toxic".
- Nitrogen Cycle, Troubleshooting, Advanced Topics, Equipment, and Fish Health
  copy now describes emergency conditioners, kits, and parasite treatments with
  neutral label-following guidance instead of brand-as-saviour claims.

CL-QA-005G Brand-name conditioner/test-kit copy validation:

- The same content validation gate now fails remaining branded
  conditioner/test-kit learning copy such as `seachem prime`, `api master test
  kit`, `api freshwater master test kit`, `dose prime`, `prime detoxifies`,
  `prime converts`, `use prime`, and `with prime`.
- Water Parameters, Nitrogen Cycle, Troubleshooting, Advanced Topics, and
  Equipment copy now explains conditioners and liquid test kits as generic
  product categories with label-following instructions.

CL-QA-005H Learning graph/source/range validation:

- The content validation gate now requires unique learning path IDs, unique
  lesson IDs, unique path and per-path lesson order indexes, matching lesson
  `pathId` values, resolvable prerequisite path/lesson IDs, non-empty lesson
  sections, sane lesson XP/duration ranges, valid quiz `correctIndex` values,
  and at least two source references per lesson guide.
- This is a guardrail-only slice; the current catalog already satisfies the
  tightened checks, so no lesson product copy or behavior changed.

CL-QA-005I Learn/practice surface audit coverage:

- Learn widget coverage now verifies the old placeholder placement-test labels
  stay hidden while no real placement flow exists, so the wrong route to
  Spaced Repetition Practice is not reachable.
- Practice Hub and Spaced Repetition Practice widget coverage now verifies
  `spacedRepetitionProvider.errorMessage` is surfaced with retry affordances.
- The Learn/Practice surface audit was updated to close those stale Must Fix
  rows and keep remaining launch gaps focused on active product issues.

CL-QA-005J Learning path load-error audit truth:

- Existing `LazyLearningPathCard` widget coverage verifies failed path loads
  show a retryable error row instead of leaving users with a stuck loader.
- The Learn/Practice surface audit was updated to close the stale path-load
  error gap while keeping the larger dedicated path-detail redesign open.

CL-QA-005K Learn/practice dead-code audit truth:

- The Learn/Practice surface audit was updated to match current source truth:
  `LearnScreen` no longer watches `hasSeenTutorial`, `LessonScreen` no longer
  contains the old hearts-modal exit flags, and reduced-motion path cards now
  use the plain non-animated branch while normal motion keeps fade/slide.
- This was a documentation-truth cleanup only; no product behavior changed.

CL-QA-005L Learning coming-soon audit truth:

- The Learn/Practice surface audit was updated to match existing Learn source
  guard coverage: `comingSoonPathIds` and placeholder "Coming Soon" learning
  path copy are already absent from `learn_screen.dart`.
- This was a documentation-truth cleanup only; no product behavior changed.

CL-P1-005H Review fallback recall prompts:

- Fallback Review Session cards with no stored `questionText` now show a clear
  recall prompt for the concept instead of only displaying the concept title.
- The prompt tells unsure users to choose Forgot so the card returns sooner,
  keeping the old self-assessment flow honest for legacy/persisted cards.
- Widget coverage verifies the no-question-text review-card path.

CL-P1-005I Distinct Learn practice entry points:

- Learn Review Banner remains the direct due-review entry point.
- Learn Practice Card now opens the Practice hub tab for weak-spot options
  instead of pushing the same Spaced Repetition Practice screen.
- Widget coverage verifies the weak-practice card switches to the Practice hub.

CL-P1-005J Fallback review reveal flow:

- Fallback Review Session cards now show a recall prompt first and hide
  Forgot/Remembered until users tap `Reveal answer`.
- Revealed cards show the saved answer/content before self-rating, and the next
  card resets back to the unrevealed prompt state.
- Widget coverage verifies hidden self-rating buttons, reveal behavior, content
  visibility, and next-card reset.

CL-P1-005K Practice Hub explicit item list:

- Practice Hub populated content now builds an explicit widget list instead of
  relying on the old fixed `_getPracticeHubItemCount` / `return 23` pattern.
- This keeps section additions/removals from silently desynchronising the list
  count from the item builder.
- Focused Practice Hub coverage verifies the source guard and existing
  populated/empty/error states.

CL-P1-005L Practice Hub profile-error handling:

- Practice Hub now shows a non-blocking retry banner when `userProfileProvider`
  errors, while keeping Practice content usable.
- The header `HeartIndicator` now reads profile energy through `valueOrNull` so
  profile load errors do not crash screens that show energy.
- Focused widget coverage verifies the profile-error banner and retained empty
  deck context.

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

CL-P1-006K Unit Converter guided context:

- Unit Converter now shows a compact `Aquarium use` card on Volume,
  Temperature, Length, and Hardness tabs so the utility reads as an aquarium
  care tool rather than a generic converter.
- The guidance stays local-only and action-neutral: dosing/water changes,
  heater/acclimation checks, tank dimensions/equipment fit, and GH/KH/species
  parameter checks.
- Focused coverage verifies aquarium-use guidance appears on every converter
  tab while existing conversion calculations keep passing.

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

CL-P1-007C Compare Tanks swap action:

- Compare Tanks now turns the middle selector control into an accessible
  one-tap swap action so users can flip the left/right selected tanks without
  reopening dropdowns.
- Focused coverage verifies the `Swap compared tanks` action switches the two
  selected tank IDs in the comparison selectors.

CL-P1-007D Multi-tank Android walkthrough:

- Phone and tablet Android QA now covers the complete current multi-tank flow
  under `docs/qa/screenshots/2026-06-22/cl-p1-007-multi-tank/`.
- Evidence includes the three-tank `All tanks at a glance` priority overview,
  `Recent activity across tanks`, and the `Swap compared tanks` after-state on
  both `danio_api36` phone and `danio_tablet_api36` tablet emulators.
- Tablet setup used the debug-only `Seed Demo Tank` action to add `QA Test Tank`
  without clearing the existing `Neon Tetra Shoal` and `Sample Tank` data, so
  the walkthrough exercises at least three local tanks while preserving logs.

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

CL-P1-008F Livestock feeding timeline refresh:

- Livestock screen feeding now invalidates both recent and all-log providers
  after a successful local feeding log save.
- This keeps timeline-style surfaces that watch `allLogsProvider` fresh when a
  user logs feeding from the livestock management area.
- Focused Livestock widget coverage verifies the real Feed action refreshes
  all-log timeline data after saving the feeding log.

CL-P1-008G Saved special-entry detail strips:

- Tank Journal now gives saved tool results, tank milestones, and optional AI
  notes a small contextual detail strip inside the timeline card.
- The strips are display-only and keep the existing local `LogEntry` schema,
  while making saved special entries easier to understand in normal language.
- Focused coverage verifies the saved tool result, milestone, and optional AI
  detail strips render in the timeline.

CL-P1-008H Timeline Android walkthrough:

- Phone and tablet Android evidence is captured under
  `docs/qa/screenshots/2026-06-22/cl-p1-008-timeline-walkthrough/`.
- Phone Journal evidence verifies the unified timeline renders water-test and
  water-change entries, month grouping, metadata, summaries, and a saved
  `Milestone:` observation with the milestone label and contextual detail strip.
- Phone Compare Tanks evidence verifies recent all-tanks activity surfaces the
  milestone, feeding, water-test, and water-change entries, alongside the
  three-tank `All tanks at a glance` overview and accessible swap action.
- Tablet Journal evidence verifies the water-test and water-change timeline
  layout remains readable with no obvious overflow on the wide tablet surface.
- Real guided-tool and optional-AI note Android save handoffs were not exercised
  in this walkthrough; those special labels remain covered by focused widget
  tests unless a future device walkthrough targets the source flows directly.

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
- The lower direct `BackupImportService.importTankScopedData` boundary now also
  rejects duplicate `livestock`, `equipment`, `tasks`, and `logs` backup IDs
  before saving imported tanks, so service-level callers cannot collapse
  duplicate backup child records onto one regenerated local ID.
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

CL-P1-009X Backup child relationship-target validation:

- Backup preview/import now rejects child relationship IDs that point at missing
  records inside the same backup.
- Covered fields are log `relatedEquipmentId`, `relatedLivestockId`,
  `relatedTaskId`, and task `relatedEquipmentId`.
- This prevents confirmed imports from silently dropping relationships during
  ID remapping when the referenced child record was not part of the backup.

CL-P1-009Y Backup profile/preferences payload validation:

- Backup preview/import now rejects malformed `sharedPreferences` payloads before
  the user confirms an import.
- `sharedPreferences` remains optional for older backups, but when present it
  must be a JSON object with an `entries` object matching
  `SharedPreferencesBackup.restoreFromJson`.
- This prevents backups from promising profile/preference restore in the preview
  while the actual import would skip or warn after confirmation.

CL-P1-009Z Backup profile/preferences entry-value validation:

- Backup preview/import now rejects malformed values inside
  `sharedPreferences.entries`.
- Supported entry values are strings, numbers, booleans, and arrays containing
  only strings, matching the value types that `SharedPreferencesBackup` can
  restore safely.
- This prevents profile/preferences restore from silently dropping unsupported
  objects or coercing mixed arrays into string lists after the user confirms an
  import.

CL-P1-009AA Backup profile/preferences restore preflight:

- `SharedPreferencesBackup.restoreFromJson` now validates exportable entry
  values before it clears existing local exportable preferences.
- Unsupported objects and mixed string-list values throw `FormatException`
  without removing the user's current local preference value.
- This protects direct restore callers and keeps the lower-level restore helper
  aligned with Backup & Restore preview validation.

CL-P1-009AB Backup non-exportable preference validation:

- Backup preview/import now applies preference entry-value validation only to
  keys that `SharedPreferencesBackup` can actually restore.
- Unknown, internal, or secret-like preference keys remain ignored by restore,
  so malformed values on those keys no longer reject an otherwise restorable
  local backup.
- This keeps preview validation strict for restorable app state while avoiding
  false failures for data that Danio intentionally does not import.

CL-P1-009AC Optional-restore preference failure reporting:

- Optional cloud-backup restore now reports a malformed `sharedPreferences`
  payload as `preferencesRestoreFailed` instead of silently treating it as no
  preference data.
- The restore result still keeps tank and child-record merge behavior separate
  from preference restore status, so a partial restore can be explained honestly.
- This keeps optional restore reporting aligned with the local Backup & Restore
  validation path without adding any cloud setup or external dependency.

CL-P1-009AD Optional-restore malformed child-record guard:

- Optional cloud-backup restore now skips malformed tank, livestock, equipment,
  log, and task records instead of letting one bad record abort valid sibling
  imports.
- The optional restore importer still keeps local records winning on conflict
  and still skips child records whose tanks are not present locally or in the
  incoming backup.
- Focused coverage verifies malformed child entries do not stop valid remote
  livestock, equipment, logs, tasks, or their tank from restoring.

CL-P1-009AE Backup cross-tank relationship validation:

- Backup preview/import now rejects log and task relationship IDs when the
  referenced livestock, equipment, or task record belongs to a different backup
  tank.
- Missing relationship targets still produce the existing "must reference
  existing backup records" validation message; cross-tank targets now produce a
  separate same-tank validation message.
- Focused coverage verifies cross-tank `relatedEquipmentId`,
  `relatedLivestockId`, and `relatedTaskId` references fail before preview,
  photo restore, or import proceeds.

CL-P1-009AF Backup export missing-photo guard:

- Backup export now rejects tank/log photo references when the referenced local
  file is missing instead of creating a ZIP that later fails import validation.
- Failed export attempts now close the archive best-effort and delete the
  partial backup ZIP while preserving the existing temporary JSON cleanup.
- Focused coverage verifies missing tank `imageUrl` photo references fail
  during `createBackup`.

CL-P1-009AG Backup livestock count validation:

- Backup preview/import now rejects livestock records that are missing `count`
  instead of letting import silently default the livestock quantity to `1`.
- The existing numeric and whole-number validators still handle malformed or
  decimal livestock counts, so the new guard only covers absent count data.
- Focused coverage verifies missing livestock `count` fails before preview,
  photo restore, or import proceeds.

CL-P1-009AH Backup required enum-field validation:

- Backup preview/import now rejects logs missing `type`, equipment missing
  `type`, and tasks missing `recurrence` instead of letting import silently
  default those records to generic categories or one-time tasks.
- Existing known-value validators still handle malformed enum values when the
  fields are present.
- Focused coverage verifies these required enum-like fields fail before
  preview, photo restore, or import proceeds.

CL-P1-009AI Backup water-test range validation:

- Backup preview/import now rejects water-test values outside the ranges used
  by the app model instead of allowing import to clamp readings.
- Temperature must stay between 0 and 50, pH between 0 and 14, and ammonia,
  nitrite, nitrate, GH, KH, phosphate, and CO2 cannot be negative.
- Focused coverage verifies out-of-range temperature, pH, and ammonia fail
  before preview, photo restore, or import proceeds.

CL-P1-009AJ Backup child numeric range validation:

- Backup preview/import now rejects child numeric values outside the ranges
  used by local app flows instead of accepting misleading records.
- Water-change percentages must stay between 1 and 100, livestock counts must
  stay between 1 and 9999, and optional livestock size, equipment interval,
  equipment lifespan, and task counter fields cannot be negative.
- Focused coverage verifies out-of-range water-change percentages, livestock
  count/size, equipment maintenance interval, and task completion count fail
  before preview, photo restore, or import proceeds.

CL-P1-009AK Backup tank numeric range validation:

- Backup preview/import now rejects out-of-range tank numeric fields when they
  are present instead of accepting impossible tank setup values.
- Tank volume must stay between 1 and 10000 litres, tank dimensions cannot be
  negative, target temperature/GH/KH values cannot be negative, and target pH
  values must stay between 0 and 14.
- Focused coverage verifies malformed volume, dimension, temperature target,
  and pH target values fail before preview, photo restore, or import proceeds.

CL-P1-009AL Backup tank target ordering validation:

- Backup preview/import now rejects inverted tank water-target ranges instead
  of allowing import to create target profiles where minimum values are greater
  than maximum values.
- Covered target pairs are temperature, pH, GH, and KH, matching the
  `WaterTargets` model contract.
- Focused coverage verifies inverted temperature, pH, GH, and KH target ranges
  fail before preview, photo restore, or import proceeds.

CL-P1-009AM Backup record timestamp ordering validation:

- Backup preview/import now rejects tank, livestock, equipment, and task records
  where `updatedAt` is earlier than `createdAt`.
- This keeps imported local history and ordering metadata coherent instead of
  allowing impossible edit timelines into storage.
- Focused coverage verifies invalid timestamp ordering fails before preview,
  photo restore, or import proceeds.

CL-P1-009AN Backup custom task recurrence validation:

- Backup preview/import now rejects custom recurring tasks that do not include
  a positive `intervalDays` value.
- This prevents imported custom tasks from completing into no next due date, or
  repeatedly scheduling themselves for the same day.
- Focused coverage verifies missing and zero-day custom recurrence intervals
  fail before preview, photo restore, or import proceeds.

CL-P1-009AO Backup recurring task due-date validation:

- Backup preview/import now rejects recurring tasks that do not include a
  `dueDate` value.
- This keeps imported recurring care tasks visible in due/overdue task surfaces
  instead of letting them become unscheduled reminders.
- Focused coverage verifies daily and custom recurring tasks without due dates
  fail before preview, photo restore, or import proceeds.

CL-P1-009AP Backup log type payload validation:

- Backup preview/import now rejects water-test logs that do not include at
  least one actual water reading.
- Backup preview/import now rejects water-change logs that do not include a
  water-change percentage.
- This keeps imported journal/timeline records aligned with the app's own log
  creation rules instead of allowing empty type-specific care events.

CL-P1-009AQ Backup journal log content validation:

- Backup preview/import now rejects observation and medication logs that do not
  include either notes or photo evidence.
- The generic backup test fixture now uses a feeding log as the minimal valid
  log shape, matching the app's own add-log content rules.
- Focused coverage verifies empty observation and medication journal events fail
  before preview, photo restore, or import proceeds.

CL-P1-009AR Backup generated-log relationship validation:

- Backup preview/import now rejects task-completion logs without
  `relatedTaskId`.
- Backup preview/import now rejects equipment-maintenance logs without
  `relatedEquipmentId`.
- Backup preview/import now rejects livestock-added and livestock-removed logs
  without `relatedLivestockId`.
- This keeps generated timeline events connected to the task, equipment, or
  livestock record that explains them after import.

CL-P1-009AS Task delete undo resilience:

- Task deletion now tells users the removal can be undone within 5 seconds.
- Successful task deletion now shows a `Task deleted` snackbar with an `Undo`
  action that restores the deleted task and refreshes the task list.
- Focused widget coverage verifies the task disappears after deletion and
  returns when Undo is tapped.

CL-P1-009AT Equipment undo maintenance-task restore:

- Equipment removal already deleted the linked auto-maintenance task and offered
  Undo for the equipment record.
- Undo now restores the linked maintenance-task snapshot as well as the
  equipment record, preserving scheduled maintenance after accidental removal.
- Focused widget coverage verifies equipment and task removal, then confirms
  both records return when Undo is tapped.

CL-P1-009AU Wishlist delete undo:

- Wishlist item deletion now shows a 5-second snackbar with an `Undo` action.
- Undo restores the same local wishlist item, preserving the item id, category,
  quantity, notes, and planning details.
- Focused widget coverage verifies the wishlist item disappears after deletion
  and returns when Undo is tapped.

CL-P1-009AV Local shop delete undo:

- Local fish shop deletion now shows a 5-second snackbar with an `Undo` action.
- Undo restores the same saved shop, preserving the shop id, distance, notes,
  and planning details.
- Focused widget coverage verifies the shop disappears after deletion and
  returns when Undo is tapped.

CL-P1-009AW Cost Tracker clear-all undo:

- Cost Tracker's clear-all-expenses flow now explains that the action can be
  undone within 5 seconds instead of claiming it is unrecoverable.
- Clearing expenses shows a 5-second snackbar with an `Undo` action.
- Undo restores the same saved expense records, preserving ids, categories,
  dates, amounts, and currency-backed totals.
- Focused widget coverage verifies the expense list disappears after clearing,
  then returns when Undo is tapped, with persisted expense ids restored.

CL-P1-009AX Bulk tank delete undo:

- Bulk tank deletion from Home selection mode now uses the same 5-second
  soft-delete window as single-tank deletion instead of deleting storage
  immediately.
- The confirmation copy now tells users the action can be undone within 5
  seconds, and the snackbar offers `Undo All`.
- Undo restores every selected tank to the visible tank list before the
  permanent-delete timer expires.
- Focused provider coverage verifies bulk-deleted tanks disappear from
  `tanksProvider`, remain present in storage during the undo window, and return
  after undo.

CL-P1-009AY Log deletion failure feedback:

- Log Detail deletion now catches local storage failures instead of surfacing a
  raw widget exception.
- Failed deletion leaves the log detail visible and shows a normal Danio error
  snackbar: `Couldn't delete that log. Try again in a moment.`
- Focused widget coverage simulates a failed `deleteLog` call and verifies no
  tester exception is exposed, feedback appears, and the original log content
  remains visible.

CL-P1-009AZ Livestock removal count copy:

- Livestock removal confirmation text, removal journal titles, and removal
  snackbars now use ASCII-safe `x` count text instead of the multiplication
  glyph.
- This matches the existing bulk-add livestock copy standard and reduces the
  risk of fragile count symbols rendering poorly in local Windows/Android
  environments.
- Focused copy coverage now guards both bulk-add and main Livestock removal
  feedback against fragile count symbols.

CL-P1-009BA Livestock bulk-move count feedback:

- Livestock bulk move now captures the selected livestock IDs and count before
  clearing selection mode.
- The success snackbar reports the real moved count instead of reading the
  cleared selection set and showing `Moved 0 livestock ...`.
- Focused widget coverage selects two livestock, moves them to another local
  tank, and verifies the snackbar says `Moved 2 livestock to Bedroom Tank`.

CL-P1-009BB Bulk livestock removal timeline logs:

- Bulk livestock removal now writes the same local `livestockRemoved` timeline
  logs as single livestock removal after the 5-second undo window expires.
- The shared removal-log helper keeps single and bulk removal titles, related
  livestock IDs, log type, and timeline refresh behavior aligned.
- Focused widget coverage selects two livestock, confirms bulk removal, lets
  the undo window expire, and verifies two local removal logs are saved.

CL-P1-009BC Equipment removal rollback:

- Equipment removal now rolls back any equipment or linked maintenance-task
  deletion that already happened if a later delete step fails.
- Failed equipment removal refreshes equipment and task providers before showing
  normal error feedback, so the local screen and saved records stay consistent.
- Focused widget coverage simulates linked maintenance-task deletion failure and
  verifies the equipment record remains saved.

CL-P1-009BD Equipment removal without stale task delete:

- Equipment removal now only deletes a linked auto-maintenance task when that
  task actually exists in local storage.
- This keeps equipment removal successful for equipment with no maintenance
  schedule or stale/missing task record, instead of treating a missing related
  task as a failed equipment delete.
- Focused widget coverage uses stricter storage behavior to verify equipment
  without a maintenance task is removed cleanly and shows normal success
  feedback.

CL-P1-009BE Task completion feedback:

- Completing a task from the Tasks screen now shows the same clear success
  feedback already used when completing tasks from Tank Detail.
- This removes a silent local action after completion logs, XP, task refresh,
  and equipment refresh succeed.
- Focused widget coverage completes a saved task through the Tasks screen,
  verifies the saved completion count increments, and checks for
  `Rinse prefilter completed!` feedback.

CL-P1-009BF Task completion rollback:

- Tasks screen completion now rolls back the saved completed task if the
  required completion log write fails.
- Linked equipment maintenance updates and logs are also rolled back on the
  same failed completion transaction where they were already written.
- Focused widget coverage simulates a failed task-completion log write and
  verifies the saved task stays uncompleted with normal error feedback.

CL-P1-009BG Task snooze failure feedback:

- Task snooze now catches failed local task saves instead of surfacing a raw
  widget exception.
- Failed snooze refreshes the task provider and shows normal error feedback,
  leaving the original saved task unchanged.
- Focused widget coverage simulates a failed snooze save and verifies the
  stored due date is unchanged with `Couldn't snooze that task. Try again.`
  feedback.

CL-P1-009BH Task delete undo failure feedback:

- Task delete undo now catches failed local restore saves instead of surfacing
  a raw widget exception from the snackbar action.
- Failed undo refreshes the task provider and shows normal error feedback while
  leaving the task deleted if the restore write did not persist.
- Task row actions now use the stable Tasks screen context, so feedback can
  still appear after the deleted row is removed from the list.
- Focused widget coverage deletes a task, forces the Undo restore write to
  fail, and verifies local storage remains unchanged with
  `Couldn't restore that task. Try again.` feedback.

CL-P1-009BI Task snooze success feedback:

- Successful task snooze now shows normal success feedback after the local task
  save succeeds.
- The feedback names the task and the chosen snooze duration, keeping the
  previously silent local data change understandable.
- Focused widget coverage snoozes a saved task for 1 day, verifies the saved
  due date changes, and checks for `Rinse prefilter snoozed for 1 day.`
  feedback.

CL-P1-009BJ Task add success feedback:

- Adding a task from the Tasks screen now shows normal success feedback after
  the local task save succeeds.
- This keeps the add-task sheet from closing silently after a new local care
  task is created.
- Focused widget coverage adds `Rinse prefilter` through the visible add-task
  flow, verifies the task is saved, and checks for `Rinse prefilter added.`
  feedback.

CL-P1-009BK Equipment add success feedback:

- Adding equipment from the Equipment screen now shows normal success feedback
  after the local equipment save and maintenance-task sync succeed.
- This keeps the add-equipment sheet from closing silently after a new local
  equipment record is created.
- Focused widget coverage adds `Sponge filter` through the visible add-equipment
  flow, verifies the equipment is saved, and checks for `Sponge filter added.`
  feedback.

CL-P1-009BL Livestock add feedback and log copy:

- Adding a single livestock entry now shows normal success feedback after the
  local livestock save, added-log write, and XP activity write succeed.
- The livestock-added timeline title now uses ASCII-safe count copy:
  `Added 1x Amano Shrimp`.
- Focused widget coverage adds `Amano Shrimp` through the visible add-livestock
  flow, verifies the saved livestock record, verifies the readable timeline
  log title, and checks for `1x Amano Shrimp added.` feedback.

CL-P1-009BM Cost Tracker add feedback:

- Adding a Cost Tracker expense now waits for the local expense save before
  closing the sheet and showing normal success feedback.
- This keeps the expense-add flow from silently returning to the list after a
  local finance record is created.
- Focused widget coverage adds `Frozen food`, verifies the saved expense
  record, and checks for `Frozen food added.` feedback.

CL-P1-009BN Local shop add feedback:

- Adding a local fish shop from Shop Street now enables the save action as soon
  as the user enters a shop name.
- The sheet waits for the local shop save before closing, preserves existing
  shop creation dates on edits, and shows normal success/error feedback.
- Focused widget coverage adds `Coral Corner`, verifies the saved shop record,
  and checks for `Coral Corner added.` feedback.

CL-P1-009BO Shop budget save feedback:

- Saving the Shop Street monthly budget now waits for the local preference
  write before closing the dialog.
- Successful budget saves show normal success feedback, and failed saves keep
  the dialog open with normal error feedback.
- Focused widget coverage saves a `150` monthly budget, verifies the saved
  `shop_budget` value, and checks for `Monthly budget saved.` feedback.

CL-P1-009BP Wishlist add feedback:

- Adding a fish wishlist item now enables the save action as soon as the user
  enters a name.
- The sheet waits for the local wishlist save before closing, then shows
  item-named success feedback from a stable screen messenger.
- Failed saves keep the sheet open with normal error feedback.
- Focused widget coverage adds `Neon Tetra`, verifies the saved wishlist item,
  and checks for `Neon Tetra added.` feedback.

CL-P1-009BQ Wishlist purchase feedback resilience:

- Marking a wishlist item as purchased now waits for the local wishlist save
  before applying the matching budget spend and showing success feedback.
- Failed purchase saves keep the item unpurchased, avoid writing budget spend,
  and show normal error feedback instead of surfacing a widget exception.
- Focused widget coverage verifies both the successful purchased/budget write
  path and the failed purchase rollback/error path for `Neon Tetra`.

CL-P1-009BR Wishlist delete failure feedback:

- Wishlist item deletion now catches failed local remove saves and keeps the
  item visible with normal error feedback instead of surfacing a widget
  exception.
- Failed delete-undo restores now keep the item deleted and show normal error
  feedback from a stable screen context.
- Focused widget coverage verifies both the failed delete path and the failed
  undo-restore path for `Neon Tetra`.

CL-P1-009BS Local shop delete failure feedback:

- Local fish shop deletion now catches failed local remove saves and keeps the
  shop visible with normal error feedback instead of surfacing a widget
  exception.
- Failed delete-undo restores now keep the shop deleted and show normal error
  feedback from the Shop Street screen context.
- Focused widget coverage verifies both the failed delete path and the failed
  undo-restore path for `Aquatic World`.

CL-P1-009BT Equipment delete-undo failure feedback:

- Equipment delete undo now catches failed local equipment restore saves
  instead of surfacing a snackbar-action exception.
- Failed equipment restore keeps the equipment and linked maintenance task
  deleted and shows normal error feedback through a captured screen messenger.
- Focused widget coverage verifies the failed undo-restore path for a
  `Canister filter`.

CL-P1-009BU Equipment service failure rollback:

- Equipment "Mark Serviced" now catches failed maintenance-log saves instead
  of surfacing a widget exception.
- If the serviced timestamp was already saved before the log failure, the
  original equipment record is restored so the service state stays consistent.
- Focused widget coverage verifies failed service logging keeps a
  `Canister filter` unchanged and shows normal error feedback.

CL-P1-009BV Equipment service task-log rollback:

- Equipment "Mark Serviced" now restores the linked maintenance task when the
  later task-completion log save fails after service logging succeeds.
- The generated service log is removed during rollback, so a failed service
  attempt does not leave timeline and task data half-written.
- Focused widget coverage verifies failed task-completion logging keeps a
  `Canister filter` and its maintenance task unchanged.

CL-P1-009BW Soft-delete expiry failure resilience:

- Tank and livestock soft-delete expiry now catches failed permanent local
  delete writes instead of surfacing timer-driven async errors.
- Failed expiry deletes settle the soft-delete state and refresh providers so
  the still-saved tank or livestock record becomes visible again.
- Undo-expired side effects, such as livestock removal timeline logs, are not
  run when the underlying permanent delete fails.
- Focused provider coverage verifies failed single-tank, bulk-tank, and
  livestock permanent deletes after the undo window.

CL-P1-009BX Tank creation default-task rollback:

- New tank creation now rolls back the just-saved tank if any default care-task
  save fails mid-flow.
- Partial default tasks written before the failure are removed with the tank
  rollback, keeping the local tank list and task list consistent.
- Focused provider coverage simulates a failed second default-task save and
  verifies no partial tank or task data remains visible.

CL-P1-009BY Livestock bulk-move rollback:

- Bulk livestock moves now only treat missing selected IDs as skips; local save
  failures surface as errors.
- If a later livestock save fails, previously moved livestock are restored to
  their original tank before the error is rethrown.
- Focused provider coverage simulates a failed second move save and verifies
  source/target livestock data remains unchanged.

CL-P1-009BZ Demo tank replacement rollback:

- Sample tank reset now snapshots existing demo tank, livestock, equipment,
  log, and task data before removing old demo records.
- If creating the replacement sample tank fails mid-flow, partial replacement
  demo data is removed and the previous demo records are restored.
- Focused provider coverage simulates a failed replacement livestock save and
  verifies the real tank plus the previous demo tank and child records remain.

CL-P1-009CA Tank reorder rollback:

- Tank reordering now snapshots original tank sort orders before the bulk local
  save runs.
- If a bulk reorder save fails after writing some records, the changed tanks are
  restored individually before the original error is rethrown.
- Focused provider coverage simulates a failed second sort-order write and
  verifies all tank ordering remains unchanged.

CL-P1-009CB First-run demo seed rollback:

- First-run demo seeding now removes partial demo data when sample tank creation
  fails after writing tank, livestock, equipment, or log records.
- Cleanup deletes the partial demo tank through the normal tank delete path so
  local child records are removed with it.
- Focused provider coverage simulates a failed demo default-task save and
  verifies no partial demo tank or child data remains.

CL-P1-009CC Tank Detail task-completion rollback:

- Completing a task from Tank Detail now rolls back partial local writes if the
  completion log or equipment-maintenance side effects fail.
- The rollback restores the original task state, removes any generated logs,
  restores the previous equipment state when needed, refreshes local providers,
  and shows normal error feedback instead of surfacing a widget exception.
- Focused Tank Detail widget coverage simulates a failed completion-log write
  and verifies the task remains incomplete with no success feedback.

CL-P1-009CD Tank Detail quick-feeding failure feedback:

- Quick feeding from Tank Detail now catches local feeding-log save failures,
  logs the failure for diagnosis, and shows normal error feedback instead of a
  widget exception.
- Failed quick-feeding saves leave the local journal unchanged and do not show
  success feedback.
- Focused Tank Detail widget coverage uses the real QuickAdd FAB feeding action
  and simulates a failed feeding-log write.

CL-P1-009CE Log Detail undo-restore failure feedback:

- Log Detail delete undo now catches local restore-write failures, logs the
  failure for diagnosis, and shows normal error feedback instead of surfacing a
  widget exception from the snackbar action.
- The restore feedback uses a pre-captured `ScaffoldMessengerState`, so the
  error can still be shown after the detail route has been popped.
- Focused Log Detail widget coverage simulates a failed undo restore write and
  verifies the user sees restore-failure feedback.

CL-P1-009CF Cost Tracker undo-restore failure feedback:

- Cost Tracker expense deletion and clear-all undo actions now wait for local
  preference writes before treating the restore as durable.
- Failed undo restore writes roll the visible expense list back to the
  pre-undo state and show normal local error feedback instead of surfacing an
  async widget exception.
- Focused Cost Tracker widget coverage simulates failed single-expense and
  clear-all undo restore writes, verifying the user sees restore-failure
  feedback and the visible expense list returns to the pre-undo state.

CL-P1-009CG Reminder delete/undo failure feedback:

- Reminder deletion now saves the local reminder list before cancelling the OS
  notification, so a failed local delete rolls the visible reminder back instead
  of cancelling a still-visible reminder.
- Reminder delete undo now saves the local restore before rescheduling the OS
  notification; failed undo restores roll back to the deleted state and show
  immediate local error feedback.
- Focused Reminders widget coverage simulates a failed undo restore preference
  write and verifies the reminder stays deleted with restore-failure feedback.

CL-P1-009CH Reminder add failure feedback:

- Reminder add now writes the candidate reminder list before changing the
  visible list or scheduling the OS notification.
- Failed add writes leave the reminder form open for retry, keep the reminder
  out of the visible list, and show normal local error feedback.
- Focused Reminders widget coverage simulates a failed add preference write and
  verifies no reminder tile is created.

CL-P1-009CI Reminder completion failure feedback:

- Reminder completion now writes the candidate reminder list before changing the
  visible list or cancelling/scheduling OS notifications.
- Failed one-time completion writes keep the reminder visible and show normal
  local error feedback instead of leaving the user with a vanished reminder.
- Focused Reminders widget coverage simulates a failed completion preference
  write and verifies the reminder tile remains visible with no notification
  cancellation side effect.

CL-P1-009CJ Profile creation save failure feedback:

- First-run profile creation now uses the immediate local save path before
  exposing the new profile in provider state.
- Failed `user_profile` writes now surface to the caller and leave the profile
  provider in an error state instead of making onboarding appear locally saved.
- Focused provider coverage simulates a failed `user_profile` preference write
  and verifies no profile JSON is stored.

CL-P1-009CK Profile edit save failure feedback:

- Profile edits now use the immediate local save path before exposing edited
  profile state.
- Failed `user_profile` edit writes now surface to the caller and keep the
  previous profile visible instead of showing unsaved edits.
- Focused provider coverage simulates a failed `user_profile` preference write
  during `updateProfile` and verifies stored JSON stays unchanged.

CL-P1-009CL Placement skip save failure feedback:

- Placement-test skip now uses the immediate local save path before exposing
  the skipped placement state.
- Failed `user_profile` skip writes now surface to the caller and keep the
  previous placement state visible instead of showing an unsaved skip.
- Focused provider coverage simulates a failed `user_profile` preference write
  during `skipPlacementTest` and verifies stored JSON stays unchanged.

CL-P1-009CM Streak-freeze grant save failure feedback:

- Streak-freeze grant now uses the immediate local save path before exposing the
  granted freeze in profile state.
- Failed `user_profile` freeze writes now surface to the caller and keep the
  previous streak-freeze state visible instead of showing an unsaved reward.
- Focused provider coverage simulates a failed `user_profile` preference write
  during `addStreakFreeze` and verifies stored JSON stays unchanged.

CL-P1-009CN Achievement progress save failure feedback:

- Achievement progress updates now use the immediate local save path before
  exposing achievement and XP changes in profile state.
- Failed `user_profile` achievement writes now surface to the caller and keep
  previous achievement/XP state visible instead of showing unsaved progress.
- Focused provider coverage simulates a failed `user_profile` preference write
  during `updateAchievements` and verifies stored JSON stays unchanged.

CL-P1-009CO Energy save failure feedback:

- Energy/hearts updates now use the immediate local save path before exposing
  heart count or refill timestamp changes in profile state.
- Failed `user_profile` energy writes now surface to the caller instead of
  silently scheduling a debounced write and showing unsaved energy state.
- Focused provider coverage simulates a failed `user_profile` preference write
  during `updateHearts` and verifies stored JSON stays unchanged.

CL-P1-009CP Story progress save failure feedback:

- Story progress updates now use the immediate local save path before exposing
  story-progress or completed-story changes in profile state.
- Failed `user_profile` story writes now surface to the caller instead of
  silently scheduling a debounced write and showing unsaved story state.
- Focused provider coverage simulates a failed `user_profile` preference write
  during `updateStoryProgress` and verifies stored JSON stays unchanged.

CL-P1-009CQ Gems refund save failure feedback:

- Gem refunds now use the immediate local save path before exposing restored
  gem balance and refund transaction state.
- Failed `gems_state` refund writes now surface to the caller instead of
  silently scheduling a debounced write and showing unsaved restored currency.
- Focused provider coverage simulates a failed `gems_state` preference write
  during `refund` and verifies stored JSON stays unchanged.

CL-P1-009CR Gems grant save failure feedback:

- Gem grants now use the immediate local save path before exposing granted gem
  balance and grant transaction state.
- Failed `gems_state` grant writes now surface to the caller instead of
  silently scheduling a debounced write and showing unsaved granted currency.
- Focused provider coverage simulates a failed `gems_state` preference write
  during `grantGems` and verifies stored JSON stays unchanged.

CL-P1-009CS Inventory effect save failure ordering:

- Consumable inventory effects now save the item consumption locally before
  applying profile or energy side effects.
- If the `shop_inventory` consumption write fails, the effect is not applied,
  so users do not receive an unsaved streak-freeze or energy effect while the
  item remains in inventory.
- Focused provider coverage simulates a failed `shop_inventory` preference
  write during `useItem('streak_freeze')` and verifies the profile and
  inventory JSON stay unchanged.

CL-P1-009CT Duplicate permanent inventory purchase guard:

- Permanent shop items now reject duplicate ownership before attempting to spend
  gems, avoiding an unnecessary refund path for items the user already owns.
- This keeps local currency untouched when a duplicate badge/theme purchase is
  blocked, even if a later gem write would fail.
- Focused provider coverage simulates a duplicate permanent badge purchase with
  failing `gems_state` writes and verifies the gem and inventory JSON stay
  unchanged.

CL-P1-009CU Gem cumulative counter rollback:

- Gem earn/spend cumulative counters now restore their previous in-memory
  values when the immediate local `gems_state` save fails.
- This prevents Total Earned or Total Spent summaries from showing unsaved
  cumulative progress after a failed local write.
- Focused provider coverage simulates failed `gems_state` writes during
  `addGems` and `spendGems` and verifies `gems_cumulative` and the in-memory
  counters stay unchanged.

CL-P1-009CV Gem partial-write rollback:

- Gem earn, spend, refund, and grant operations now restore the previous
  persisted `gems_state` if the main gem JSON writes successfully but the
  following `gems_cumulative` write fails.
- This prevents a failed two-key gem save from reappearing after restart as a
  silently persisted balance or transaction change.
- Focused provider coverage simulates failed `gems_cumulative` writes during
  `addGems`, `spendGems`, `refund`, and `grantGems` and verifies both local gem
  preference keys stay unchanged.

CL-P1-009CW Settings preference save ordering:

- App settings setters now wait for the local SharedPreferences write before
  exposing updated theme or boolean preference state.
- If a preference save fails, the previous visible setting remains in place and
  the failed write is logged instead of showing an unsaved value that would be
  lost after restart.
- Focused provider coverage simulates failed `use_metric` and `theme_mode`
  writes and verifies the in-memory settings and persisted preferences stay
  unchanged.

CL-P1-009CX Wishlist provider save ordering:

- Wishlist item add, update, remove, and purchase-mark operations now save the
  candidate `wishlist_items` preference payload before exposing the changed
  provider state.
- If the local wishlist preference write is still pending or fails, normal
  wishlist state stays on the last persisted item list instead of briefly
  showing unsaved planning changes.
- Focused provider coverage pauses `wishlist_items` writes during item add and
  removal, verifying the visible provider list changes only after the local save
  completes.

CL-P1-009CY Shop planning provider save ordering:

- Shop Street budget updates and local shop add/update/remove operations now
  save the candidate SharedPreferences payload before exposing the changed
  provider state.
- If `shop_budget` or `local_shops` writes are still pending or fail, the
  visible planning state stays on the last persisted budget/shop list instead
  of briefly showing unsaved changes.
- Focused provider coverage pauses `shop_budget` and `local_shops` writes,
  verifying the visible budget and local shop list change only after local save
  completion.

CL-P1-009CZ Species unlock save ordering:

- Earned species unlocks now save the candidate `unlocked_species_v1` payload
  before exposing the new species in `speciesUnlockProvider`.
- If a species unlock save is pending or fails, the species remains locked in
  visible provider state instead of appearing briefly and disappearing after an
  app restart.
- Focused provider coverage pauses and rejects `unlocked_species_v1` writes,
  verifying successful unlocks appear only after local save completion and
  failed unlocks return `false`.

CL-P1-009DA Tank Journal new-entry save failure feedback:

- Tank Journal's new-entry sheet now rebuilds the Save action as users type,
  so non-empty notes can be saved without leaving and reopening the sheet.
- Failed local journal-entry saves now keep the sheet open, clear the saving
  state, log the failure, and show inline retry feedback instead of surfacing a
  widget exception or silently dismissing the draft.
- Focused widget coverage simulates a failed `saveLog` write and verifies the
  sheet stays open with normal feedback.

CL-P1-009DB Inventory item-use failure feedback:

- Inventory item use now catches failed local `shop_inventory` writes, logs the
  failure, and shows normal retry feedback instead of letting the provider
  exception escape the screen.
- The failed use path keeps the owned consumable visible and leaves persisted
  inventory unchanged.
- Focused widget coverage simulates a failed item-use save, confirms the
  normal retry snackbar, and verifies the item remains visible.

CL-P1-009DC Preferences crash-report consent failure feedback:

- Preferences Crash Reports consent now waits for the local
  `gdpr_analytics_consent` write before changing the visible switch or applying
  diagnostics consent.
- Failed consent writes keep the switch on its previous value, log the failure,
  and show normal retry feedback instead of making crash reporting look enabled
  or disabled when the local preference was not saved.
- Focused widget coverage simulates a failed consent preference write and
  verifies the switch stays unchanged with retry feedback.

CL-P1-009DD Local JSON storage atomic write failures:

- `LocalJsonStorageService` now builds candidate entity maps, persists them to
  the JSON file, and only swaps same-process in-memory state after the durable
  write succeeds.
- Failed tank saves no longer expose unsaved tanks through `getTank` after the
  persistence exception, and failed tank deletes keep the tank and child
  livestock visible in memory.
- Focused storage coverage simulates write-path failures through a local
  path-provider fake and verifies save/delete failures keep memory aligned with
  the last durable state.

CL-P1-009DF Local JSON migration persistence:

- Migrated local JSON files are now persisted back to disk after a successful
  load, preserving the raw migrated payload while stamping the current schema
  version.
- This prevents older v0/v1 local files from re-running the same forward
  migration on every launch after the app has already loaded them correctly.
- Focused storage coverage writes a legacy v0 JSON file, reloads it through the
  public recovery path, verifies tank defaults are applied on read, and checks
  the file is stamped to schema version 2.

CL-P1-009GJ Local JSON migration stamp failure boundary:

- If a legacy local JSON file can be parsed and migrated but the
  `aquarium_data.json.tmp` migration-stamp write cannot be persisted, Danio now
  treats the load as an I/O failure instead of reporting `StorageState.loaded`.
- The original legacy file remains intact, the in-memory migrated entities are
  cleared, and `StorageMigrationPersistenceException` is thrown for retry or
  recovery handling.
- Focused storage coverage blocks the migration temp-file path and verifies the
  service reports `StorageState.ioError` without adding a false schema version
  to the legacy file.

CL-P1-009GK Bulk tank delete retry feedback:

- Bulk tank soft-delete expiry now uses the same retry feedback channel as
  single-tank soft-delete expiry when the durable local delete write fails.
- The tank remains visible again after the soft-delete state settles, and the
  existing global feedback listener can show "Couldn't delete one or more
  tanks. Try again." instead of leaving the failure as a log-only event.
- Focused provider coverage verifies a failed permanent bulk soft delete both
  restores tank visibility and publishes `tankDeleteFailureFeedbackProvider`.

CL-P1-009GL Backup import no-tank preference guard:

- Backup & Restore now routes confirmed imports through a tested import-flow
  helper that only restores app-wide SharedPreferences after at least one local
  tank imports.
- Backups with zero tanks keep profile, learning, gems, settings, and other
  app-wide preference data unchanged while showing the existing "No tanks found
  in this backup file." warning.
- Focused service coverage verifies zero-tank imports skip preference restore
  and provider invalidation callbacks.

CL-P1-009DG Backup & Restore local recovery surface:

- Backup & Restore now surfaces a local recovery card when the local JSON
  storage service reports corrupted data.
- The card explains in normal-user language that Danio stopped loading damaged
  local data and kept a recovery copy on this device before offering options.
- Users can retry after repairing/replacing the file, or confirm Start Fresh On
  This Device to clear the damaged local aquarium data file.
- Focused widget coverage verifies the visible recovery copy, Try Again action,
  and confirmed start-fresh action.

CL-P1-009DH Backup restored-photo import rollback:

- Backup photo restore now records only the local photo files it created during
  the current restore attempt.
- If photo extraction fails, tank-scoped backup import fails, or the import
  screen unmounts before tank data is committed, those newly restored photos are
  cleaned up instead of being left as orphaned local files.
- Existing local photos with matching restored filenames are not overwritten and
  are not removed by the cleanup path.
- Focused service coverage verifies cleanup removes only newly restored photos,
  and Backup & Restore screen coverage guards the import failure cleanup path.

CL-P1-009DI Profile/preferences restore rollback:

- `SharedPreferencesBackup.restoreFromJson` now snapshots existing exportable
  profile/preferences values before applying a backup.
- If an exportable preference write fails after restore has started, Danio
  restores the previous exportable profile/preferences values before surfacing
  the original write failure.
- The restore helper now treats failed preference clear/write return values as
  real restore failures instead of assuming the platform write succeeded.
- Focused service coverage verifies a mid-restore `use_metric` write failure
  keeps the previous theme, unit, room-theme, and non-exportable API-key values.

CL-P1-009DJ Livestock single-delete expiry failure feedback:

- Single livestock removal now passes a permanent-delete failure callback from
  `TankActions.softDeleteLivestock` back to the Livestock screen.
- If the undo window expires but the local livestock delete write fails, Danio
  restores the item and replaces the stale undo snackbar with normal error
  feedback: `Couldn't remove <fish>. Try again.`
- The removal timeline log is still skipped on failed permanent deletes, so the
  journal does not record a removal that did not commit locally.
- Focused widget coverage verifies failed expiry restores the visible fish,
  shows retry feedback, and writes no livestock-removal timeline log.

CL-P1-009DK Optional AI key write-result handling:

- `AiProxyService.saveApiKey` and `AiProxyService.clearApiKey` now treat failed
  local `SharedPreferences` write/remove return values as real failures instead
  of silently reporting success.
- The existing Optional AI setup dialog can now show its normal save/remove
  retry feedback when the local key write does not commit.
- Focused service coverage simulates false `setString` and `remove` results and
  verifies the visible key state is not reported as changed.

CL-P1-009DL Add Log post-save profile failure boundary:

- Add/Edit Log now treats the local journal write as the durable source of truth
  before profile XP/activity side effects run.
- If profile activity persistence fails after `storage.saveLog(log)` succeeds,
  Danio logs the profile-side failure, refreshes the profile provider, exits the
  form, and shows non-retry feedback: `<type> logged, but progress couldn't
  update.`
- XP animation, XP success copy, and achievement checks only run when the
  profile activity write succeeds, so the UI does not claim progress that did
  not persist.
- Focused widget coverage verifies a failed `user_profile` write after an
  observation log save leaves exactly one saved log, exits the form, shows the
  non-blocking progress warning, and does not show the generic save retry.

CL-P1-009DM Create Tank post-create profile failure boundary:

- Create Tank now treats `actions.createTank(...)` as the durable source of
  truth before profile XP/activity side effects run.
- If profile activity persistence fails after the local tank is created, Danio
  logs the profile-side failure, refreshes the profile provider, closes the
  wizard, and shows non-retry feedback:
  `<tank name> created, but progress couldn't update.`
- XP animation, XP success copy, and achievement checks only run when the
  profile activity write succeeds, so the UI does not claim profile progress
  that did not persist.
- Focused widget coverage verifies a failed `user_profile` write after guided
  tank creation leaves exactly one saved tank, exits the form, shows the
  non-blocking progress warning, and does not show the generic create retry.

CL-P1-009DN Smart local cache persistence boundary:

- Smart AI history, anomaly history, and weekly-plan cache providers now wait
  for their local `SharedPreferences` writes before exposing updated provider
  state.
- Failed Smart cache write return values are treated as local failures instead
  of silently reporting success, and provider loads can no longer overwrite a
  pending cache mutation after it has been requested.
- Weekly Plan now awaits the durable plan-cache save before rendering the new
  plan, while secondary AI activity history logging remains best-effort and
  does not make completed optional-AI results feel broken.
- Focused provider coverage verifies delayed and failed preference writes for
  AI history, weekly plan cache, anomaly creation, and anomaly dismissal.
- Weekly Plan cache clearing now also waits for durable local
  `weekly_plan_cache` removal before hiding the visible plan; failed removals
  surface as errors and keep the existing plan visible instead of leaving a
  stale cache that can reappear after restart.

CL-P1-009DO Achievement lifecycle persistence boundary:

- Achievement progress now records the latest debounced progress map as a
  pending local write.
- On app pause or detach, the achievement provider cancels the debounce timer
  and flushes pending progress to `SharedPreferences`, matching the
  data-resilience pattern already used for profile/gem lifecycle writes.
- Backup restore cancellation clears any pending achievement progress before
  provider invalidation, preventing stale lifecycle flushes during import.
- Focused provider coverage verifies achievement progress is persisted during
  app pause before the normal debounce timer fires, and verifies restore
  cancellation does not persist stale progress.

CL-P1-009DP Spaced-repetition review-card persistence boundary:

- Review-card create, lesson auto-seed, and delete flows now restore the
  previous visible cards/stats when the `spaced_repetition_cards`
  `SharedPreferences` write fails.
- The lesson auto-seed contract remains non-blocking for lesson completion,
  but failed local review-card setup no longer leaves unsaved cards visible.
- Focused provider coverage simulates local card-write failures and verifies
  visible review progress stays consistent with persisted storage.

CL-P1-009DQ Room-vibe apply persistence boundary:

- Room-vibe applies now update visible theme state only after the local
  `room_theme` preference write succeeds.
- Theme Picker and Inventory no longer show success feedback for failed room
  vibe applies; failed writes keep the current room vibe visible with normal
  retry feedback.
- Focused provider coverage simulates failed `room_theme` writes and verifies
  the previous visible room vibe stays consistent with persisted storage.

CL-P1-009DR Reduce Motion preference persistence boundary:

- Reduce Motion manual overrides now clear correctly when the user returns to
  the system motion setting.
- Manual Reduce Motion enable/disable and clear actions now update visible
  motion state only after the local `reduced_motion_override` write or removal
  succeeds.
- Failed Reduce Motion preference saves keep the previous visible motion state
  and show normal retry feedback instead of reporting success.
- Focused provider coverage simulates failed set/clear writes and verifies
  visible motion state stays consistent with persisted preferences.

CL-P1-009DS First-visit guidance prompt persistence boundary:

- First-visit guidance prompts now save their `guidance_seen_*` flag before
  running the dismiss animation or notifying parent screens that the prompt was
  dismissed.
- Failed local guidance-seen writes keep the prompt retryable and avoid false
  parent-screen dismissed state.
- Focused widget coverage verifies both successful guidance dismissal and
  failed local write handling.

CL-P1-009DT Seasonal tip dismissal persistence boundary:

- Seasonal tip cards now save the monthly dismissal flag before running the
  dismiss animation or hiding the card.
- Failed local seasonal-tip writes keep the card visible and retryable instead
  of disappearing without a durable preference.
- Focused widget coverage verifies both successful seasonal-tip dismissal and
  failed local write handling.

CL-P1-009DU First-run consent persistence boundary:

- First-run diagnostics consent now waits for both the diagnostics and
  `tos_accepted` preference writes before applying diagnostics consent or
  completing the consent step.
- The under-13 hard block now uses the injectable shared-preferences provider
  and waits for the local `under_13_blocked` flag before navigating to the hard
  block screen.
- Failed local first-run consent or under-13 writes keep the user on the
  consent screen and show retry feedback instead of advancing with unsaved
  state.
- Focused widget coverage simulates failed consent and under-13 preference
  writes.

CL-P1-009DV User profile preference write boundary:

- User profile saves now treat a `SharedPreferences.setString` false return as
  a local save failure instead of exposing created or updated profile state.
- The existing profile save failure handling still catches thrown write errors,
  and the shared `_saveImmediate` helper now covers false results for profile
  creation, edits, progress, energy, achievements, and story progress.
- Focused provider coverage simulates a false `user_profile` write result and
  verifies profile creation fails before persisted or visible profile state is
  exposed.

CL-P1-009DW Schema migration stamp persistence boundary:

- Schema migration version stamps now treat `SharedPreferences.setInt` false
  results as migration failures.
- The v0-to-v1 stamp runs through a shared helper so future stamp writes can use
  the same durable-write contract.
- Focused unit coverage simulates a failed `_schemaVersion` stamp and verifies
  migration does not silently complete without a persisted marker.

CL-P1-009DX Onboarding completion preference boundary:

- Onboarding completion now treats a `SharedPreferences.setBool` false result
  as a local setup save failure instead of invalidating the router as if setup
  completed durably.
- `OnboardingService` has an injectable preferences factory for isolated
  service tests while production callers continue using the shared singleton.
- Focused service coverage simulates a failed `onboarding_completed` write and
  verifies the local completion flag remains unset.

CL-P1-009DY Shared guidance dismissal persistence boundary:

- `GuidanceService.markDismissed` now treats false `SharedPreferences` write
  results as local dismissal failures for both forever and one-day dismissal
  scopes.
- The shared service boundary now matches the prompt widgets: guidance should
  not be reported as dismissed unless its local flag was saved.
- Focused service coverage simulates failed forever and day-scope guidance
  dismissal writes and verifies no dismissed flag is persisted.

CL-P1-009DZ Gems preference write boundary:

- Gem state, cumulative earned/spent counters, and rollback writes now treat
  false `SharedPreferences.setString` results as local save failures.
- The existing gem reward, spend, refund, and grant rollback paths now cover
  both thrown preference failures and false preference write results.
- Focused provider coverage simulates false `gems_state` and `gems_cumulative`
  writes and verifies false reward progress is not exposed.

CL-P1-009EA Inventory preference write boundary:

- Inventory saves now treat false `SharedPreferences.setString` results as
  local inventory save failures instead of exposing unsaved item progress.
- Item-use flows keep profile effects unapplied when `shop_inventory` writes
  return false, and purchase flows refund spent gems when the item cannot be
  saved.
- Focused provider coverage simulates false `shop_inventory` writes and
  verifies inventory state, profile state, and gem balance stay consistent.

CL-P1-009EB Spaced-repetition preference write boundary:

- Spaced-repetition review-card saves now treat false
  `SharedPreferences.setString` results as local save failures for card and
  stats persistence.
- Review-card create, lesson auto-seed, and delete flows keep their existing
  rollback/error paths when `spaced_repetition_cards` writes return false.
- Focused provider coverage simulates false review-card preference writes and
  verifies visible cards, review stats, and persisted card JSON stay
  consistent.

CL-P1-009EC Reminder and Cost Tracker preference write boundary:

- Reminder saves now treat false `SharedPreferences.setString` results as local
  save failures, so add and complete flows keep the reminder UI unchanged and
  skip notification side effects when `aquarium_reminders` is not saved.
- Cost Tracker expense and currency preference writes now reject false
  `SharedPreferences.setString` results instead of reporting add, clear, undo,
  or currency changes as durable when local storage rejected them.
- Focused widget coverage simulates false reminder and cost-tracker preference
  writes and verifies normal retry feedback with no false saved item state.

CL-P1-009ED Maintenance Checklist preference write boundary:

- Maintenance Checklist now persists weekly and monthly progress through a
  versioned local preference snapshot while still reading the previous
  multi-key format for existing installs.
- Checklist toggles and reset actions now reject false
  `SharedPreferences.setString` results, roll back visible progress, and show
  normal retry feedback instead of displaying unsaved task completion.
- Local backup exports now include `checklist_` preference snapshots so care
  checklist progress survives backup/restore alongside the other local profile
  preferences.
- Focused widget and backup-service coverage simulates a false checklist
  snapshot write and verifies the new snapshot is exportable.

CL-P1-009EE Difficulty Settings preference write boundary:

- Manual difficulty overrides now wait for the local `user_skill_profile`
  preference write before changing the visible selected difficulty.
- Failed or false `SharedPreferences.setString` results keep the previous
  automatic/manual selection visible and show normal retry feedback instead of
  implying an unsaved override was applied.
- Focused widget coverage verifies both the direct Difficulty Settings callback
  contract and the Settings wrapper path where `user_skill_profile` returns
  false from `setString`.

CL-P1-009EF Review request preference write boundary:

- In-app review request tracking now uses `RateService` as the single local
  save boundary for both service-triggered and lesson-completion prompts.
- Failed or false `SharedPreferences.setBool` results for `review_requested`
  are treated as local tracking failures instead of reporting the prompt flow
  as fully saved.
- Focused service coverage fakes the review API and verifies false
  `review_requested` writes leave the local flag unset and return a failed
  tracking result.

CL-P1-009EG API rate-limit preference write boundary:

- Optional-AI API rate-limit tracking now returns whether the local
  `SharedPreferences.setStringList` timestamp write succeeded.
- Failed or false rate-limit writes still count in the current app session, so
  repeated requests remain limited while the app is running, but the save result
  is no longer treated as durable.
- Focused service coverage simulates a false `rate_limit_ask_danio` write and
  verifies the persisted list stays unset while the in-memory request count is
  reduced.

CL-P1-009EH Legacy inventory migration write boundary:

- Legacy `UserProfile.inventory` migration now uses the same guarded
  `shop_inventory` preference write path as normal inventory changes.
- Failed or false migration writes keep the legacy profile inventory intact
  instead of clearing it before the new single-source `shop_inventory` snapshot
  is durable.
- Focused provider coverage simulates a false `shop_inventory` migration write
  and verifies the visible migrated item remains available while the legacy
  profile inventory is preserved for a later retry.

CL-P1-009EI Review session count write boundary:

- Spaced-repetition session completion now saves `spaced_repetition_sessions`
  through the guarded local preference write path before updating streak or
  achievement side effects.
- Failed or false session-count writes keep the active review session open and
  prevent unsaved streak progress from appearing as durable.
- Focused provider coverage simulates a false `spaced_repetition_sessions`
  write and verifies the session remains active, the session counter is unset,
  and no streak snapshot is written.

CL-P1-009EJ Review streak write boundary:

- Spaced-repetition streak updates now save `spaced_repetition_streak` through
  the guarded local preference write path instead of ignoring false
  `SharedPreferences` results.
- Failed or false streak writes keep the previous visible streak and preserve a
  normal retry warning while allowing the durable review session completion to
  finish.
- Focused provider coverage simulates a false `spaced_repetition_streak` write
  and verifies the completed session remains saved without writing a fake
  streak snapshot or fake persisted streak value.

CL-P1-009EK Achievement progress false-write retry:

- Debounced achievement progress saves now treat false
  `SharedPreferences.setString` results as failed local writes instead of
  clearing the pending reward-progress snapshot.
- Lifecycle pause/detach flushes can retry the same pending
  `achievement_progress` snapshot after the failed debounced write.
- Focused provider coverage simulates a false first `achievement_progress`
  write and verifies the next lifecycle flush persists the same local progress.

CL-P1-009EL Delete My Data preference-clear boundary:

- The privacy Delete My Data flow now treats a false
  `SharedPreferences.clear` result as a local deletion failure instead of
  continuing to delete files, reset onboarding, or navigate away.
- Failed preference clears keep the persistent preference store retryable and
  show normal retry feedback: `Couldn't delete data. Try again!`.
- Focused widget coverage simulates a false platform preference clear and
  verifies the destructive flow reports the failure and leaves local preference
  data available for retry.

CL-P1-009EM Onboarding reset preference-removal boundary:

- `OnboardingService.resetOnboarding` now treats missing preferences or a false
  `SharedPreferences.remove` result as local reset failures instead of
  silently reporting reset completion.
- Settings, debug, and data-deletion callers that already await the service can
  now use their existing retry/error paths when the onboarding completion flag
  cannot be removed.
- Focused service coverage simulates a false `onboarding_completed` removal
  and verifies the completion flag remains set for retry.

CL-P1-009EN Settings replay-onboarding reset failure boundary:

- Preferences Replay Onboarding now catches local onboarding reset failures,
  logs the failure, keeps the user on Settings, and shows normal retry
  feedback instead of letting the async reset error escape.
- Failed replay resets no longer invalidate onboarding state or navigate away
  while the `onboarding_completed` flag remains saved.
- Focused widget coverage simulates a false `onboarding_completed` removal and
  verifies Settings remains visible with `Couldn't replay onboarding. Try
  again.` feedback.

CL-P1-009EO Clear All Data scope copy:

- Preferences Clear All Data now describes its actual local scope as tanks,
  logs, tasks, and photos instead of claiming to delete settings.
- Delete My Data remains the broader privacy action for preferences, progress,
  achievements, and onboarding state.
- Focused widget coverage verifies the visible Danger Zone subtitle matches the
  implemented clear-data flow.

CL-P1-009EP Add Log edit reward boundary:

- Editing an existing Add Log entry now saves the log without awarding new XP,
  streak credit, achievement checks, feeding pulses, water-change celebration,
  or unsafe-water new-entry routing.
- Successful Add Log saves mark the form as saved before closing, so the
  dirty-form guard no longer leaves a saved edit route open.
- Focused widget coverage verifies an existing water-change edit preserves the
  saved profile XP and closes the edit route after saving.

CL-P1-009EQ Tank Settings saved-edit close boundary:

- Successful Tank Settings edits now mark the form as saved before closing, so
  the dirty-form guard does not leave a durably saved edit route open.
- Focused widget coverage edits a tank name through a pushed settings route,
  verifies the local tank was saved, and verifies the settings screen closes
  without showing the unsaved-changes prompt.

CL-P1-009ER Equipment add maintenance-task rollback:

- Adding equipment with a maintenance interval now rolls back the newly saved
  equipment record if the auto maintenance-task save fails.
- The add sheet keeps normal failure feedback and does not show the success
  message for the partial add.
- Focused widget coverage simulates a failed task save, verifies no
  equipment/task records remain, and checks the retry feedback.

CL-P1-009ES Equipment add progress boundary:

- Adding equipment now treats profile XP/progress persistence as secondary to
  the durable equipment save.
- If profile progress fails after the equipment is saved, the equipment remains
  saved, the add sheet closes, XP animation is suppressed, and the user sees
  progress-specific feedback instead of a generic add failure.
- Focused widget coverage simulates a failed `user_profile` preference write
  after add and verifies the equipment remains saved with the progress warning.

CL-P1-009ET Livestock add progress boundary:

- Adding livestock now treats profile XP/progress persistence as secondary to
  the durable livestock save and readable timeline log save.
- If profile progress fails after the livestock/log records are saved, the
  records remain saved, the add sheet closes, XP animation is suppressed, and
  the user sees progress-specific feedback instead of a generic add failure.
- Focused widget coverage simulates a failed `user_profile` preference write
  after add and verifies the livestock plus timeline log remain saved with the
  progress warning.

CL-P1-009EU Bulk livestock add timeline-log rollback:

- Bulk livestock add now tracks newly saved livestock and readable timeline logs
  during the local add transaction.
- If a timeline log save fails mid-add, the flow deletes any newly saved bulk
  livestock/log records before showing retry feedback, avoiding partial
  livestock without matching journal evidence.
- Focused widget coverage mounts the bulk-add sheet, simulates a failed log
  save, and verifies no livestock or log records remain.

CL-P1-009GP Bulk livestock add missing-parent guard:

- Bulk livestock add now rechecks its parent tank in storage before saving any
  bulk livestock records or acquisition timeline logs.
- If the sheet is stale after tank deletion, the flow shows the existing retry
  feedback and saves no orphan livestock or log records.
- Focused widget coverage mounts the bulk-add sheet, deletes the parent tank,
  and verifies no livestock or log records are saved.

CL-P1-009EV Single livestock add timeline-log rollback:

- Single livestock add now rolls back the newly saved livestock record if the
  readable timeline log save fails.
- The flow keeps normal retry feedback and does not show add success for a
  partial livestock record without matching journal evidence.
- Focused widget coverage simulates a failed add-log save and verifies no
  livestock or log records remain.

CL-P1-009EW Quick Water Test progress boundary:

- Quick Water Test now treats the local water-test log save as the durable
  aquarium action and handles the follow-up profile-XP write separately.
- If XP persistence fails after the water-test log is saved, the sheet still
  closes and reports that the water test was logged while the XP could not be
  saved.
- Focused widget coverage simulates a failed `user_profile` write after saving
  a quick water-test log and verifies the log remains saved without false
  water-test failure feedback.

CL-P1-009EX User profile reset removal boundary:

- `UserProfileNotifier.resetProfile` now checks the local `user_profile`
  preference removal result before exposing a reset profile state.
- Failed preference removals throw a local persistence error and keep the
  current in-memory profile aligned with the still-persisted profile.
- Focused provider coverage simulates a false remove result and verifies the
  profile remains visible while the saved profile JSON remains intact.

CL-P1-009EY Practice lesson XP feedback boundary:

- Practice-mode lesson completion now distinguishes a real saved XP award from
  a failed or unavailable profile write before choosing completion feedback.
- If the practice XP write fails, the flow no longer claims `+XP`; it reports
  that practice completed but XP could not be saved.
- When a lesson has no existing review progress record, practice completion
  now writes practice XP directly instead of letting `reviewLesson` no-op while
  still showing XP feedback.
- Focused widget coverage opens a practice lesson from a parent route,
  simulates a failed `user_profile` write, and verifies the post-pop feedback
  does not claim the XP reward.

CL-P1-009EZ Energy explainer dismissal boundary:

- The energy explainer no longer writes `hearts_explained` before the user has
  actually seen and dismissed the dialog.
- If the lesson surface unmounts while preferences are still loading, the
  prompt is not silently consumed.
- Focused widget coverage verifies both dismissal timing and the unmounted
  screen boundary.

CL-P1-009FA Stage sheet hint preference boundary:

- The Tank stage sheet first-use hint now reads and writes
  `hasSeenSheetHint` through `sharedPreferencesProvider`.
- This keeps the hint aligned with the same local preference override,
  restore/reset, and failure-injection boundary used by the rest of the app.
- Focused stage-panel coverage verifies that hint persistence goes through the
  shared provider rather than a direct `SharedPreferences.getInstance()` call.

CL-P1-009FB Optional AI disclosure acceptance boundary:

- Weekly Plan now catches failed local saves of
  `openai_disclosure_accepted`, shows normal retry feedback, and returns before
  any OpenAI request is made.
- Focused widget coverage injects a false `setBool` result and verifies that
  the disclosure flag stays unset, `weekly_plan_cache` stays empty, and the
  fake OpenAI service is not called.

CL-P1-009FC Symptom Triage disclosure acceptance boundary:

- Symptom Triage now catches failed local saves of
  `openai_disclosure_accepted`, shows normal retry feedback, and returns before
  starting the diagnosis stream.
- Focused widget coverage injects a false `setBool` result and verifies that
  the disclosure flag stays unset and the fake OpenAI stream is not called.

CL-P1-009FD Fish ID disclosure acceptance boundary:

- Fish ID now catches failed local saves of `openai_disclosure_accepted`, shows
  normal retry feedback, and returns before any image-identification request is
  made.
- A focused source contract covers Weekly Plan, Symptom Triage, and Fish ID so
  future Optional AI disclosure-save paths keep the same stop-before-request
  behavior.

CL-P1-009FE Shared Optional AI disclosure gate:

- Weekly Plan, Symptom Triage, Fish ID, Ask Danio, AI Stocking Suggestions, and
  AI Compatibility Advice now use one shared disclosure gate before making
  OpenAI requests.
- The gate catches failed local saves of `openai_disclosure_accepted`, logs the
  failure with the feature tag, gives normal retry feedback, and returns `false`
  before any request can send photos, text, species, or tank context off-device.
- Focused source coverage now requires every current OpenAI request surface to
  call `ensureOpenAIDisclosureAccepted`.

CL-P1-009GM Ask Danio disclosure gate:

- Ask Danio now routes typed aquarium questions through the shared Optional AI
  disclosure gate before checking configuration, connectivity, rate limits, or
  sending the OpenAI chat request.
- Disclosure-save failures surface retryable inline Ask Danio feedback and
  return before any typed question can leave the device.
- Focused source-contract coverage now includes `lib/screens/smart_screen.dart`
  alongside the other current OpenAI request surfaces.

CL-P1-009GN Ask Danio local-history confirmation:

- Ask Danio now shows the AI answer immediately, then asks before saving the
  typed-question summary to local Recent AI Activity.
- Canceling the save confirmation leaves `ai_interaction_history` empty while
  keeping the visible answer available.
- Confirming the save writes one local `ask_danio` history entry.
- Focused widget coverage exercises both cancel and confirm paths.

CL-P1-009GO Cycling Assistant reminder parent-tank boundary:

- Cycling Assistant now rechecks the parent tank in storage before saving a
  phase-aware reminder task from the guided action card.
- If a stale open assistant no longer has a durable parent tank, the reminder is
  not saved and the existing retry feedback is shown.
- Focused widget coverage verifies both the missing-parent failure path and the
  normal phase-aware reminder create path.

CL-P1-009GQ Symptom Triage journal parent-tank boundary:

- Symptom Triage now rechecks the selected tank in storage before saving a
  confirmed AI diagnosis journal log or recording confirmed AI history.
- If the screen has a stale cached tank list after the durable tank was deleted,
  the journal log and AI history entry are not saved and existing retry feedback
  is shown.
- Focused widget coverage verifies the stale-tank failure path keeps local
  journal logs and `ai_interaction_history` empty.

CL-P1-009GR Species care-task parent-tank boundary:

- Species detail now rechecks the selected tank in storage before creating or
  updating the weekly species care task from the Care Actions card.
- If the detail sheet has a stale cached tank list after the durable tank was
  deleted, the task is not saved and existing retry feedback is shown.
- Focused widget coverage verifies the stale-tank failure path keeps local
  species care tasks empty while normal care-task creation still works.

CL-P1-009GS Tank Journal manual-entry parent-tank boundary:

- Tank Journal now rechecks the current tank in storage before saving a manual
  observation log from the New Journal Entry sheet.
- If the Journal route remains open after the durable tank was deleted, the log
  is not saved and the existing sheet-level retry feedback is shown.
- Focused widget coverage verifies the stale-tank failure path keeps local
  journal logs empty while preserving the separate save-failure feedback path.

CL-P1-009GT Tank Detail quick-feeding parent-tank boundary:

- Tank Detail now rechecks the current tank in storage before saving a
  quick-feeding log from the QuickAdd FAB.
- If the Tank Detail route remains open after the durable tank was deleted, the
  feeding log is not saved and the existing retry feedback is shown.
- Focused widget coverage verifies the stale-tank failure path keeps local
  feeding logs empty while preserving normal quick-feeding behavior.

CL-P1-009GU Equipment delete Undo parent-tank boundary:

- Equipment delete Undo now rechecks the current tank in storage before
  restoring the deleted equipment or its generated maintenance task.
- If the Equipment route remains open after the durable tank was deleted, Undo
  leaves equipment and tasks deleted and shows the existing restore-failure
  feedback.
- Focused widget coverage verifies the stale-tank undo path keeps local
  equipment and task records empty while preserving normal equipment Undo
  behavior.

CL-P1-009FF Stage sheet hint failed-save boundary:

- The Tank stage sheet first-use hint now checks the
  `hasSeenSheetHint` write result before hiding the hint permanently.
- If the write returns false, the hint is restored to visible opacity so the
  prompt remains retryable instead of being silently consumed.
- Focused source coverage protects the `setBool` return check and retry
  visibility path.

CL-P1-009FG Spaced-repetition reset removal boundary:

- `SpacedRepetitionNotifier.resetAll` now checks both review-card and review
  stats preference removals before exposing an empty review state.
- If reset removal fails after one key was removed, the provider restores the
  original local JSON for the removed key where possible.
- Failed resets keep the previous visible cards/stats, set normal retry copy,
  and rethrow the local failure for callers that need to stop follow-up work.
- Focused provider coverage simulates a false
  `spaced_repetition_cards` removal and verifies visible state plus persisted
  cards/stats remain unchanged.

CL-P1-009FH Tank returning-user prompt dismissal boundary:

- Tank day-2, day-7, and day-30 returning-user prompt dismissal writes now
  check the `SharedPreferences.setBool` result before treating the seen flag as
  durably persisted.
- Failed seen-flag writes are logged with the prompt key, keeping the prompt
  retryable instead of silently consuming the local dismissal marker.
- Focused HomeScreen source coverage protects the `setBool` return check and
  failed-write logging copy.

CL-P1-009FI Full spaced-repetition reset boundary:

- `SpacedRepetitionNotifier.resetAll` now owns all four practice preference
  removals: cards, stats, streak, and session counters.
- Failed reset removals restore any partially removed local JSON before
  rethrowing, so Debug reset and QA seed callers do not report a clean practice
  reset while old counters remain behind.
- The Debug Practice reset no longer performs separate unchecked streak/session
  removals after calling `resetAll`.
- Focused provider coverage simulates a false
  `spaced_repetition_sessions` removal and verifies visible state plus all four
  persisted practice keys remain unchanged.

CL-P1-009FJ Gem/inventory reset removal boundary:

- `GemsNotifier.reset` and `InventoryNotifier.reset` now check local
  preference removal results before reloading reset state.
- False `gems_state` and `shop_inventory` removals throw a local failure, keep
  visible provider state unchanged, and leave persisted JSON intact.
- Focused provider coverage simulates false remove results for both reset
  helpers.

CL-P1-009FK Debug achievement reset persistence boundary:

- Debug `Reset Achievements Only` now checks the local `achievement_progress`
  removal before clearing profile achievements.
- If the profile achievement write fails after progress was removed, the reset
  restores the previous achievement-progress JSON before showing normal error
  feedback.
- Focused DebugMenu widget coverage simulates both false progress removal and
  false profile writes, verifying achievement progress and profile achievements
  remain intact.

CL-P1-009FW Achievement provider reset persistence boundary:

- `AchievementProgressNotifier.resetAll` now checks the local
  `achievement_progress` removal before clearing visible achievement progress.
- Failed reset removals keep the previous in-memory progress and persisted JSON
  retryable, instead of exposing an unsaved empty achievement state.
- Focused provider coverage simulates a false `achievement_progress` removal
  and verifies visible progress remains intact.

CL-P1-009FX Lesson completion achievement-stat persistence boundary:

- Lesson completion now awaits the persistent perfect-score profile update
  before achievement checks use the perfect-score count.
- Achievement checks after lesson completion now use the already-persisted
  completed-lesson list and count, rather than adding the current lesson again
  after `completeLesson` has saved it.
- Focused source-contract coverage guards against reintroducing unawaited
  perfect-score saves or duplicate completed-lesson achievement stats.

CL-P1-009FY Tank delete expiry failure feedback:

- Single-tank soft-delete expiry now emits a provider-backed failure event when
  the permanent local delete write fails after the undo window.
- The root app feedback listener shows normal retry feedback from a still-mounted
  shell instead of relying on the popped Tank Detail or Tank Settings route.
- Tank Detail and Tank Settings pass tank-specific retry copy, and focused
  widget coverage verifies failed expiry restores the tank and shows
  `Couldn't delete Retry Reef. Try again.`

CL-P1-009FZ Cost Tracker single-delete rollback:

- Failed single-expense delete writes now defer the visible rollback until the
  next frame, avoiding a dismissed `Dismissible` key reinsert error.
- The failed delete keeps the expense visible, preserves the last durable
  expense JSON, and shows normal retry feedback.
- Focused Cost Tracker widget coverage verifies `Filter` remains visible when
  its swipe-delete persistence fails.

CL-P1-009FL DebugMenu profile-write action boundary:

- DebugMenu now routes profile rewrites for Set XP, Set Streak, Reset Learning,
  Reset Gamification, and Complete All Lessons through a guarded local
  `user_profile` save helper.
- False `user_profile` writes show the existing action-specific error feedback
  instead of invalidating profile state or showing success.
- Focused DebugMenu widget coverage drives each visible action and verifies the
  persisted profile JSON remains unchanged when the local write returns false.

CL-P1-009FM Debug species reset persistence boundary:

- Debug `Reset Species to Defaults` now checks the local
  `unlocked_species_v1` write before invalidating species unlock state or
  showing success.
- False unlock writes show the existing reset-species error feedback and leave
  the previous persisted species JSON unchanged.
- Focused DebugMenu widget coverage drives the visible reset action with a
  false local write.

CL-P1-009FN Debug clear-all preference boundary:

- Debug `Clear All Data` now checks the `SharedPreferences.clear` result before
  telling the user to restart with cleared local state.
- False clear results show normal error feedback and do not show the restart
  success copy.
- Focused DebugMenu widget coverage confirms failed clear results leave the
  existing local preference value in place.

CL-P1-009FO Debug force-SR-cards persistence boundary:

- Debug `Force 10/50 SR Cards Due` now checks the local
  `spaced_repetition_cards` write before invalidating practice state or showing
  due-now success.
- False review-card writes show the existing force-SR error feedback and leave
  the previous persisted review-card JSON unchanged.
- Focused DebugMenu widget coverage drives the visible Force 10 action with a
  false local write.

CL-P1-009FP Settings toggle persistence boundary:

- Settings theme, Phone Notifications, Day/Night Ambiance, and Haptic Feedback
  writes now return explicit durable-save success/failure results instead of
  hiding failed local persistence behind `void` futures.
- Phone Notifications now stops before cancellation side effects or disabled
  success feedback when the `notifications_enabled` save fails.
- Focused provider coverage verifies false preference writes preserve the
  previous settings state, and focused Settings widget coverage verifies a
  failed phone-notification disable keeps the switch on with retry feedback.

CL-P1-009FQ Settings theme-picker persistence boundary:

- The Settings Light/Dark Mode picker now awaits the `theme_mode` save result
  before dismissing the sheet.
- Failed theme writes keep the picker open, preserve the previous local
  `theme_mode` value, and show retry feedback instead of silently closing.
- Focused Settings widget coverage drives the Dark option with a simulated
  failed `theme_mode` write.

CL-P1-009FR Settings ambient/haptic toggle feedback boundary:

- Day/Night Ambiance and Haptic Feedback toggles now await their local
  preference save result before treating the tap as handled.
- Failed `ambient_lighting_enabled` and `haptic_feedback_enabled` writes keep
  the previous switch value and show retry feedback instead of failing
  silently.
- Focused Settings widget coverage drives both toggles with simulated false
  local writes.

CL-P1-009FS Reminder Settings toggle persistence boundary:

- Reminder Settings review and streak reminder toggles now catch failed
  `user_profile` writes before scheduling notification changes or showing
  enabled/disabled success feedback.
- Failed reminder-toggle writes preserve the previous switch value, keep the
  previous persisted profile JSON, and show retry feedback instead of leaking
  an async error.
- Focused NotificationSettings widget coverage drives both toggles with
  simulated false local `user_profile` writes.

CL-P1-009FT Reminder intensity persistence boundary:

- Reminder Settings intensity presets now catch failed `user_profile` writes
  before scheduling notification changes or showing preset-selected feedback.
- Failed intensity writes keep the picker open, preserve the previous persisted
  profile JSON, and show retry feedback instead of leaking an async error.
- Focused NotificationSettings widget coverage drives the Quiet preset with a
  simulated false local `user_profile` write.

CL-P1-009FU Reminder time persistence boundary:

- Reminder Settings time edits now catch failed `user_profile` writes before
  rescheduling streak notifications or showing updated-time feedback.
- Failed time writes preserve the previous persisted profile JSON and visible
  reminder time, then show retry feedback instead of leaking an async error.
- Focused NotificationSettings widget coverage drives the Morning Reminder
  time picker with a simulated false local `user_profile` write.

CL-P1-009FV Preferences setup-context persistence boundary:

- Preferences region, tank-stage, experience-level, and goals edits now await
  `user_profile` writes before closing their pickers.
- Failed setup-context writes keep the relevant picker open, preserve the
  previous persisted profile JSON, and show retry feedback instead of leaking
  an async error or exposing false profile changes.
- Focused Settings widget coverage drives a failed Region save and failed Goals
  save with simulated false local `user_profile` writes.

CL-P1-009GI Root lifecycle gem detached flush:

- The root app lifecycle handler now includes `AppLifecycleState.detached` in
  the pending gem flush condition.
- Pending debounced `gems_state` writes now call
  `GemsNotifier.flushPendingWrite()` on detach as well as pause/inactive,
  covering app-kill paths before the debounce timer can be skipped.
- Focused source-contract coverage verifies the lifecycle handler keeps paused,
  inactive, detached, and `flushPendingWrite()` together.

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

CL-P1-010H Optional AI privacy route:

- Preferences > Smart Hub > Optional AI now includes a direct `Review AI
  privacy` action inside the setup dialog.
- The action opens the existing Privacy Policy screen from the point where
  users decide whether to add a custom key or review Optional AI data handling.
- Focused widget coverage verifies the Optional AI dialog routes directly to
  the local Privacy Policy screen.

CL-P1-010I Preferences Units save-failure feedback:

- The Units picker now waits for the local `use_metric` preference write before
  closing, so failed saves do not look successful.
- Failed unit preference saves keep the picker open, leave the current unit
  selection unchanged, and show normal retry feedback.
- Focused widget coverage simulates a failed `use_metric` write and verifies
  the picker stays open with retry feedback.

CL-P1-010J Smart setup-context nudge contrast:

- The Smart setup-context nudge now uses explicit light-card text tokens for
  its title and body copy instead of inheriting surrounding Smart-screen text
  color.
- Focused widget coverage verifies the nudge title/body colors and contrast
  against the light setup-card surface.

CL-P1-010K Optional AI disclosure reset write-result handling:

- Optional AI disclosure acceptance/reset now treats failed local
  `SharedPreferences` write/remove return values as real preference failures.
- Preferences > Smart Hub > Optional AI now opens the dialog with the shared
  preferences provider, so the same local failure handling is used by app code
  and widget tests.
- Failed disclosure reset attempts keep the accepted status visible, keep the
  saved local flag intact, and show normal retry feedback instead of reporting
  that the disclosure will be shown again.
- Focused widget coverage simulates a failed disclosure-reset remove result and
  verifies the accepted state and retry feedback.

CL-P3-001A Optional AI provider setup boundary:

- Preferences > Smart Hub > Optional AI now shows a provider-status section
  instead of presenting the setup as an unexplained OpenAI-only key field.
- OpenAI is labelled as the recommended current bring-your-own key provider.
- Anthropic, Google Gemini, OpenRouter, and Mistral are named as provider
  targets, but are explicitly marked as not available for local keys in this
  version so the UI does not pretend unsupported connectors work.
- `AppDialog` now constrains tall dialog content and flexes the body above fixed
  action buttons, so richer settings dialogs scroll instead of overflowing.
- Focused widget coverage verifies the provider-status copy and catches the
  Optional AI dialog overflow regression.

CL-P3-001B OpenAI release key policy:

- `AiProxyService` now treats build-time `OPENAI_API_KEY` as a
  local-development-only fallback and returns no build-time direct key in
  release builds.
- `OpenAIService` no longer reads the build-time OpenAI key directly, so the
  release-key policy stays centralized at the proxy/direct-key boundary.
- Focused service coverage verifies the release guard source contract, proxy
  routing, direct dev fallback routing, and missing-proxy-auth failure path.

SEC-2026-07-04-012 Optional AI Privacy Policy scope:

- The in-app Privacy Policy now names Fish ID photos, symptom descriptions,
  stocking or compatibility requests, and weekly-plan tank context as current
  Optional AI request data that can leave the device after disclosure.
- The OpenAI retention/training copy now follows the current API data-controls
  boundary: API inputs and outputs may be retained for abuse monitoring for up
  to 30 days unless longer retention is legally required, and API data is not
  used for model training unless the API account explicitly opts in.
- Focused widget/source coverage prevents the old Fish-ID-only policy copy from
  returning.

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

### CL-P1-011B Search Entry Points And Android Walkthrough

- The Tank top bar and More hub now open global Search through
  `AppRoutes.toSearch`, so search is available as a contextual feature instead
  of a bottom navigation tab.
- The Tank top-bar Search button keeps the same 48dp tap-target guardrail as
  Emergency Guide, Tank Toolbox, and Tank Settings, with `Search` tooltip and
  semantics.
- The More hub now includes a Search tile under Tank Tools with the normal-user
  subtitle `Find tanks, fish, guides, and logs`.
- Focused widget and layout coverage verifies More-to-Search navigation,
  Tank-top-bar navigation, and phone/tablet/large-text top-bar visibility.
- Android evidence under
  `docs/qa/screenshots/2026-06-22/cl-p1-011-global-search/` covers phone More
  entry with sample tank/log results and tablet Tank top-bar entry with Backup
  & Restore app results.

### CL-P1-011C Direct Lesson Search

- Global search now loads the real local lesson catalog for non-empty search
  queries and adds direct lesson results alongside path-level Learning results.
- Lesson results search lesson title, description, ID, guide scenario,
  outcomes, care drills, and body section text, then open the matching
  `LessonScreen` directly with the correct path title.
- The lesson search index is read-only and independent of live lesson-provider
  state, so searching cannot mutate the current Learn screen loading/progress
  state.
- Focused widget coverage verifies searching for `Why New Tanks Kill Fish`
  surfaces a Lessons result and opens that lesson directly.

### CL-P1-012A Resettable Sample Tank

- Settings now presents the sample-tank action as `Reset Sample Tank` and tells
  users it replaces demo data without touching real tanks.
- `TankActions.addDemoTank()` now removes only existing `isDemoTank` records
  before creating a fresh populated sample tank, so onboarding, empty-state, and
  Settings flows cannot pile up duplicate demo tanks.
- Focused provider coverage verifies existing demo tanks are replaced while a
  real user tank remains in storage.

### CL-P1-012B Final Android Demo-Mode Screen QA

- Final phone and tablet Android evidence is captured under
  `docs/qa/screenshots/2026-06-22/cl-p1-012-demo-mode/`.
- The Preferences flow exposes `Reset Sample Tank` with the explanatory copy
  `Replaces demo data without touching your real tanks` on both phone and
  tablet.
- Tapping the action opens the populated `Sample Tank` detail screen with the
  demo banner, 18 fish, 3 equipment items, 120L volume, tank-health score, quick
  actions, and latest water snapshot visible and accessible.
- The captured phone and tablet result screens show no obvious visual overflow
  in the above-the-fold demo experience.

### CL-P2-002A Workshop Adaptive Tablet Grid

- Workshop no longer uses a fixed two-column phone grid on every screen size.
  The tool grid now keeps two columns on compact phone widths, expands to
  bounded three-column tablet portrait layouts, and uses a bounded multi-column
  tablet landscape layout so calculator cards do not stretch across the display.
- Tool cards use tighter icon-to-copy spacing so phone-sized large text avoids
  vertical RenderFlex overflow without suppressing layout errors.
- Focused widget coverage verifies phone overflow safety, phone large-text
  safety, Android gesture-navigation inset clearance, tablet portrait bounded
  card widths, and tablet landscape bounded first-row columns.

### CL-P2-002B Lesson Reader Tablet Readability

- Lesson reader content now uses a centered readable frame on wide tablet
  surfaces instead of stretching headings, guide cards, sections, and the
  primary lesson action across the full display.
- Lesson quiz progress, question text, answer options, explanations, and the
  fixed quiz action now use the same readable tablet width.
- Focused widget coverage verifies the lesson reader and quiz primary actions
  stay at or below the established 720px tablet readability bound on a
  2000x1200 tablet viewport.

### CL-P2-002C Learn Hub Tablet Readability

- Learn keeps the illustrated study-room header full-bleed, but centers the
  actual learning hub content in a readable 720px rail on wide tablet surfaces.
- The readable rail now wraps the next-lesson card, review handoff, streak
  surfaces, stories card, learning progress copy, loading skeleton cards, and
  learning path cards instead of stretching phone-card layouts across the full
  display.
- Focused widget coverage verifies the next-lesson card, stories card, and
  first learning path card stay at or below the 720px tablet readability bound
  on a 2000x1200 tablet viewport.

### CL-P2-002D Smart Hub Tablet Readability

- Smart keeps the illustrated Smart header full-bleed, but centers local
  intelligence, setup, optional AI, emergency, anomaly, and compatibility
  surfaces in a readable 720px rail on wide tablet surfaces.
- The readable rail is applied at the Smart content-list level so future Smart
  feature cards inherit the tablet guardrail without each card hand-rolling its
  own constraints.
- Focused widget coverage verifies the local Aquarium Intelligence card and
  Emergency Guide card stay at or below the 720px tablet readability bound on a
  2000x1200 tablet viewport.

### CL-P2-002E Species And Plant Guide Tablet Readability

- Fish Database and Plant Database now center search, filter, results-count,
  empty-state, and list-card surfaces in a readable 720px rail on wide tablet
  surfaces instead of stretching phone list cards across the full display.
- Fish and plant detail sheets now constrain their guide content to the same
  readable rail while keeping the modal sheet behavior unchanged.
- Focused widget coverage verifies representative browser cards and Care
  Actions detail cards stay at or below the 720px tablet readability bound on a
  2000x1200 tablet viewport.

### CL-P2-002F Timeline And Log Tablet Readability

- Tank Journal now centers timeline month sections, entry cards, and the new
  journal-entry sheet in a readable 720px rail on wide tablet surfaces.
- Activity Log now centers its filter summary, loaded row cards, and skeleton
  row placeholders in the same readable tablet rail.
- Log Detail now centers its detail content rail so narrow cards no longer sit
  against the left edge on tablet landscape.
- Focused widget coverage verifies representative Journal, Activity Log, and
  Log Detail cards stay readable and centered on a 2000x1200 tablet viewport.

### CL-P2-002G Livestock Tablet Readability

- Livestock now centers the summary card, selection banner, livestock row
  cards, skeleton placeholders, and select-mode bulk-action controls in a
  readable 720px rail on wide tablet surfaces.
- The bottom bulk-action bar keeps its full-width anchored surface while
  constraining the actual controls for readable tablet ergonomics.
- Focused widget coverage verifies representative summary and livestock cards
  stay at or below the 720px tablet readability bound on a 2000x1200 tablet
  viewport.

### CL-P2-002H Tasks And Maintenance Tablet Readability

- Tasks now centers section headers and task cards in the same readable 720px
  rail on wide tablet surfaces.
- Maintenance Checklist now centers its progress summary, section headers, and
  checklist cards in the readable tablet rail while keeping the existing care
  checklist behavior unchanged.
- Focused widget coverage verifies representative Tasks and Maintenance
  surfaces stay at or below the 720px tablet readability bound on a 2000x1200
  tablet viewport.

### CL-P2-002I Equipment Tablet Readability

- Equipment now centers loading skeleton cards, overdue-maintenance warnings,
  and equipment cards in the same readable 720px rail on wide tablet surfaces.
- Existing equipment add, service, history, remove, undo, and maintenance-task
  behavior remains unchanged.
- Focused widget coverage verifies representative Equipment loading, warning,
  and row-card surfaces stay at or below the 720px tablet readability bound on
  a 2000x1200 tablet viewport.

### CL-P2-002J Water Change Calculator Tablet Readability

- Water Change Calculator now centers its intro, nitrate inputs, result,
  recommendation, guided-log, quick-reference, and strategy surfaces in the
  same readable 720px rail on wide tablet surfaces.
- Existing nitrate calculation and prefilled water-change log navigation remain
  unchanged.
- Focused widget coverage verifies representative intro, result, and guided-log
  cards stay at or below the 720px tablet readability bound on a 2000x1200
  tablet viewport.

### CL-P2-002K Cycling Assistant Tablet Readability

- Cycling Assistant now centers its phase header, guided next step, cycle
  diagram, parameter timeline, education, action items, and completion
  celebration in the same readable 720px rail on wide tablet surfaces.
- Existing phase detection, water-test navigation, and cycling-reminder
  creation remain unchanged.
- Focused widget coverage verifies representative phase, guided-action, and
  diagram cards stay at or below the 720px tablet readability bound on a
  2000x1200 tablet viewport.

### CL-P2-002L Compatibility Checker Tablet Readability

- Compatibility Checker now centers the search field, search results, empty
  guidance, selected-species chips, verdict, issues, recommended setup, and
  guided-log card in the same readable 720px rail on wide tablet surfaces.
- Existing species search, compatibility verdicts, tank-size warnings, and
  observation-log navigation remain unchanged.
- Focused widget coverage verifies representative search and empty-guidance
  surfaces stay at or below the 720px tablet readability bound on a 2000x1200
  tablet viewport.

### CL-P2-002M Lighting Schedule Tablet Readability

- Lighting Schedule now centers setup, schedule, timeline, recommendation,
  guided-log, quick-guide, and CO2 timing content in the same readable 720px
  rail on wide tablet surfaces.
- Existing lighting-duration calculations, siesta overlap handling,
  recommendation copy, and journal handoff remain unchanged.
- Focused widget coverage verifies representative intro, setup, and timeline
  cards stay at or below the 720px tablet readability bound on a 2000x1200
  tablet viewport.

### CL-P2-002N Dosing Calculator Tablet Readability

- Dosing Calculator now centers medication-safety copy, tank-volume and dose
  inputs, validation and empty prompts, calculated result, guided-log card, and
  liquid-product presets in the same readable 720px rail on wide tablet
  surfaces.
- Existing liquid-product safety copy, dose calculations, product presets, and
  journal handoff remain unchanged.
- Focused widget coverage verifies representative input, empty prompt, and
  result card surfaces stay at or below the 720px tablet readability bound on a
  2000x1200 tablet viewport.

### CL-P2-002O CO2 Calculator Tablet Readability

- CO2 Calculator now centers intro guidance, pH/KH inputs, validation copy,
  result card, guided-log card, reference chart, drop-checker guide, tips, and
  pH/KH table in the same readable 720px rail on wide tablet surfaces.
- Existing CO2 calculation, validation bounds, result status copy, reference
  data, and journal handoff remain unchanged.
- Focused widget coverage verifies representative input, result, and reference
  card surfaces stay at or below the 720px tablet readability bound on a
  2000x1200 tablet viewport.

### CL-P2-002P Tank Volume Calculator Tablet Readability

- Tank Volume Calculator now centers unit selection, shape chips, dimension
  inputs, empty and calculated result cards, tank-profile apply guidance, and
  tips in the same readable 720px rail on wide tablet surfaces.
- Existing volume calculations, unit conversion, shape selection, and local
  tank-profile apply behavior remain unchanged.
- Focused widget coverage verifies representative dimension input, empty
  prompt, and calculated result surfaces stay at or below the 720px tablet
  readability bound on a 2000x1200 tablet viewport.

### CL-P2-002Q Stocking Calculator Tablet Readability

- Stocking Calculator now centers tank setup, validation copy, stocking meter,
  species search, search results, selected-stock rows, advice, and guided-log
  content in the same readable 720px rail on wide tablet surfaces.
- Existing stocking calculations, species search, count controls, validation,
  advice copy, and journal handoff remain unchanged.
- Focused widget coverage verifies representative setup, meter, and search
  surfaces stay at or below the 720px tablet readability bound on a 2000x1200
  tablet viewport.

### CL-P2-002R Unit Converter Tablet Readability

- Unit Converter now centers aquarium-use guidance, input rows, conversion
  result cards, and hardness reference content in the same readable 720px rail
  across Volume, Temperature, Length, and Hardness tabs on wide tablet
  surfaces.
- Existing conversion formulas, tab navigation, plain unit labels, and
  aquarium-use guidance remain unchanged.
- Focused widget coverage verifies representative input and conversion-result
  card surfaces stay at or below the 720px tablet readability bound on a
  2000x1200 tablet viewport.

### CL-P2-002S Cost Tracker Tablet Readability

- Cost Tracker now centers the empty state, summary cards, category breakdown,
  and expense tiles in the same readable 720px rail on wide tablet surfaces.
- Existing local expense persistence, currency settings, add/delete/clear/undo
  flows, category breakdown, and feedback copy remain unchanged.
- Focused widget coverage verifies representative summary and expense card
  surfaces stay at or below the 720px tablet readability bound on a 2000x1200
  tablet viewport.

### CL-P2-002T Acclimation Guide Tablet Readability

- Acclimation Guide now centers intro guidance, method headings, step cards,
  tip cards, and sensitive-species guidance in the same readable 720px rail on
  wide tablet surfaces.
- Existing acclimation guidance, timing copy, method ordering, and iconography
  remain unchanged.
- Focused widget coverage verifies representative intro and step card surfaces
  stay at or below the 720px tablet readability bound on a 2000x1200 tablet
  viewport.

### CL-P2-002U Feeding Guide Tablet Readability

- Feeding Guide now centers the golden-rule intro, feeding frequency rows,
  food-type cards, common-mistake guidance, and fasting guidance in the same
  readable 720px rail on wide tablet surfaces.
- Existing feeding guidance, frequency labels, food-type pros/cons, mistakes,
  and fasting copy remain unchanged.
- Focused widget coverage verifies representative intro and frequency card
  surfaces stay at or below the 720px tablet readability bound on a 2000x1200
  tablet viewport.

### CL-P2-002V Emergency Guide Tablet Readability

- Emergency Guide now centers the quick-reference intro, emergency expansion
  cards, and emergency-kit checklist in the same readable 720px rail on wide
  tablet surfaces.
- Existing urgency labels, emergency actions, follow-up advice, and kit
  checklist copy remain unchanged.
- Focused widget coverage verifies representative intro and emergency card
  surfaces stay at or below the 720px tablet readability bound on a 2000x1200
  tablet viewport.

### CL-P2-002W Quarantine Guide Tablet Readability

- Quarantine Guide now centers the why-quarantine intro, setup cards, protocol
  steps, symptom table, medication cards, and tips in the same readable 720px
  rail on wide tablet surfaces.
- Existing quarantine guidance, medication copy, setup checklist, protocol
  ordering, and symptom mapping remain unchanged.
- Focused widget coverage verifies representative intro and setup card surfaces
  stay at or below the 720px tablet readability bound on a 2000x1200 tablet
  viewport.

### CL-P2-002X Disease Guide Tablet Readability

- Disease Guide now centers search, educational-vet-substitute disclaimer,
  disease cards, and expanded symptom/treatment/prevention content in the same
  readable 720px rail on wide tablet surfaces.
- Existing disease names, symptom matching, treatment guidance, prevention
  copy, search debounce behavior, and contagious status labels remain
  unchanged.
- Focused widget coverage verifies representative search, disclaimer, and
  disease card surfaces stay at or below the 720px tablet readability bound on
  a 2000x1200 tablet viewport.

### CL-P2-002Y Parameter Guide Tablet Readability

- Parameter Guide now centers its intro, water-parameter cards, expanded tips,
  and quick-reference card in the same readable 720px rail on wide tablet
  surfaces.
- Chemistry labels and temperature copy are now source-safe ASCII text, and the
  pH raising tip now names crushed coral instead of the previous typo.
- Focused widget coverage verifies representative intro, parameter-card, and
  quick-reference surfaces stay at or below the 720px tablet readability bound
  on a 2000x1200 tablet viewport.

### CL-P2-002Z Equipment Guide Tablet Readability

- Equipment Guide now centers category headers, equipment cards, and expanded
  pros/cons/maintenance content in the same readable 720px rail on wide tablet
  surfaces.
- Existing equipment categories, card order, expansion behavior, and care
  guidance remain unchanged.
- Focused widget coverage verifies representative filtration and heating cards
  stay at or below the 720px tablet readability bound on a 2000x1200 tablet
  viewport.

### CL-P2-002AA Algae Guide Tablet Readability

- Algae Guide now centers its intro card, algae cards, algae-eating crew cards,
  section headings, and prevention checklist in the same readable 720px rail on
  wide tablet surfaces.
- Existing algae type data, crew guidance, prevention checklist content, and
  expansion behavior remain unchanged.
- Focused widget coverage verifies representative intro, algae-card, crew-card,
  and checklist-card surfaces stay at or below the 720px tablet readability
  bound on a 2000x1200 tablet viewport.

### CL-P2-002AB Breeding Guide Tablet Readability

- Breeding Guide now centers intro, method cards, conditioning guidance,
  fry-stage cards, easy-breeder rows, and the pre-breeding warning card in the
  same readable 720px rail on wide tablet surfaces.
- Temperature, fry-feeding/care, and warning copy are now source-safe ASCII
  text while preserving the existing breeding guidance.
- Focused widget coverage verifies representative intro, method, conditioning,
  fry-stage, and warning surfaces stay at or below the 720px tablet readability
  bound on a 2000x1200 tablet viewport.

### CL-P2-002AC Vacation Guide Tablet Readability

- Vacation Guide now centers intro, duration guidance, departure checklists,
  feeding-option cards, sitter guidance, extended-absence guidance, and return
  steps in the same readable 720px rail on wide tablet surfaces.
- Option pros/cons and sitter bullet rows now use source-safe ASCII bullet copy
  while preserving the existing vacation care guidance.
- Focused widget coverage verifies representative intro, duration, checklist,
  feeding-option, and return-step surfaces stay at or below the 720px tablet
  readability bound on a 2000x1200 tablet viewport.

### CL-P2-002AD Quick Start Guide Tablet Readability

- Quick Start Guide now centers the hero card, step cards, cycle warning
  guidance, and common beginner mistake card in the same readable 720px rail on
  wide tablet surfaces.
- Bullet prefixes and mistake-result separators now use source-safe ASCII copy
  while preserving the existing beginner setup guidance.
- Focused widget coverage verifies representative hero, step, cycle, and
  mistake surfaces stay at or below the 720px tablet readability bound on a
  2000x1200 tablet viewport.

### CL-P2-002AE Nitrogen Cycle Guide Tablet Readability

- Nitrogen Cycle Guide now centers intro, cycle-stage, cycling-method,
  completion-check, and tip surfaces in the same readable 720px rail on wide
  tablet surfaces.
- Chemistry labels, bacteria-temperature guidance, and method pros/cons now use
  source-safe ASCII copy while preserving the existing cycling guidance.
- Focused widget coverage verifies representative intro, stage, method,
  completion, and tip surfaces stay at or below the 720px tablet readability
  bound on a 2000x1200 tablet viewport.

### CL-P2-002AF Substrate Guide Tablet Readability

- Substrate Guide now centers intro, substrate-card, tank-type, layering, and
  pro-tip surfaces in the same readable 720px rail on wide tablet surfaces.
- Expanded substrate pros/cons and the amount formula now use source-safe ASCII
  copy while preserving the existing substrate guidance.
- Focused widget coverage verifies representative intro, substrate, tank-type,
  layering, and pro-tip surfaces stay at or below the 720px tablet readability
  bound on a 2000x1200 tablet viewport.

### CL-P2-002AG Hardscape Guide Tablet Readability

- Hardscape Guide now centers intro, rock-card, wood-card, preparation,
  design-tip, and safety-note surfaces in the same readable 720px rail on wide
  tablet surfaces.
- Safety-note bullets now use source-safe ASCII copy while preserving the
  existing hardscape safety guidance.
- Focused widget coverage verifies representative intro, rock, wood,
  preparation, design-tip, and safety-note surfaces stay at or below the 720px
  tablet readability bound on a 2000x1200 tablet viewport.

### CL-P2-002AH Backup And Restore Tablet Readability

- Backup & Restore now centers intro, export, import, exported-item, recovery,
  and import-safety surfaces in the same readable 720px rail on wide tablet
  surfaces.
- The local ZIP backup and import-safety copy remains unchanged and source-safe
  while the page no longer stretches operational cards across wide tablet
  layouts.
- Focused widget coverage verifies representative intro, export, import,
  exported-item, and import-safety surfaces stay at or below the 720px tablet
  readability bound on a 2000x1200 tablet viewport.

### CL-P2-002AI Account Tablet Readability

- Account now centers offline-local, signed-out, and signed-in account surfaces
  in the same readable 720px rail on wide tablet surfaces.
- Optional cloud backup success copy now stays ASCII-safe while preserving the
  local-first account boundary and offline data message.
- Focused widget coverage verifies the offline-local account explanation stays
  at or below the 720px tablet readability bound on a 2000x1200 tablet
  viewport, and source coverage keeps Account copy ASCII-safe.

### CL-P2-002AJ Achievements Tablet Gallery

- Achievements now keeps the progress header and filter controls in a readable
  720px rail while preserving the full-width trophy-case gradient band.
- The trophy grid now uses a centered bounded grid with adaptive tablet columns
  so achievement cards do not stretch into oversized phone-card layouts.
- Focused widget coverage verifies the progress bar stays at or below 720px
  and representative trophy cards stay at or below 340px on a 2000x1200 tablet
  viewport, with source coverage keeping Achievements copy ASCII-safe.

### CL-P2-002AK Inventory Rewards Tablet Layout

- Inventory consumable and active item grids now use a centered bounded
  adaptive tablet grid so owned-item cards do not stretch across wide screens.
- Permanent room-vibe, tank-decoration, and keepsake collections now keep the
  existing horizontal scroller behavior on narrow surfaces while switching to
  wrapped bounded collections on wide tablet surfaces.
- Focused widget coverage verifies consumable item cards stay at or below 340px
  on a 2000x1200 tablet viewport and that permanent reward collections do not
  require sideways scrolling on that tablet layout.

### CL-P2-002AL Gem Shop Tablet Grid

- Gem Shop category grids now use a centered bounded adaptive tablet layout so
  product cards do not stretch into oversized two-column phone-card layouts on
  wide screens.
- Phone and compact surfaces keep the existing two-column shop behavior, with a
  single-column fallback for very narrow surfaces.
- Focused widget coverage verifies representative shop item cards stay at or
  below 360px on a 2000x1200 tablet viewport.

### CL-P2-002AM Shop Street Tablet Rail

- Shop Street now centers its header, wishlist entry points, budget summary,
  and local-shop planning card in the same 720px readable tablet rail.
- Compact phone surfaces keep the existing vertical card sequence and local
  planning behaviour.
- Focused widget coverage verifies representative shopping and budget surfaces
  start inside the centered tablet rail on a 2000x1200 tablet viewport.

### CL-P2-002AN Wishlist Tablet Cards

- Wishlist saved-item lists now use a centered 720px readable tablet rail so
  individual fish, plant, and equipment wishlist cards do not stretch across
  wide screens.
- Compact phone surfaces keep the existing vertical list padding and item-card
  behaviour.
- Focused widget coverage verifies a representative wishlist item card stays at
  or below 720px on a 2000x1200 tablet viewport.

### CL-P2-002AO About Tablet Readability

- About now centers app identity, feature rows, community copy, and policy
  actions in a 720px readable tablet rail.
- Compact phone surfaces keep the existing centered vertical About layout.
- Focused widget coverage verifies representative feature content starts inside
  the centered tablet rail on a 2000x1200 tablet viewport.

### CL-P2-002AP FAQ Tablet Readability

- FAQ now uses a centered 720px readable tablet rail so question cards and
  expanded answer copy do not stretch across wide screens.
- Compact phone surfaces keep the existing vertical FAQ list padding.
- Focused widget coverage verifies a representative FAQ card stays at or below
  720px on a 2000x1200 tablet viewport.

### CL-P2-002AQ Privacy Policy Tablet Readability

- Privacy Policy now centers the header, summary, legal sections, data-rights
  cards, and contact card in a 720px readable tablet rail.
- Compact phone surfaces keep the existing vertical policy layout.
- Focused widget coverage verifies representative policy header content starts
  inside the centered tablet rail on a 2000x1200 tablet viewport.

### CL-P2-002AR Terms of Service Tablet Readability

- Terms of Service now centers the legal summary sections, action buttons, and
  agreement notice in a 720px readable tablet rail.
- Compact phone surfaces keep the existing vertical terms layout.
- Focused widget coverage verifies representative terms section content starts
  inside the centered tablet rail on a 2000x1200 tablet viewport.

### CL-P2-002AS Glossary Tablet Readability

- Glossary now centers the search field, category chips, term count, and term
  cards in a 720px readable tablet rail.
- Compact phone surfaces keep the existing glossary list and horizontal filter
  behavior.
- Focused widget coverage verifies representative glossary cards stay at or
  below 720px on a 2000x1200 tablet viewport.

### CL-P2-002AT Settings Hub Tablet Readability

- Settings Hub now centers profile, section header, destination tile, and footer
  list items in a 720px readable tablet rail.
- Compact phone surfaces keep the existing More hub vertical list behavior.
- Focused widget coverage verifies representative More destination tiles stay at
  or below 720px on a 2000x1200 tablet viewport.

### CL-P2-002AU Reminders Tablet Readability

- Reminders now centers overdue/upcoming section headers and reminder cards in a
  720px readable tablet rail.
- Compact phone surfaces keep the existing reminder list, dock-cleared FAB, and
  swipe-dismiss behavior.
- Focused widget coverage verifies representative reminder cards stay at or
  below 720px on a 2000x1200 tablet viewport.

### CL-P2-002AV Search Results Tablet Readability

- Search now centers result section headers, spacers, and destination/result
  cards in a 720px readable tablet rail.
- Compact phone surfaces keep the existing vertical search result list behavior.
- Focused widget coverage verifies representative search result cards stay at or
  below 720px on a 2000x1200 tablet viewport.

### CL-P2-002AW Charts Tablet Readability

- Water Charts now centers parameter chips, chart controls, alerts, chart area,
  summary card, and recent values table in a 720px readable tablet rail.
- Compact phone surfaces keep the existing vertical chart workflow and
  horizontal parameter chip scrolling.
- Focused widget coverage verifies representative chart cards stay at or below
  720px on a 2000x1200 tablet viewport.

### CL-P2-002AX Analytics Tablet Readability

- Analytics now centers loading skeletons, time range chips, overview stats,
  charts, insights, topic breakdown, and prediction surfaces in a 720px
  readable tablet rail.
- Compact phone surfaces keep the existing vertical analytics dashboard flow.
- Focused widget coverage verifies representative loading skeleton and stat
  cards stay at or below 720px on a 2000x1200 tablet viewport.

### CL-P2-002AY Livestock Detail Tablet Readability

- Livestock Detail now centers header, compatibility, care guide, parameter,
  tankmate, and missing-species cards in a 720px readable tablet rail.
- Compact phone surfaces keep the existing vertical livestock detail flow.
- Focused widget coverage verifies representative livestock detail cards stay
  at or below 720px on a 2000x1200 tablet viewport.

### CL-P0-004E Tablet first-run consent layout

- A dedicated local `danio_tablet_api36` AVD now exists for tablet QA without
  reusing the other app's emulator.
- The first-run privacy consent screen now constrains its main content to a
  readable tablet width instead of stretching copy and buttons across the full
  landscape display.
- Focused widget coverage verifies the privacy explanation width at a
  2000x1200 tablet viewport.

### CL-P0-004F Tablet first-run onboarding frame

- Added a shared first-run onboarding content frame so reading/CTA surfaces do
  not stretch across the full tablet width.
- Applied the frame to Welcome, Region/Units, Experience Level, Tank Status,
  Goals, Micro Lesson, XP Celebration, Aha Moment final reveal, Feature Summary,
  Reminder setup, and Warm Entry.
- Focused widget coverage verifies the primary readable/control width for these
  screens at a 2000x1200 tablet viewport.
- Remaining first-run visual QA should still inspect Fish Select grid/search and
  the full phone/tablet walkthrough on real Android surfaces.

### CL-P0-005D Tank daily-loop layout guardrails

- Added focused Home/Tank layout tests that do not suppress Flutter overflow
  diagnostics.
- The guardrails cover Android phone, tablet portrait, tablet landscape, and
  larger-text phone surfaces for the central Tank daily surface.
- Tank top-bar Emergency, Toolbox, and Settings controls now keep explicit
  48dp minimum hit targets even when compact theme density is active.
- Remaining Tank daily-loop work is still final Android phone/tablet visual QA
  against the live app surface.

### CL-P0-004G Fish Select tablet layout

- Fish Select now keeps header/search and search-result cards within the shared
  readable onboarding frame on tablet.
- Popular fish choices still use the broader tablet surface, but the grid now
  adapts into compact multi-column tiles instead of stretching three oversized
  cards across landscape displays.
- Focused widget coverage verifies tablet search width, compact popular-tile
  width, and readable confirm CTA width after a selection.
- Remaining first-run work is live Android phone/tablet walkthrough evidence,
  not a known Fish Select layout blocker.

### CL-P0-004H Final Android first-run walkthrough

- Tablet walkthrough evidence is captured under
  `docs/qa/screenshots/2026-06-22/cl-p0-004-first-run/` as
  `tablet-01-welcome` through `tablet-07-tank-landing`.
- Phone walkthrough evidence is captured in the same folder from an isolated
  disposable `danio_phone_firstrun_api36` AVD so the active live-preview phone
  and tablet states were not reset.
- The phone sequence covers consent, Welcome, Region/Units, Experience Level,
  Tank Status, Goals, Micro Lesson, XP Celebration, Fish Select grid,
  Fish Select confirmation, Betta profile, Feature Summary, optional reminders,
  Warm Entry, and the final Tank landing.
- Final phone landing opens on the Tank tab with the onboarding-created
  `Betta Paradise` tank, visible fish, plants, earned energy, and local action
  controls.
- CL-P0-004 is now closed for complete-local scope; future onboarding findings
  should be filed as follow-up polish, not as remaining P0 first-run work.

### CL-P0-005E Final Tank daily-loop Android visual QA

- Phone and tablet Today Board evidence is captured under
  `docs/qa/screenshots/2026-06-22/cl-p0-005-tank-daily-loop/`.
- The final phone evidence is
  `phone-02-today-panel-after-contrast-fix`, showing readable Today Board
  cards after the dark Tank contrast fix.
- The final tablet evidence is
  `tablet-02-today-panel-after-semantics-fix`, showing the tablet Tank daily
  loop after quick-care semantics were exposed to Android.
- Focused widget tests, `flutter analyze`, the Focused gate, and the Visual
  gate passed for the Tank daily-loop slice before this evidence was committed.
- CL-P0-005 is now closed for complete-local scope; broader living-tank states
  and seasonal/plant/decor depth remain tracked under P1 work.

Current Android device state:

- ADB previously saw `RFCY8022D5R` as `unauthorized`.
- The dedicated `danio_api36` phone emulator is attached as `emulator-5554` and
  is foregrounding `com.tiarnanlarkin.danio` for local live preview.
- The dedicated `danio_tablet_api36` tablet emulator is attached as
  `emulator-5556` and is foregrounding `com.tiarnanlarkin.danio` for tablet
  QA.
- A disposable `danio_phone_firstrun_api36` AVD was used only for fresh phone
  first-run evidence so the live-preview devices were not reset.

## 5. Current Complete-Local Gap Map

P0 status:

| ID | State | Notes |
| --- | --- | --- |
| CL-P0-001 | Done | Returning users now land on Tank by default. |
| CL-P0-002 | Done | Canonical docs now point at complete-local as the active finish line. |
| CL-P0-003 | Done | Local/offline account copy, optional account/cloud backup copy, account-keyed backup encryption copy, optional cloud account failure copy, signed-in account cloud-data copy, weekly-progress tier copy, returning-user milestone upgrade wording, age-blocked account-setup wording, generic server-error wording, onboarding feature-summary paywall-stub/subscription wording, settings data feedback copy, bulk livestock feedback copy, reward/shop honesty, Shop Street planning copy, Privacy local-build/local-version copy, Optional AI privacy-policy request-scope copy, Delete My Data privacy/help copy, stale social comments, visible debug crash controls, debug sync shell diagnostics, dead sync-status scaffolds, dormant backend-sync queue code, dormant social reward/referral mechanics, unsupported marine setup choices/scope copy, legacy marine profile copy, Optional AI server-config/setup/version copy, Smart optional-AI copy, and current README/registry/data-resilience docs honesty fixed and tested. Future walkthrough findings should be filed against their feature area. |
| CL-P0-004 | Done | First-run now captures region/units, experience, tank stage, goals, quick-start sample handoff, setup-context repair prompts, tablet-constrained reading/CTA surfaces, adaptive Fish Select, and final Android phone/tablet walkthrough evidence under `docs/qa/screenshots/2026-06-22/cl-p0-004-first-run/`. |
| CL-P0-005 | Done | Tank now acts as the daily ritual surface with care priority, next-best action, direct feeding feedback, visible Today Board quick care, phone/tablet layout guardrails, Android quick-care semantics, readable dark Tank contrast, and final phone/tablet visual QA under `docs/qa/screenshots/2026-06-22/cl-p0-005-tank-daily-loop/`. |
| CL-P0-006 | Done | Emergency Guide is now directly reachable from Tank top bar, unsafe-water Tank alerts, Smart Hub, global search, More, LessonScreen, species detail sheets, and unsafe water-test save flows. |
| CL-P0-007 | Done | Smart now works as a no-AI Aquarium Intelligence hub: local rules surface risks, suggestions, compatibility signals, care-plan actions, anomaly history, equipment maintenance, and checked reasons, with a full review screen and action routes. Richer per-tank/save-apply depth belongs to P1 guided workflows. |

High-confidence P1/P2 gaps from code/docs evidence:

- Optional AI setup now names the provider boundary, with OpenAI as the current
  recommended bring-your-own key provider and Anthropic, Google Gemini,
  OpenRouter, and Mistral visible but honestly disabled as local key paths.
  Runtime AI calls are still OpenAI-first until those connectors are built.
- Living Tank visuals now react to latest water-test state, old water-change
  logs, feeding events, livestock health/compatibility cues, aquascape equipment
  cues, earned species progression, and equipped earned decorations. Remaining
  living-tank work is fuller plant inventory, seasonal variants, and final
  phone/tablet visual QA.
- Rewards now include local room-vibe unlock rules, achievement celebration
  feedback, a subtle achievement tank cosmetic cue, Inventory access to earned
  room vibes, and a local earned tank-decoration inventory with equip controls.
  Remaining reward work is seasonal cosmetics and deeper plant/decor
  collections.
- Species and plant detail pages now have the first complete local guide pass:
  profiles, actions, watch-outs, wishlist saves, tank/task handoffs, missing
  species request guidance, and source trails. Future species work is content
  database depth and visual asset quality, not missing core page actions.
- Learning depth is now started with structured guide metadata plus Nitrogen
  Cycle, Water Parameters, First Fish, Maintenance, Planted Tanks, Equipment,
  Fish Health, Species Care, Advanced Topics, Aquascaping, and Breeding Basics
  path enrichment, plus Troubleshooting emergency enrichment. Emergency lessons
  now carry educational/professional escalation safety-boundary copy guarded by
  the content validator, and emergency/distress lessons are kept directly
  accessible without prerequisites. Every current learning path now has
  structured guide coverage.
  Remaining learning work is expanding visual depth and richer learning
  interactions across the catalog.
- Practice depth now includes workflow-based Skill Drills mapped to existing
  lesson paths, filtered review sessions, scenario-style Parameter Reading,
  Diagnosis Practice, Compatibility Checks, Setup Planning, and Emergency
  Decisions questions, plus tank-context recommendation hints in Practice Hub.
- Guided tools now cover tank-context handoffs for the main calculators,
  Cycling Assistant local actions, Cost Tracker currency resilience, and
  aquarium-use guidance on every Unit Converter tab.
- Multi-tank comparison now has a first all-tanks priority overview, recent
  all-tanks activity card, accessible one-tap selected-tank swap action, and
  final phone/tablet Android walkthrough evidence for the current local scope.
- Tank Journal now has a first unified local timeline pass for current log
  types, saved guided-tool notes now appear as Tool Result entries, and Compare
  Tanks now surfaces recent history across tanks. Saved `Milestone:` journal
  notes now appear as Milestone entries, saved accepted AI notes now appear as
  AI Note entries, and saved special entries now have contextual detail strips.
  Phone/tablet Android walkthrough evidence now covers Journal water-test,
  water-change, and milestone rendering plus all-tanks activity; remaining
  timeline work is any future source-specific guided-tool or optional-AI Android
  save handoff walkthrough beyond existing focused widget coverage.
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
  preview/import. Child relationship IDs now reject missing backup targets before
  preview/import. Malformed profile/preferences payloads now reject before
  preview/import. Malformed profile/preferences entry values now reject before
  preview/import. Direct profile/preferences restore now validates values before
  clearing existing local preferences, then rolls back previous exportable
  profile/preferences values if a platform write fails mid-restore.
  Non-exportable profile/preferences entries no longer cause false preview failures
  when their values are malformed.
  Optional restore now reports malformed preference payloads as preference
  restore failures instead of silently skipping them. Optional restore also
  skips malformed tank, livestock, equipment, log, and task records instead of
  letting one bad child record abort valid sibling imports. Backup relationship
  validation now rejects cross-tank log/task relationship targets before
  preview/import. Backup export now rejects missing referenced local photo
  files before creating an invalid ZIP. Backup preview/import now rejects
  livestock records missing required quantity data before silently defaulting
  counts. Backup preview/import now rejects missing required log, equipment,
  and task enum-like fields before silently defaulting them. Out-of-range
  water-test readings now reject before import can silently clamp them. Child
  numeric ranges now reject impossible water-change percentages, counts, sizes,
  maintenance intervals, lifespan values, interval days, and completion counts
  before import. Tank numeric ranges now reject impossible volume, dimension,
  and water-target values before import. Tank target ranges now reject inverted
  minimum/maximum pairs before import. Backup record timestamps now reject
  `updatedAt` values earlier than `createdAt` before import. Custom recurring
  backup tasks now require positive interval days and due dates before import.
  Water-test and water-change backup logs now require their type-specific
  payloads before import. Observation and medication backup logs now require
  notes or photos before import. Generated task/equipment/livestock timeline
  logs now require their backing relationship IDs before import. Task deletion
  now has a 5-second undo snackbar that restores the deleted task. Equipment
  removal undo now restores the linked auto-maintenance task as well as the
  equipment record. Wishlist item deletion now has a 5-second undo snackbar
  that restores the same local planning item. Local fish shop deletion now has
  a 5-second undo snackbar that restores the same saved shop. Cost Tracker
  clear-all now has a 5-second undo snackbar that restores the same saved
  expense records, and failed single-expense deletes now roll back without
  dismissed-widget errors. Bulk tank deletion now uses the same 5-second undo
  window as single-tank deletion instead of deleting tank storage immediately.
  Failed Log Detail deletion now stays on the log and shows normal error
  feedback instead of surfacing a raw widget exception. Livestock removal
  feedback now uses ASCII-safe count text in confirmation, journal, and snackbar
  copy. Livestock bulk move now reports the real moved count after clearing
  selection mode.
  Bulk livestock removal now writes local removal timeline logs after the undo
  window expires. Equipment removal now rolls back partial local deletes if the
  linked maintenance-task delete fails, and skips stale task deletion when no
  linked task exists. Task completion from the Tasks screen now gives normal
  success feedback after local writes succeed, and rolls back the completed
  task if the required completion log write fails. Task snooze failures now
  keep the saved task unchanged and show normal error feedback. Task delete
  undo failures now keep the task deleted and show normal error feedback from
  a stable screen context. Successful task snooze now gives normal success
  feedback after the saved due date changes. Adding a task now gives normal
  success feedback after the local save succeeds. Adding equipment now gives
  normal success feedback after the local equipment save succeeds. Adding
  livestock now gives normal success feedback and writes ASCII-safe added-log
  count copy. Adding a local fish shop now enables save after name entry,
  waits for the local save, and gives normal success feedback. Saving the Shop
  Street monthly budget now waits for the local preference write and gives
  normal success/error feedback. Adding a wishlist item now enables save after
  name entry, waits for the local save, and gives normal success/error
  feedback. Marking a wishlist item as purchased now waits for the local item
  save before applying budget spend, and failed purchase saves leave local data
  unchanged with normal error feedback. Failed wishlist, local fish shop, and
  equipment delete/delete-undo saves now show normal error feedback while
  keeping local data consistent. Shop Street budget and local shop provider
  changes now wait for local SharedPreferences writes before exposing updated
  budget/shop state. Earned species unlocks now wait for the local
  `unlocked_species_v1` write before appearing in visible unlock state. Failed
  Equipment service logging now rolls back the saved serviced timestamp, linked
  maintenance-task changes, and generated service log with normal error
  feedback. Failed tank and livestock soft-delete expiry now restores
  visibility when permanent local delete writes fail, failed tank expiry shows
  normal retry feedback from the root app shell, and failed single livestock
  removal expiry now shows normal retry feedback without writing a false removal
  timeline log. Failed new-tank default-task creation now rolls back partial
  tank/task data. Failed livestock
  bulk moves now roll back earlier moved records. Failed sample-tank replacement
  now restores the previous demo tank and child data. Failed tank reorders now
  restore partial sort-order writes. Failed first-run demo seeding now removes
  partial demo data. Failed Tank Detail task completions now roll back partial
  task/log/equipment writes. Failed Tank Detail quick-feeding saves now show
  normal error feedback without changing the local journal, and stale Tank
  Detail quick-feeding routes now reject missing parent tanks before saving.
  Failed Inventory item uses keep the owned item visible, failed Crash Reports consent writes
  keep the visible switch unchanged with retry feedback, failed local JSON
  entity saves/deletes keep same-process reads aligned with the last durable
  file state, and backup tank-scoped imports now use a tested transaction
  service that remaps related IDs, preserves timeline relationships, and rolls
  back imported tanks and children if a later child save fails. Migrated local
  JSON files are now stamped back to the current schema version after successful
  load so old files do not re-run the same migration on every launch. Backup &
  Restore now surfaces corrupted local-data recovery with retry and confirmed
  start-fresh actions, and failed imports now clean up newly restored photo
  files when tank data import does not commit. Reminder and Cost Tracker
  preference writes now reject false local save results with normal rollback
  feedback. Add Log edits now update existing logs without duplicate
  reward/progress side effects and close the saved edit route cleanly. Tank
  Settings saved edits now close without unsaved-prompt loops after the durable
  local tank update. Equipment adds now roll back partial equipment records when
  maintenance-task sync fails, while secondary progress-write failures no longer
  undo durable equipment adds. Livestock adds now keep durable livestock and
  timeline-log saves when only secondary progress writes fail. Bulk livestock
  adds, Symptom Triage confirmed journal saves, and Species detail care-task
  actions now reject missing parent tanks before saving, and bulk/single
  livestock adds now roll back partial livestock/log records when timeline-log
  persistence fails. Quick Water Test
  now keeps saved
  water-test logs when only the secondary profile-XP write fails, and user
  profile reset rejects failed local preference removals before exposing reset
  state. Practice-mode lessons no longer claim XP when profile XP persistence
  fails. The energy explainer now marks itself seen only after the dialog is
  dismissed, and does not consume the prompt if the lesson screen unmounts
  before it can be shown. The Tank stage sheet first-use hint now persists
  through the shared preferences provider and restores visible retry state
  when its seen-flag write fails. Spaced-repetition reset now keeps visible
  cards/stats and restores partially removed card/stat/streak/session local
  JSON when reset removal fails. Gem and inventory reset helpers now reject
  false local preference removals before exposing reset success. Achievement
  provider resets now reject false progress removals before clearing visible
  progress. Lesson-completion achievement checks now use persisted
  completed-lesson and perfect-score profile state rather than inferred
  duplicate counts. Debug achievement reset now rejects failed progress/profile
  preference writes and restores progress if the profile write fails after
  progress removal.
  DebugMenu profile-write actions now reject false local `user_profile` saves
  before showing success. Debug species reset now rejects false local
  unlock-list writes before showing success. Debug Clear All Data now rejects
  false local preference-clear results before showing restart copy. Tank
  returning-user prompts now check failed dismissal seen-flag writes, and all
  current OpenAI request surfaces, including Ask Danio typed questions, use the
  shared disclosure gate and stop before sending any Optional AI request when
  the disclosure acceptance flag cannot be saved. Backup imports that import
  zero local tanks now skip app-wide SharedPreferences restore while keeping the
  existing no-tanks warning. Cycling Assistant reminder create actions now reject
  missing parent tank IDs before saving, preventing orphan local tasks after
  tank deletion, Symptom Triage confirmed journal saves now reject missing
  parent tank IDs before saving local AI diagnosis logs or history, Species
  detail care-task actions now reject missing parent tank IDs before saving
  local weekly care tasks, Tank Journal manual-entry saves now reject missing
  parent tank IDs before saving local observation logs, Tank Detail
  quick-feeding saves now reject missing parent tank IDs before saving local
  feeding logs, and Equipment delete Undo now rejects missing parent tanks
  before restoring equipment or generated maintenance tasks. Delayed Livestock
  removal timeline logs now recheck the parent tank before saving, preventing
  orphan local removal logs after the tank is deleted during the undo window.
  Direct tank-scoped backup imports now reject child rows whose tank IDs are
  absent from the imported tank map, rolling back instead of reporting success
  while silently skipping livestock, equipment, task, or log data.
  Direct tank-scoped backup imports also now reject task/log relationship IDs
  whose backup targets are absent from the imported ID maps, rolling back
  instead of reporting success while silently clearing relationship links.
  Direct tank-scoped backup imports now also reject duplicate backup tank IDs
  before saving imported tanks, preventing duplicate backup tanks from
  collapsing relationship mapping onto one regenerated local tank ID.
  Direct tank-scoped backup imports now also reject task/log relationship IDs
  whose backup targets belong to a different backup tank from the source
  task/log, preventing cross-tank relationship links from being preserved while
  the service reports success.
  Backup Restore now extracts only archive `photos/` entries whose filenames
  are referenced by validated backup data, preventing valid restores from
  leaving unrelated archive-only photo files in local app storage or
  cleanup-tracking state.
  Remaining
  backup/data work is broader edit/delete/undo coverage and restore/migration
  walkthrough QA.
- Profile/preferences now centralises units, region, tank stage, experience
  level, and goals. Tank Settings water-profile labels are readable and
  source-safe. The Haptic Feedback preference now controls shared snackbar
  haptics, the Reduce Motion preference now reaches descendant MediaQuery
  animation checks, Notification Settings now has guided reminder intensity
  presets, Preferences links directly to the Privacy Policy, and Optional AI
  disclosure acceptance can be reset from Preferences. Optional AI setup now
  links directly to the Privacy Policy from the setup dialog, names OpenAI as
  the current recommended BYO provider, lists the remaining provider targets
  honestly as unavailable local key paths in this version, and the Smart
  setup-context nudge now uses readable light-card text colors. Build-time
  `OPENAI_API_KEY` is now a local-development-only direct fallback ignored in
  release builds, while user-supplied BYO keys and proxy routing remain
  supported. Remaining profile/preferences work is any final AI/provider
  walkthrough gaps.
- Optional AI confirmation has started: Symptom Triage now asks before saving
  an AI-generated diagnosis to the tank journal, rejects stale missing-parent
  tank saves before writing the journal or AI history, Weekly Plan now asks
  before caching an AI-generated care plan, and Ask Danio now asks before saving
  a typed-question summary to Recent AI Activity. Focused widget coverage
  verifies canceling those confirmations writes no journal log, stale Symptom
  Triage saves leave logs and `ai_interaction_history` empty, canceling Ask
  Danio leaves `ai_interaction_history` untouched, and canceling Weekly Plan
  leaves `weekly_plan_cache` empty. Remaining AI confirmation work is any future
  AI changes to tank data, tasks, and reminders.
- Global search now has complete-local coverage for app destinations, tools,
  learning paths, direct lesson results, guides, settings/privacy/backup,
  species, equipment, livestock, local logs, real Tank top-bar and More entry
  points, and phone/tablet Android walkthrough evidence. Search is currently
  closed for complete-local scope unless future walkthroughs reveal a new
  findability issue.
- Demo mode now has a resettable populated sample tank that replaces existing
  demo data without deleting real tanks, with final phone/tablet Android screen
  evidence captured under
  `docs/qa/screenshots/2026-06-22/cl-p1-012-demo-mode/`.
- Debug QA tools now include CL-QA-007A, a debug-only `Seed Emergency Water
  Spike` action that creates `QA Emergency Water Spike`, one sick livestock
  entry, and an unsafe ammonia/nitrite/nitrate water-test log for repeatable
  Emergency Guide, Tank alert, Smart Hub risk, and aquarium-visual checks.
- Debug QA tools now include CL-QA-007B, a debug-only `Seed Incompatible Fish
  Tank` action that creates `QA Incompatible Fish Tank` with Betta plus Guppy,
  and focused widget coverage verifies that the existing livestock visual
  service reports `compatibilityConcern`.
- Debug QA tools now include CL-QA-007C, a debug-only `Seed Skipped Onboarding`
  action that mirrors quick start by writing a beginner freshwater profile,
  creating the populated `Sample Tank`, selecting the Tank tab, and persisting
  the onboarding-completed flag.
- Debug QA tools now include CL-QA-007D, a debug-only `Seed No-AI Smart Hub
  State` action that removes any local Optional AI key/disclosure state and
  creates `QA No-AI Smart Hub` with a high-nitrate water-test log, so local
  Smart Hub risk/suggestion checks can be reviewed without fake AI readiness.
- Debug QA tools now include CL-QA-007E, a debug-only `Seed Unlock Edge State`
  action that writes a partial progression state: 900 XP, a 6-day streak, 9
  completed lessons, Betta species unlock, Driftwood Arch unlock/equip, and
  Evening Glow room theme, while keeping later unlock thresholds locked.
- Debug QA tools now include CL-QA-007F, a debug-only `Seed Tablet QA State`
  action that creates `QA Tablet Long Layout Community Tank` with dense
  long-copy livestock, equipment, tasks, water-test, feeding, water-change, and
  observation data for repeatable tablet walkthroughs. Remaining debug seed gap
  is any real keyed-AI state only when it can avoid fake provider readiness.
- Full-app tablet verification is not yet current, though Workshop, Lesson, and
  Learn now have focused phone/tablet or tablet readability layout guardrails.
- Visual asset quality still has known older audit gaps.
- Full local screen audit can continue while `danio_api36` remains dedicated to
  Danio live preview.
- Richer per-tank intelligence drill-downs and save/apply flows remain useful
  future depth, but the P0 no-AI Smart hub acceptance is now covered.

## 6. Next Execution Step

Continue CL-P1-009 local depth while Android transport is reserved by other
sessions:

- Continue remaining timeline/guided-tool phone/tablet QA when device ownership
  is clear, continue CL-P1-009 data-safety hardening, and keep CL-P1-010
  preference centralisation honest as more settings surfaces change.
- Keep Android phone/tablet visual QA deferred until emulator/device ownership
  is confirmed.
