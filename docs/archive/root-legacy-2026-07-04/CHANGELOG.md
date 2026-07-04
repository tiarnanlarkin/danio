# Changelog

All notable changes to the Aquarium Hobby App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] - 2026-02-12 (MVP)

### 🎉 Initial MVP Release

This is the first release of the Aquarium Hobby App, featuring a complete learning system, tank management, and Duolingo-style gamification.

### Added

#### Phase 0: Navigation & Accessibility (2026-02-11)
- Workshop screen with all 8 calculators accessible
- Settings screen with 14 guides organized into categories
- Difficulty settings integration
- Tank detail enhancements (charts, comparison, cost tracker)
- Removed 2 demo screens (xp_animations_demo, offline_mode_demo)

#### Phase 1: Gamification Integration (2026-02-11)
- **Gem Earning System** — Automatic gem rewards for 14 trigger events:
  - Lesson complete (+5 gems)
  - Quiz pass (+3 gems), perfect quiz (+5 gems)
  - Daily goal met (+5 gems)
  - Streak milestones: 7-day (+10), 30-day (+25), 100-day (+100)
  - Level up (+10-200 gems based on level)
  - Placement test complete (+10 gems)
  - Weekly active (+10 gems), perfect week (+25 gems)

- **XP Integration Expansion** — XP awards for 15+ activities:
  - Tank created (+25 XP)
  - Livestock added (+10 XP)
  - Equipment logged (+10 XP)
  - Water test logged (+15 XP)
  - Maintenance complete (+20 XP)
  - Photo added (+5 XP)
  - Guide read (+5 XP)
  - Calculator used (+3 XP)
  - Species/plant researched (+5 XP)
  - Profile completed (+50 XP)

- **Shop Item Effects** — All items now functional:
  - XP Boost (2x XP for 1 hour)
  - Hearts Refill (restore all hearts)
  - Streak Freeze (protect streak for 1 day)
  - Quiz Retry (bypass heart deduction)
  - Timer Boost (extra quiz time)
  - Hint Token (reveal quiz answer)
  - Cosmetic badges, themes, and effects

- **Home Screen Dashboard** — Gamification stats prominently displayed
- **Achievement Checker Wiring** — All 55 achievements can now unlock
- **Inventory System** — View and use purchased items

#### Phase 2: Content Expansion (2026-02-12)
- **Species Database** — Expanded from 44 to 122 species:
  - Tropical community (Mollies, Platies, Swordtails, Rainbowfish)
  - Beginner cichlids (Keyhole, Firemouth, Angelfish, Discus)
  - Catfish & loaches (Bristlenose, Corydoras, Yoyo, Hillstream)
  - Livebearers (Endlers, Guppies, Mosquitofish)
  - Rasboras & danios (Galaxy, Lambchop, Pearl, Giant Danio)
  - Tetras (Glowlight, Diamond, Bloodfin, Congo)
  - Barbs (Tiger, Rosy, Gold, Denison, Odessa)
  - Specialty (Scarlet Badis, African Dwarf Frog, Axolotl)

- **Plant Database** — Expanded from 21 to 52 plants:
  - Anubias varieties (Nana, Petite, Coffeefolia, Hastifolia)
  - Java Fern varieties (Trident, Windelov, Narrow Leaf, Philippine)
  - Cryptocoryne varieties (Wendtii Green/Brown/Red, Parva, Lucens)
  - Stem plants (Rotala, Ludwigia, Bacopa, Hygrophila)
  - Carpeting plants (Dwarf Hairgrass, Marsilea)
  - Floating plants (Salvinia, Red Root Floaters, Water Lettuce)
  - Mosses (Christmas, Flame, Weeping)

- **Achievement System** — Full activation with trigger wiring:
  - Learning achievements (lessons, XP milestones, streaks)
  - Hobby achievements (tanks, livestock, photos)
  - Review streak achievements
  - 35 achievement tests passing

### Fixed

#### Critical Fixes (Phase 3 Sprint 3.2)
- **GemsProvider race condition** — Fixed initialization issue on fresh install causing gem count display errors
- **AppColors.border undefined** — Fixed missing border color in `experience_assessment_screen.dart`
- **AppTypography.titleMedium undefined** — Fixed missing typography in onboarding screens
- **FutureProvider.notifier undefined** — Fixed provider access in `first_tank_wizard_screen.dart`
- **5 onboarding screen errors** — All errors that would crash the app are now resolved

#### Phase 0 Fixes
- Test timing issues (3 edge cases)
- Dart format compliance (10 files auto-fixed)
- 147 lint warnings addressed

#### Phase 1 Fixes
- Gem reward duplication prevention
- XP boost timer persistence
- Shop item state consistency
- Achievement notification display

#### Phase 2 Fixes
- Achievement stats tracking (`reviewsCompleted`, `reviewStreak` added)
- 8 missing switch cases for review achievements
- `checkAfterReview()` helper method added

### Changed
- Workshop screen now displays all calculators in organized grid
- Settings screen reorganized with "Guides & Education" section
- Home screen includes gamification dashboard widget
- Shop screen includes inventory tab for owned items

### Removed
- `xp_animations_demo_screen.dart` (development demo)
- `offline_mode_demo_screen.dart` (development demo)

### Technical Details
- 86 total screens (77 navigable, 9 orphaned — to be addressed in Phase 3)
- 435+ unit tests passing (98%+ coverage)
- Build time: ~30-60 seconds (debug APK)
- APK size: ~50MB (debug)

---

## [Unreleased]

### Planned for Phase 3
- Quality scripts setup (`scripts/quality_gates/`)
- Duplicate navigation consolidation
- LearnScreen vs StudyScreen consolidation
- Remaining P1/P2 bug fixes
- Full regression testing
- Release APK generation

### Planned for Phase 4 (Future)
- Supabase backend integration
- Cloud sync across devices
- User authentication (email, Google, Apple)
- Photo cloud storage
- Real-time multi-device sync

---

## Version History

| Version | Date | Phase | Status |
|---------|------|-------|--------|
| 0.1.0 | 2026-02-12 | MVP (Phases 0-3) | 🚧 In Progress |
| 0.2.0 | TBD | Phase 4 (Backend) | 📋 Planned |
| 1.0.0 | TBD | Production Release | 📋 Planned |

---

*For detailed implementation notes, see [MASTER_INTEGRATION_ROADMAP.md](MASTER_INTEGRATION_ROADMAP.md)*
