# Danio Complete Local Product

Status: Product north star  
Created: 2026-06-13  
Scope: Android phone and Android tablet, local app completion before public launch

## 1. Purpose

Danio is not complete because it can build, pass a release smoke test, or be
submitted to Google Play. Danio is complete when it feels like a finished,
loved, premium aquarium app locally: stable, beautiful, content rich,
responsive, clever by default, and trustworthy across the full Android phone
and Android tablet experience.

Public launch work is explicitly paused until this complete-local-product bar
is met. That means Play Store listing work, public legal URLs, store assets,
release notes, and Play Console forms are out of scope until the app itself is
complete locally.

## 2. Product Principles

- Tank is the emotional centre of the product.
- The app is clever by default and AI-enhanced later.
- The experience is charming and game-like, but never misleading about real
  aquarium care.
- Rich content should not become clutter.
- Danio should explain why recommendations, warnings, tool outputs, practice
  answers, and care plans matter.
- The app should be confident and practical while making clear that it is
  educational and not a substitute for veterinary or professional advice.
- Local-first trust matters: no account should be required for the complete
  local experience.
- Every visible feature must feel complete.
- Quality and polish matter more than speed.

## 3. Anti-Goals

- Do not make Danio feel corporate, generic, or visually stripped back.
- Do not make AI required for core usefulness.
- Do not gamify harmful care behaviour, such as overfeeding or unnecessary
  water changes to maintain streaks.
- Do not show visible placeholders, TODOs, "coming soon" surfaces, or unfinished
  feature cards.
- Do not make the app beginner-only; it must grow with serious users.
- Do not clutter the Tank screen with every possible action.
- Do not treat tablet as a stretched phone layout.
- Do not add unlicensed real photos or unclear third-party media.
- Do not resume public launch/admin work before the local product is complete.

## 4. Target Domains

Danio should be world-class for:

- Tropical freshwater and community tanks.
- Planted tropical tanks.
- Coldwater and goldfish, with clear protective guidance.
- Shrimp and nano tanks, with stability warnings.
- Aquascaping as a major cross-cutting pillar.
- Breeding as an advanced but polished area.

Marine and brackish tanks are out of scope until they can be supported properly.
The app should not offer them as normal setup paths.

## 5. Core Experience

The app should open to the Tank screen, and Tank should remain physically in
the centre of the bottom navigation. Learn, Practice, Smart, tools, library,
settings, and rewards should orbit around the user's tank rather than feeling
like disconnected modules.

The main navigation can change if the final product shape demands it, but the
current likely structure is:

- Learn: structured learning paths and varied activities.
- Practice: spaced repetition plus broader fishkeeping skill drills.
- Tank: living aquarium, care centre, quick actions, and daily next-best action.
- Smart: built-in aquarium intelligence, risks, plans, insights, and optional AI.
- More: organized library, tools, profile, settings, backup, rewards, and help.

## 6. Onboarding And Personalization

Onboarding should be short in feel but high-value in what it captures. It should
ask only for context that makes Danio meaningfully smarter:

- Experience level.
- Broad region for sensible unit defaults.
- Aquarium type or aspiration.
- Whether the user already has a tank.
- Tank stage: planning, cycling, stocked, troubleshooting, planted, etc.
- Goals and interests.
- Optional livestock/plants if already known.

Users must be able to skip onboarding and still land in a polished experience.
When later features need missing context, Danio should ask contextually and
lightly at the point of need. All onboarding answers must be editable later in
Profile/Preferences.

Tropical freshwater should be the default suggested route, while clearly
supporting coldwater/goldfish, shrimp/nano, planted, existing tank, and "not
sure yet" paths.

Starter plans should be guided recommendations rather than rigid templates.
Examples:

- Beginner Tropical Community.
- Easy Planted Tropical.
- Shrimp Nano, with stability warnings.
- Goldfish Done Properly.
- Low-Tech Planted Tank.
- Betta Tank Done Right.

Starter plans should connect to visual inspiration, starter checklists,
recommended lessons, compatible species shortlists, plant/decor ideas, and
progress rewards.

## 7. Tank As Living Centre

The Tank screen should feel like a living, collectible, responsive aquarium and
room scene, not just a dashboard.

Requirements:

- Preserve the current illustrated/watercolor room-and-tank identity.
- Keep the visual aquarium emotionally central.
- Keep care actions close at hand without clutter.
- Surface one context-aware next-best action.
- Provide quick log actions for water test, feeding, water change, maintenance,
  notes/photos, and relevant task completion.
- Show a calm tank status summary: stable, needs check, caution, urgent, or
  missing data.
- Link to full-screen deeper tank areas for livestock, plants, equipment, water,
  maintenance, timeline/journal, tasks, photos, and value/costs.

The living tank should reflect real records where possible:

- Fish sprites should reflect the user's real livestock where supported.
- Schooling fish may be represented as groups rather than every individual.
- Plants and decorations should appear visually where supported.
- Users may name individual fish where they want to, while grouped livestock
  records remain supported.
- Users can choose display favourites where the tank would otherwise be too
  crowded.

Simple fish moods/states should be supported where grounded in care context:

- Calm/stable.
- Active after feeding is logged.
- Hiding/stressed after poor parameters or serious incompatibility.
- Sluggish when temperature is off.
- Schooling/comfortable when group size is appropriate.

The app should avoid a single opaque "health score." Use clear category statuses
and explainable triggers instead.

## 8. Care State Visuals

Care state should affect the tank visually in tasteful, non-distressing ways:

- Subtle cloudy water for overdue care or poor parameters.
- Warmer/cooler lighting for temperature problems.
- Fish hiding/slowing for stress.
- Alert badges or panels for clarity.
- Feeding/logging care should trigger satisfying but short animation feedback.

Avoid graphic illness, dead fish, or playful fighting. Incompatibility should
use gentler tension signals such as hiding, spacing, stress cues, and clear
compatibility warnings.

## 9. Customization, Rewards, And Progression

Customization is a real feature, not decoration only. It should support:

- Room themes and swappable illustrated backgrounds.
- Decorations.
- Plants and aquascape-inspired layout templates.
- Tank vibes/styles.
- Seasonal/local lightweight rewards.
- Achievement-based cosmetics.
- Gems/shop rewards, with gems earned only in-app during this phase.

Unlock sources should include a mix of learning, practice, care consistency,
tank milestones, achievements, gems, and seasonal/special rewards. Rewards
should be harder-earned and meaningful rather than spammy.

Real tank records and visual customization should be tightly linked but clearly
distinguishable:

- Real records drive care advice.
- Visual tank reflects real fish/plants where possible.
- Cosmetic rewards are visual unless the user explicitly records them as real
  items.

Customization should use polished slots/templates rather than freeform
drag-and-drop unless a later implementation can maintain quality across phone
and tablet layouts.

## 10. Learn

Learn must feel content-rich and varied, not like a simple quiz list.

Requirements:

- Large, well-structured learning paths.
- Deeper explanations with real examples.
- Strong progression and recommendations.
- Rich activity variety mixed naturally into paths.
- Visuals where they help comprehension.
- Subtle sources/provenance where useful, especially in deeper learning content.
- Content should support beginner, intermediate, and advanced users.

Activity types should include:

- Standard lessons.
- Quizzes.
- Scenario decisions.
- Diagnose-a-problem exercises.
- Build-a-tank exercises.
- Species matching.
- Compatibility decisions.
- Water-parameter interpretation.
- Myths/facts.
- Flashcards.
- Mini-games where they teach accurately.
- Checklists.

Activities should be mixed into the learning journey naturally, not presented as
a confusing set of modes the user must manage.

## 11. Practice

Practice should build judgement, not only recall.

Requirements:

- Spaced repetition of learned concepts.
- Broader skill drills such as identifying risks, choosing compatible
  tankmates, interpreting water parameters, and deciding the next care action.
- Personal-tank-based drills where possible as a clever extra.
- Feedback that explains why.
- Practice should connect to the user's tanks, current lessons, and care
  context.

## 12. Species And Plant Content

Species and plant content is a major product pillar.

Requirements:

- Broad database.
- Detailed care guides.
- Strong compatibility logic.
- Beautiful, actionable presentation.
- Links into tank records, Learn, Smart, Practice, and tools.
- Add to my tank.
- Check compatibility.
- Recommended lessons.
- Care reminders.
- Common problems.
- Request missing species/plant.

Pages should provide instant labels and detailed reasons. Compatibility should
have severity levels:

- Fine.
- Watch.
- Caution.
- Avoid.
- Hard no.

Danio should be protective where risks are serious, but flexible and educational
for context-dependent cases. Users can override warnings where appropriate, but
serious welfare risks must remain clearly flagged.

## 13. Art And Assets

The illustrated Danio style is a core strength. Preserve and improve it.

Requirements:

- Strong custom-fit visuals for every major screen.
- Detailed illustrated room backgrounds and swappable themes.
- Charming fish/species sprites.
- Polished fallback sprites by family/type where exact species art is missing.
- No ugly missing-image states.
- A request path for missing species/plants.
- An asset inventory, art bible, naming/export rules, and missing asset list.

Real photos may be valuable later for identification, disease signs, sexing,
breeding, and real-world reference, but they must only be added through a clean
licensing/ownership pipeline. Local completion should not rely on random
unlicensed photos.

## 14. Smart And Built-In Intelligence

Smart should be valuable without AI. It is the aquarium intelligence hub.

Requirements:

- Risks.
- Suggestions.
- Care plans.
- Compatibility.
- Anomaly history.
- User-facing insights.
- Emergency guidance.
- Optional AI upgrades.

Smart should not be a locked AI page. It should be as useful as possible with
local rules, content, and user data.

## 15. Recommendation Engine

Danio needs a formal rule-based recommendation engine so the app feels clever
without scattered one-off logic.

Inputs should include:

- Experience level.
- Region/unit preferences.
- Goals/interests.
- Active tank.
- Tank stage.
- Livestock.
- Plants.
- Equipment.
- Water parameters.
- Maintenance logs.
- Reminders/tasks.
- Lesson/practice progress.
- Recent actions.
- Dismissed/snoozed recommendations.

Outputs should include:

- Next-best action.
- Care alerts.
- Lesson recommendations.
- Practice drills.
- Tool suggestions.
- Species/care nudges.
- "Do nothing today" reassurance.
- Missing-data prompts.

Each recommendation should have:

- Title.
- Action.
- Priority/severity.
- Reason.
- Source/input trigger.
- Optional "why this matters."
- Destination link.
- Dismiss/snooze rules.

Recommendations should be explainable and testable. Users must be able to
dismiss or snooze recommendations. Safety-critical issues can be acknowledged
but should return if the risk remains.

## 16. AI

AI should enhance the app, not be required for the core experience.

The finished local product should support multiple providers in the user-facing
AI setup:

- OpenAI.
- Anthropic.
- Google Gemini.
- OpenRouter.
- Mistral.

Provider capabilities should be shown clearly:

- Text advice.
- Image/fish/plant ID.
- Care plans.
- Anomaly explanations.
- Lesson coaching.
- Ask Danio.

Danio should recommend a default provider/model for normal users while allowing
advanced users to choose. Bring-your-own API key setup should be simple,
guided, and understandable by normal users. Keys should be stored locally and
securely, ideally using Android secure storage/Keystore, not included in normal
exports unless explicitly chosen.

AI and built-in recommendations may suggest actions, but the user must confirm
before anything changes user data.

## 17. Emergencies And Health

Emergency workflows are part of the finished product.

Examples:

- Ammonia spike.
- Fish gasping.
- Heater stuck on/off.
- Filter failure.
- White spot outbreak.
- Sudden death.
- Temperature shock.
- Cycling emergency.

Emergency help should be accessible from:

- Tank alerts.
- Smart.
- Search/More.
- Relevant lessons.
- Species pages.
- Water parameter logs.

Guidance should be confident, practical, and bounded:

- Immediate steps.
- What to check.
- Likely causes.
- Common treatment categories where appropriate.
- Warnings about species sensitivity, dosing, invertebrates, plants, carbon,
  filtration, and diagnosis uncertainty.
- Clear prompts to consult an aquatic vet/local expert where needed.

## 18. Tools And Calculators

Tools should become guided workflows, not isolated calculators.

Requirements:

- Ask only for necessary inputs.
- Prefill from active tank where possible.
- Explain the result in plain English.
- Show warnings/tradeoffs.
- Link to relevant lessons and species/tank actions.
- Save or apply results only after user confirmation.

Tool results may be saved to tank history where relevant:

- Water change plans.
- Dosing calculations.
- Stocking checks.
- Compatibility checks.
- CO2 calculations.

## 19. Timeline And Journal

Each tank should have a unified timeline/journal combining:

- Water tests.
- Feedings.
- Maintenance.
- Livestock/plants added.
- Photos.
- Notes.
- Care plans.
- Tool results.
- AI suggestions accepted by the user.
- Milestones and achievements.

There should be both per-tank and all-tanks timeline views. The all-tanks view
must support filtering so it does not become noisy.

Photo support should include multiple photos per tank/journal entry, with a
primary photo plus gallery pattern where useful for livestock/species records.
User photos should remain records/journal/ID assets, not part of the illustrated
living tank.

## 20. Multi-Tank Experience

Multi-tank support should be first-class.

Requirements:

- Each tank has its own stage, livestock, plants, equipment, parameters, tasks,
  notes, care plan, and history.
- Tank screen can switch tanks cleanly.
- Smart recommendations can be per-tank plus overall.
- Reminders and care plans are tank-specific.
- Learning can be influenced by all tanks but prioritized by the active tank.
- All-tanks overview shows both care priorities and comparison metrics.

## 21. Streaks And Gamification

Streaks should be central, but not cruel.

Recommended model:

- Learning streak for lessons/practice.
- Care streak for completing relevant due care/check-in actions.
- Overall Danio rhythm summary rather than forcing all behaviour into one
  number.

Care streaks must only reward appropriate care. Do not encourage overfeeding,
unnecessary testing, or unnecessary water changes.

Support:

- Earned streak freezes.
- Gentle recovery after missed days.
- Clear distinction between learning habit and actual tank care.
- Urgent care always outranks streak chasing.

## 22. Profile And Preferences

The app needs a proper profile/preferences area storing:

- Experience level.
- Goals.
- Region/unit defaults.
- Reminder intensity.
- Interests.
- Tank stages.
- AI/API setup.
- Privacy/data controls.
- Onboarding answers.

Users should be able to change onboarding answers later.

Reminder intensity should support:

- Gentle.
- Balanced.
- Proactive.

Users must be able to disable reminders or categories clearly.

## 23. Units And Region

Danio should remain universal, not deeply region-specific.

Requirements:

- Broad region during onboarding for defaults.
- Region/default units editable in Settings.
- Support litres/gallons.
- Celsius/Fahrenheit.
- ppm/mg/L where relevant.
- cm/inches for species sizes.
- Contextual unit prompts only where helpful.

## 24. Search

Danio should support global search across:

- Lessons.
- Species.
- Plants.
- Tools.
- Glossary.
- Emergencies.
- User tanks/livestock/logs.

Search should be globally accessible through key top bars and More/Library, not
necessarily a bottom tab.

## 25. Demo/Sample Mode

Demo/sample mode should be included so users can explore a rich app before
entering real data.

Requirements:

- Offered during onboarding: set up my tank, explore sample tank, skip for now.
- Accessible later from Help/More.
- Sample mode should be clearly marked.
- Users can play with it, log actions, run tools, and see effects.
- Sample data is resettable and separate from real data.
- No mixing sample records into real tanks unless explicitly copied.

Initial demo should include one beautiful beginner-friendly community tank.
Later demo browser can include planted shrimp nano, goldfish/coldwater caution,
and multi-tank hobbyist samples.

## 26. Data, Backup, And Trust

Offline-first robustness is part of completion.

The app must handle gracefully:

- Fresh install.
- Skipped onboarding.
- Partial onboarding.
- Returning user.
- App restart and force close.
- No internet.
- No AI key.
- Permission denial.
- Import/export.
- Delete data.
- Migration from old data shapes.
- Weird partial setup states.

Backup/restore is a polished trust feature, not a hidden utility.

Requirements:

- Export/import clarity.
- Clear destructive-action warnings.
- Optional backup before destructive import/delete where sensible.
- Safe restore from mistake flows.
- No half-restored app state.
- Schema versioning.
- Safe migrations.
- Stable IDs for lessons/species/items/rewards.
- Tests for old data shapes.

User-created records should support edit/delete. Use undo snackbars where
sensible and confirmations for destructive actions.

## 27. Validation

Input validation must exist everywhere user data is entered.

Block impossible data:

- Negative tank volume.
- pH outside physical plausible range.
- Negative counts.
- Invalid dates.

Warn but allow suspicious data:

- Very high nitrate.
- Unusual tank size.
- Old log date.
- Advanced/edge-case water parameters.

Warnings should explain gently rather than saying only "invalid input."

## 28. Permissions

Permission flows must be polished:

- Explain why permission is needed before asking.
- Handle denial.
- Handle permanent denial.
- Provide graceful fallback.
- Provide Settings instructions.
- Avoid scary technical language.

Relevant permissions include camera, photos/media, notifications, exact alarms,
and any future storage/share flows.

## 29. Help, Contact, And Feedback

The app should include a polished Help/Contact/Feedback area.

Categories:

- Bug report.
- Species/plant request.
- Content correction.
- Feature suggestion.
- Support question.
- General feedback.

Bug reports should use a simple email-first flow with optional diagnostics only
after clear user consent. Never include tank data/photos unless explicitly
chosen by the user.

An in-app guide should support:

- Getting started.
- Managing tanks.
- Learning and practice.
- Understanding Smart suggestions.
- Using tools.
- Backup and restore.
- AI setup.
- Troubleshooting.

The guide should support deeper use, not compensate for poor UI.

## 30. Cloud, Accounts, And Social

For the complete local product, cloud sync/accounts should remain hidden or
dormant unless they are genuinely polished. Local-first backup/export/import is
the trust path for this phase.

Community/social/friends/leaderboards should not be a networked feature during
this phase. Existing visible social-style features should be reworked into solo
progress:

- Personal achievements.
- Mastery levels.
- Tank milestones.
- Collection goals.
- Local share cards where appropriate.

## 31. Visual Design System

The design system needs a full polish pass.

Requirements:

- Preserve warm illustrated Danio identity.
- Expand the palette beyond amber/cream so the app does not feel one-note.
- Use aquatic blues/teals for water/calm/clarity.
- Use greens for plants/success/stable care.
- Use coral/red carefully for warning/urgent care.
- Use deeper navy/charcoal for expert/reference/data areas.
- Give major areas subtle identities while staying cohesive.
- Keep friendly rounded typography, but tighten hierarchy and sizing.
- Use compact, calmer typography for dense tools/settings.
- Ensure long educational content is readable.
- Ensure numbers/data are scannable.
- Ensure tablet text does not become oversized.

Every screen should have a clear primary job.

## 32. States Required For Every Visible Feature

No visible feature is complete unless relevant states are polished:

- Empty state.
- Loading state.
- Error state.
- Denied-permission state.
- Rich-data state.
- Edit/delete state.
- Offline/no-network state.
- No-AI/no-provider state.
- Tablet portrait state.
- Tablet landscape state where relevant.

Empty states should guide users with useful next steps and education, not merely
say "nothing here yet."

## 33. Android Phone And Tablet

Complete scope is Android phone and Android tablet first.

- Phone: polished portrait-first experience.
- Tablet: polished portrait and landscape with adapted layouts.
- Web/desktop are secondary and not part of this complete-local bar.

Tablet should use extra space intentionally:

- Tank: larger living aquarium plus side panel for today/status/care.
- Learn: path list plus preview/detail.
- Practice: question plus progress/explanation panel.
- Species/library: list/grid plus detail pane.
- Tank management: master-detail layouts.
- Settings/More: grouped sidebar plus detail content.

## 34. Accessibility

Accessibility target for this phase is the solid basic bar:

- Readable contrast.
- Usable touch targets.
- Text scaling does not break layouts.
- Meaningful labels on important controls.
- Reduced-motion behaviour is sane where animations exist.
- Colour should not be the only signal for care severity.

## 35. Motion And Haptics

Motion should add meaning and delight:

- Living tank: subtle ongoing life.
- Feeding/logging care: short satisfying feedback.
- Rewards/unlocks: bigger but meaningful celebration.
- Lesson/practice feedback: quick confidence-building motion.
- Warnings/status: subtle attention cues, not flashing alarm.
- Onboarding: gentle transitions.

Use haptics for key moments only:

- Answer selection.
- Correct answer.
- Saved log.
- Feeding.
- Unlock/reward.
- Serious warning/destructive confirmation.

No default audio for this phase.

## 36. Performance

Performance should be handled throughout and as a formal milestone.

Target modern mid-range Android devices first, while avoiding obvious waste.

Requirements:

- Smooth core navigation.
- No obvious tank animation jank.
- Images optimized enough not to create memory pressure.
- Fast enough first launch.
- Graceful loading of heavy content.
- No battery-draining background work.
- Dedicated pass for startup, navigation, image memory, long lists, tank
  animation, tablet layouts, and background work.

## 37. Debug And QA Tooling

Debug-only tooling should be built early to support quality:

- Jump to screens/states.
- Seed tanks/livestock/plants/logs.
- Force warnings/emergencies.
- Unlock rewards/themes.
- Preview tablet layouts.
- Capture screenshots.
- Validate content/catalogs.
- Inspect recommendation reasons.

None of this should exist in release UI.

## 38. Testing Strategy

Use layered testing:

- Unit tests for recommendation logic, compatibility, ranges, unlock rules, and
  calculations.
- Widget tests for key screens, empty/rich/error states, forms, and important
  interactions.
- Integration tests for onboarding, tank setup, learning, practice,
  backup/restore, AI setup, and core navigation.
- Emulator screenshot audits for visual polish.
- Selective golden tests for stable reusable components and important visual
  states.

Every milestone should pass relevant tests and emulator QA before being called
complete.

## 39. Final Acceptance Scenarios

The final product should pass day-in-the-life walkthroughs for:

- Total beginner choosing "not sure yet" and being guided to a safe starter
  plan.
- Beginner setting up a tropical freshwater community tank.
- Existing tropical user adding a real tank and livestock.
- Planted/shrimp user checking care and recommendations.
- Goldfish/coldwater user being guided away from bowl/small-tank mistakes.
- Multi-tank experienced user seeing priorities and comparisons.
- User facing a water/emergency issue.
- User with no internet and no AI key still getting value.
- User setting up and testing BYO AI provider.
- User using Android tablet portrait.
- User using Android tablet landscape.
- User importing/exporting/backing up data.
- User denying permissions and still seeing graceful fallback.

## 40. Milestone Roadmap

This roadmap is deliberately rough. The audit should refine it.

1. Product spec and full audit.
2. QA/debug tooling.
3. Core navigation, Tank-first home, and product structure.
4. Design system polish.
5. Living Tank, customization, and rewards.
6. Recommendation engine and Smart built-in intelligence.
7. Learn/Practice rich activity system.
8. Species/plants/actionable care content.
9. Tools as guided workflows.
10. Emergency and health workflows.
11. Timeline/journal and multi-tank overview.
12. Profile/preferences/units/reminders.
13. Backup/restore/offline/data migration robustness.
14. AI provider setup and BYO key flows.
15. Asset system/art bible/sprite inventory.
16. Tablet portrait and landscape adaptation.
17. Performance pass.
18. Full acceptance walkthroughs and final polish.

## 41. Working Rule

If a feature is visible, it must work, look polished, explain itself, handle
edge cases, and fit Danio's product identity. Anything less is unfinished.
